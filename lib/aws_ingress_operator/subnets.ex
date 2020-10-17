defmodule AwsIngressOperator.Subnets do
  @moduledoc """
  A repository pattern wrapper for a Subnet inventory
  """
  alias AwsIngressOperator.Schemas.Subnet
  alias AwsIngressOperator.ExAws.EC2

  def list(filter \\ []) do
    subnets =
      EC2.Subnet.describe_subnets!(filter)
      |> Enum.map(&Subnet.changeset/1)
      |> Enum.map(&Ecto.Changeset.apply_changes/1)

    {:ok, subnets}
  end

  def get(filter) do
    case list(filter) do
      {:ok, [subnet]} -> {:ok, subnet}
      {:ok, []} -> {:error, :resource_not_found}
    end
  end
end
