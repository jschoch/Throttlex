defmodule Throttlex.Server do
	use GenServer.Behaviour
        @timeout 5000
        require Lager
        def start_link(state) do
                :gen_server.start_link({:local,:throttlex},__MODULE__,state,[])
        end
        def throttle do
          Lager.info "Throttle: Starting at #{inspect :erlang.time}"
          :gen_server.cast :throttle, :done
          Lager.info "Throttle: ending at #{inspect :erlang.time}"
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
        def handle_call(:throttle,_from,state) do
		tex = state.by_name[:"1s"]
                tex = up_tex(tex)
		state = update_state(state,tex)
                {:reply,tex.wait,state}
        end
        def handle_cast(:done,wait) do
                wait = wait - 15000
                IO.puts "Counter is now: #{wait}"
                {:noreply,wait}
        end
        def work_it do
          lc x inlist [1,2,3,4,5,6] do
                spawn(Throttle,:throttle,[])
          end
          lc x inlist [1,2,3,4,5,6] do
                spawn(Throttle,:throttle,[])
          end
        end
        def init(state) do
		Lager.info inspect state
                {:ok, state}
        end
        def stop do
                :gen_server.call :throttle, :stop
        end


end
