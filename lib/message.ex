defmodule Message do

  use        GenServer
  import MessageStruct

  @moduledoc """

  """

  def write(from, to, value) do
    %MessageStruct{
      from:   from,
      to:       to,
      value: value
    } |> write()
  end

  def write(message) when is_message(message) do
    GenServer.start(__MODULE__, message)
  end

  def read(message_pid, user_pid) when is_pid(message_pid) do
    message = Message.state(message_pid)
    from?   = message.from == user_pid
    to?     = message.to   == user_pid
    if from? or to? do
      GenServer.cast(message_pid, { :read, to? })
    end
  end

  def state(message_pid) do
    GenServer.call(message_pid, :state)
  end

  def header(message_pid) do
    message_pid
      |> Message.state()
      |> MessageStruct.header()
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
    IO.inspect(state)
    { :noreply, MessageStruct.read(state) }
  end

  @impl true
  def handle_cast({ :read, see? }, state) do
    read_message = fn x ->
      if see? do MessageStruct.read(x)
      else x end
    end
    state
      |> read_message.()
      |> Map.get(:value)
      |> IO.inspect()
    { :noreply, state }
  end

end
