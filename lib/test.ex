defmodule Test do

  @generic_name :ivcho
  @generic_pass "123456"

  def user(username \\ @generic_name) when is_atom(username) do
    %UserStruct{ username: username, password: @generic_pass }
  end

  def process(username) when is_atom(username) do
    username
      |> user()
      |> process()
  end

  def process(user) do
    { :ok, process } = User.start(user)
    process
  end

end
