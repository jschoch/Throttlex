Code.require_file "test_helper.exs", __DIR__

defmodule ThrottlexTest do
  use ExUnit.Case
  alias Throttlex.Server, as: T
  alias Throttlex.Super, as: S
  def startup do
		IO.puts "starting"
  end
  def teardown do
  	IO.puts "shutting down"
    T.stop
  end
  test "super works on crash" do
     #S.start_link
     #T.stop
     #{:error,{:shutdown,{:failed_to_start_child,_module,{status,_pid}}}} = S.start_link
     
		#assert(status == :already_started)
  end
  test "goes fast" do
		T.stop
		tex = S.Tex.new
		fast = S.Tex.new(name: :fast,timeout: 100)
		crap = [{tex.name,tex}]
		#crap = ListDict.put(crap,fast.name,fast)
    state = S.Throttles.new(by_name: crap, count: 1)
		state = T.add_tex(state,fast)
    T.start_link(state)
		res = TWork.start(:fast)
		#res2 = TWwork.start(:fast)
		:timer.sleep(1200)
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
		foo = S.Tex.new(name: :register_new_throttle,timeout: 15)
		tex = S.Tex.new
		state = S.Throttles.new(by_name: [{tex.name, tex}], count: 1)
		T.start_link(state)
		#state = T.add_tex(state,foo)
		T.add_tex(foo)
		result = T.throttle(:register_new_throttle)
		IO.puts("result: #{inspect result}")
		assert(15 == result)
	
  end
  test "default throttle works" do
    #S.start_link(1)
    tex = S.Tex.new
    state = S.Throttles.new(by_name: [{tex.name, tex}], count: 1)
    T.start_link(state)
    wait = T.throttle
    assert(1000 == wait)
  end
end
