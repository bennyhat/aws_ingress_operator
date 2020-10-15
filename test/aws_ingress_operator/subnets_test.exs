defmodule AwsIngressOperator.SubnetsTest do
  @moduledoc false
  use ExUnit.Case
  import SweetXml
  use AwsIngressOperator.Test.Support.MotoCase, url: "http://localhost:5000"

  alias AwsIngressOperator.Subnets
  alias AwsIngressOperator.Schemas.Subnet

  describe "list/1" do
    test "given the default subnet, returns list of them (6 for moto)", %{
      default_aws_vpc: vpc
    } do
      vpc_id = vpc.id

      assert {:ok, [%Subnet{vpc_id: ^vpc_id}| _] = subnets} = Subnets.list()
      assert length(subnets) == 6
    end

    test "given some subnets, returns list of them by id", %{default_aws_vpc: vpc} do
      # moto "should" assign the private block to this VPC
      cidr_block = "172.31.255.0/24"

      id = ExAws.EC2.create_subnet(
        vpc.id,
        cidr_block
      )
      |> ExAws.request!()
      |> Map.get(:body)
      |> SweetXml.xpath(~x"//subnetId/text()"s)

      assert {:ok, [%Subnet{subnet_id: ^id}]} = Subnets.list(subnet_id: id)
    end

    test "given some subnets, returns list of them by filter", %{default_aws_vpc: vpc} do
      cidr_block = "172.31.255.0/24"

      ExAws.EC2.create_subnet(
        vpc.id,
        cidr_block
      )
      |> ExAws.request!()

      assert {:ok, subnets} = Subnets.list(filter: [%{name: "vpc-id", value: vpc.id}])

      assert 7 == Enum.filter(subnets, fn subnet -> subnet.vpc_id == vpc.id end)
      |> length()
    end
  end

  describe "get/1" do
    test "given some subnets, returns one by id", %{default_aws_vpc: vpc} do
      cidr_block = "172.31.255.0/24"

      id = ExAws.EC2.create_subnet(
        vpc.id,
        cidr_block
      )
      |> ExAws.request!()
      |> Map.get(:body)
      |> SweetXml.xpath(~x"//subnetId/text()"s)

      assert {:ok, %Subnet{subnet_id: ^id}} = Subnets.get(id: id)
    end
  end
end
