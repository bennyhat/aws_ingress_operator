defmodule AwsIngressOperator.ExAws.FilterAliases do
  @moduledoc """
  Aliases for filters used in list APIs
  """

  @aliases %{
    describe_target_groups: %{
      load_balancer_arn: %{
        name: :load_balancer_arn,
        list: false
      },
      arn: %{
        name: :target_group_arns,
        list: true
      },
      arns: %{
        name: :target_group_arns,
        list: true
      },
      target_group_arns: %{
        name: :target_group_arns,
        list: true
      },
      target_group_arn: %{
        name: :target_group_arns,
        list: true
      },
      name: %{
        name: :names,
        list: true
      },
      names: %{
        name: :names,
        list: true
      },
      target_group_name: %{
        name: :names,
        list: true
      }
    },
    describe_listeners: %{
      load_balancer_arn: %{
        name: :load_balancer_arn,
        list: false
      },
      arn: %{
        name: :listener_arns,
        list: true
      },
      arns: %{
        name: :listener_arns,
        list: true
      },
      listener_arns: %{
        name: :listener_arns,
        list: true
      }
    }
  }

  def apply_aliases(action, filters) do
    Enum.map(filters, fn {k, v} ->
      case get_in(@aliases, [action, k]) do
        %{name: name, list: true} -> {name, List.wrap(v)}
        %{name: name, list: false} -> {name, v}
      end
    end)
  end
end
