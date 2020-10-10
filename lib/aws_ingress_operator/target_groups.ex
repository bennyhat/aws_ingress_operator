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

    describe_request = AwsIngressOperator.ExAws.Elbv2.describe_target_groups(opts)
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
    %{target_group_arn: arn} = AwsIngressOperator.ExAws.Elbv2.create_target_group(target_group)
    |> ExAws.request!()

    get(arn: arn)
  end

  defp update(existing_target_group, target_group) do
    AwsIngressOperator.ExAws.Elbv2.modify_target_group(target_group)
    |> ExAws.request!()

    get(arn: existing_target_group.target_group_arn)
  end

  # def delete(listener) do
  #   ExAws.ElasticLoadBalancingV2.delete_listener(listener.listener_arn)
  #   |> ExAws.request!()

  #   :ok
  # end
end
