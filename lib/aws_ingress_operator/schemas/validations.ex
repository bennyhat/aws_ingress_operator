defmodule AwsIngressOperator.Schemas.Validations do
  import Ecto.Changeset

  alias AwsIngressOperator.Addresses
  alias AwsIngressOperator.LoadBalancers
  alias AwsIngressOperator.SecurityGroups
  alias AwsIngressOperator.Subnets
  alias AwsIngressOperator.TargetGroups

  def validate_aws_resource_exists(changeset, field, options \\ []) do
    validate_change(changeset, field, fn field_name, ids ->
      case missing_resources(field_name, ids) do
        [] ->
          []

        missing ->
          [
            {field,
             options[:message] ||
               "Field #{inspect(field)} references AWS resources that do not exist: #{
                 Enum.join(missing, ",")
               }"}
          ]
      end
    end)
  end

  def validate_aws_resource_missing(changeset, field, options \\ []) do
    validate_change(changeset, field, fn field_name, ids ->
      case missing_resources(field_name, ids) do
        [] ->
          [
            {field,
             options[:message] ||
               "Field #{inspect(field)} references AWS resources that already exist: #{
                 Enum.join(List.wrap(ids), ",")
               }"}
          ]

        _ ->
          []
      end
    end)
  end

  def traverse_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {message, opts} ->
      Regex.replace(~r"%{(\w+)}", message, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end

  defp missing_resources(:security_groups, ids) when is_list(ids) do
    Enum.reject(ids, fn id ->
      case SecurityGroups.get(id: id) do
        {:ok, _} -> true
        _ -> false
      end
    end)
  end

  defp missing_resources(:subnets, ids) when is_list(ids) do
    Enum.reject(ids, fn id ->
      case Subnets.get(id: id) do
        {:ok, _} -> true
        _ -> false
      end
    end)
  end

  defp missing_resources(:subnet_id, id) do
    case Subnets.get(id: id) do
      {:ok, _} -> []
      _ -> [id]
    end
  end

  defp missing_resources(:allocation_id, id) do
    case Addresses.get(id: id) do
      {:ok, _} -> []
      _ -> [id]
    end
  end

  defp missing_resources(:load_balancer_name, name) do
    case LoadBalancers.get(name: name) do
      {:ok, _} -> []
      _ -> [name]
    end
  end

  defp missing_resources(:target_group_name, name) do
    case TargetGroups.get(name: name) do
      {:ok, _} -> []
      _ -> [name]
    end
  end

  defp missing_resources(:vpc_id, id) do
    query = ExAws.EC2.describe_vpcs(vpc_ids: [id])

    case ExAws.request(query) do
      {:ok, _} -> []
      _ -> [id]
    end
  end

  defmacro protocols() do
    [
      "HTTP",
      "HTTPS",
      "TCP",
      "TLS",
      "UDP",
      "TCP_UDP"
    ]
  end
end
