defmodule UserStruct do

  @moduledoc """
    Provides `UserStruct` `struct` and
    functions associated with `UserStruct`.
  """

  defstruct [
    id:          nil,
    username:    nil,
    password:    nil,
    friends:      [],
    messages:     []
  ]

  @doc """
    Guard checks if user is a valid `UserStruct`.
  """
  defguard is_user(user)              when
    user.__struct__ === UserStruct     and
    is_pid(user.id) or user.id === nil and
    is_atom(user.username)             and
    is_list(user.friends)              and
    is_list(user.messages)             and
    user.password !== nil

  @doc """
    Check if `UserStruct` is valid
  """
  def valid_user?( user) when is_user(user) do true  end
  def valid_user?(_user)                    do false end

  @doc """
    This functions is the definition of
    love and joy. It befirends the pid of
    the *second* user to the state of the *first*.
  """
  def befriend(user, pid) when is_user(user) and is_pid(pid) do
    new_friends = [ pid | user.friends ]
    %UserStruct{ user | friends: new_friends }
  end

  @doc """
    This functions is the definition of
    hate. It defirends the pid of the
    *second* user from the state of the *first*.
  """
  def defriend(user, pid) when is_user(user) and is_pid(pid) do
    new_friends = List.delete(user.friends, pid)
    %UserStruct{ user | friends: new_friends }
  end

end
