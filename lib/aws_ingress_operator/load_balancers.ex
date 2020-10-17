defmodule AwsIngressOperator.LoadBalancers do
  @moduledoc """
  A repository pattern wrapper for a Load Balancer inventory
  """

  alias AwsIngressOperator.Schemas.LoadBalancer
  alias AwsIngressOperator.ExAws.Elbv2

  import AwsIngressOperator.Schemas.Validations, only: [traverse_errors: 1]

  def list(filter \\ []) do
    load_balancers =
      Elbv2.LoadBalancer.describe_load_balancers!(filter)
      |> Enum.map(&LoadBalancer.changeset/1)
      |> Enum.map(&Ecto.Changeset.apply_changes/1)

    {:ok, load_balancers}
  end

  def get(filter) do
    case list(filter) do
      {:ok, [load_balancer]} -> {:ok, load_balancer}
      {:ok, []} -> {:error, :resource_not_found}
    end
  end

  def create(load_balancer) do
    changeset = LoadBalancer.changeset(load_balancer)

    case changeset.valid? do
      false ->
        {:invalid, traverse_errors(changeset)}

      true ->
        %{load_balancer_arn: arn} = Elbv2.LoadBalancer.create_load_balancer!(load_balancer)

        get(arn: arn)
    end
  end

  def delete(load_balancer) do
    Elbv2.LoadBalancer.delete_load_balancer!(load_balancer)

    :ok
  end
end
