Code.require_file "test_helper.exs", __DIR__

defmodule ThrottlexTest do
  use ExUnit.Case
  alias Throttlex.Server, as: T
  alias Throttlex.Super, as: S
  alias Throttlex, as: A
  setup_all do
	  IO.puts "starting"
	  :ok
  end
  teardown_all do
  	IO.puts "shutting down"
    :application.stop(:throttlex)
	:ok
  end
  test "goes fast" do
		fast = S.Tex.new(name: :fast,timeout: 100)
		state = T.add_tex(fast)
		res = TWork.start(:fast)
		count = Enum.count(res)
		sum = Enum.reduce(res,0,fn(i,acc) -> i + acc end)
		assert(count == 10)
		assert(sum == 5500)
  end
  test "record tests" do
		tex = S.Tex.new
		state = S.Throttles.new(by_name: [{tex.name, tex}])
		assert(tex.name == :w1s)
		tex = T.up_tex(tex)
		assert(tex.wait == 1000)
		tex = T.down_tex(tex)
		assert(tex.wait == 0)
		tst = state.by_name[:w1s]	
		assert(tex == tst)
		tex2 = S.Tex.new(name: :foo, timeout: 1500)
		state = T.add_tex(state,tex2)
		assert(:foo == state.by_name[:foo].name)
		state = T.update_state(state,tex)
		keys = ListDict.keys(state.by_name)
		assert([:w1s,:foo] == keys)
  end
  test "register new throttle" do
		foo = S.Tex.new(name: :register_new_throttle,timeout: 55)
		T.add_tex(foo)
		result = T.throttle(:register_new_throttle)
		{time,val} = :timer.tc(fn -> T.throttle(:register_new_throttle) end)
		IO.puts("result: #{inspect result}")
		assert(result == 55)
  end
  test "default throttle works" do
    tex = S.Tex.new
    wait = T.throttle
    assert(1000 == wait)
  end
end
