defmodule Project2 do
  use GenServer

  def main(args) do
    #IO.puts "**START SEQUENCE INITIATED**"
    {:ok, pid} = GenServer.start_link(__MODULE__, args, name: :main_server)
  end  

  def init(args) do
    Scheduler.start_link(args)
    {:ok, %{"start_time"=>System.monotonic_time()}}
  end

  def handle_call(:gossip_convergance_achieved, _from, state) do
      #IO.puts "Gossip convergance Call ... Going to halt the system.."
      diff = System.monotonic_time() - state["start_time"]
      #IO.puts "Gossip converger in time: "<>diff
      #System.halt(0)
  end
  
  def handle_call({:gossip_add_inactive,worker_name}, _from, state) do
    list = state["inactive_workers"] 
    state = [worker_name | list]
    {:reply, state}
  end

  def handle_call({:gossip_check_inactive,worker_name}, _from, state) do
    flag = Enum.member?(state["inactive_workers"],worker_name)
    {:reply, flag, state}
  end
end