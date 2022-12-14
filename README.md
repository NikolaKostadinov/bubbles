<p align="center">
    <img src="./assets/logo_real.png" style="height: 200px" />
</p>

# Bubbles

Bubbles is my Elixir project as an intern. It is a backend messaging app based entirely on Elixir processes. The idea is that users, messages and clients are process which between each other.

## Log In - Log Out

To sign up in Bubbles use `Client.sign_up/2`. The first argument is your username which must be an atom. The second one is your password. It must be a string. This function starts a `User` process.

Let's create a user with username `:bubble` and password `"123456"` (shhhh). We will use `Client.sign_up/2`:

```elixir
iex(1)> Client.sign_up(:bubble, "123456")
:ok
```

We have successfuly started a `User` process with name `:bubble`. To sign in as `:bubble` we will use `Client.sign_in/2`. This function will return the PID of your session process so we will save it in a new variable.


```elixir
iex(2)> me = Client.sign_in(:bubble, "123456")
#PID<0.150.0>
```

**Do not share the PID of your session!**

Now let's inspect the state of our session. To to this we will use the function `Client.inspect/1`. The argument is our session PID.

```elixir
iex(3)> Client.inspect(me)
%{
  client: %ClientStruct{
    user_pid: #PID<0.150.0>,
    username: :bubble,
    password: :private
  },
  user: %UserStruct{
    id: #PID<0.150.0>,
    username: :bubble,
    password: :private,
    friends: [],
    requests: :private,
    mailbox: :private,
    active?: true
  }
}
:ok
```

As you see we get two structures: `:client` and `:user`. `:client` is the state of our session process. `:user` is the state of our user process. We can see that `:bubble` is now active because of `active?: true` in `UserStruct`. 

## Friends

Let's see how we can make some new friend. We will create a new user wirh username `:hubble`. Then we will log in as `:hubble`. We will save the new session in a new variable. Here is the code: 


```elixir
iex(4)> Client.sign_up(:hubble, "123456")
:ok
iex(5)> you = Client.sign_in(:hubble, "123456")
#PID<0.160.0>
```

To befriend `:hubble` we will send him a request. We will use `Client.send_request/2`. The first argument of this function is our session PID. The second is the user that we want to befriend.

```elixir
iex(6)> me |> Client.send_request(:hubble)
:ok
```

`:bubble` should have sent a request to `:hubble`. Let's verify this. We will inspect all `:hubble`'s requests with `Client.inspect_requests/1`. This functions takes one argument: the PID of the session. It inspects the list of requests. Here the result:

```elixir
iex(7)> you |> Client.inspect_requests
[:bubble]
:ok
```

As you see `:bubble`'s requests is in `:hubble`'s mailbox. Let's accept the friend request: 

```elixir
iex(8)> you |> Client.accept(:bubble)
:ok
```

`Client.accept/2` is a function that accepts a user's friend request. To decline a request you can use `Client.decline/2`. Let's check if `:bubble` and `:hubble` are friends. We will inspect their friend list with `Client.inspect_friends/2`:

```elixir
iex(9)> me |> Client.inspect_friends
[:hubble]
:ok
iex(10)> you |> Client.inspect_friends
[:bubble]
:ok
```

This friendship is now official. `:bubble` and `:hubble` are now able to send messages to each other.

## "Hello World"

To send a message we will use `Client.send_message/3`. The first argument of this function is the session PID. The second is the reciver's username which must me in the friend list and the third argument is the content of the message. It must be a binary. The function returns the PID of the message's process. Here is how `:bubble` could send `"Hello World!"` to `hubble`:

```elixir
iex(11)> me |> Client.send_message(:hubble, "Hello World!")
#PID<0.172.0>
```

Let's see what is is `:hubble`'s mailbox:

```elixir
iex(12) you |> Client.inspect_mailbox
[
  %{
    pid: #PID<0.172.0>,
    from: :bubble,
    to: :hubble,
    send_at: ~U[2023-01-19 22:37:01.393000Z],
    value: "Hello World!"
  }
]
```

`Client.inspect_mailbox/1` inspects all unread messages, but is doesn't read them. The `:value` field shows only the first 16 characters of the message content. To read the message we will get the message's pid from the result and we will use it as the second argument for `Client.read_message`:

```elixir
iex(13)> message = pid(0, 172, 0)
#PID<0.172.0>
iex(14)> you |> Client.read_message(message)
"Hello World!"
:ok
```

If `:hubble` inspects his mailbox he will see an empty array because `:hubble` had already read the message.

```elixir
iex(15) you |> Client.inspect_mailbox
[]
:ok
```

## Other Functions

* `Client.inspect_mailbox_from/2`: this function inspects unread messages from a given user
* `Client.inspect_number_of_unread/1`: this function inspects the total ammount of unread messages
* `Client.inspect_chat_with/2`: this functions inspects all messages between you and a given user chronologically
* `Client.active?/2`: this function returns the `:active?` field