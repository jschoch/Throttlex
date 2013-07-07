defmodule Throttlex.Server do
	use GenServer.Behaviour
        require Lager
        def start_link(state) do
                :gen_server.start_link({:local,:throttlex},__MODULE__,state,[])
        end
        #def done do
          #Lager.info "Throttle: Starting at #{inspect :erlang.time}"
          #res = :gen_server.cast :throttlex, :done
          #Lager.info "Throttle: ending at #{inspect :erlang.time} res: #{res}"
	  #res
        #end
	def throttle do
		throttle(:w1s)
	end
	def throttle(name) do
          Lager.info "Throttle: Starting at #{inspect :erlang.time}"
          result = :gen_server.call :throttlex, {:throttle,name}
          Lager.info "sleeping for: #{result}"
          timer_result = :timer.sleep(result)
	  Lager.info "Timer Result was: #{timer_result}"
          :gen_server.cast :throttlex, {:done,name}
          Lager.info "Throttle: ending at #{inspect :erlang.time}"
	  result
        end
	
	def up_tex(tex) do
		tex.update wait: tex.wait + tex.timeout, queue: tex.queue + 1
	end
	def down_tex(tex) do
		tex.update wait: tex.wait - tex.timeout, queue: tex.queue - 1
	end
	def update_state(state,tex) do
		new_list = lc {name, e} inlist state.by_name do
			if e.name == tex.name do
				IO.puts "found #{e.name}"
				[{tex.name,tex}]
			else
				[{e.name, e}]
			end
		end
		state.by_name List.flatten(new_list)
	end
	def add_tex(state,tex) do
		state.by_name state.by_name ++ [{tex.name, tex}]
	end
	def update(state) do
		:gen_server.cast :throttlex, {:update,state}
	end
	def handle_cast({:update,new_state},state) do
		{:noreply,new_state}
	end
	
        def handle_call({:throttle,name},_from,state) do
		case state.by_name[name] do
		  nil -> 
			Lager.error "can't find throttle named: #{inspect name}"	
			Lager.error "available throttles: #{inspect ListDict.keys(state.by_name)}"
			{:reply,0,state}
		  tex -> 
                	tex = up_tex(tex)
			state = update_state(state,tex)
			Lager.info "wait? #{tex.wait}"
                	{:reply,tex.wait,state}
		end
        end
        def handle_cast({:done,name},state) do
		case state.by_name[name] do
			nil -> Lager.error "cast :done no name #{name}"
				{:noreply,state}
			tex -> 
                		tex = tex.wait tex.wait - tex.timeout
				state = update_state(state,tex)
                		IO.puts "Wait #{tex.name} is now: #{tex.wait}"
                		{:noreply,state}
			end
        end
        def work_it do
          lc x inlist [1,2,3,4,5,6] do
                spawn(Throttle,:throttlex,[])
          end
          lc x inlist [1,2,3,4,5,6] do
                spawn(Throttle,:throttlex,[])
          end
        end
        def init(state) do
		Lager.info "Starting Throttle Server"
		Lager.info inspect state
                {:ok, state}
        end
        def stop do
                :gen_server.call :throttlex, :stop
        end
	def handle_call(:stop,_from,state) do
                IO.puts "shutting down"
                {:stop,:normal,:shutdown_ok,state}
        end
end
