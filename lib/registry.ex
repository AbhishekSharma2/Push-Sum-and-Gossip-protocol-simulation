defmodule Worker.Registry do
    use GenServer

    def start_link do
        GenServer.start_link(__MODULE__,nil,name: :registry)
    end

    #API
    def whereis_name(worker_name) do
        GenServer.call(:registry, {:whereis_name, worker_name})
    end
    
    def register_name(worker_name, pid) do
        GenServer.call(:registry, {:register_name, worker_name, pid})
    end
    
    def unregister_name(worker_name) do
        GenServer.cast(:registry, {:unregister_name, worker_name})
    end

    def send(worker_name, message) do
        # If we try to send a message to a process
        # that is not registered, we return a tuple in the format
        # {:badarg, {process_name, error_message}}.
        # Otherwise, we just forward the message to the pid of this
        # room.
        case whereis_name(worker_name) do
          :undefined ->
            {:badarg, {worker_name, message}}
          pid ->
            Kernel.send(pid, message)
            pid
        end
    end

    # SERVER
    def init(_) do
        # We will use a simple Map to store our processes in
        # the format %{"room name" => pid}
        {:ok, Map.new}
    end
    
    def handle_call({:whereis_name, worker_name}, _from, state) do
        {:reply, Map.get(state, worker_name, :undefined), state}
    end
    
    def handle_call({:register_name, worker_name, pid}, _from, state) do
        # Registering a name is just a matter of putting it in our Map.
        # Our response tuple include a `:no` or `:yes` indicating if
        # the process was included or if it was already present.
        case Map.get(state, worker_name) do
        nil ->
            {:reply, :yes, Map.put(state, worker_name, pid)}
        _ ->
            {:reply, :no, state}
        end
    end
    
    def handle_cast({:unregister_name, worker_name}, state) do
        # And unregistering is as simple as deleting an entry
        # from our Map
        {:noreply, Map.delete(state, worker_name)}
    end
end