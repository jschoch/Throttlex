# Throttlex

gen_server to throttle arbitrary requests

## Usage ##


Default throttle (named :w1s) will allow 1 request per second

```
iex(3)> alias Throttlex.Server, as: T
nil
iex(4)> alias Throttlex.Super, as: S
nil
iex(5)> S.start_link
18:37:03.069 [info] Starting Throttle Server
18:37:03.082 [info] Throttlex.Super.Throttles[by_name: [w1s: Throttlex.Super.Tex[name: :w1s, timeout: 1000, wait: 0, queue: 0]], count: 1]
{:ok,#PID<0.106.0>}
iex(6)> T.throttle
18:37:13.585 [info] Throttle: Starting at {18,37,13}
18:37:13.585 [info] sleeping for: 1000
1000
iex(7)> 18:37:14.586 [info] Throttle: ending at {18,37,14}

```
### register a throttle ###
```

iex(8)> foo = S.Tex.new(name: :foo, timeout: 1500)
Throttlex.Super.Tex[name: :foo, timeout: 1500, wait: 0, queue: 0]
iex(9)> T.add_tex(foo)
:ok
iex(11)> T.throttle(:foo)
18:40:56.416 [info] Throttle: Starting at {18,40,56}
18:40:56.416 [info] sleeping for: 1500
1500
iex(12)> 18:40:57.917 [info] Throttle: ending at {18,40,57}
```
** TODO: add more tests **
