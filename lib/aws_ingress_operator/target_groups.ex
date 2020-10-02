defmodule AwsIngressOperator.TargetGroups do
  @moduledoc """
  A repository pattern wrapper for a Target Group inventory
  """
  import SweetXml

  alias AwsIngressOperator.Schemas.TargetGroup

  @option_aliases %{
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

  defp alias_options(opts) do
    Enum.map(opts, fn {k, v} ->
      case Map.get(@option_aliases, k) do
        %{name: name, list: true} -> {name, List.wrap(v)}
        %{name: name, list: false} -> {name, v}
      end
    end)
  end

  def list(opts \\ []) do
    opts = alias_options(opts)

    case ExAws.ElasticLoadBalancingV2.describe_target_groups(opts) |> ExAws.request() do
        {:ok, %{body: body}} ->
          target_groups = Map.get(body, :target_groups)
          |> Enum.map(&TargetGroup.changeset/1)
          |> Enum.map(&Ecto.Changeset.apply_changes/1)

          {:ok, target_groups}
        error -> error
    end

  end

  # def get(opts \\ []) do
  #   case list(opts) do
  #     {:ok, [listener]} -> {:ok, listener}
  #     error -> error
  #   end
  # end

  # def insert_or_update(listener) do
  #   case Map.get(listener, :listener_arn) do
  #     nil -> insert(listener)
  #     arn ->
  #       case get(arn: arn) do
  #         {:ok, existing_listener} -> update(existing_listener, listener)
  #         {:error, _} -> {:error, :listener_not_found}
  #       end
  #   end
  # end

  # defp insert(listener) do
  #   [arn] = ExAws.ElasticLoadBalancingV2.create_listener(
  #     listener.load_balancer_arn,
  #     listener.protocol,
  #     listener.port,
  #     listener.default_actions
  #   )
  #   |> ExAws.request!()
  #   |> Map.get(:body)
  #   |> SweetXml.xpath(~x"//ListenerArn/text()"ls)

  #   get(arn: arn)
  # end

  # defp update(existing_listener, updated_listener) do
  #   ExAws.ElasticLoadBalancingV2.modify_listener(
  #     existing_listener.listener_arn, [
  #       protocol: updated_listener.protocol,
  #       port: updated_listener.port,
  #       default_actions: updated_listener.default_actions,
  #       ssl_policy: updated_listener.ssl_policy,
  #       certificates: updated_listener.certificates
  #     ]
  #   )
  #   |> ExAws.request!()
  #   |> Map.get(:body)

  #   get(arn: existing_listener.listener_arn)
  # end

  # def delete(listener) do
  #   ExAws.ElasticLoadBalancingV2.delete_listener(listener.listener_arn)
  #   |> ExAws.request!()

  #   :ok
  # end
end
