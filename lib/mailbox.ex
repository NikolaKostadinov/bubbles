defmodule Mailbox do

  import MessageStruct

  def uniq?(mailbox) do
    ids = ids(mailbox)
    ids != Enum.uniq(ids)
  end

  def ids(mailbox) do
    Enum.map(mailbox, fn x when is_message(x) -> x.id end)
  end

  def add_message(mailbox, new_message) when is_message(new_message) do
    if new_message.id in ids(mailbox) do
      add_message(mailbox, reset_id(new_message))
    else
      [ new_message | mailbox ]
    end
  end

end
