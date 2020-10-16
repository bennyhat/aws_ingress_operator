defmodule AwsIngressOperator.ExAws.EC2.SecurityGroup do
  @moduledoc false

  alias AwsIngressOperator.ExAws.FilterAliases
  import AwsIngressOperator.ExAws.EC2, only: [make_request: 3]

  def describe_security_groups!(filters) do
    return_security_groups = fn
      %{
        describe_security_groups_response: %{
          security_group_info: security_groups
        }
      } ->
        security_groups || []
    end

    action = :describe_security_groups
    aliased_filters = FilterAliases.apply_aliases(action, filters)

    case make_request(aliased_filters, action, return_security_groups) |> ExAws.request() do
      {:ok, sgs} -> sgs
      _ -> []
    end
  end
end
