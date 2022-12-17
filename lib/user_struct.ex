defmodule UserStruct do

  #import MessageStruct

  @moduledoc """
    ## Description

    Provides `UserStruct` `struct` and functions associated with `UserStruct`.

    ## Structure fields

    * `:id`: `User` process's PID or `nil` if process not initiated
    * `:username`: an atom which must be unique
    * `:password`: @$#!&?%
    * `:friends`: a list of friendly `User` PIDs
    * `:requests`: a list of the PIDs of the users that request a friendship
    * `:mailbox`: a list of all user's messages's PIDs
    * `:active?`: a boolean that specifies whether a client is logged as this user
  """

  defstruct [
    id:          nil,
    username:    nil,
    password:    nil,
    friends:      [],
    requests:     [],
    mailbox:      [],
    active?:   false,
  ]

  @doc """
    ## Description

    This guard checks if user is a valid `UserStruct`.
  """
  defguard is_user(user)              when
    user.__struct__ === UserStruct     and
    is_pid(user.id) or user.id === nil and
    is_atom(user.username)             and
    is_list(user.friends)              and
    is_list(user.requests)             and
    is_list(user.mailbox)              and
    is_boolean(user.active?)           and
    user.password !== nil

  @doc """
    ## Description

    Filter out private data from a `UserStruct`.

    ## Example

    ```elixir
      iex(1)> UserStruct.secure(user)
      %UserStruct{
        id: #PID<0.156.0>,
        username: :bob,
        password: :private,
        friends: [
          #PID<0.157.0>,
          #PID<0.158.0>
        ],
        requests: :private,
        mailbox: :private,
        active?: true,
      }
    ```
  """
  def secure(user) when is_user(user) do
    user
      |> (&%UserStruct{ &1 | password: :private }).()
      |> (&%UserStruct{ &1 | requests: :private }).()
      |> (&%UserStruct{ &1 | mailbox:  :private }).()
  end

  @doc """
    ## Description

    Set a `UserStruct`'s `:active?` field on `true`.
  """
  def set_active(user) when is_user(user) do
    %UserStruct{ user | active?: true }
  end

  @doc """
    ## Description

    Set a `UserStruct`'s `:active?` field on `false`.
  """
  def set_inactive(user) when is_user(user) do
    %UserStruct{ user | active?: false }
  end

  @doc """
    ## Description

    Append a new request to the `:request` list of a `UserStruct`.
  """
  def add_request(user, from_pid) when is_user(user) and is_pid(from_pid) do
    new_requests = [ from_pid | user.requests ]
    %UserStruct{ user | requests: new_requests }
  end

  @doc """
    ## Description

    Remove a request from the `:request` list of a `UserStruct`.
  """
  def remove_request(user, from_pid) when is_user(user) and is_pid(from_pid) do
    new_requests = user.requests -- [from_pid]
    %UserStruct{ user | requests: new_requests }
  end

  @doc """
    ## Description

    Befriend a `UserStruct` to a friendly `User` pid.
  """
  def befriend(user, friendly_pid) when is_user(user) and is_pid(friendly_pid) do
    new_friends = [ friendly_pid | user.friends ]
    %UserStruct{ user | friends: new_friends }
  end

  @doc """
    ## Description

    Add a `Message` process's PID to the mailbox of a `UserStruct`.
  """
  def add_message(user, message_pid) when is_user(user) and is_pid(message_pid) do
    new_mailbox = [ message_pid | user.mailbox ]
    %UserStruct{ user | mailbox: new_mailbox }
  end

end
