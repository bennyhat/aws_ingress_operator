defmodule AwsIngressOperator.LoadBalancers do
  @moduledoc """
  A repository pattern wrapper for a LoadBalancer inventory
  """

  alias AwsIngressOperator.Schemas.LoadBalancer

  @option_aliases %{
    load_balancer_arns: :load_balancer_arns,
    load_balancer_arn: :load_balancer_arns,
    arns: :load_balancer_arns,
    arn: :load_balancer_arns,
    load_balancer_names: :names,
    load_balancer_name: :names,
    name: :names,
    names: :names
  }

  def list(opts \\ []) do
    aliased_opts =
      Enum.map(opts, fn {k, v} ->
        {Map.get(@option_aliases, k), List.wrap(v)}
      end)
      |> Keyword.new()

    load_balancers =
      ExAws.ElasticLoadBalancingV2.describe_load_balancers(aliased_opts)
      |> ExAws.request!()
      |> get_in([:body, :load_balancers])
      |> Enum.map(&LoadBalancer.changeset/1)
      |> Enum.map(&Ecto.Changeset.apply_changes/1)

    {:ok, load_balancers}
  end

  def get(opts \\ []) do
    {:ok, [load_balancer]} = list(opts)

    {:ok, load_balancer}
  end

  def create(opts \\ []) do
    {name_kw, rest} = Keyword.split(opts, [:name])

    name = name_kw[:name]

    ExAws.ElasticLoadBalancingV2.create_load_balancer(name, rest)
    |> ExAws.request!()

    get(name: name)
  end

  def delete(opts \\ []) do
    aliased_opts =
      Enum.map(opts, fn {k, v} ->
        {Map.get(@option_aliases, k), List.wrap(v)}
      end)
      |> Keyword.new()

    [arn] = Keyword.fetch!(aliased_opts, :load_balancer_arns)

    ExAws.ElasticLoadBalancingV2.delete_load_balancer(arn)
    |> ExAws.request!()

    :ok
  end
end
