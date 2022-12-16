defmodule Message do

  use        GenServer
  import MessageStruct

  @moduledoc """

  """

  def write(from, to, value) do
    %MessageStruct{
      from:      from,
      to:          to,
      value:    value,
      seen?:    false,
    }
      |> write()
  end

  def write(message) when is_message(message) do
    GenServer.start(__MODULE__, message)
  end

  def read(message_pid, user_pid) when is_pid(message_pid) do
    message = Message.state(message_pid)
    from?   = message.from == user_pid
    to?     = message.to   == user_pid
    cond do
      from? -> GenServer.cast(message_pid, :see )
      to?   -> GenServer.cast(message_pid, :read)
      true  -> :permission_denied
    end
  end

  def inspect(message_pid) do
    GenServer.call(message_pid, :inspect)
  end

  def state(message_pid) do
    GenServer.call(message_pid, :state)
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
