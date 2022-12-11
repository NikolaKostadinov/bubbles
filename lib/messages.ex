defmodule Messages do

  import MessageStruct

  def uniq?(messages) do
    ids = ids(messages)
    ids != Enum.uniq(ids)
  end

  def ids(messages) do
    Enum.map(messages, fn x when is_message(x) -> x.id end)
  end

  def add_message(messages, new_message) when is_message(new_message) do
    if new_message.id in ids(messages) do
      add_message(messages, reset_id(new_message))
    else
      [ new_message | messages ]
    end
  end

end
