defmodule AwsIngressOperator.ExAws.Elbv2.TargetGroup do
  alias AwsIngressOperator.ExAws.FilterAliases

  import AwsIngressOperator.ExAws.Elbv2, only: [make_request: 2, make_request: 3]

  def describe_target_groups(filters) do
    action = :describe_target_groups
    aliased_filters = FilterAliases.apply_aliases(action, filters)

    return_target_groups = fn
    %{
      describe_target_groups_response: %{
        describe_target_groups_result: %{
          target_groups: tgs
        }
      }
    } ->
        tgs || []
    end

    make_request(aliased_filters, action, return_target_groups)
    |> ExAws.request()
  end

  def create_target_group!(tg) do
    return_target_group = fn
    %{
      create_target_group_response: %{
        create_target_group_result: %{
          target_groups: [tg]
        }
      }
    } ->
        tg
    end

    Map.put(tg, :name, tg.target_group_name)
    |> make_request(:create_target_group, return_target_group)
    |> ExAws.request!()
  end

  def modify_target_group!(tg) do
    make_request(tg, :modify_target_group)
    |> ExAws.request!()
  end

  def delete_target_group!(tg) do
    make_request(tg, :delete_target_group)
    |> ExAws.request!()
  end
end
