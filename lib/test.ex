defmodule Test do

  @generic_name :ivcho
  @generic_pass "123456"

  def user(username \\ @generic_name) do
    %UserStruct{ username: username, password: @generic_pass }
  end

  def process(user) do
    { :ok, process } = User.start(user)
    process
  end

end
