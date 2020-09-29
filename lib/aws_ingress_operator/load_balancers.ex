defmodule AwsIngressOperator.LoadBalancers do
  @moduledoc """
  A repository pattern wrapper for a LoadBalancer inventory
  """

  alias AwsIngressOperator.Schemas.LoadBalancer

  def list() do
    load_balancers = ExAws.ElasticLoadBalancingV2.describe_load_balancers()
    |> ExAws.request!()
    |> get_in([:body, :load_balancers])
    |> Enum.map(&LoadBalancer.changeset/1)
    |> Enum.map(&Ecto.Changeset.apply_changes/1)

    {:ok, load_balancers}
  end
end
