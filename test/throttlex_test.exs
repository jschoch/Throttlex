Code.require_file "test_helper.exs", __DIR__

defmodule ThrottlexTest do
  use ExUnit.Case
  alias Throttlex.Server, as: T
  alias Throttlex.Super, as: S
  test "super works on crash" do
     #S.start_link 
     T.throttle(:fail)
    assert(false)
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
	tex2 = S.Tex.new(name: :foo)
	state = T.add_tex(state,tex2)
	assert(:foo == state.by_name[:foo].name)
	state = T.update_state(state,tex)
	keys = ListDict.keys(state.by_name)
	assert([:w1s,:foo] == keys)
	

  end
  test "register new throttle" do

    assert(false)
  end
  test "default throttle works" do
    #S.start_link
    assert(1000 == T.throttle)
  end
end
