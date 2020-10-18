defmodule AwsIngressOperator.TargetGroups do
  @moduledoc """
  A repository pattern wrapper for a Target Group inventory
  """
  alias AwsIngressOperator.Schemas.TargetGroup
  alias AwsIngressOperator.ExAws.Elbv2

  import AwsIngressOperator.Schemas.Validations

  def list(filter \\ []) do
    tgs =
      Elbv2.TargetGroup.describe_target_groups!(filter)
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
    changeset =
      TargetGroup.changeset(target_group)
      |> validate_aws_resource_missing(:target_group_name)

    case changeset.valid? do
      false ->
        {:invalid, traverse_errors(changeset)}

      true ->
        %{target_group_arn: arn} = Elbv2.TargetGroup.create_target_group!(target_group)

        get(arn: arn)
    end
  end

  defp update(existing_target_group, target_group) do
    changeset = TargetGroup.changeset(target_group)

    case changeset.valid? do
      false ->
        {:invalid, traverse_errors(changeset)}

      true ->
        Elbv2.TargetGroup.modify_target_group!(target_group)

        get(arn: existing_target_group.target_group_arn)
    end
  end

  def delete(target_group) do
    Elbv2.TargetGroup.delete_target_group!(target_group)

    :ok
  end
end
