defmodule AuthEngine.Util do
  def check_auth_token(user_lookup, auth_token) do
    {status, user} = user_lookup

    if status === :ok do
      auth_token === user["auth_token"]
    else
      false
    end
  end

  def set_property(user_data, property, request_data) do
    unless request_data[property] === nil do
      Map.put(user_data, property, request_data[property])
    else
      user_data
    end
  end

  def get_id(user_lookup) do
    {status, user} = user_lookup
    user_data = Poison.decode!(user)

    if status === :ok do
      user_data["link"]
    else
      nil
    end
  end
end
