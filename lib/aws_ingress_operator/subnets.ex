defmodule AwsIngressOperator.Subnets do
  @moduledoc """
  A repository pattern wrapper for a Security Group inventory
  """
  alias AwsIngressOperator.Schemas.Subnet
  alias AwsIngressOperator.ExAws.EC2

  def list(filter \\ []) do
    tgs =
      EC2.Subnet.describe_subnets!(filter)
      |> Enum.map(&Subnet.changeset/1)
      |> Enum.map(&Ecto.Changeset.apply_changes/1)

    {:ok, tgs}
  end

  def get(filter) do
    case list(filter) do
      {:ok, [sg]} -> {:ok, sg}
      {:ok, []} -> {:error, :resource_not_found}
    end
  end
end
