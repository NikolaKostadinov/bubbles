defmodule MessageStruct do

  @moduledoc """
    Provides `MessageStruct` `struct` and functions associated with `MessageStruct`

    `MessageStruct` fields are:
    - `:id`: the PID of the `Message` process
    - `:from`: the PID that sent the message
    - `:to`: the PID that recieved the message
    - `:value`: the content of the message
    - `:seen`: a boolean that specifies whether the message had been seen
  """

  defstruct [
    id:           nil,
    from:         nil,
    to:           nil,
    value:         "",
    seen:       false,
  ]

  @doc """
    Guard checks if message is a valid `MessageStruct`.
  """
  defguard is_message(message)          when
    message.__struct__ === MessageStruct and
    is_pid(message.id)                   and
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

  def read(message) when is_message(message) do
    %MessageStruct{ message | seen: true }
  end

end
