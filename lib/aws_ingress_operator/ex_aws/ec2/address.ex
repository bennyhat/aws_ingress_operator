defmodule AwsIngressOperator.ExAws.EC2.Address do
  @moduledoc false

  alias AwsIngressOperator.ExAws.FilterAliases
  import AwsIngressOperator.ExAws.EC2, only: [make_request: 3]

  def describe_addresses!(filters) do
    return_addresses = fn
    %{
      describe_addresses_response: %{
        addresses_set: addresses
      }
    } ->
        addresses || []
    end

    action = :describe_addresses
    aliased_filters = FilterAliases.apply_aliases(action, filters)

    case make_request(aliased_filters, action, return_addresses) |> ExAws.request() do
      {:ok, addresses} -> addresses
      {:error, _} -> []
    end
  end

  def allocate_address!(address) do
    return_address = fn
    %{
      allocate_address_response: address
    } ->
        address
    end

    make_request(address, :allocate_address, return_address)
    |> ExAws.request!()
  end
end
