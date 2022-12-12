defmodule Client do

  use GenServer

  def sign_in(username, password) do
    user_pid = User.pid(username)
    if User.auth(username, password) do
      GenServer.start(__MODULE__, user_pid)
    end
  end

  def inspect(pid) do
    GenServer.cast(pid, :inspect)
  end

  def messages(pid) do
    GenServer.cast(pid, :messages)
  end

  @impl true
  def init(state) do
    { :ok, state }
  end

  @impl true
  def handle_cast(:inspect, state) do
    IO.inspect( state )
    { :noreply, state }
  end

  @impl true
  def handle_cast(:messages, state) do
    GenServer.call(state, :messages)
    { :noreply, state }
  end

end
