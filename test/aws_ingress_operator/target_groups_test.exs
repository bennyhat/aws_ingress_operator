defmodule AwsIngressOperator.TargetGroupsTest do
  @moduledoc false
  use ExUnit.Case
  use AwsIngressOperator.Test.Support.MotoCase, url: "http://localhost:5000"

  alias AwsIngressOperator.TargetGroups
  alias AwsIngressOperator.Listeners
  alias AwsIngressOperator.LoadBalancers
  alias AwsIngressOperator.Schemas.Listener
  alias AwsIngressOperator.Schemas.LoadBalancer
  alias AwsIngressOperator.Schemas.Matcher
  alias AwsIngressOperator.Schemas.TargetGroup

  describe "list/1" do
    test "can return an empty list" do
      assert {:ok, []} = TargetGroups.list()
    end

    test "given some target groups, returns list of them", %{default_aws_vpc: vpc} do
      name = Faker.Person.first_name()

      TargetGroups.insert_or_update(%TargetGroup{target_group_name: name, vpc_id: vpc.id})

      assert {:ok, [%TargetGroup{target_group_name: ^name}]} = TargetGroups.list()
    end

    test "given some target groups, returns list of them by arn", %{default_aws_vpc: vpc} do
      name = Faker.Person.first_name()

      {:ok, %TargetGroup{target_group_arn: arn}} =
        TargetGroups.insert_or_update(%TargetGroup{target_group_name: name, vpc_id: vpc.id})

      TargetGroups.insert_or_update(%TargetGroup{
        target_group_name: Faker.Person.first_name(),
        vpc_id: vpc.id
      })

      assert {:ok,
              [
                %TargetGroup{
                  target_group_arn: ^arn
                }
              ]} = TargetGroups.list(arns: [arn])
    end

    test "given some target groups, returns list of them by name", %{default_aws_vpc: vpc} do
      name = Faker.Person.first_name()

      TargetGroups.insert_or_update(%TargetGroup{target_group_name: name, vpc_id: vpc.id})

      TargetGroups.insert_or_update(%TargetGroup{
        target_group_name: Faker.Person.first_name(),
        vpc_id: vpc.id
      })

      assert {:ok,
              [
                %TargetGroup{
                  target_group_name: ^name
                }
              ]} = TargetGroups.list(names: [name])
    end

    test "given some target groups, returns list of them by load balancer arn", %{
      default_aws_vpc: vpc
    } do
      {:ok, %LoadBalancer{load_balancer_arn: lb_arn}} =
        LoadBalancers.create(
          name: Faker.Person.name(),
          schema: "internet-facing",
          subnets: [vpc.subnet.id],
          security_groups: [vpc.security_group.id]
        )

      {:ok, %TargetGroup{target_group_arn: tg_arn}} =
        TargetGroups.insert_or_update(%TargetGroup{
          target_group_name: Faker.Person.first_name(),
          vpc_id: vpc.id
        })

      TargetGroups.insert_or_update(%TargetGroup{
        target_group_name: Faker.Person.first_name(),
        vpc_id: vpc.id
      })

      Listeners.insert_or_update(%Listener{
        load_balancer_arn: lb_arn,
        protocol: "HTTP",
        port: 80,
        default_actions: [%{type: "forward", target_group_arn: tg_arn}]
      })

      assert {:ok,
              [
                %TargetGroup{
                  target_group_arn: ^tg_arn
                }
              ]} = TargetGroups.list(load_balancer_arn: lb_arn)
    end
  end

  describe "get/1" do
    test "given some target groups, returns one by arn", %{default_aws_vpc: vpc} do
      TargetGroups.insert_or_update(%TargetGroup{
        target_group_name: Faker.Person.first_name(),
        vpc_id: vpc.id
      })

      {:ok, %TargetGroup{target_group_arn: arn}} =
        TargetGroups.insert_or_update(%TargetGroup{
          target_group_name: Faker.Person.first_name(),
          vpc_id: vpc.id
        })

      assert {:ok, %TargetGroup{target_group_arn: ^arn}} = TargetGroups.get(arn: arn)
    end

    test "given some target groups, returns one by name", %{default_aws_vpc: vpc} do
      TargetGroups.insert_or_update(%TargetGroup{
        target_group_name: Faker.Person.first_name(),
        vpc_id: vpc.id
      })

      name = Faker.Person.first_name()

      TargetGroups.insert_or_update(%TargetGroup{target_group_name: name, vpc_id: vpc.id})

      assert {:ok, %TargetGroup{target_group_name: ^name}} = TargetGroups.get(name: name)
    end
  end

  describe "insert_or_update/1" do
    test "given a non-existent target group, it creates one", %{default_aws_vpc: vpc} do
      assert {:ok, %TargetGroup{target_group_arn: _arn}} =
               TargetGroups.insert_or_update(%TargetGroup{
                 target_group_name: Faker.Person.first_name(),
                 vpc_id: vpc.id
               })
    end

    test "given a non-existent target group, with an arn provided it fails", %{
      default_aws_vpc: vpc
    } do
      assert {:error, :resource_not_found} =
               TargetGroups.insert_or_update(%TargetGroup{
                 target_group_arn: "not_there",
                 target_group_name: Faker.Person.first_name(),
                 vpc_id: vpc.id
               })
    end

    test "given an existing target group, with an arn provided it updates the target group", %{
      default_aws_vpc: vpc
    } do
      {:ok, %TargetGroup{target_group_arn: arn}} =
        TargetGroups.insert_or_update(%TargetGroup{
          target_group_name: Faker.Person.first_name(),
          vpc_id: vpc.id
        })

      assert {:ok,
              %TargetGroup{
                target_group_arn: ^arn,
                # missing from moto
                health_check_enabled: nil,
                health_check_interval_seconds: 10,
                health_check_path: "/api/v1/healthy",
                health_check_port: "2000",
                health_check_protocol: "TLS",
                health_check_timeout_seconds: 10,
                healthy_threshold_count: 3,
                unhealthy_threshold_count: 4,
                matcher: %Matcher{
                  http_code: "200"
                }
              }} =
               TargetGroups.insert_or_update(%TargetGroup{
                 target_group_arn: arn,
                 health_check_enabled: true,
                 health_check_interval_seconds: 10,
                 health_check_path: "/api/v1/healthy",
                 health_check_port: "2000",
                 health_check_protocol: "TLS",
                 health_check_timeout_seconds: 10,
                 healthy_threshold_count: 3,
                 unhealthy_threshold_count: 4,
                 matcher: %Matcher{
                   http_code: "200"
                 }
               })
    end
  end

  describe "delete/1" do
    test "given a target group that exists, deletes it", %{default_aws_vpc: vpc} do
      {:ok, %TargetGroup{target_group_arn: arn}} =
        TargetGroups.insert_or_update(%TargetGroup{
          target_group_name: Faker.Person.first_name(),
          vpc_id: vpc.id
        })

      assert :ok =
               TargetGroups.delete(%TargetGroup{
                 target_group_arn: arn
               })

      assert {:error, _} = TargetGroups.list(target_group_arn: arn)
    end
  end
end
