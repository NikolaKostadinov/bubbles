defmodule User do

  @moduledoc """
    ## Description

    This module provides `User` processes
    and their assosiated functions.
  """

  use        GenServer
  import    UserStruct

  @doc """
    ## Description

    This guard checks whether a user has typed the correct password.
  """
  defguard is_password(password, user) when password == user.password

  defmacrop pattern(command, password) do { command, { :pasword, password } } end
  defmacrop pattern(command, options, password) do { { command, options }, { :pasword, password } } end

  @doc """
    ## Description

    Return the PID of a `User` process with a given username.
  """
  def pid(username) when is_atom(username) do
    Process.whereis(username)
  end

  @doc """
    ## Description

    Check whether a user has typed the correct password.
  """
  def auth?(user, password) when is_pid(user) or is_atom(user) do
    password == user
      |> User.state(password)
      |> Map.get(:password)
  end

  @doc """
    ## Description

    Return the state of a `User` process
    which is a `UserStruct`. User password
    is **required**.
  """
  def state(username, password) when is_atom(username) do
    username
      |> User.pid
      |> User.state(password)
  end
  def state(user_pid, password) when is_pid(user_pid) do
    GenServer.call(user_pid, pattern(:state, password))
  end

  @doc """
    ## Description

    Return the **secured** state of a `User`
    process which is a `UserStruct`.
  """
  def state(username) when is_atom(username) do
    username
      |> User.pid
      |> User.state
  end
  def state(user_pid) when is_pid(user_pid) do
    GenServer.call(user_pid, :state)
  end

  @doc """
    ## Description

    Return the username of `User` process.
  """
  def username(user_pid) when is_pid(user_pid) do
    user_pid
      |> User.state
      |> Map.get(:username)
  end

  @doc """
    ## Description

    Check if two `User` processes are friends.
  """
  def friends?(user1_pid, user2_pid) when is_pid(user1_pid) and is_pid(user2_pid) do
    user2_pid in (
      user1_pid
        |> User.state
        |> Map.get(:friends)
    )
  end

  @doc """
    ## Description

    Inspect `User` process's current state.
    First argument could be a username or a
    `User` PID. User password is **required**.
  """
  def inspect(user, password) when is_pid(user) or is_atom(user) do
    user
      |> User.state(password)
      |> IO.inspect
    :ok
  end

  @doc """
    ## Description

    Create a `User` process with an initial `UserStruct`.
  """
  def create(user) when is_user(user) do
    GenServer.start(__MODULE__, user, name: user.username)    # `name: username` ensures unique usernames
  end

  @doc """
    ## Description

    Set a `User` process on `active: true`.
  """
  def set_active(username, password) when is_atom(username) do
    username
      |> User.pid
      |> User.set_active(password)
  end
  def set_active(user_pid, password) when is_pid(user_pid) do
    GenServer.cast(user_pid, pattern(:activate, password))
  end

  @doc """
    ## Description

    Set a `User` process on `active: false`.
  """
  def set_inactive(username, password) when is_atom(username) do
    username
      |> User.pid
      |> User.set_active(password)
  end
  def set_inactive(user_pid, password) when is_pid(user_pid) do
    GenServer.cast(user_pid, pattern(:deactivate, password))
  end

  @doc """
    ## Description

    Send a friend request to a given user.
  """
  def send_request(from_pid, password, to_username) when is_pid(from_pid) and is_atom(to_username) do
    if auth?(from_pid, password) do
      to_username
        |> User.pid
        |> GenServer.cast({ :request, { :pid, from_pid } })
    else
      :invalid_password
    end
  end

  @doc """
    ## Description

    Accept request from a given user.
  """
  def accept(user_pid, password, from_pid) do
    GenServer.cast(user_pid, pattern(:accept, from_pid, password))
    GenServer.cast(from_pid, { :befriend, user_pid })
  end

  @doc """
    ## Description

    Decline request from a given user.
  """
  def decline(user_pid, password, from_pid) do
    GenServer.cast(user_pid, pattern(:decline, from_pid, password))
  end

  @doc """
    ## Description

    Send a message to a given user.
  """
  def send_message(from, from_password, to_username, text_message) when is_pid(from) and is_atom(to_username) do
    if User.auth?(from, from_password) do
      to = User.pid(to_username)
      if User.friends?(from, to) do
        { :ok, message_pid } = Message.write(from, to, text_message)
        GenServer.cast(to  , { :add_message, message_pid })
        GenServer.cast(from, { :add_message, message_pid })
        message_pid
      else
        :not_friends
      end
    else
      :invalid_password
    end
  end

  defp noreply( x ) do
    { :noreply, x }
  end

  @impl true
  def init(user) do
    { :ok, %UserStruct{ user | id: self() } }
  end

  @impl true
  def handle_call(pattern(:state, password), _from, state) when is_password(password, state) do
    { :reply, state, state }
  end

  @impl true
  def handle_call(:state, _from, state) do
    { :reply, UserStruct.secure(state), state }
  end

  @impl true
  def handle_cast(pattern(:activate, password), state) when is_password(password, state) do
    state
      |> UserStruct.set_active
      |> noreply
  end

  @impl true
  def handle_cast(pattern(:deactivate, password), state) when is_password(password, state) do
    state
      |> UserStruct.set_inactive
      |> noreply
  end

  @impl true
  def handle_cast({ :request, { :pid, from } }, state) do
    state
      |> UserStruct.add_request(from)
      |> noreply
  end

  @impl true
  def handle_cast(pattern(:accept, request, password), state) when is_password(password, state) do
    state
      |> UserStruct.remove_request(request)
      |> UserStruct.befriend(request)
      |> noreply
  end

  @impl true
  def handle_cast(pattern(:decline, request, password), state) when is_password(password, state) do
    state
      |> UserStruct.remove_request(request)
      |> noreply
  end

  @impl true
  def handle_cast({ :befriend, pid }, state) do
    state
      |> UserStruct.befriend(pid)
      |> noreply
  end

  @impl true
  def handle_cast({ :add_message, message_pid }, state) do
    state
      |> UserStruct.add_message(message_pid)
      |> noreply
  end

end
