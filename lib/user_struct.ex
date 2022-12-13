defmodule UserStruct do

  #import MessageStruct

  @moduledoc """
    Provides `UserStruct` `struct` and functions associated with `UserStruct`.

    `UserStruct`'s field are:
    * `:id`: `User` process's PID or `nil` if process not initiated
    * `:username`: an atom which must be unique
    * `:password`: @$#!&?%
    * `:friends`: a list of friendly `User` PIDs
    * `:requests`: a list of the PIDs of the users that request a friendship
    * `:mailbox`: a list of all user's messages's PIDs
    * `:active`: a boolean that specifies whether a client is logged as this user

    > **Example:**
    >
    > Here is how generate a `UserStruct` with `username` and `password` and
    > use it to start a new `User` process:
    >
    > ```elixir
    > iex(1)> user = %UserStruct{ username: username, password: password }
    > iex(2)> User.start(user)
    > ```
  """

  defstruct [
    id:          nil,
    username:    nil,
    password:    nil,
    friends:      [],
    requests:     [],
    mailbox:      [],
    active:    false,
  ]

  @doc """
    Guard checks if user is a valid `UserStruct`.
  """
  defguard is_user(user)              when
    user.__struct__ === UserStruct     and
    is_pid(user.id) or user.id === nil and
    is_atom(user.username)             and
    is_list(user.friends)              and
    is_list(user.requests)             and
    is_list(user.mailbox)              and
    is_boolean(user.active)            and
    user.password !== nil

  @doc """
    Check if `UserStruct` is valid
  """
  def valid_user?( user) when is_user(user) do true  end
  def valid_user?(_user)                    do false end

  @doc """
    Filter out private data from a `UserStruct`.
  """
  def secure(user) when is_user(user) do
    user
      |> (&%UserStruct{ &1 | password: :private }).()
      |> (&%UserStruct{ &1 | requests: :private }).()
      |> (&%UserStruct{ &1 | mailbox:  :private }).()
  end

  def set_active(user) when is_user(user) do
    %UserStruct{ user | active: true }
  end

  def set_inactive(user) when is_user(user) do
    %UserStruct{ user | active: false }
  end

  def add_request(user, from) when is_user(user) and is_pid(from) do
    new_requests = [ from | user.requests ]
    %UserStruct{ user | requests: new_requests }
  end

  def remove_request(user, pid) when is_user(user) and is_pid(pid) do
    new_requests = user.requests -- [pid]
    %UserStruct{ user | requests: new_requests }
  end

  def accept(user, pid) when is_user(user) and is_pid(pid) do
    user
    |> remove_request(pid)
    |> befriend(pid)
  end

  def befriend(user, pid) when is_user(user) and is_pid(pid) do
    new_friends = [ pid | user.friends ]
    %UserStruct{ user | friends: new_friends }
  end

  @doc """
    Filter out duplicate friends.

    > **Example:**
    >
    > Suppose `user` has friends `[#PID<0.168.0>,#PID<0.168.0>,#PID<0.169.0>]`.
    > Than `UserStruct.uniq_friends(user)` will filter one of the `#PID<0.168.0>` pids.
    >
    > ```elixir
    >   iex(1)> user = UserStruct.uniq_friends(user)
    >   iex(2)> user.friends
        [#PID<0.168.0>,#PID<0.169.0>]
    > ```
  """
  def uniq_friends(user) when is_user(user) do
    %UserStruct{ user | friends: Enum.uniq(user.friends) }
  end

end
