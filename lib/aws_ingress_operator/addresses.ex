defmodule AwsIngressOperator.Addresses do
  @moduledoc """
  A repository pattern wrapper for an Elastic IP Address inventory
  """
  alias AwsIngressOperator.Schemas.Address
  alias AwsIngressOperator.ExAws.EC2

  def list(filter \\ []) do
    addresses =
      EC2.Address.describe_addresses!(filter)
      |> Enum.map(&Address.changeset/1)
      |> Enum.map(&Ecto.Changeset.apply_changes/1)

    {:ok, addresses}
  end

  def get(filter) do
    case list(filter) do
      {:ok, [address]} -> {:ok, address}
      {:ok, []} -> {:error, :resource_not_found}
    end
  end

  def create(address) do
    %{allocation_id: aid} = EC2.Address.allocate_address!(address)

    get(id: aid)
  end
end
