defmodule AwsIngressOperator.TargetGroups do
  @moduledoc """
  A repository pattern wrapper for a Target Group inventory
  """
  alias AwsIngressOperator.Schemas.TargetGroup
  alias AwsIngressOperator.ExAws.Elbv2

  def list(filter \\ []) do
    tgs = Elbv2.TargetGroup.describe_target_groups!(filter)
    |> Enum.map(&TargetGroup.changeset/1)
    |> Enum.map(&Ecto.Changeset.apply_changes/1)

    {:ok, tgs}
  end

  def get(filter) do
    case list(filter) do
      {:ok, [target_group]} -> {:ok, target_group}
      {:ok, []} -> {:error, :resource_not_found}
    end
  end

  def insert_or_update(%{target_group_arn: nil} = tg), do: insert(tg)

  def insert_or_update(%{target_group_arn: arn} = tg) do
    case get(arn: arn) do
      {:ok, existing_tg} -> update(existing_tg, tg)
      error -> error
    end
  end

  def insert_or_update(tg), do: insert(tg)

  defp insert(target_group) do
    %{target_group_arn: arn} = Elbv2.TargetGroup.create_target_group!(target_group)

    get(arn: arn)
  end

  defp update(existing_target_group, target_group) do
    Elbv2.TargetGroup.modify_target_group!(target_group)

    get(arn: existing_target_group.target_group_arn)
  end

  def delete(target_group) do
    Elbv2.TargetGroup.delete_target_group!(target_group)

    :ok
  end
end
