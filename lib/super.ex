defmodule Throttlex do
	use Application.Behaviour
  def start(_type, args) do
  	IO.puts "GET READY  TO THROTTLE"
    Throttlex.Super.start_link
  end
  def stop(_state) do
    IO.puts "Shuttding down App"
  end
end


defmodule Throttlex.Super do
	use Supervisor.Behaviour
	def start_link do
		:supervisor.start_link(__MODULE__, 1)
	end
	defrecord Tex, name: :w1s, timeout: 1000, wait: 0, queue: 0
	defrecord Throttles, by_name: [], count: 0
	def init(_) do
		tex = Tex.new	
		state = Throttles.new(by_name: [{tex.name, tex}], count: 1)
		child_processes = [ worker(Throttlex.Server, [state]) ]
    case :application.get_env(:throttlex, :add_throttles) do
      {:ok,stuff} when is_list stuff ->
        IO.puts "registering throttles: #{inspect stuff}"
        throttles = Enum.map stuff, fn(opts) ->  
          t = Tex.new(opts)
          IO.puts "putting this: #{inspect t}"
          {t.name,t} 
        end 
      doh -> 
        IO.puts "problem with :application.env #{inspect doh}"
        []
    end
    throttles = [{tex.name,tex}|throttles]
    IO.puts "throttles: #{inspect throttles}"
    state = Throttles.new(by_name: throttles,count: 1)
    child_processes = [ worker(Throttlex.Server, [state]) ]
		supervise child_processes, strategy: :one_for_one
	end
end

