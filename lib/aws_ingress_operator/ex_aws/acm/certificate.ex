defmodule AwsIngressOperator.ExAws.ACM.Certificate do
  alias AwsIngressOperator.ExAws.FilterAliases

  def describe_certificate(filters) do
    action = :describe_certificate
    aliased_filters = FilterAliases.apply_aliases(action, filters)
    arn = Keyword.get(aliased_filters, :certificate_arn)

    case ExAws.ACM.describe_certificate(arn) |> ExAws.request() do
      {:ok, certificate} ->
        certificate =
          AtomicMap.convert(certificate, safe: false)
          |> Map.get(:certificate)

        {:ok, certificate}

      error ->
        error
    end
  end
end
