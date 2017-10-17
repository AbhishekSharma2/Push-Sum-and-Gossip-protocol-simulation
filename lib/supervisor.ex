defmodule Worker.Supervisor do
    use Supervisor

    def start_link do
        #IO.puts "Starting Supervisor"
        Supervisor.start_link(__MODULE__,[],name: :worker_supervisor)
        #IO.puts "Supervisor started"
    end

    def init(_) do
        children = [
            #worker(WorkerNode,[],shutdown: :infinity)
            worker(WorkerNode,[])
        ]
        supervise(children, strategy: :simple_one_for_one)
    end    

    def start_worker(args) do
        #IO.puts "Starting worker"
        Supervisor.start_child(:worker_supervisor, [args])
        #IO.puts "Worker started"
    end

    def call_gossip_worker(worker_name) do
        WorkerNode.gossip(worker_name)
    end

    def call_push_sum_worker(worker_name,s,w) do
        WorkerNode.push_sum(worker_name,s,w)
    end    

end