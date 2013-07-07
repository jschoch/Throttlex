Code.require_file "test_helper.exs", __DIR__

defmodule ThrottlexTest do
  use ExUnit.Case
  alias Throttlex.Server, as: T
  alias Throttlex.Super, as: S
  def startup do

  end
  def teardown do
    T.stop
  end
  def work_it do
    lc x inlist [1,2,3,4,5,6] do
      spawn(Throttlex.Server,:throttle,[:fast])
    end
    lc x inlist [1,2,3,4,5,6] do
      spawn(Throttlex.Server,:throttle,[:fast])
    end
  end
  test "super works on crash" do
     #S.start_link(1)
     #T.throttle(:fail)
    assert(false)
  end
  test "goes fast" do
	T.stop
	tex = S.Tex.new
	fast = S.Tex.new(name: :fast,timeout: 1000)
	crap = [{tex.name,tex}]
	#crap = ListDict.put(crap,fast.name,fast)
        state = S.Throttles.new(by_name: crap, count: 1)
	state = T.add_tex(state,fast)
        T.start_link(state)
	work_it
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
	foo = S.Tex.new(name: :foo,timeout: 15)
	tex = S.Tex.new
    	state = S.Throttles.new(by_name: [{tex.name, tex}], count: 1)
	T.start_link(state)
	state = T.add_tex(state,foo)
	T.update(state)
	result = T.throttle(:foo)
	IO.puts("result: #{inspect result}")
	assert(15 == result)
	
  end
  test "default throttle works" do
    #S.start_link(1)
    tex = S.Tex.new
    state = S.Throttles.new(by_name: [{tex.name, tex}], count: 1)
    T.start_link(state)
    wait = T.throttle
    IO.puts "FUCKYOU: #{wait}"
    assert(1000 == wait)
  end
end
