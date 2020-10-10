defmodule AwsIngressOperator.TargetGroups do
  @moduledoc """
  A repository pattern wrapper for a Target Group inventory
  """
  import SweetXml

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
    [arn] = ExAws.ElasticLoadBalancingV2.create_target_group(
      target_group.target_group_name,
      target_group.vpc_id
    )
    |> ExAws.request!()
    |> Map.get(:body)
    |> SweetXml.xpath(~x"//TargetGroupArn/text()"ls)

    get(arn: arn)
  end

  defp update(existing_target_group, updated_target_group) do
    ExAws.ElasticLoadBalancingV2.modify_target_group(
      existing_target_group.target_group_arn, [
        health_check_enabled: updated_target_group.health_check_enabled,
        health_check_interval_seconds: updated_target_group.health_check_interval_seconds,
        health_check_path: updated_target_group.health_check_path,
        health_check_port: updated_target_group.health_check_port,
        health_check_protocol: updated_target_group.health_check_protocol,
        health_check_timeout_seconds: updated_target_group.health_check_timeout_seconds,
        healthy_threshold_count: updated_target_group.healthy_threshold_count,
        unhealthy_threshold_count: updated_target_group.unhealthy_threshold_count,
        matcher: updated_target_group.matcher.http_code
      ]
    )
    |> ExAws.request!()

    get(arn: existing_target_group.target_group_arn)
  end

  defp better_parser({:ok, %{body: body}}, :describe_target_groups) do
    {:ok, response} = XmlJson.AwsApi.deserialize(body)

    tgs = AtomicMap.convert(response, %{safe: false})
    |> get_in([:describe_target_groups_response, :describe_target_groups_result, :target_groups, Access.all()])

    {:ok, tgs}
  end

  defp better_parser({:error, {_type, _code, %{body: body}}}, :describe_target_groups) do
    response = XmlJson.AwsApi.deserialize!(body)

    {:error, response}
  end

  # def delete(listener) do
  #   ExAws.ElasticLoadBalancingV2.delete_listener(listener.listener_arn)
  #   |> ExAws.request!()

  #   :ok
  # end
end
