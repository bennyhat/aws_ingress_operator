defmodule AwsIngressOperator.CertificatesTest do
  @moduledoc false
  use ExUnit.Case
  use AwsIngressOperator.Test.Support.MotoCase, url: "http://localhost:5000"

  alias AwsIngressOperator.Certificates
  alias AwsIngressOperator.Schemas.Certificate

  describe "get/1" do
    test "gets the certificate in question by arn" do
      %{"CertificateArn" => arn} =
        ExAws.ACM.request_certificate("helloworld.example.com", validation_method: "DNS")
        |> ExAws.request!()

      assert {:ok,
              %Certificate{
                certificate_arn: ^arn
              }} = Certificates.get(arn: arn)
    end
  end
end
