defmodule AwsIngressOperator.Listeners do
  @moduledoc """
  A repository pattern wrapper for a Listener inventory
  """
  alias AwsIngressOperator.Schemas.Listener
  alias AwsIngressOperator.ExAws.Elbv2

  def list(filter) do
    listeners =
      Elbv2.Listener.describe_listeners!(filter)
      |> Enum.map(&Listener.changeset/1)
      |> Enum.map(&Ecto.Changeset.apply_changes/1)

    {:ok, listeners}
  end

  def get(filter) do
    case list(filter) do
      {:ok, [listener]} -> {:ok, listener}
      {:ok, []} -> {:error, :resource_not_found}
    end
  end

  def insert_or_update(%{listener_arn: nil} = listener), do: insert(listener)

  def insert_or_update(%{listener_arn: arn} = listener) do
    case get(arn: arn) do
      {:ok, existing_listener} -> update(existing_listener, listener)
      error -> error
    end
  end

  def insert_or_update(listener), do: insert(listener)

  defp insert(listener) do
    %{listener_arn: arn} = Elbv2.Listener.create_listener!(listener)

    get(arn: arn)
  end

  defp update(existing_listener, listener) do
    Elbv2.Listener.modify_listener!(listener)

    get(arn: existing_listener.listener_arn)
  end

  def delete(listener) do
    Elbv2.Listener.delete_listener!(listener)

    :ok
  end
end
