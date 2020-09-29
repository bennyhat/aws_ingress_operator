defmodule AwsIngressOperator.LoadBalancerTest do
  @moduledoc false
  use ExUnit.Case
  use AwsIngressOperator.Test.Support.MotoCase, url: "http://localhost:5000"

  test "does the thing", %{default_aws_vpc: vpc} do
    IO.inspect(vpc)
    assert true
  end

end
