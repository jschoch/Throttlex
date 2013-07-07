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
      :timer.sleep(result)
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
	def get_tex_count do
		:gen_server.call :throttlex, :get_tex_count	
	end
	def handle_call(:get_tex_count,_from,state) do
		res = Enum.count state.by_name	
		{:reply,res,state}
	end
	def add_tex(tex) do
		:gen_server.cast :throttlex, {:add_tex, tex	}
	end
	def handle_cast({:add_tex,tex},state) do
		state = add_tex(state,tex)
		{:noreply, state}	
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
				Lager.debug "wait? #{tex.wait}"
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
        {:noreply,state}
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
                IO.puts "Throttlex.Server.stop: shutting down"
                {:stop,:normal,:shutdown_ok,state}
        end
end
