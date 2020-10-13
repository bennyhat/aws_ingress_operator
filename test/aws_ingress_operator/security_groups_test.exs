defmodule AwsIngressOperator.SecurityGroupsTest do
  @moduledoc false
  use ExUnit.Case
  use AwsIngressOperator.Test.Support.MotoCase, url: "http://localhost:5000"

  alias AwsIngressOperator.SecurityGroups
  alias AwsIngressOperator.Schemas.SecurityGroup

  describe "list/1" do
    test "given the default security group, returns list of them", %{
      default_aws_vpc: vpc
    } do
      vpc_id = vpc.id

      assert {:ok, [_default_sg, %SecurityGroup{vpc_id: ^vpc_id}]} = SecurityGroups.list()
    end

    # test "given some listeners, returns list of them by listener arn", %{default_aws_vpc: vpc} do
    #   {:ok, %LoadBalancer{load_balancer_arn: lb_arn}} =
    #     LoadBalancers.create(
    #       %{
    #         load_balancer_name: Faker.Person.name(),
    #         scheme: "internet-facing",
    #         subnets: [vpc.subnet.id],
    #         security_groups: [vpc.security_group.id]
    #       }
    #     )

    #   {:ok, %TargetGroup{target_group_arn: tg_arn}} =
    #     TargetGroups.insert_or_update(%TargetGroup{
    #       target_group_name: Faker.Person.first_name(),
    #       vpc_id: vpc.id
    #     })

    #   {:ok, %{listener_arn: arn}} =
    #     SecurityGroups.insert_or_update(%SecurityGroup{
    #       load_balancer_arn: lb_arn,
    #       protocol: "HTTP",
    #       port: 80,
    #       default_actions: [%{type: "forward", target_group_arn: tg_arn}]
    #     })

    #   SecurityGroups.insert_or_update(%SecurityGroup{
    #     load_balancer_arn: lb_arn,
    #     protocol: "HTTP",
    #     port: 80,
    #     default_actions: [%{type: "forward", target_group_arn: tg_arn}]
    #   })

    #   assert {:ok,
    #           [
    #             %SecurityGroup{
    #               listener_arn: ^arn
    #             }
    #           ]} = SecurityGroups.list(listener_arns: [arn])
    # end
  end

  # describe "get/1" do
  #   test "given some listeners, returns one by arn", %{default_aws_vpc: vpc} do
  #     {:ok, %LoadBalancer{load_balancer_arn: lb_arn}} =
  #       LoadBalancers.create(
  #         %{
  #           load_balancer_name: Faker.Person.name(),
  #           scheme: "internet-facing",
  #           subnets: [vpc.subnet.id],
  #           security_groups: [vpc.security_group.id]
  #         }
  #       )

  #     {:ok, %TargetGroup{target_group_arn: tg_arn}} =
  #       TargetGroups.insert_or_update(%TargetGroup{
  #         target_group_name: Faker.Person.first_name(),
  #         vpc_id: vpc.id
  #       })

  #     SecurityGroups.insert_or_update(%SecurityGroup{
  #       load_balancer_arn: lb_arn,
  #       protocol: "HTTP",
  #       port: 80,
  #       default_actions: [%{type: "forward", target_group_arn: tg_arn}]
  #     })

  #     {:ok, %{listener_arn: arn}} =
  #       SecurityGroups.insert_or_update(%SecurityGroup{
  #         load_balancer_arn: lb_arn,
  #         protocol: "HTTP",
  #         port: 80,
  #         default_actions: [%{type: "forward", target_group_arn: tg_arn}]
  #       })

  #     assert {:ok, %SecurityGroup{listener_arn: ^arn}} = SecurityGroups.get(arn: arn)
  #   end
  # end
end
