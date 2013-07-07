defmodule TWork do
	require Lager
	def go(name) do
		result = Throttlex.Server.throttle(name)	
		Lager.info "TWork.go: #{inspect self} result: #{result}"
	end
  def mon([]) do
 		Lager.info "Processes all done" 
  end	
  def mon([h|t]) do
  	thing = :erlang.monitor(:process, h)	
  	#todo: figure out how to poll the process till completion
  	Lager.info inspect thing
  	mon t
  end
	def start(name) do
		pids = lc x inlist Enum.to_list 1..10 do
			Lager.info "TWork.start: Starting spawn #{x}"
			pid = spawn(TWork,:go,[name])	
			Lager.info "TWork.start Ending spawn #{x}"
			pid
		end	
		IO.puts inspect pids
		mon(pids)	
	end
end