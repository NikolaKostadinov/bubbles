defmodule ClientStruct do

  @moduledoc """
    ## Description

    This module provides `ClientStruct` which
    is used for `Client` process's state. No
    additional functions provided.

    ## Structure Fields:
    * `:user_pid`: the PID of the user process
    * `:username`: the username of the user
    * `:password`: @#$%&*?
  """

  defstruct [
    user_pid: nil,
    username: nil,
    password: nil
  ]

end
