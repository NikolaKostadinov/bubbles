defmodule Message do

  @moduledoc """
    ## Description

    This module provides `Message` processes
    and their assosiated functions.
  """

  use        GenServer
  import MessageStruct

  @doc """
    ## Description

    Start a new `Message` process.

    ## Example

    ```elixir
      iex(1)> Message.write(pid(0, 160, 0), pid(0, 161, 0), "Hello process 161!")
      { :ok, #PID<0.172.0> }
    ```
  """
  def write(from, to, value) when is_pid(from) and is_pid(to) and is_binary(value) do
    %MessageStruct{
      from:      from,
      to:          to,
      value:    value,
      seen?:    false,
    }
      |> Message.write
  end
  def write(message) when is_message(message) do
    GenServer.start(__MODULE__, message)
  end

  @doc """
    ## Description

    Inspect the value of a `Message` process.
    If the reader of the message is the
    reciever than the `:seen?` field of the
    state will be set on `true`.

    ## Example

    ```elixir
      iex(1)> Message.read(pid(0, 172, 0), pid(0, 161, 0))
      "Hello process 161!"
      :ok
    ```
  """
  def read(message_pid, reader_pid) when is_pid(message_pid) do
    message = Message.state( message_pid)
    from?   = message.from == reader_pid
    to?     = message.to   == reader_pid
    cond do
      from? -> GenServer.cast(message_pid, :see )   # do NOT set `:seen?` on true
      to?   -> GenServer.cast(message_pid, :read)   #        set `:seen?` on true
      true  -> :permission_denied
    end
  end

  @doc """
    ## Description

    Return the state of the `Message` process.
  """
  def state(message_pid) do
    GenServer.call(message_pid, :state)
  end

  @doc """
    ## Description

    Inspect the state of the `Message` process.
  """
  def inspect(message_pid) do
    GenServer.call(message_pid, :inspect)
  end

  defp noreply( x ) do
    { :noreply, x }
  end

  @impl true
  def init(message) do
    { :ok, %MessageStruct{ message | id: self() } }
  end

  @impl true
  def handle_call(:state, _from, state) do
    { :reply, state, state }
  end

  @impl true
  def handle_cast(:inspect, state) do
    state
      |> IO.inspect
      |> noreply
  end

  @impl true
  def handle_cast(:see, state) do
    state
      |> Map.get(:value)
      |> IO.inspect
    state
      |> noreply
  end

  @impl true
  def handle_cast(:read, state) do
    state
      |> Map.get(:value)
      |> IO.inspect
    state
      |> MessageStruct.read
      |> noreply
  end

end
