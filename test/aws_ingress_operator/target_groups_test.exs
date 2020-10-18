defmodule AwsIngressOperator.TargetGroupsTest do
  @moduledoc false
  use ExUnit.Case
  use AwsIngressOperator.Test.Support.MotoCase, url: "http://localhost:5000"

  import Checkov

  alias AwsIngressOperator.TargetGroups
  alias AwsIngressOperator.Listeners
  alias AwsIngressOperator.Schemas.Listener
  alias AwsIngressOperator.Schemas.Matcher
  alias AwsIngressOperator.Schemas.TargetGroup

  describe "list/1" do
    test "can return an empty list" do
      assert {:ok, []} = TargetGroups.list()
    end

    test "given some target groups, returns list of them", %{default_aws_vpc: vpc} do
      {_arn, name} = create_target_group!(vpc)

      assert {:ok, [%TargetGroup{target_group_name: ^name}]} = TargetGroups.list()
    end

    test "given some target groups, returns list of them by arn", %{default_aws_vpc: vpc} do
      {arn, _name} = create_target_group!(vpc)
      create_target_group!(vpc)

      assert {:ok,
              [
                %TargetGroup{
                  target_group_arn: ^arn
                }
              ]} = TargetGroups.list(arns: [arn])
    end

    test "given some target groups, returns list of them by name", %{default_aws_vpc: vpc} do
      {_arn, name} = create_target_group!(vpc)
      create_target_group!(vpc)

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
      {lb_arn, _name} = create_load_balancer!(vpc)
      {tg_arn, _name} = create_target_group!(vpc)
      create_target_group!(vpc)

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
      create_target_group!(vpc)
      {arn, _name} = create_target_group!(vpc)

      assert {:ok, %TargetGroup{target_group_arn: ^arn}} = TargetGroups.get(arn: arn)
    end

    test "given some target groups, returns one by name", %{default_aws_vpc: vpc} do
      create_target_group!(vpc)
      {_arn, name} = create_target_group!(vpc)

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
      {arn, _name} = create_target_group!(vpc)

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
                  http_code: "200,202-299"
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
                   http_code: "200,202-299"
                 }
               })
    end

    test "validates name is unique on insert", %{default_aws_vpc: vpc} do
      {_arn, same_name} = create_target_group!(vpc)

      assert {:invalid, %{target_group_name: _}} =
        TargetGroups.insert_or_update(%TargetGroup{
          target_group_name: same_name,
          vpc_id: vpc.id
        })
    end

    test "validates vpc exists" do
      assert {:invalid, %{vpc_id: _}} =
        TargetGroups.insert_or_update(%TargetGroup{
          target_group_name: Faker.Person.first_name(),
          vpc_id: "cannot-exist"
        })
    end

    data_test "validates #{field}", %{default_aws_vpc: vpc} do
      fields = Map.merge(
        %{
          target_group_name: Faker.Person.first_name(),
          vpc_id: vpc.id
        },
        %{
          field => value
        }
      )
      result = struct(TargetGroup, fields)
      |> TargetGroups.insert_or_update()

      if valid? do
        assert {:ok, _} = result
      else
        assert {:invalid, %{ ^field => _ }} = result
      end

      where([
        [:field, :value, :valid?],
        [:health_check_interval_seconds, 4, false],
        [:health_check_interval_seconds, 301, false],
        [:health_check_path, random_string(1025), false],
        [:health_check_enabled, "a string", false],
        [:health_check_protocol, "not HTTP, TCP etc.", false],
        [:health_check_timeout_seconds, 1, false],
        [:health_check_timeout_seconds, 121, false],
        [:healthy_threshold_count, 1, false],
        [:healthy_threshold_count, 11, false],
        [:port, 0, false],
        [:port, 65536, false],
        [:protocol, "not HTTP, TCP etc.", false],
        [:target_type, "not instance, ip or lambda", false],
        [:unhealthy_threshold_count, 1, false],
        [:unhealthy_threshold_count, 11, false],
        [:matcher, %Matcher{http_code: "199"}, false],
        [:matcher, %Matcher{http_code: "100,200-499"}, false],
        [:matcher, %Matcher{http_code: "500"}, false],
        [:matcher, %Matcher{http_code: "200/300"}, false],
        [:matcher, %Matcher{http_code: "200-499"}, true],
        [:matcher, %Matcher{http_code: "201,205,300-499"}, true],
      ])
    end
  end

  describe "delete/1" do
    test "given a target group that exists, deletes it", %{default_aws_vpc: vpc} do
      {arn, _name} = create_target_group!(vpc)

      assert :ok =
               TargetGroups.delete(%TargetGroup{
                 target_group_arn: arn
               })

      assert {:ok, []} = TargetGroups.list(target_group_arn: arn)
    end
  end

  def random_string(length) do
    :crypto.strong_rand_bytes(length) |> Base.url_encode64 |> binary_part(0, length)
  end
end
