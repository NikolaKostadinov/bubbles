defmodule MessageStruct do

  @moduledoc """
    Provides `MessageStruct` `struct` and
    functions associated with `MessageStruct`

  """

  @id_range 0..1_000_000_000

  defstruct [
    id:    Enum.random(@id_range),
    from:                  self(),
    to:                       nil,
    value:                     "",
    seen:                   false,
  ]

  @doc """
    Guard checks if message is a valid `MessageStruct`.
  """
  defguard is_message(message)          when
    message.__struct__ === MessageStruct and
    is_number(message.id)                and
    is_pid(message.from)                 and
    is_pid(message.to)                   and
    is_binary(message.value)             and
    is_boolean(message.seen)             and
    message.to    !== message.from       and
    message.value !== ""

  @doc """
    Check if `MessageStruct` is valid
  """
  def valid_message?( message) when is_message(message) do true  end
  def valid_message?(_message)                          do false end

  @doc """
    Reset message's id. Sometimes ids
    could be duplicate. Reseting the id
    might help.
  """
  def reset_id(message) when is_message(message) do
    %MessageStruct{ message | id: Enum.random(@id_range) }
  end

end
