defmodule User do

  use        GenServer
  import    UserStruct

  defguard is_password(password, user) when password == user.password

  defmacro state_pattern(password) do { :state, { :password, password } } end

  @doc """
    Return the PID of a `User` with given username.
  """
  def pid(username) when is_atom(username) do
    Process.whereis(username)
  end

  def auth(username, password) when is_atom(username) do
    user = state(username, password)
    is_password(password, user)
  end

  @doc """
    Return the state of a `User` with given username or PID.
    User password is required.
  """
  def state(username, password) when is_atom(username) do
    username
      |> User.pid()
      |> User.state(password)
  end

  def state(pid, password) when is_pid(pid) do
    GenServer.call(pid, state_pattern(password))
  end

  @doc """
    Inspect `User` process's current state.
    User password is required.
  """
  def inspect(user, password) do
    state(user, password) |> IO.inspect()
  end

  @doc """
    Create a `User` process with initial `UserStruct`.
    Need more info? Try this: `h UserStruct`
  """
  def create(user) when is_user(user) do
    GenServer.start(__MODULE__, user, name: user.username)    # `name: username` ensures unique usernames
  end

  @impl true
  def init(user) do
    { :ok, %UserStruct{ user | id: self() } }
  end

  @impl true
  def handle_call(state_pattern(password), _from, state) when is_password(password, state) do
    { :reply, state, state }
  end

end
