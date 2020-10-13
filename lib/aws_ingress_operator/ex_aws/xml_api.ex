defmodule AwsIngressOperator.ExAws.XmlApi do
  def build_params(tg) do
    camel_keyed = to_camel_key(tg)

    XmlJson.AwsApi.serialize_as_params!(camel_keyed)
  end

  def parser({:ok, %{body: body}}, _, unpacker, list_element_names \\ ["member"]) do
    {:ok, response} = XmlJson.AwsApi.deserialize(body, list_element_names: list_element_names)

    converted =
      AtomicMap.convert(response, %{safe: false})
      |> unpacker.()

    {:ok, converted}
  end

  def parser({:error, {_type, _code, %{body: body}}}, _action, _unpacker, _lens) do
    response = XmlJson.AwsApi.deserialize!(body)

    {:error, response}
  end

  def parser({:error, {_type, _code, body}}, _action, _unpacker, _lens) do
    {:error, body}
  end

  def to_camel(value) do
    to_string(value)
    |> Macro.camelize()
    |> to_string()
  end

  defp to_camel_key([]), do: %{}

  defp to_camel_key([{_k, _v} | _] = kwlist) do
    to_camel_key(Map.new(kwlist))
  end

  defp to_camel_key(%_is_struct{} = value) do
    to_camel_key(Map.from_struct(value))
  end

  defp to_camel_key(value) when is_map(value) do
    Enum.map(value, &to_camel_key/1)
    |> Enum.reject(fn {_k, v} ->
      is_nil(v)
    end)
    |> Map.new()
  end

  defp to_camel_key(value) when is_list(value) do
    Enum.map(value, &to_camel_key/1)
  end

  defp to_camel_key({k, v}) do
    {to_camel(k), to_camel_key(v)}
  end

  defp to_camel_key(value), do: value

end
