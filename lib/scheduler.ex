defmodule Scheduler do
    use GenServer

    def start_link(args) do
        IO.puts "1. Starting Scheduler Server"
        GenServer.start_link(__MODULE__, args,name: :scheduler_server)
        IO.puts "END - Scheduler Server Started"
        IO.puts "Entering Infinite Loop"
        do_work()
    end

    def converge do
        GenServer.call(:scheduler_server,:gossip_convergance_achieved,:infinity)
    end

    def converge_push_sum do
        GenServer.call(:scheduler_server,:push_sum_convergance_achieved,:infinity)
    end

    def init(args) do
        num_nodes = Enum.at(args,0)
        topology = Enum.at(args,1)
        algorithm = Enum.at(args,2)

        if String.equivalent?(topology,"2D") or String.equivalent?(topology,"imp2D") do
            rounded_n = Kernel.round :math.sqrt(String.to_integer(num_nodes))
            num_nodes = Integer.to_string(rounded_n * rounded_n)
        end
        #IO.inspect num_nodes
        #rumour = "DOS is the way to go!!"
        IO.puts num_nodes
        IO.puts topology
        IO.puts algorithm
        neighbour_list = []
        Worker.Counter.start_link([num_nodes])
        Worker.Supervisor.start_link
        if String.equivalent?(topology,"full") do
          neighbour_list = for n <- 1..String.to_integer(num_nodes), do: "worker"<>Integer.to_string(n)
          #IO.inspect neighbour_list
          for n <- 1..String.to_integer(num_nodes), do: Worker.Supervisor.start_worker(["worker" <> Integer.to_string(n), algorithm, List.delete(neighbour_list, "worker"<>Integer.to_string(n)),n])
        end
        

        if String.equivalent?(topology,"line") do
            main_list = for n <- 0..String.to_integer(num_nodes) do
                            cond do
                                n == 0 -> []    
                                n == 1 -> ["worker"<>Integer.to_string(n+1)]
                                n == String.to_integer(num_nodes) -> ["worker"<>Integer.to_string(n-1)]
                                true -> ["worker"<>Integer.to_string(n+1), "worker"<>Integer.to_string(n-1)]
                            end
                        end
            IO.inspect main_list            
            for n <- 1..String.to_integer(num_nodes), do: Worker.Supervisor.start_worker(["worker" <> Integer.to_string(n), algorithm, Enum.at(main_list, n),n])         
        end
        #argument = ["worker" <> "1", algorithm,neighbour_list]
        #pid = spawn fn -> Node.start_link(argument) end
        #Task.start fn -> Worker.Supervisor.start_worker(["worker" <> Integer.to_string(n), algorithm, neighbour_list]) end
        #start the counter server
        if String.equivalent?(topology,"2D") do
            rounded_n = Kernel.round :math.sqrt(String.to_integer(num_nodes))
            num_elem = rounded_n * rounded_n
            main_list = for i <- 0..num_elem do
                            o = []
                            if i != 0 and (rem i,rounded_n) != 1 do
                               o = ["worker"<>Integer.to_string(i-1)|o]     
                            end
                            if i != 0 and (rem i,rounded_n) > 0 do
                                o = ["worker"<>Integer.to_string(i+1)|o]     
                            end
                            if i != 0 and (i - rounded_n) > 0 do
                                o = ["worker"<>Integer.to_string(i-rounded_n)|o]     
                            end
                            if i != 0 and (i + rounded_n) <= num_elem do
                                o = ["worker"<>Integer.to_string(i+rounded_n)|o]     
                            end
                            o    
                        end
            for n <- 1..String.to_integer(num_nodes), do: Worker.Supervisor.start_worker(["worker" <> Integer.to_string(n), algorithm, Enum.at(main_list, n),n])
            #IO.inspect main_list
        end

        if String.equivalent?(topology,"imp2D") do
            rounded_n = Kernel.round :math.sqrt(String.to_integer(num_nodes))
            num_elem = rounded_n * rounded_n
            elem_list = for i <- 1..num_elem, do: i
            #IO.puts elem_list
            main_list = for i <- 0..num_elem do
                            o = []
                            v = elem_list
                            if i != 0 and (rem i,rounded_n) != 1 do
                               o = ["worker"<>Integer.to_string(i-1)|o]
                               v = List.delete(v,i-1)     
                            end
                            if i != 0 and (rem i,rounded_n) > 0 do
                                o = ["worker"<>Integer.to_string(i+1)|o] 
                                v = List.delete(v,i+1)    
                            end
                            if i != 0 and (i - rounded_n) > 0 do
                                o = ["worker"<>Integer.to_string(i-rounded_n)|o]     
                                v = List.delete(v,i-rounded_n)
                            end
                            if i != 0 and (i + rounded_n) <= num_elem do
                                o = ["worker"<>Integer.to_string(i+rounded_n)|o]
                                v = List.delete(v,i+rounded_n)    
                            end
                            o = ["worker"<>Integer.to_string(Enum.random(List.delete(v,i)))|o]
                            o    
                        end
            for n <- 1..String.to_integer(num_nodes), do: Worker.Supervisor.start_worker(["worker" <> Integer.to_string(n), algorithm, Enum.at(main_list, n),n])
            #IO.inspect main_list
        end
        
    
        if String.equivalent?(algorithm,"Gossip") or String.equivalent?(algorithm,"gossip") do
           #send rumour to worker 1 
           Worker.Supervisor.call_gossip_worker("worker1") 
        else
           Worker.Supervisor.call_push_sum_worker("worker1",1,1)  
        end
        {:ok, %{"start_time"=>System.system_time(:millisecond)}}
    end    

    def handle_call(:gossip_convergance_achieved, _from, state) do
        #IO.puts "Gossip convergance Call ... Going to halt the system.."
        #IO.puts state["start_time"]
        #IO.puts System.system_time(:millisecond) 
        diff = System.system_time(:millisecond) - state["start_time"]
        IO.puts "Push Sum convergence in time: " <> Integer.to_string(diff)
        #IO.puts diff
        System.halt(0)
    end

    def handle_call(:push_sum_convergance_achieved, _from, state) do
        #IO.puts "Push Sum convergance Call ... Going to halt the system.."
        #IO.puts state["start_time"]
        #IO.puts System.system_time(:millisecond) 
        diff = System.system_time(:millisecond) - state["start_time"]
        IO.puts "Push Sum convergence in time: " <> Integer.to_string(diff)
        #IO.puts diff
        System.halt(0)
    end

    def do_work() do
      do_work()
    end    
end    