defmodule AwsIngressOperator.LoadBalancersTest do
  @moduledoc false
  use ExUnit.Case

  use AwsIngressOperator.Test.Support.MotoCase,
    url: "http://localhost:5000"

  import Checkov

  alias AwsIngressOperator.LoadBalancers
  alias AwsIngressOperator.Schemas.LoadBalancer
  alias AwsIngressOperator.Schemas.SubnetMapping

  describe "list/0" do
    test "when no load balancers exist, returns empty list", %{default_aws_vpc: _vpc} do
      assert {:ok, []} == LoadBalancers.list()
    end

    test "given some load balancers, returns list of them", %{default_aws_vpc: vpc} do
      {_arn, name} = create_load_balancer!(vpc)

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
      {_arn, name} = create_load_balancer!(vpc)

      create_load_balancer!(vpc)

      assert {:ok,
              [
                %LoadBalancer{
                  load_balancer_name: ^name
                }
              ]} = LoadBalancers.list(names: [name])
    end

    test "given some load balancers, returns them by arn", %{default_aws_vpc: vpc} do
      {arn, name} = create_load_balancer!(vpc)

      create_load_balancer!(vpc)

      assert {:ok,
              [
                %LoadBalancer{
                  load_balancer_name: ^name
                }
              ]} = LoadBalancers.list(load_balancer_arns: [arn])
    end

    test "given some load balancers, returns them by short arn option", %{default_aws_vpc: vpc} do
      {arn, name} = create_load_balancer!(vpc)

      create_load_balancer!(vpc)

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
      {_arn, name} = create_load_balancer!(vpc)

      create_load_balancer!(vpc)

      assert {:ok,
              %LoadBalancer{
                load_balancer_name: ^name
              }} = LoadBalancers.get(name: name)
    end

    test "gets the load balancer in question by arn", %{default_aws_vpc: vpc} do
      {arn, _name} = create_load_balancer!(vpc)

      create_load_balancer!(vpc)

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
               LoadBalancers.create(%LoadBalancer{
                 load_balancer_name: name,
                 scheme: "internet-facing",
                 subnets: [vpc.subnet.id],
                 security_groups: [vpc.security_group.id]
               })
    end

    test "validates load balancer name is unique", %{default_aws_vpc: vpc} do
      name = Faker.Person.first_name()

      LoadBalancers.create(%LoadBalancer{
        load_balancer_name: name,
        scheme: "internet-facing",
        subnets: [vpc.subnet.id],
        security_groups: [vpc.security_group.id]
      })

      assert {:invalid, %{load_balancer_name: _}} =
               LoadBalancers.create(%LoadBalancer{
                 load_balancer_name: name,
                 scheme: "internet-facing",
                 subnets: [vpc.subnet.id],
                 security_groups: [vpc.security_group.id]
               })
    end

    test "validates subnets exist", %{default_aws_vpc: vpc} do
      assert {:invalid, %{subnets: _}} =
               LoadBalancers.create(%LoadBalancer{
                 load_balancer_name: Faker.Person.first_name(),
                 scheme: "internet-facing",
                 subnets: [vpc.subnet.id, "cannot-exist"],
                 security_groups: [vpc.security_group.id]
               })
    end

    test "validates subnet mappings", %{default_aws_vpc: vpc} do
      assert {:invalid, %{subnet_mappings: [%{allocation_id: _}, %{subnet_id: _}, %{}]}} =
               LoadBalancers.create(%LoadBalancer{
                 load_balancer_name: Faker.Person.first_name(),
                 scheme: "internet-facing",
                 subnet_mappings: [
                   %SubnetMapping{
                     allocation_id: "cannot-exist",
                     subnet_id: vpc.subnet.id
                   },
                   %SubnetMapping{
                     allocation_id: vpc.eip.id,
                     subnet_id: "cannot-exist"
                   },
                   %SubnetMapping{
                     allocation_id: vpc.eip.id,
                     subnet_id: vpc.subnet.id
                   }
                 ],
                 security_groups: [vpc.security_group.id]
               })
    end

    test "validates security groups", %{default_aws_vpc: vpc} do
      assert {:invalid, %{security_groups: _}} =
               LoadBalancers.create(%LoadBalancer{
                 load_balancer_name: Faker.Person.first_name(),
                 scheme: "internet-facing",
                 subnets: [vpc.subnet.id],
                 security_groups: [vpc.security_group.id, "cannot-exist"]
               })
    end

    data_test "validates #{field}", %{default_aws_vpc: vpc} do
      fields =
        Map.merge(
          %{
            load_balancer_name: Faker.Person.first_name(),
            scheme: "internet-facing",
            subnets: [vpc.subnet.id],
            security_groups: [vpc.security_group.id]
          },
          %{
            field => invalid_value
          }
        )

      lb = struct(LoadBalancer, fields)

      assert {:invalid, %{^field => _}} = LoadBalancers.create(lb)

      where([
        [:field, :invalid_value],
        [:load_balancer_name, 3],
        [:type, "cannot-be"],
        [:scheme, "cannot-be"],
        [:ip_address_type, "cannot-be"]
      ])
    end

    test "does not blow up when load balancer doesn't exist" do
      assert {:error, _} = LoadBalancers.get(name: "cannot-exist")
    end
  end

  describe "delete/1" do
    test "given a load balancer that exists, deletes it", %{default_aws_vpc: vpc} do
      {arn, _name} = create_load_balancer!(vpc)

      assert :ok = LoadBalancers.delete(%LoadBalancer{load_balancer_arn: arn})
      assert {:ok, []} == LoadBalancers.list()
    end
  end
end
