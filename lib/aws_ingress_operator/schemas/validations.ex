defmodule AwsIngressOperator.Schemas.Validations do
  import Ecto.Changeset

  alias AwsIngressOperator.Addresses
  alias AwsIngressOperator.SecurityGroups
  alias AwsIngressOperator.Subnets

  def validate_aws_resource_exists(changeset, field, options \\ []) do
    validate_change(changeset, field, fn field_name, ids ->
      case missing_resources(field_name, ids) do
        [] -> []
        missing ->
          [{field, options[:message] || "These #{inspect(field)} do not exist: #{inspect(missing)}"}]
      end
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
end
