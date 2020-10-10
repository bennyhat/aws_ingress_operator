defmodule AwsIngressOperator.TargetGroups do
  @moduledoc """
  A repository pattern wrapper for a Target Group inventory
  """
  alias AwsIngressOperator.Schemas.TargetGroup

  @option_aliases %{
    load_balancer_arn: %{
      name: :load_balancer_arn,
      list: false
    },
    arn: %{
      name: :target_group_arns,
      list: true
    },
    arns: %{
      name: :target_group_arns,
      list: true
    },
    target_group_arns: %{
      name: :target_group_arns,
      list: true
    },
    name: %{
      name: :names,
      list: true
    },
    names: %{
      name: :names,
      list: true
    },
    target_group_name: %{
      name: :names,
      list: true
    }
  }

  defp alias_options(opts) do
    Enum.map(opts, fn {k, v} ->
      case Map.get(@option_aliases, k) do
        %{name: name, list: true} -> {name, List.wrap(v)}
        %{name: name, list: false} -> {name, v}
      end
    end)
  end

  def list(opts \\ []) do
    opts = alias_options(opts)

    describe_request = ExAws.ElasticLoadBalancingV2.describe_target_groups(opts)
    |> Map.put(:parser, &better_parser/2)

    case ExAws.request(describe_request) do
        {:ok, target_groups} ->
          tgs = target_groups
          |> get_in([:describe_target_groups_response, :describe_target_groups_result, :target_groups, Access.all()])
          |> Enum.map(&TargetGroup.changeset/1)
          |> Enum.map(&Ecto.Changeset.apply_changes/1)

          {:ok, tgs}
        error -> error
    end

  end

  def get(opts \\ []) do
    case list(opts) do
      {:ok, [target_group]} -> {:ok, target_group}
      error -> error
    end
  end

  def insert_or_update(target_group) do
    case Map.get(target_group, :target_group_arn) do
      nil -> insert(target_group)
      arn ->
        case get(arn: arn) do
          {:ok, existing_tg} -> update(existing_tg, target_group)
          {:error, _} -> {:error, :resource_not_found}
        end
    end
  end

  defp insert(target_group) do
    main_params = %{
      "Action" => "CreateTargetGroup",
      "Version" => "2015-12-01"
    }
    arn = %ExAws.Operation.Query{
      action: :create_target_group,
      content_encoding: "identity",
      params: Map.merge(
        main_params,
        build_params(target_group) |> Map.put("Name", target_group.target_group_name)
      ),
      parser: &better_parser/2,
      path: "/",
      service: :elasticloadbalancing
    }
    |> ExAws.request!()
    |> get_in([:create_target_group_response, :create_target_group_result, :target_groups, Access.all()])
    |> List.first()
    |> Map.get(:target_group_arn)

    get(arn: arn)
  end

  defp update(existing_target_group, updated_target_group) do
    main_params = %{
      "Action" => "ModifyTargetGroup",
      "Version" => "2015-12-01"
    }
    %ExAws.Operation.Query{
      action: :modify_target_group,
      content_encoding: "identity",
      params: Map.merge(
        main_params,
        build_params(updated_target_group)
      ),
      parser: &ExAws.ElasticLoadBalancingV2.Parsers.parse/2,
      path: "/",
      service: :elasticloadbalancing
    }
    |> ExAws.request!()

    get(arn: existing_target_group.target_group_arn)
  end

  defp build_params(tg) do
    camel_keyed = to_camel_key(tg)

    XmlJson.AwsApi.serialize_as_params!(camel_keyed)
  end

  defp to_camel_key(%_is_struct{} = tg) do
    to_camel_key(Map.from_struct(tg))
  end

  defp to_camel_key(tg) when is_map(tg) do
    Enum.map(tg, &to_camel_key/1)
    |> Enum.reject(fn {_k, v} ->
      is_nil(v)
    end)
    |> Map.new()
  end

  defp to_camel_key(tg) when is_list(tg) do
    Enum.map(tg, &to_camel_key/1)
  end

  defp to_camel_key({k, v}) do
    camel = to_string(k)
    |> Macro.camelize()
    |> to_string()
    {camel, to_camel_key(v)}
  end

  defp to_camel_key(v) do
    v
  end

  defp better_parser({:ok, %{body: body}}, _) do
    {:ok, response} = XmlJson.AwsApi.deserialize(body)

    tgs = AtomicMap.convert(response, %{safe: false})

    {:ok, tgs}
  end

  defp better_parser({:error, {_type, _code, %{body: body}}}, _) do
    response = XmlJson.AwsApi.deserialize!(body)

    {:error, response}
  end

  defp better_parser({:error, {_type, _code, body}}, _) do
    {:error, body}
  end

  # def delete(listener) do
  #   ExAws.ElasticLoadBalancingV2.delete_listener(listener.listener_arn)
  #   |> ExAws.request!()

  #   :ok
  # end
end
