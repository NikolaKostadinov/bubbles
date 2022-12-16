defmodule User do

  use        GenServer
  import    UserStruct

  defguard is_password(password, user) when password == user.password

  defmacro pattern(command, password) do { command, { :pasword, password } } end
  defmacro pattern(command, options, password) do { { command, options }, { :pasword, password } } end

  @doc """
    Return the PID of a `User` with given username.
  """
  def pid(username) when is_atom(username) do
    Process.whereis(username)
  end

  @doc """

  """
  def auth?(username, password) do
    user = state(username, password)
    is_password(password, user)
  end

  @doc """
    Return the state of a `User` with given username or PID.
    User password is required.
  """
  def state(username, password) when is_atom(username) do
    username
      |> User.pid
      |> User.state(password)
  end
  def state(pid, password) when is_pid(pid) do
    GenServer.call(pid, pattern(:state, password))
  end

  @doc """
    Return the public fields of the state of a `User` with given username or PID.
  """
  def state(username) when is_atom(username) do
    username
      |> User.pid
      |> User.state
  end
  def state(pid) when is_pid(pid) do
    GenServer.call(pid, :state)
  end

  def username(pid) do
    pid
      |> User.state
      |> Map.get(:username)
  end

  def friends?(user1_pid, user1_password, user2_pid) do
    user2_pid in (
      user1_pid
        |> User.state(user1_password)
        |> Map.get(:friends)
    )
  end

  @doc """
    Inspect `User` process's current state.
    **User password is required.**
  """
  def inspect(user, password) do
    user
      |> state(password)
      |> IO.inspect
    :ok
  end

  @doc """
    Create a `User` process with initial `UserStruct`.
    Need more info? Try this: `h UserStruct`
  """
  def create(user) when is_user(user) do
    GenServer.start(__MODULE__, user, name: user.username)    # `name: username` ensures unique usernames
  end

  @doc """
    Set a `User` process on `active: true`.
  """
  def set_active(username, password) when is_atom(username) do
    username
      |> User.pid
      |> User.set_active(password)
  end

  def set_active(pid, password) when is_pid(pid) do
    GenServer.cast(pid, pattern(:activate, password))
  end

  @doc """
    Set a `User` process on `active: false`.
  """
  def set_inactive(username, password) when is_atom(username) do
    username
      |> User.pid
      |> User.set_active(password)
  end

  def set_inactive(pid, password) when is_pid(pid) do
    GenServer.cast(pid, pattern(:deactivate, password))
  end

  @doc """
    Send a friend request to a given user.
  """
  def send_request(from, password, to_username) when is_pid(from) and is_atom(to_username) do
    if auth?(from, password) do
      to_username
        |> User.pid
        |> GenServer.cast({ :request, { :pid, from } })
    else
      :invalid_password
    end
  end

  def accept(pid, password, request) do
    GenServer.cast(pid, pattern(:accept, request, password))
    GenServer.cast(request, { :befriend, pid })
  end

  def decline(pid, password, request) do
    GenServer.cast(pid, pattern(:decline, request, password))
  end

  def send_message(from, from_password, to_username, text_message) when is_pid(from) and is_atom(to_username) do
    if User.auth?(from, from_password) do
      to = User.pid(to_username)
      if User.friends?(from, from_password, to) do
        { :ok, message_pid } = Message.write(from, to, text_message)
        GenServer.cast(to  , { :add_message, message_pid })
        GenServer.cast(from, { :add_message, message_pid })
        message_pid
      else
        :not_friends
      end
    else
      :invalid_password
    end
  end

  defp noreply( x ) do
    { :noreply, x }
  end

  @impl true
  def init(user) do
    { :ok, %UserStruct{ user | id: self() } }
  end

  @impl true
  def handle_call(pattern(:state, password), _from, state) when is_password(password, state) do
    { :reply, state, state }
  end

  @impl true
  def handle_call(:state, _from, state) do
    { :reply, UserStruct.secure(state), state }
  end

  @impl true
  def handle_cast(pattern(:activate, password), state) when is_password(password, state) do
    state
      |> UserStruct.set_active
      |> noreply
  end

  @impl true
  def handle_cast(pattern(:deactivate, password), state) when is_password(password, state) do
    state
      |> UserStruct.set_inactive
      |> noreply
  end

  @impl true
  def handle_cast({ :request, { :pid, from } }, state) do
    state
      |> UserStruct.add_request(from)
      |> noreply
  end

  @impl true
  def handle_cast(pattern(:accept, request, password), state) when is_password(password, state) do
    state
      |> UserStruct.accept(request)
      |> noreply
  end

  @impl true
  def handle_cast(pattern(:decline, request, password), state) when is_password(password, state) do
    state
      |> UserStruct.remove_request(request)
      |> noreply
  end

  @impl true
  def handle_cast({ :befriend, pid }, state) do
    state
      |> UserStruct.befriend(pid)
      |> noreply
  end

  @impl true
  def handle_cast({ :add_message, message_pid }, state) do
    state
      |> UserStruct.add_message(message_pid)
      |> noreply
  end

end
