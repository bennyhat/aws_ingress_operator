defmodule AwsIngressOperator.LoadBalancers do
  @moduledoc """
  A repository pattern wrapper for a LoadBalancer inventory
  """

  alias AwsIngressOperator.Schemas.LoadBalancer

  @option_aliases %{
    load_balancer_arns: :load_balancer_arns,
    arns: :load_balancer_arns,
    load_balancer_names: :names,
    names: :names
  }

  def list(opts \\ []) do
    aliased_opts = Enum.map(opts, fn {k, v} ->
      {Map.get(@option_aliases, k), v}
    end)
    |> Keyword.new()

    load_balancers = ExAws.ElasticLoadBalancingV2.describe_load_balancers(aliased_opts)
    |> ExAws.request!()
    |> get_in([:body, :load_balancers])
    |> Enum.map(&LoadBalancer.changeset/1)
    |> Enum.map(&Ecto.Changeset.apply_changes/1)

    {:ok, load_balancers}
  end
end
