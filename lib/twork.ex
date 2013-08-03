defmodule TWork do
	require Lager
	def go(name,pid) do
    result = Throttlex.Server.throttle(name)  
    :timer.sleep(result)
    Throttlex.Server.done(name)
		pid <- {:ok, result}
		Lager.info "TWork.go: #{inspect self} slept: #{result}"
		exit(:normal)
		#:timer.sleep(100)
	end
  def do_work(name) do
 		pids = lc x inlist Enum.to_list 1..10 do
			Lager.info "TWork.start: Starting spawn #{x}"
			pid = spawn(TWork,:go,[name,self])	
			Lager.info "TWork.start Ending spawn #{x}"
			pid
		end
		list = get_msgs(pids,[])
		Lager.info "LIST: #{inspect list}"
		list
  end
  def get_msgs([],list) do
		list
	end
  def get_msgs(pids,list) do
		receive do
			{:ok, value} when is_number(value) -> 
				Lager.info "get_msgs got #{inspect value}"	
				get_msgs(pids,[value|list])
			{:EXIT,pid,status} -> get_msgs(Enum.filter(pids,&1 != pid),list) 
			doh -> 
				IO.puts "Poof #{inspect doh}"
				[]
		after 200 -> IO.puts "out of luck"
			list
		end
	end
	def start(name) do
		start_time = :erlang.now
		{time, list} = :timer.tc(__MODULE__,:do_work,[name])
		end_time = :erlang.now
		Lager.info "Time: #{inspect time}"
		list
	end
end
