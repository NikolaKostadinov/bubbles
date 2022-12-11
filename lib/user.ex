defmodule User do

  use    GenServer
  import UserStruct

  @doc """
    Start a `User` process with initial `UserStruct`.
  """
  def start(user) when is_user(user) do
    GenServer.start(__MODULE__, user)
  end

  @doc """
    Inspect `User` process's state.
  """
  def inspect(pid) when is_pid(pid) do
    GenServer.cast(pid, :inspect)
  end

  @doc """
    Befriend two `User` processes,
    so they can communicate.
  """
  def befriend(this_pid, other_pid) when is_pid(this_pid) and is_pid(other_pid)  do

    GenServer.cast( this_pid, { :befriend, other_pid })
    GenServer.cast(other_pid, { :befriend,  this_pid })

  end

  @impl true
  def init(user) do
    { :ok, %UserStruct{ user | id: self() } }
  end

  @impl true
  def handle_cast(:inspect, state) do
    IO.inspect( state )
    { :noreply, state }
  end

  @impl true
  def handle_cast({ :befriend, pid }, state) do
    state
    |> UserStruct.befriend(pid)
    |> Enum.uniq()
    |> (&{ :noreply, &1 }).()
  end

end
