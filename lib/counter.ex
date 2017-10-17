defmodule Worker.Counter do
    use GenServer

    def start_link(args) do
        #IO.puts "2. Starting Counter Server"
        GenServer.start_link(__MODULE__, args,name: :counter_server)
        #IO.puts "End - Counter Server Started"
    end

    def init(args) do
        {:ok, %{"counter"=>0,"num_nodes"=>String.to_integer(Enum.at(args, 0)),"inactive_workers"=>[], "start_time"=>System.monotonic_time()}}
    end

    def check_inactive(worker_name) do
        flag = GenServer.call(:counter_server,{:gossip_check_inactive,worker_name},:infinity)
        flag
    end

    
    def check_inactive_push_sum(worker_name) do
        flag = GenServer.call(:counter_server,{:push_sum_check_inactive,worker_name},:infinity)
        flag
    end   
    
    def handle_call({:gossip_add_inactive,worker_name}, _from, state) do
        #IO.puts "(((((gossip_add_inactive started)))))"
        #IO.puts "Add worker to inactive list"
        list = state["inactive_workers"] 
        list = [worker_name | list]
        state = Map.put(state,"inactive_workers",list)
        #IO.puts "****Inactive list is *******"
        #IO.inspect list
        #IO.puts "Added worker to inactive list"
        {:reply,:ok, state}
      end
    
      def handle_call({:push_sum_add_inactive,worker_name}, _from, state) do
        #IO.puts "(((((gossip_add_inactive started)))))"
        #IO.puts "Add worker to inactive list"
        list = state["inactive_workers"] 
        list = [worker_name | list]
        state = Map.put(state,"inactive_workers",list)
        #IO.puts "****Inactive list is *******"
        #IO.inspect list
        #IO.puts "Added worker to inactive list"
        {:reply,:ok, state}
      end
    
    
      def handle_call({:gossip_check_inactive,worker_name}, _from, state) do
        list = state["inactive_workers"]
        
        if Enum.count(list) >= state["num_nodes"] do
            #IO.puts "Achieved convergence"
            GenServer.call(:scheduler_server,:gossip_convergance_achieved,:infinity)
        end

        flag = Enum.member?(list,worker_name)
        #IO.puts "**Check Inactive start****"
        #IO.puts worker_name
        #IO.inspect state["inactive_workers"]
        #IO.puts flag
        #IO.puts "***Check Inactive end***"
        {:reply, flag, state}
    end

    def handle_call({:push_sum_check_inactive,worker_name}, _from, state) do
        
        list = state["inactive_workers"]
        if Enum.count(list) >= state["num_nodes"] do
            #IO.puts "Achieved convergence"
            GenServer.call(:scheduler_server,{:push_sum_convergance_achieved})
        end

        flag = Enum.member?(list,worker_name)
        #IO.puts "**Check Inactive start****"
        #IO.puts worker_name
        #IO.inspect state["inactive_workers"]
        #IO.puts flag
        #IO.puts "***Check Inactive end***"
        {:reply, flag, state}
    end


    def handle_call(:gossip_convergance, _from ,state) do
        #IO.puts "Checking for gossip convergance"
        #IO.puts state["counter"]
        nodes = state["num_nodes"]
        #IO.puts "number of nodes are" <> nodes
        #IO.inspect state
        #IO.puts "******"
        #IO.inspect (state["counter"] + 1)
        #IO.inspect "hello"
        n = Enum.count(state["inactive_workers"])
        #if state["counter"]+1 >= nodes do
        if state["counter"]+1 >= 5 do
            #IO.puts "$$$$$$$$$$$$$$$$$$$Achieved Convergance$$$$$$$$$$$$$$$$$$$$$$$"
            Scheduler.converge
            #IO.puts "$$$$$$$$$$$$$$$$$$$Should not be here$$$$$$$$$$$$$$$$$$$$$$$"
        end
        #IO.puts "Increased the count by 1"
        state = Map.put(state,"counter",state["counter"]+1)
        #IO.inspect state["counter"]
        #IO.puts "Gossip convergance call ends"
        {:reply, :ok, state}
    end


    def handle_call(:push_sum_convergance, _from ,state) do
        #IO.puts "Checking for gossip convergance"
        #IO.puts state["counter"]
        nodes = state["num_nodes"]
        #IO.puts "number of nodes are" <> nodes
        #IO.inspect state
        #IO.puts "******"
        #IO.inspect (state["counter"] + 1)
        #IO.inspect "hello"
        n = Enum.count(state["inactive_workers"])
        #if state["counter"]+1 >= nodes do
        if state["counter"]+1 >= 3 do
            #IO.puts "$$$$$$$$$$$$$$$$$$$Achieved Convergance$$$$$$$$$$$$$$$$$$$$$$$"
            Scheduler.converge_push_sum
            #IO.puts "$$$$$$$$$$$$$$$$$$$Should not be here$$$$$$$$$$$$$$$$$$$$$$$"
        end
        #IO.puts "Increased the count by 1"
        state = Map.put(state,"counter",state["counter"]+1)
        #IO.inspect state["counter"]
        #IO.puts "Gossip convergance call ends"
        {:reply, :ok, state}
    end


end    