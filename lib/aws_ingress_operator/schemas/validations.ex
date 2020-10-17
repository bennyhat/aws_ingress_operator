defmodule AwsIngressOperator.Schemas.Validations do
  import Ecto.Changeset

  alias AwsIngressOperator.Subnets
  alias AwsIngressOperator.SecurityGroups

  def validate_aws_resource_exists(changeset, field, options \\ []) do
    validate_change(changeset, field, fn field_name, ids ->
      case missing_resources(field_name, ids) do
        [] -> []
        missing ->
          [{field, options[:message] || "These #{inspect(field)} do not exist: #{inspect(missing)}"}]
      end
    end)
  end

  defp missing_resources(:security_groups, ids) do
    Enum.reject(ids, fn id ->
      case SecurityGroups.get(id: id) do
        {:ok, _} -> true
        _ -> false
      end
    end)
  end

  defp missing_resources(:subnets, ids) do
    Enum.reject(ids, fn id ->
      case Subnets.get(id: id) do
        {:ok, _} -> true
        _ -> false
      end
    end)
  end
end
