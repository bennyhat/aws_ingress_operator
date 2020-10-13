defmodule AwsIngressOperator.Certificates do
  @moduledoc """
  A repository pattern wrapper for a Certificate inventory
  """
  alias AwsIngressOperator.Schemas.Certificate
  alias AwsIngressOperator.ExAws.ACM

  def get(filter) do
    case ACM.Certificate.describe_certificate(filter) do
      {:ok, certificate} ->
        certificate =
          Certificate.changeset(certificate)
          |> Ecto.Changeset.apply_changes()

        {:ok, certificate}

      error ->
        error
    end
  end
end
