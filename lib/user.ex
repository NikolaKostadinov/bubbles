defmodule User do

  use    GenServer
  import UserStruct

  @doc """
    Start a `User` process with initial `UserStruct`.
  """
  def start(user) when is_user(user) do
    GenServer.start(__MODULE__, user, name: __MODULE__)
  end

  @doc """
    Inspect `User` process's state.
  """
  def inspect(pid) when is_pid(pid) do
    GenServer.cast(pid, :inspect)
  end

  @impl true
  def init(user) do
    { :ok, %UserStruct{ user | id: self() } }
  end

  @impl true
  def handle_cast(:inspect, state) do
    IO.inspect(state)
    { :noreply, state }
  end

end
