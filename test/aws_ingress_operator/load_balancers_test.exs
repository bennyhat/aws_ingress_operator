defmodule AwsIngressOperator.LoadBalancersTest do
  @moduledoc false
  use ExUnit.Case
  import SweetXml
  use AwsIngressOperator.Test.Support.MotoCase, url: "http://localhost:5000"

  alias AwsIngressOperator.LoadBalancers
  alias AwsIngressOperator.Schemas.LoadBalancer

  describe "list/0" do
    test "when no load balancers exist, returns empty list", %{default_aws_vpc: _vpc} do
      assert {:ok, []} == LoadBalancers.list()
    end

    test "given some load balancers, returns list of them", %{default_aws_vpc: vpc} do
      name = Faker.Person.name()
      ExAws.ElasticLoadBalancingV2.create_load_balancer(
        name,
        [
          schema: "internal",
          subnets: [vpc.subnet.id],
          security_groups: [vpc.security_group.id]
        ]
      )
      |> ExAws.request!()

      assert {:ok, [
        %LoadBalancer{
          load_balancer_name: ^name
        }
      ]} = LoadBalancers.list()
    end

  end

  describe "list/1" do
    test "given some load balancers, returns them by name", %{default_aws_vpc: vpc} do
      name = Faker.Person.name()
      ExAws.ElasticLoadBalancingV2.create_load_balancer(
        name,
        [
          schema: "internal",
          subnets: [vpc.subnet.id],
          security_groups: [vpc.security_group.id]
        ]
      )
      |> ExAws.request!()
      ExAws.ElasticLoadBalancingV2.create_load_balancer(
        Faker.Person.name(),
        [
          schema: "internal",
          subnets: [vpc.subnet.id],
          security_groups: [vpc.security_group.id]
        ]
      )
      |> ExAws.request!()

      assert {:ok, [
                 %LoadBalancer{
                   load_balancer_name: ^name
                 }
               ]} = LoadBalancers.list(names: [name])
    end

    test "given some load balancers, returns them by arn", %{default_aws_vpc: vpc} do
      name = Faker.Person.name()

      [arn] = ExAws.ElasticLoadBalancingV2.create_load_balancer(
        name,
        [
          schema: "internal",
          subnets: [vpc.subnet.id],
          security_groups: [vpc.security_group.id]
        ]
      )
      |> ExAws.request!()
      |> Map.get(:body)
      |> SweetXml.xpath(~x"//LoadBalancerArn/text()"ls)

      ExAws.ElasticLoadBalancingV2.create_load_balancer(
        Faker.Person.name(),
        [
          schema: "internal",
          subnets: [vpc.subnet.id],
          security_groups: [vpc.security_group.id]
        ]
      )
      |> ExAws.request!()

      assert {:ok, [
                 %LoadBalancer{
                   load_balancer_name: ^name
                 }
               ]} = LoadBalancers.list(load_balancer_arns: [arn])
    end

    test "given some load balancers, returns them by short arn option", %{default_aws_vpc: vpc} do
      name = Faker.Person.name()

      [arn] = ExAws.ElasticLoadBalancingV2.create_load_balancer(
        name,
        [
          schema: "internal",
          subnets: [vpc.subnet.id],
          security_groups: [vpc.security_group.id]
        ]
      )
      |> ExAws.request!()
      |> Map.get(:body)
      |> SweetXml.xpath(~x"//LoadBalancerArn/text()"ls)

      ExAws.ElasticLoadBalancingV2.create_load_balancer(
        Faker.Person.name(),
        [
          schema: "internal",
          subnets: [vpc.subnet.id],
          security_groups: [vpc.security_group.id]
        ]
      )
      |> ExAws.request!()

      assert {:ok, [
                 %LoadBalancer{
                   load_balancer_name: ^name
                 }
               ]} = LoadBalancers.list(arns: [arn])
    end
  end
  describe "get/1" do
  end
  describe "insert/1" do
  end
  describe "update/1" do
  end
  describe "delete/1" do
  end
end
