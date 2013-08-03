# Throttlex

gen_server to throttle arbitrary requests

## Usage ##


Default throttle (named :w1s) will allow 1 request per second

```elixir
iex -S mix 


iex(3)> alias Throttlex.Server, as: T
nil
iex(4)> alias Throttlex.Super, as: S
nil
iex(5)> T.auto_throttle
:ok

```
### register a throttle ###
```elixir

iex(8)> foo = S.Tex.new(name: :foo, timeout: 1500)
Throttlex.Super.Tex[name: :foo, timeout: 1500, wait: 0, queue: 0]
iex(9)> T.add_tex(foo)
:ok
iex(11)> T.auto_throttle(:foo)
:ok
```
** manual throttle, make sure you call done **
```elixir
this_long = T.throttle
:timer.sleep(this_long)
... do something
T.done
```

** add throttles to startup like this **

```elixir
def application do
    throttles =
      [
        [name: :w2s, timeout: 2000],
        [name: :w3s, timeout: 3000]
      ]
    [env: [add_throttles: throttles]]
  end
```
