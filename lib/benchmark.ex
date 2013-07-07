defmodule Throttlex.Bench do
	require Benchmark
	alias Throttlex.Server, as: T
  alias Throttlex.Super, as: S
	def start do
		S.start_link
		lots_of_texes
		lots_of_processes	
	end
	def make_texes do
		texes = lc x inlist Enum.to_list 1..1000 do
			S.Tex.new(name: :"r#{:random.uniform(100000000000000)}",timeout: 15)	
		end
		texes
	end
	def put_tex(tex) do
		T.add_tex(tex)	
	end
	def lots_of_texes do
		make_texes_result = Benchmark.times 1, do: make_texes
		test_tex = S.Tex.new(name: :"r#{:random.uniform(100000000000000)}",timeout: 15)
		put_texes_result = Benchmark.times 1000, do: put_tex(test_tex)
		IO.puts "make_texes #{inspect make_texes_result}"
		IO.puts "put_texes #{inspect put_texes_result}"
	end
	def lots_of_processes do
	
	end
end