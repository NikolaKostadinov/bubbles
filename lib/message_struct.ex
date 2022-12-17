defmodule MessageStruct do

  @moduledoc """
    ## Description

    Provides `MessageStruct` `struct` and functions associated with `MessageStruct`

    ## Structure Fields

    `MessageStruct` fields are:
    - `:id`: the PID of the `Message` process
    - `:from`: the PID or the username of the user that sent the message
    - `:to`: the PID or the username of the user that recieved the message
    - `:value`: the content of the message
    - `:seen`: a boolean that specifies whether the message had been seen
  """

  @header_length 16

  defstruct [
    id:                        nil,
    from:                      nil,
    to:                        nil,
    value:                 <<0x0>>,
    send_at:      DateTime.utc_now,
    seen?:                   false,
  ]

  @doc """
    ## Description

    This guard checks if a message is a valid `MessageStruct`.
  """
  defguard is_message(message)                   when
    message.__struct__ === MessageStruct          and
    is_pid(message.id)   or message.id === nil    and
    is_pid(message.from) or is_atom(message.from) and
    is_pid(message.to)   or is_atom(message.from) and
    is_binary(message.value)                      and
    is_boolean(message.seen?)                     and
    message.to    !== message.from                and
    message.value !== ""

  @doc """
    ## Description

    This function sets `:seen?` field on `true`.
  """
  def read(message) when is_message(message) do
    %MessageStruct{ message | seen?: true }
  end

  @doc """
    ## Description

    Return message's header.
  """
  def header(message) when is_message(message) do

    from_username = User.username(message.from)
    to_username   = User.username(message.to)
    sliced = String.slice(message.value, 0, @header_length)

    value = unless message.value == sliced do
      sliced <> "..."
    else
      message.value
    end

    %{
      pid:             message.id,
      from:         from_username,
      to:             to_username,
      send_at:    message.send_at,
      value:                value
    }

  end

end
