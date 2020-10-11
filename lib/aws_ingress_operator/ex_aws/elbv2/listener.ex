defmodule AwsIngressOperator.ExAws.Elbv2.Listener do
  alias AwsIngressOperator.ExAws.FilterAliases

  import AwsIngressOperator.ExAws.Elbv2, only: [make_request: 2, make_request: 3]

  def describe_listeners(filters) do
    action = :describe_listeners
    aliased_filters = FilterAliases.apply_aliases(action, filters)

    return_listeners = fn
      %{
        describe_listeners_response: %{
          describe_listeners_result: %{
            listeners: listeners
          }
        }
      } ->
        listeners || []

      # moto is broken
      %{
        describe_load_balancers_response: %{
          describe_listeners_result: %{
            listeners: listeners
          }
        }
      } ->
        listeners || []
    end

    make_request(aliased_filters, action, return_listeners)
    |> ExAws.request()
  end

  def create_listener!(listener) do
    return_listener = fn
      %{
        create_listener_response: %{
          create_listener_result: %{
            listeners: [listener]
          }
        }
      } ->
        listener
    end

    make_request(listener, :create_listener, return_listener)
    |> ExAws.request!()
  end

  def modify_listener!(listener) do
    make_request(listener, :modify_listener)
    |> ExAws.request!()
  end

  def delete_listener!(listener) do
    make_request(listener, :delete_listener)
    |> ExAws.request!()
  end
end
