defmodule Client do

  use GenServer

  def sign_in(username, password) do
    if User.auth?(username, password) do
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
  end

  def sign_out(pid) do
    client = Client.state(pid)
    user_pid = client.user_pid
    password = client.password

    if User.auth?(user_pid, password) do
      User.set_inactive(user_pid, password)
      :ok
    end
  end

  def inspect(pid) do
    GenServer.cast(pid, :inspect)
  end

  def state(pid) do
    GenServer.call(pid, :state)
  end

  def send_request(pid, username) do
    client = Client.state(pid)
    user_pid = client.user_pid
    password = client.password
    User.send_request(user_pid, password, username)
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
    IO.inspect( state )
    { :noreply, state }
  end

end
