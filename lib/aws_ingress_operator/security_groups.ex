defmodule AwsIngressOperator.SecurityGroups do
  @moduledoc """
  A repository pattern wrapper for a Security Group inventory
  """
  alias AwsIngressOperator.Schemas.SecurityGroup
  alias AwsIngressOperator.ExAws.EC2

  def list(filter \\ []) do
    tgs =
      EC2.SecurityGroup.describe_security_groups!(filter)
      |> Enum.map(&SecurityGroup.changeset/1)
      |> Enum.map(&Ecto.Changeset.apply_changes/1)

    {:ok, tgs}
  end
end
