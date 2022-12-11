defmodule User do

  use        GenServer
  import    UserStruct

  @doc """
    Start a `User` process with initial `UserStruct`.
    Need more info? Try this: `h UserStruct`
  """
  def start(user) when is_user(user) do
    GenServer.start(__MODULE__, user, name: user.username)
  end

  @doc """
    Inspect `User` process's current state.
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

  @doc """
    Defriend two `User` processes.
  """
  def defriend(this_pid, other_pid) when is_pid(this_pid) and is_pid(other_pid) do

    GenServer.cast( this_pid, { :defriend, other_pid })
    GenServer.cast(other_pid, { :defriend,  this_pid })

  end

  @doc """
    Make two users communicate.
  """
  def send_message(from, to, value) when is_pid(from) and is_pid(to) do

    message = %MessageStruct{
      from:      from,
      to:          to,
      value:    value,
      seen:     false
    }

    GenServer.cast(from, { :send, message })

  end

  def state(username, password) when is_atom(username) do
    username
      |> Process.whereis()
      |> state(password)
  end

  def state(pid, password) when is_pid(pid) do

    user = GenServer.call(pid, :state)

    if password !== user.password do
      nil
    else
      user
    end

  end

  defp noreply( state ) do
    { :noreply, state }
  end

  @impl true
  def init(user) do
    { :ok, %UserStruct{ user | id: self() } }
  end

  @impl true
  def handle_call(:state, _from, state) do
    { :reply, state, state }
  end

  @impl true
  def handle_call(:messages, _from, state) do

    state.messages
      |> Enum.map(&MessageStruct.read/1)
      |> (&%UserStruct{ state | mailbox: &1 }).()
      |> (&{ :reply, &1, &1 }).()

  end

  @impl true
  def handle_cast(:inspect, state) do
    state
      |> IO.inspect()
      |> noreply()
  end

  @impl true
  def handle_cast({ :befriend, pid }, state) do
    state
      |> UserStruct.befriend(pid)
      |> UserStruct.uniq_friends()
      |> noreply()
  end

  @impl true
  def handle_cast({ :defriend, pid }, state) do
    state
      |> UserStruct.uniq_friends()
      |> UserStruct.defriend(pid)
      |> noreply()
  end

  @impl true
  def handle_cast({ :send, message }, state) do

    GenServer.cast(message.to, { :message, message })

    state
      |> UserStruct.add_message_mailbox(message)
      |> noreply()
  end

  def handle_cast({ :message, message }, state) do
    state
      |> UserStruct.add_message_mailbox(message)
      |> noreply()
  end

end
