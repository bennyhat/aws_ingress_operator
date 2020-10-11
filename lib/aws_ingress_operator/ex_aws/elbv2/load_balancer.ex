defmodule AwsIngressOperator.ExAws.Elbv2.LoadBalancer do
  alias AwsIngressOperator.ExAws.FilterAliases

  import AwsIngressOperator.ExAws.Elbv2, only: [make_request: 2, make_request: 3]

  def describe_load_balancers!(filters) do
    action = :describe_load_balancers
    aliased_filters = FilterAliases.apply_aliases(action, filters)

    return_load_balancers = fn
      %{
        describe_load_balancers_response: %{
          describe_load_balancers_result: %{
            load_balancers: load_balancers
          }
        }
      } ->
        load_balancers || []
    end

    make_request(aliased_filters, action, return_load_balancers)
    |> ExAws.request!()
  end

  def create_load_balancer!(load_balancer) do
    return_load_balancer = fn
      %{
        create_load_balancer_response: %{
          create_load_balancer_result: %{
            load_balancers: [load_balancer]
          }
        }
      } ->
        load_balancer
    end

    Map.put(load_balancer, :name, load_balancer.load_balancer_name)
    |> make_request(:create_load_balancer, return_load_balancer)
    |> ExAws.request!()
  end

  def modify_load_balancer!(load_balancer) do
    make_request(load_balancer, :modify_load_balancer)
    |> ExAws.request!()
  end

  def delete_load_balancer!(load_balancer) do
    make_request(load_balancer, :delete_load_balancer)
    |> ExAws.request!()
  end
end
