defmodule Client do

  use GenServer

  @doc """
    This functions starts a new session in Bubbles
    with your username and password. It returns the
    PID of the session. **Do not share it!**

    > **Example:**
    >
    > ```elixir
    > iex(1)> my_session = Client.sign_in(:me, "123456")
    > ```
  """
  def sign_in(username, password) do
    user_pid = User.pid(username)
    client = %ClientStruct{
      user_pid: user_pid,
      username: username,
      password: password,
    }
    { :ok, client_pid } = GenServer.start(__MODULE__, client)
    User.set_active(user_pid, password)
    client_pid
  end

  @doc """
    This functions creates a new user in Bubbles.
    It returns the atom `:ok`. To log in use the
    function `Client.sign_in/2`.

    > **Example:**
    >
    > ```elixir
    > iex(1)> Client.sign_up(:me, "123456")
    > :ok
    > ```
  """
  def sign_up(username, password) do
    %UserStruct{
      username: username,
      password: password
    } |> User.create()
    :ok
  end

  @doc """
    This functions sings your session off Bubbles
    It returns the atom `:ok`.

    > **Example:**
    >
    > ```elixir
    > iex(1)> Client.sign_out(my_session)
    > :ok
    > ```
  """
  def sign_out(pid) do
    client = Client.state(pid)
    user_pid = client.user_pid
    password = client.password
    User.set_inactive(user_pid, password)
    :ok
  end

  @doc """
    This function returns the state
    of your session process.
  """
  def state(pid) do
    GenServer.call(pid, :state)
  end

  def user(pid) do
    password = pid
      |> Client.state()
      |> Map.get(:password)

    pid
      |> Client.state()
      |> Map.get(:user_pid)
      |> User.state(password)
  end

  def user_pid(pid) do
    pid
      |> Client.state()
      |> Map.get(:user_pid)
  end

  def username(pid) do
    pid
      |> Client.state()
      |> Map.get(:username)
  end

  def requests(pid, usernames?) do
    result = pid
      |> Client.user()
      |> Map.get(:requests)

    if usernames? do
      Enum.map(result, &User.username/1)
    else
      result
    end
  end

  @doc """
    This function inspects the state
    of your session process.
  """
  def inspect(pid) do
    GenServer.cast(pid, :inspect)
  end

  def inspect_requests(pid) do
    pid
      |> Client.requests(true)
      |> IO.inspect()
    :ok
  end

  @doc """
    This function sends a friend request
    to a user with given username. It returns
    the atom `:ok`.

    > **Example:**
    >
    > Suppose you want to befriend the user `:bob`.
    > To send him a request simply use:
    >
    > ```elixir
    > iex(1)> Client.send_request(my_session, :bob)
    > :ok
    > ```
  """
  def send_request(pid, username) do
    client = Client.state(pid)
    user_pid = client.user_pid
    password = client.password
    User.send_request(user_pid, password, username)
  end

  def accept(pid, username) do
    requests = Client.requests(pid, true)
    if username in requests do
      GenServer.cast(pid, { :accept, username })
    else
      :request_does_not_exist
    end
  end

  def decline(pid, username) do
    requests = Client.requests(pid, true)
    if username in requests do
      GenServer.cast(pid, { :decline, username })
    else
      :request_does_not_exist
    end
  end

  @impl true
  def init(state) do
    { :ok, state }
  end

  @impl true
  def handle_call(:state, _from, state) do
    { :reply, state, state }
  end

  @impl true
  def handle_cast(:inspect, state) do
    %{
      client: state,
      user: User.state(state.user_pid)
    }
      |> IO.inspect()
    { :noreply, state }
  end

  @impl true
  def handle_cast({ :accept, username }, state) do
    user_pid = state.user_pid
    password = state.password
    request = User.pid(username)
    User.accept(user_pid, password, request)
    { :noreply, state }
  end

end
