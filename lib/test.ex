defmodule Test do

  @generic_name :ivcho
  @generic_pass "123456"

  def user(username \\ @generic_name, password \\ @generic_pass) do
    %UserStruct{ username: username, password: password }
  end

  def process(username) when is_atom(username) do
    username
      |> user()
      |> process()
  end

  def process(user) do
    { :ok, process } = User.create(user)
    process
  end

end
