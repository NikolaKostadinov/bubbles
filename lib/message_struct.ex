defmodule MessageStruct do

  @moduledoc """
    Provides `MessageStruct` `struct` and
    functions associated with `MessageStruct`

  """

  defstruct [
    from:     self(),
    to:          nil,
    value:        "",
    seen:      false,
  ]

  @doc """
    Guard checks if message is a valid `MessageStruct`.
  """
  defguard is_message(message)          when
    message.__struct__ === MessageStruct and
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

end
