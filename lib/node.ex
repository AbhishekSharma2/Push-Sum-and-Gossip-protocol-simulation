defmodule WorkerNode do
    use GenServer

    def start_link(args) do
        #IO.inspect args
        serverName = Enum.at(args,0)
        GenServer.start_link(__MODULE__, args,name: via_tuple(serverName))
    end
    
    def init(args) do
        {:ok, %{"counter"=>0,"neighbour_list"=>Enum.at(args,2),"name"=>Enum.at(args,0),"s"=>Enum.at(args,3),"w"=>1},:infinity}
    end
    #Client API
    def gossip(worker_name) do
        IO.inspect "Calling gossip for " <> worker_name
        GenServer.cast(via_tuple(worker_name),{:gossip})
    end

    def push_sum(worker_name,s,w) do
        #IO.inspect "Calling push_sum for " <> worker_name
        GenServer.cast(via_tuple(worker_name),{:push_sum,s,w})
    end
    
    #Server Callbacks
    def handle_cast({:gossip}, state) do
    #def handle_call({:gossip}, _from,state) do
        IO.puts "Got a message"
        IO.puts "Inside handle cast for gossip"
        #IO.inspect state
        #:timer.sleep(4000)
        count = state["counter"]
        count = count + 1
        state = Map.put(state,"counter",count)
        #send message to a random process
        #random_worker = Enum.random(state["neighbour_list"])    
        IO.puts "&&Randomization logic begins&&"
        var = true
        random_worker = ""
        random_worker =  check(var,state,random_worker)
        IO.puts "Random worker is" <> random_worker
        IO.puts "&&Randomization logic ends&&"
        if count >= 10 do
            #signal stop
            IO.puts "calling GenServer.cast(:counter_server, :gossip_convergance)    "
            if random_worker == "" do
                IO.puts "Random Worker is null"
                GenServer.call(:counter_server, :gossip_convergance)
                GenServer.call(:counter_server,{:gossip_add_inactive,state["name"]},:infinity)
            else
                Worker.Supervisor.call_gossip_worker(random_worker) 
                GenServer.call(:counter_server, :gossip_convergance)    
                #:sys.suspend(via_tuple(state["name"]),:infinity)
                #IO.puts "badi tatti"
                #IO.puts random_worker
                GenServer.call(:counter_server,{:gossip_add_inactive,state["name"]},:infinity)
                #IO.puts "sabse badi tatti"     
            end 
        else
            Worker.Supervisor.call_gossip_worker(random_worker) 
        end
        {:noreply, state}
    end

    defp via_tuple(worker_name) do
        {:via, :gproc, {:n, :l, {:worker, worker_name}}}
    end

    def check(var,state,random_worker) when var == true do
        IO.puts "Selection Random Worker begins"
        #IO.inspect state
        #IO.puts state["neighbour_list"]
        #IO.puts "papap"
        #IO.puts Enum.count(state["neighbour_list"]) 
        if Enum.count(state["neighbour_list"]) > 0 do
            random_worker = Enum.random(state["neighbour_list"])  
            IO.puts "random worker is "<>random_worker

            status = Worker.Counter.check_inactive(random_worker)
            IO.puts"@@@@@@@@Check Method Node@@@@@@@@@@@@@@@"
            IO.inspect status
            if(status == true) do
              IO.puts "suspended"
              IO.puts "trying to delete " <> random_worker
              
              #IO.puts  state["neighbour_list"]
              l = List.delete(state["neighbour_list"], random_worker)
              state = Map.put(state,"neighbour_list",l)
              IO.puts "After deletion list is: "
              #IO.inspect l
              check(var,state,random_worker)
            else
              var = false
              IO.puts"@@@@@@@@Check Method Node End@@@@@@@@@@@@@@@"
              check(var,state,random_worker)   
            end
            else
              IO.puts "Neighbour list is empty"
              var = false
              check(var,state,random_worker)
        end    
    end

    def check(var,state,random_worker) when var == false do
    IO.puts "False check here"
    random_worker
    end

    #push sum server api
    def handle_cast({:push_sum,s,w}, state) do
            #IO.puts "Inside handle cast for push sum"
            #IO.inspect state
            #IO.puts "Incoming s and w are"
            #IO.inspect s
            #IO.inspect w
            count = state["counter"]
            s_old = state["s"] 
            w_old = state["w"]
            s_new = state["s"] + s
            w_new = state["w"] + w
            ratio_diff = Kernel.abs((s_new / w_new) - (s_old / w_old))
            #IO.puts "&&Randomization logic begins&&"
            var = true
            random_worker = ""
            random_worker =  check_push_sum(var,state,random_worker)
            #IO.puts "Random worker is" <> random_worker
            #IO.puts "&&Randomization logic ends&&"
            if (ratio_diff < 0.0000000001) do
                count = count + 1
                if count >=3 do
                    if random_worker != "" do
                        Worker.Supervisor.call_push_sum_worker(random_worker,s_new/2,w_new/2)      
                    end
                    GenServer.call(:counter_server,{:push_sum_add_inactive,state["name"]},:infinity)
                    GenServer.call(:counter_server, :push_sum_convergance)
                    #add to inactive
                    #convergance check   
                else
                    Worker.Supervisor.call_push_sum_worker(random_worker,s_new/2,w_new/2)                                      
                end
                state = Map.put(state, "counter", count)    
            else
                state = Map.put(state, "counter", 0)
                Worker.Supervisor.call_push_sum_worker(random_worker,s_new/2,w_new/2)                                      
            end
            state = Map.put(state, "s", s_new)    
            state = Map.put(state, "w", w_new)
            {:noreply, state}
        end
        
        def check_push_sum(var,state,random_worker) when var == true do
            IO.puts "Selection Random Worker begins"
            #IO.inspect state
            IO.puts state["neighbour_list"]
            #IO.puts "papap"
            IO.puts Enum.count(state["neighbour_list"]) 
            if Enum.count(state["neighbour_list"]) > 0 do
                random_worker = Enum.random(state["neighbour_list"])  
                IO.puts "random worker is "<>random_worker
                #{status, Pid, {module, Module}, [SItem]} = :sys.get_status(via_tuple(random_worker))
                #status = GenServer.call(:main_server,{:gossip_check_inactive,random_worker},:infinity)
                #IO.puts 
                status = Worker.Counter.check_inactive_push_sum(random_worker)
                IO.puts"@@@@@@@@Check Method Node@@@@@@@@@@@@@@@"
                IO.inspect status
                if(status == true) do
                  IO.puts "suspended"
                  IO.puts "trying to delete " <> random_worker
                  #IO.puts  state["neighbour_list"]
                  l = List.delete(state["neighbour_list"], random_worker)
                  state = Map.put(state,"neighbour_list",l)
                  #IO.puts "After deletion list is: "
                  #IO.inspect l
                  check_push_sum(var,state,random_worker)
                else
                  var = false
                  IO.puts"@@@@@@@@Check Method Node End@@@@@@@@@@@@@@@"
                  check_push_sum(var,state,random_worker)   
                end
                else
                  IO.puts "Neighbour list is empty"
                  var = false
                  check_push_sum(var,state,random_worker)
            end    
        end

        def check_push_sum(var,state,random_worker) when var == false do
            #IO.puts "False check here"
            random_worker
        end
end    
