defmodule Message do

  use        GenServer
  import MessageStruct

  @moduledoc """

  """

  def start(from, to, value) do
    message = %MessageStruct{ from: from, to: to, value: value }
    start(message)
  end

  def start(message) when is_message(message) do
    GenServer.start(__MODULE__, message)
  end

  @impl true
  def init(state) do
    { :ok, state }
  end

end
