defmodule AwsIngressOperator.LoadBalancersTest do
  @moduledoc false
  use ExUnit.Case
  use AwsIngressOperator.Test.Support.MotoCase, url: "http://localhost:5000"

  alias AwsIngressOperator.LoadBalancers
  alias AwsIngressOperator.Schemas.LoadBalancer

  describe "list/0" do
    test "when no load balancers exist, returns empty list", %{default_aws_vpc: _vpc} do
      assert {:ok, []} == LoadBalancers.list()
    end

    test "given some load balancers, returns list of them", %{default_aws_vpc: vpc} do
      name = Faker.Person.first_name()

      LoadBalancers.create(
        %LoadBalancer{
          load_balancer_name: name,
          scheme: "internal",
          subnets: [vpc.subnet.id],
          security_groups: vpc.security_group.id
        }
      )

      assert {:ok,
              [
                %LoadBalancer{
                  load_balancer_name: ^name
                }
              ]} = LoadBalancers.list()
    end
  end

  describe "list/1" do
    test "given some load balancers, returns them by name", %{default_aws_vpc: vpc} do
      name = Faker.Person.first_name()

      LoadBalancers.create(
        %LoadBalancer{
          load_balancer_name: name,
          scheme: "internal",
          subnets: [vpc.subnet.id],
          security_groups: vpc.security_group.id
        }
      )

      LoadBalancers.create(
        %LoadBalancer{
          load_balancer_name: Faker.Person.first_name(),
          scheme: "internal",
          subnets: [vpc.subnet.id],
          security_groups: vpc.security_group.id
        }
      )

      assert {:ok,
              [
                %LoadBalancer{
                  load_balancer_name: ^name
                }
              ]} = LoadBalancers.list(names: [name])
    end

    test "given some load balancers, returns them by arn", %{default_aws_vpc: vpc} do
      name = Faker.Person.first_name()

      {:ok, %LoadBalancer{load_balancer_arn: arn}} = LoadBalancers.create(
        %LoadBalancer{
          load_balancer_name: name,
          scheme: "internal",
          subnets: [vpc.subnet.id],
          security_groups: vpc.security_group.id
        }
      )

      LoadBalancers.create(
        %LoadBalancer{
          load_balancer_name: Faker.Person.first_name(),
          scheme: "internal",
          subnets: [vpc.subnet.id],
          security_groups: vpc.security_group.id
        }
      )

      assert {:ok,
              [
                %LoadBalancer{
                  load_balancer_name: ^name
                }
              ]} = LoadBalancers.list(load_balancer_arns: [arn])
    end

    test "given some load balancers, returns them by short arn option", %{default_aws_vpc: vpc} do
      name = Faker.Person.first_name()

      {:ok, %LoadBalancer{load_balancer_arn: arn}} = LoadBalancers.create(
        %LoadBalancer{
          load_balancer_name: name,
          scheme: "internal",
          subnets: [vpc.subnet.id],
          security_groups: vpc.security_group.id
        }
      )

      LoadBalancers.create(
        %LoadBalancer{
          load_balancer_name: Faker.Person.first_name(),
          scheme: "internal",
          subnets: [vpc.subnet.id],
          security_groups: vpc.security_group.id
        }
      )

      assert {:ok,
              [
                %LoadBalancer{
                  load_balancer_name: ^name
                }
              ]} = LoadBalancers.list(arns: [arn])
    end
  end

  describe "get/1" do
    test "gets the load balancer in question by name", %{default_aws_vpc: vpc} do
      name = Faker.Person.first_name()

      LoadBalancers.create(
        %LoadBalancer{
          load_balancer_name: name,
          scheme: "internal",
          subnets: [vpc.subnet.id],
          security_groups: vpc.security_group.id
        }
      )

      LoadBalancers.create(
        %LoadBalancer{
          load_balancer_name: Faker.Person.first_name(),
          scheme: "internal",
          subnets: [vpc.subnet.id],
          security_groups: vpc.security_group.id
        }
      )

      assert {:ok,
              %LoadBalancer{
                load_balancer_name: ^name
              }} = LoadBalancers.get(name: name)
    end

    test "gets the load balancer in question by arn", %{default_aws_vpc: vpc} do
      {:ok, %LoadBalancer{load_balancer_arn: arn}} = LoadBalancers.create(
        %LoadBalancer{
          load_balancer_name: Faker.Person.first_name(),
          scheme: "internal",
          subnets: [vpc.subnet.id],
          security_groups: vpc.security_group.id
        }
      )

      LoadBalancers.create(
        %LoadBalancer{
          load_balancer_name: Faker.Person.first_name(),
          scheme: "internal",
          subnets: [vpc.subnet.id],
          security_groups: vpc.security_group.id
        }
      )

      assert {:ok,
              %LoadBalancer{
                load_balancer_arn: ^arn
              }} = LoadBalancers.get(arn: arn)
    end
  end

  describe "create/1" do
    test "given a load balancer that doesn't exist, creates it", %{default_aws_vpc: vpc} do
      name = Faker.Person.first_name()

      assert {:ok,
              %LoadBalancer{
                load_balancer_name: ^name
              }} =
        LoadBalancers.create(
          %LoadBalancer{
            load_balancer_name: name,
            scheme: "internet-facing",
            subnets: [vpc.subnet.id],
            security_groups: [vpc.security_group.id]
          }
      )
    end
    # TODO - sad path for already existing
  end

  describe "delete/1" do
    test "given a load balancer that exists, deletes it", %{default_aws_vpc: vpc} do
      {:ok, %LoadBalancer{load_balancer_arn: arn}} = LoadBalancers.create(
        %LoadBalancer{
          load_balancer_name: Faker.Person.first_name(),
          scheme: "internal",
          subnets: [vpc.subnet.id],
          security_groups: vpc.security_group.id
        }
      )

      assert :ok = LoadBalancers.delete(%LoadBalancer{load_balancer_arn: arn})
      assert {:ok, []} == LoadBalancers.list()
    end
  end
end
