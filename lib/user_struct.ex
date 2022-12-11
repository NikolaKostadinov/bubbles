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
    is_list(user.friends)              and
    is_list(user.messages)             and
    user.username !== nil              and
    user.password !== nil

  @doc """
    Guard checks if **two** users are valid.
    This is used to save some space in code.
  """
  defguard are_users(this_user, other_user) when
    is_user(this_user) and is_user(other_user)

  @doc """
    Check if `UserStruct` is valid
  """
  def valid_user?( user) when is_user(user) do true  end
  def valid_user?(_user)                    do false end

  @doc """
    This functions is the definition of
    love and joy. It befirends the *second*
    user to the *first*.
  """
  def befriend(this_user, other_user) when are_users(this_user, other_user) do
    new_friends = [ other_user.id | this_user.friends ]
    %UserStruct{ this_user | friends: new_friends }
  end

  @doc """
    This functions is the definition of
    hate. It defirends the *second*
    user from the *first*.
  """
  def defriend(this_user, other_user) when are_users(this_user, other_user) do
    new_friends = List.delete(this_user.friends, other_user.id)
    %UserStruct{ this_user | friends: new_friends }
  end

end
