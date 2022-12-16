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

  @header_length 16

  defstruct [
    id:                        nil,
    from:                      nil,
    to:                        nil,
    value:                      "",
    send_at:      DateTime.utc_now,
    seen?:                   false,
  ]

  @doc """
    Guard checks if message is a valid `MessageStruct`.
  """
  defguard is_message(message)              when
    message.__struct__ === MessageStruct     and
    is_pid(message.id) or message.id === nil and
    is_pid(message.from)                     and
    is_pid(message.to)                       and
    is_binary(message.value)                 and
    is_boolean(message.seen?)                and
    message.to    !== message.from           and
    message.value !== ""

  @doc """
    Check if `MessageStruct` is valid
  """
  def valid_message?( message) when is_message(message) do true  end
  def valid_message?(_message)                          do false end

  def read(message) when is_message(message) do
    %MessageStruct{ message | seen?: true }
  end

  def header(message) when is_message(message) do

    from   = User.username(message.from)
    to     = User.username(message.to)
    sliced = String.slice( message.value, 0, @header_length)

    value = unless message.value == sliced do
      sliced <> "..."
    else
      message.value
    end

    %{
      pid:             message.id,
      from:                  from,
      to:                      to,
      send_at:    message.send_at,
      value:                value
    }

  end

end
