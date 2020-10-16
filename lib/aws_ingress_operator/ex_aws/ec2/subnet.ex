defmodule AwsIngressOperator.ExAws.EC2.Subnet do
  @moduledoc false

  alias AwsIngressOperator.ExAws.FilterAliases
  import AwsIngressOperator.ExAws.EC2, only: [make_request: 3]

  def describe_subnets!(filters) do
    return_subnets = fn
      %{
        describe_subnets_response: %{
          subnet_set: subnets
        }
      } ->
        subnets || []
    end

    action = :describe_subnets
    aliased_filters = FilterAliases.apply_aliases(action, filters)

    case make_request(aliased_filters, action, return_subnets) |> ExAws.request() do
      {:ok, subnets} -> subnets
      {:error, _} -> []
    end
  end
end
