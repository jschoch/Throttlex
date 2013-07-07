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
		supervise child_processes, strategy: :one_for_one
	end
end

