defmodule Client do

  @moduledoc """
    # Bubbles API

    ## Description

    The `Client` module is Bubbles' API.
    This module provides all the necessary
    functions for Bubbles' users like:
    * `Client.sign_up/2`
    * `Client.sign_in/2`
    * `Client.sign_out/1`
    * `Client.inspect/1`
    * `Client.inspect_requests/1`
    * `Client.inspect_friends/1`
    * `Client.send_request/2`
    * `Client.accept/2`
    * `Client.decline/2`
    * `Client.send_message/3`
    * `Client.read_message/2`
    * `Client.inspect_mailbox/1`
    * `Client.inspect_mailbox_from/2`
    * `Client.inspect_number_of_unread/1`
    * `Client.inspect_chat_with/2`

    ## Example

    Here is a simple example how to sign up,
    befriend a user and send a message:

    ```elixir
      ...
      iex(3)> Client.sign_up(:me, "123456")
      :ok
      iex(4)> me = Client.sign_in(:me, "123456")
      #PID<0.160.0>
      iex(5)> me |> Client.send_request(:you)
      :ok
      iex(6)> you |> Client.accept(:me)
      :ok
      iex(7)> me |> Client.send_message(:you, "Hello there!")
      #PID<0.168.0>
      iex(8)> you |> Client.read_message(pid(0, 168, 0))
      "Hello there!"
      :ok
    ```
  """

  use GenServer

  @doc """
    ## Description

    This functions starts a new session in Bubbles
    with your username and password. It returns the
    PID of the session. **Do not share it!**

    ## Example

    ```elixir
      iex(1)> me = Client.sign_in(:me, "123456")
      #PID<0.160.0>
    ```
  """
  def sign_in(username, password) when is_atom(username) do
    user_pid = User.pid(username)
    client = %ClientStruct{
      user_pid: user_pid,
      username: username,
      password: password,
    }
    { :ok, client_pid } = GenServer.start(__MODULE__, client)
    User.set_active(user_pid, password)
    client_pid
  end

  @doc """
    ## Description

    This functions creates a new user in Bubbles.
    It returns the atom `:ok`. To log in use the
    function `Client.sign_in/2`.

    ## Example

    ```elixir
      iex(1)> Client.sign_up(:me, "123456")
      :ok
    ```
  """
  def sign_up(username, password) when is_atom(username) do
    User.create(%UserStruct{
      username: username,
      password: password
    })
    :ok
  end

  @doc """
    ## Description

    This functions sings your session
    off Bubbles. It returns the atom `:ok`.

    ## Example

    ```elixir
      iex(1)> me |> Client.sign_out
      :ok
    ```
  """
  def sign_out(client_pid) when is_pid(client_pid) do
    client = Client.state(client_pid)
    user_pid = client.user_pid
    password = client.password
    User.set_inactive(user_pid, password)
    :ok
  end

  @doc """
    ## Description

    This function returns the state
    of your session process wich is
    a `ClientStruct`.
  """
  def state(client_pid) when is_pid(client_pid) do
    GenServer.call(client_pid, :state)
  end

  @doc """
    ## Description

    This function returns the
    sessions's `User` process's
    state wich is a `UserStruct`.
  """
  def user(client_pid) when is_pid(client_pid) do
    password = client_pid
      |> Client.state()
      |> Map.get(:password)
    client_pid
      |> Client.state()
      |> Map.get(:user_pid)
      |> User.state(password)
  end

  @doc """
    ## Description

    This function returns the list of your friend
    requests. The second argument `usernames?` is
    a boolean which specifies wheter the elements
    of the list are usernames or user PIDs. By
    default `usernames?` is set `true`.

    ## Example

    ```elixir
      iex(1)> requests = me |> Client.friends(false)
      [#PID<0.161.0>, #PID<0.162.0>, #PID<0.163.0>]
      iex(2)> requests = me |> Client.friends(true)
      [:random1,:random2,:random3]
    ```
  """
  def requests(client_pid, usernames? \\ true) when is_pid(client_pid) and is_boolean(usernames?) do
    requests = client_pid
      |> Client.user()
      |> Map.get(:requests)

    if usernames? do
      Enum.map(requests, &User.username/1)
    else
      requests
    end
  end

  @doc """
    ## Description

    This function returns the list of your friends.
    The second argument `usernames?` is a boolean
    which specifies wheter the elements of the list
    are usernames or user PIDs. By default
    `usernames?` is set `true`.

    ## Example

    ```elixir
      iex(1)> friends = me |> Client.friends(false)
      [#PID<0.161.0>, #PID<0.162.0>, #PID<0.163.0>]
      iex(2)> friends = me |> Client.friends(true)
      [:friend1,:friend2,:friend3]
    ```
  """
  def friends(client_pid, usernames? \\ true) when is_pid(client_pid) and is_boolean(usernames?) do
    friends = client_pid
      |> Client.user()
      |> Map.get(:friends)
    if usernames? do
      Enum.map(friends, &User.username/1)
    else
      friends
    end
  end

  @doc """
    ## Description

    This function inspects the state
    of your session process.

    ## Example

    ```elixir
    iex(1)> Client.inspect(me)
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
          active: true
        }
      }
      :ok
    ```
  """
  def inspect(client_pid) when is_pid(client_pid) do
    GenServer.cast(client_pid, :inspect)
  end

  @doc """
    ## Description

    This function inspects the list
    of your friendly requests.

    ## Example

    Suppose `:bubble` and `:hubble` had send you
    friend requests. To verify wheter it is true you
    can call this function on your session PID:

    ```elixir
      iex(1)> me |> Client.inspect_requests
      [:bubble, :hubble]
      :ok
    ```
  """
  def inspect_requests(client_pid) when is_pid(client_pid) do
    client_pid
      |> Client.requests(true)
      |> IO.inspect()
    :ok
  end

  @doc """
    ## Description

    This function inspects the
    list of your friends.

    ## Example

    ```elixir
      iex(1)> me |> Client.inspect_friends
      [:friend1,:friend2,:friend3]
      :ok
    ```
  """
  def inspect_friends(client_pid) when is_pid(client_pid) do
    client_pid
      |> Client.friends(true)
      |> IO.inspect()
    :ok
  end

  @doc """
    ## Description

    This function sends a friend request
    to a user with given username. It returns
    the atom `:ok`.

    ## Example

    Suppose you want to befriend the user `:bob`.
    To send him a request simply use:

    ```elixir
      iex(1)> Client.send_request(my_session, :bob)
      :ok
    ```
  """
  def send_request(client_pid, to_username) when is_pid(client_pid) and is_atom(to_username) do
    client = Client.state(client_pid)
    user_pid = client.user_pid
    password = client.password
    User.send_request(user_pid, password, to_username)
  end

  @doc """
    ## Description

    Accept a user's friend request.

    ## Example

    Suppose `:bubble` had send you a friend request.
    To accept it simply use:

    ```elixir
      iex(1)> me |> Client.decline(:bubble)
      :ok
    ```
  """
  def accept(client_pid, from_username) when is_pid(client_pid) and is_atom(from_username) do
    requests = Client.requests(client_pid, true)
    if from_username in requests do
      client = Client.state(client_pid)
      user_pid = client.user_pid
      password = client.password
      request = User.pid(from_username)
      User.accept(user_pid, password, request)
    else
      :request_does_not_exist
    end
  end

  @doc """
    ## Description

    Decline a user's friend request.

    ## Example

    Suppose `:bubble` had send you a friend request.
    To decline it simply use:

    ```elixir
      iex(1)> me |> Client.decline(:bubble)
      :ok
    ```
  """
  def decline(client_pid, from_username) when is_pid(client_pid) and is_atom(from_username) do
    requests = Client.requests(client_pid, true)
    if from_username in requests do
      client = Client.state(client_pid)
      user_pid = client.user_pid
      password = client.password
      request = User.pid(from_username)
      User.decline(user_pid, password, request)
    else
      :request_does_not_exist
    end
  end

  @doc """
    ## Description

    Send a message to a **friendly** user.
    The message must be a binary.
    The function returns the message's PID.

    ## Example

    ```elixir
      iex(1)> greeting = me |> Client.send_message(:my_friend, "Hello there!")
      #PID<0.172.0>
    ```
  """
  def send_message(client_pid, to_username, text_message) when is_pid(client_pid) and is_atom(to_username) and is_binary(text_message) do
    client = Client.state(client_pid)
    user_pid = client.user_pid
    password = client.password
    User.send_message(user_pid, password, to_username, text_message)
  end

  @doc """
    ## Description

    Read a message from a friend.
    This function sets the `:seen` field on
    `true` if the reader is the reciever.
    Message PID is required.

    ## Example

    Suppose you want to read a message with PID of `#PID<0.172.0>`.
    To read the constent of the message:

    ```elixir
      iex> me |> Client.read_message(pid(0, 172, 0))
      "Hello there!"
      :ok
    ```
  """
  def read_message(client_pid, message_pid) when is_pid(client_pid) and is_pid(message_pid) do
    client = Client.state(client_pid)
    user_pid = client.user_pid
    Message.read(message_pid, user_pid)
  end

  @doc """
    ## Description

    This function returns the headers
    of all user's messages. This function
    does not alter the `:seen` fields.

    ## Example

    ```elixir
      iex> headers = me |> Client.message_headers
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
  """
  def message_headers(client_pid) when is_pid(client_pid) do
    username = client_pid
      |> Client.state
      |> Map.get(:username)
    client_pid
      |> Client.user
      |> Map.get(:mailbox)
      |> Enum.map(&Message.state/1)
      |> Enum.filter(&(!Map.get(&1, :seen?)))
      |> Enum.map(&MessageStruct.header/1)
      |> Enum.filter(&(&1.to == username))
  end

  @doc """
    ## Description

    This function inspects the headers
    of a user's mailbox. This function
    does not alter the `:seen` fields.

    ## Example

    ```elixir
      iex> me |> Client.inspect_mailbox
      [
        %{
          pid: #PID<0.172.0>,
          from: :bubble,
          to: :hubble,
          send_at: ~U[2023-01-19 22:37:01.393000Z],
          value: "Hello World!"
        }
      ]
      :ok
    ```
  """
  def inspect_mailbox(client_pid) when is_pid(client_pid) do
    client_pid
      |> Client.message_headers
      |> IO.inspect
    :ok
  end

  @doc """
    ## Description

    Inspect all messages headers
    from an arbitrary user.
  """
  def inspect_mailbox_from(client_pid, username) when is_pid(client_pid) and is_atom(username) do
    client_pid
      |> Client.message_headers
      |> Enum.filter(&(&1.from == username))
      |> IO.inspect
    :ok
  end

  @doc """
    ## Description

    Inspect the number of all
    unread by you messages.
  """
  def inspect_number_of_unread(client_pid) when is_pid(client_pid) do
    client_pid
    |> Client.message_headers
    |> Enum.count
    |> IO.inspect
    :ok
  end

  @doc """
    ## Description

    Inspect the list of all
    your messages with a given user.

    ## Example

    ```elixir
      iex(1)> me |> Client.inspect_chat_with(:hubble)
      [
        %MessageStruct{
          id: #PID<0.198.0>,
          from: :bubble,
          to: :hubble,
          value: "Hello!",
          send_at: ~U[2022-12-16 15:05:12.393000Z],
          seen?: false
        },
        %MessageStruct{
          id: #PID<0.196.0>,
          from: :hubble,
          to: :bubble,
          value: "Hello there!",
          send_at: ~U[2022-12-16 15:05:06.393000Z],
          seen?: true
        }
      ]
      :ok
    ```
  """
  def inspect_chat_with(client_pid, username) when is_pid(client_pid) and is_atom(username) do
    friend = User.pid(username)
    client_pid
      |> Client.user
      |> Map.get(:mailbox)
      |> Enum.map(&Message.state/1)
      |> Enum.filter(&(
        &1.from == friend or
        &1.to   == friend
      ))
      |> Enum.sort_by(
        fn msg -> {
          msg.send_at.year  ,
          msg.send_at.month ,
          msg.send_at.day   ,
          msg.send_at.hour  ,
          msg.send_at.minute,
          msg.send_at.second
        } end
      )
      |> IO.inspect
    :ok
  end

  @impl true
  def init(state) do
    { :ok, state }
  end

  @impl true
  def handle_call(:state, _from, state) do
    { :reply, state, state }
  end

  @impl true
  def handle_cast(:inspect, state) do
    secured_state = %ClientStruct{ state | password: :private }
    %{
      client: secured_state,
      user:   User.state(state.user_pid)
    }
      |> IO.inspect
    { :noreply, state }
  end

end
