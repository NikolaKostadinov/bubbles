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

  def read(message_pid) when is_pid(message_pid) do
    GenServer.cast(message_pid, :inspect)
  end

  @impl true
  def init(message) do
    { :ok,  %MessageStruct{ message | id: self() } }
  end

  @impl true
  def handle_cast(:inspect, state) do
    IO.inspect( state )
    { :noreply, state }
  end

end
