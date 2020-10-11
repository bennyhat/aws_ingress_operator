defmodule AwsIngressOperator.ExAws.Elbv2 do
  alias AwsIngressOperator.ExAws.FilterAliases

  def describe_target_groups(filters) do
    action = :describe_target_groups
    aliased_filters = FilterAliases.apply_aliases(action, filters)

    return_target_groups = fn
    %{
      describe_target_groups_response: %{
        describe_target_groups_result: %{
          target_groups: tgs
        }
      }
    } ->
        tgs || []
    end

    make_request(aliased_filters, action, return_target_groups)
    |> ExAws.request()
  end

  def create_target_group!(tg) do
    return_target_group = fn response ->
      [tg] = get_in(response, [:create_target_group_response, :create_target_group_result, :target_groups, Access.all()])
      tg
    end

    Map.put(tg, :name, tg.target_group_name)
    |> make_request(:create_target_group, return_target_group)
    |> ExAws.request!()
  end

  def modify_target_group!(tg) do
    make_request(tg, :modify_target_group)
    |> ExAws.request!()
  end

  defp make_request(model, action, unpacker \\ &(&1)) do
    main_params = %{
      "Action" => to_camel(action),
      "Version" => "2015-12-01"
    }
    %ExAws.Operation.Query{
      action: action,
      content_encoding: "identity",
      params: Map.merge(main_params, build_params(model)),
      parser: &parser(&1, &2, unpacker),
      path: "/",
      service: :elasticloadbalancing
    }
  end

  defp build_params(tg) do
    camel_keyed = to_camel_key(tg)

    XmlJson.AwsApi.serialize_as_params!(camel_keyed)
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
  defp to_camel(value) do
    to_string(value)
    |> Macro.camelize()
    |> to_string()
  end

  defp parser({:ok, %{body: body}}, _, unpacker) do
    {:ok, response} = XmlJson.AwsApi.deserialize(body)

    converted = AtomicMap.convert(response, %{safe: false})
    |> unpacker.()

    {:ok, converted}
  end
  defp parser({:error, {_type, _code, %{body: body}}}, _action, _unpacker) do
    response = XmlJson.AwsApi.deserialize!(body)

    {:error, response}
  end
  defp parser({:error, {_type, _code, body}}, _action, _unpacker) do
    {:error, body}
  end
end