<p align="center">
    <img src="./assets/logo_real.png" style="height: 200px" />
</p>

# Bubbles

Bubbles is my Elixir project as an intern.

```elixir
iex(1)> Client.sign_up(:bubble, "123456")
:ok
```

```elixir
iex(2)> me = Client.sign_in(:bubble, "123456")
#PID<0.150.0>
```

```elixir
iex(3)> Client.inspect(me)
%{
  client: %ClientStruct{
    user_pid: #PID<0.150.0>,
    username: :bubble,
    password: "123456"
  },
  user: %UserStruct{
    id: #PID<0.150.0>,
    username: :bubble,
    password: :private,
    friends: [],
    requests: :private,
    mailbox: :private,
    active: true
  }
}
:ok
```

```elixir
iex(4)> Client.sign_up(:hubble, "123456")
:ok
iex(5)> you = Client.sign_in(:hubble, "123456")
#PID<0.160.0>
```

```elixir
iex(6)> me |> Client.send_request(:hubble)
:ok
```

```elixir
iex(7)> you |> Client.inspect_requests()
[:bubble]
:ok
```

```elixir
iex(8)> you |> Client.accept(:bubble)
[:bubble]
:ok
```