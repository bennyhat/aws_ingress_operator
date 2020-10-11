defmodule AwsIngressOperator.ListenersTest do
  @moduledoc false
  use ExUnit.Case
  use AwsIngressOperator.Test.Support.MotoCase, url: "http://localhost:5000"

  alias AwsIngressOperator.LoadBalancers
  alias AwsIngressOperator.TargetGroups
  alias AwsIngressOperator.Listeners
  alias AwsIngressOperator.Schemas.Listener
  alias AwsIngressOperator.Schemas.LoadBalancer
  alias AwsIngressOperator.Schemas.TargetGroup
  alias AwsIngressOperator.Schemas.Action
  alias AwsIngressOperator.Schemas.Certificate

  describe "list/1" do
    test "given some listeners, returns list of them by load balancer arn", %{
      default_aws_vpc: vpc
    } do
      {:ok, %LoadBalancer{load_balancer_arn: lb_arn}} =
        LoadBalancers.create(
          %{
            load_balancer_name: Faker.Person.name(),
            scheme: "internet-facing",
            subnets: [vpc.subnet.id],
            security_groups: [vpc.security_group.id]
          }
        )

      {:ok, %TargetGroup{target_group_arn: tg_arn}} =
        TargetGroups.insert_or_update(%TargetGroup{
          target_group_name: Faker.Person.first_name(),
          vpc_id: vpc.id
        })

      {:ok, %{listener_arn: arn}} =
        Listeners.insert_or_update(%Listener{
          load_balancer_arn: lb_arn,
          protocol: "HTTP",
          port: 80,
          default_actions: [%{type: "forward", target_group_arn: tg_arn}]
        })

      assert {:ok,
              [
                %Listener{
                  load_balancer_arn: ^lb_arn,
                  listener_arn: ^arn
                }
              ]} = Listeners.list(load_balancer_arn: lb_arn)
    end

    test "given some listeners, returns list of them by listener arn", %{default_aws_vpc: vpc} do
      {:ok, %LoadBalancer{load_balancer_arn: lb_arn}} =
        LoadBalancers.create(
          %{
            load_balancer_name: Faker.Person.name(),
            scheme: "internet-facing",
            subnets: [vpc.subnet.id],
            security_groups: [vpc.security_group.id]
          }
        )

      {:ok, %TargetGroup{target_group_arn: tg_arn}} =
        TargetGroups.insert_or_update(%TargetGroup{
          target_group_name: Faker.Person.first_name(),
          vpc_id: vpc.id
        })

      {:ok, %{listener_arn: arn}} =
        Listeners.insert_or_update(%Listener{
          load_balancer_arn: lb_arn,
          protocol: "HTTP",
          port: 80,
          default_actions: [%{type: "forward", target_group_arn: tg_arn}]
        })

      Listeners.insert_or_update(%Listener{
        load_balancer_arn: lb_arn,
        protocol: "HTTP",
        port: 80,
        default_actions: [%{type: "forward", target_group_arn: tg_arn}]
      })

      assert {:ok,
              [
                %Listener{
                  listener_arn: ^arn
                }
              ]} = Listeners.list(listener_arns: [arn])
    end
  end

  describe "get/1" do
    test "given some listeners, returns one by arn", %{default_aws_vpc: vpc} do
      {:ok, %LoadBalancer{load_balancer_arn: lb_arn}} =
        LoadBalancers.create(
          %{
            load_balancer_name: Faker.Person.name(),
            scheme: "internet-facing",
            subnets: [vpc.subnet.id],
            security_groups: [vpc.security_group.id]
          }
        )

      {:ok, %TargetGroup{target_group_arn: tg_arn}} =
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

      {:ok, %{listener_arn: arn}} =
        Listeners.insert_or_update(%Listener{
          load_balancer_arn: lb_arn,
          protocol: "HTTP",
          port: 80,
          default_actions: [%{type: "forward", target_group_arn: tg_arn}]
        })

      assert {:ok, %Listener{listener_arn: ^arn}} = Listeners.get(arn: arn)
    end
  end

  describe "insert_or_update/1" do
    test "given a non-existent listener, it creates one", %{default_aws_vpc: vpc} do
      {:ok, %LoadBalancer{load_balancer_arn: lb_arn}} =
        LoadBalancers.create(
          %{
            load_balancer_name: Faker.Person.name(),
            scheme: "internet-facing",
            subnets: [vpc.subnet.id],
            security_groups: [vpc.security_group.id]
          }
        )

      {:ok, %TargetGroup{target_group_arn: tg_arn}} =
        TargetGroups.insert_or_update(%TargetGroup{
          target_group_name: Faker.Person.first_name(),
          vpc_id: vpc.id
        })

      assert {:ok, %Listener{listener_arn: _arn, load_balancer_arn: ^lb_arn}} =
               Listeners.insert_or_update(%Listener{
                 load_balancer_arn: lb_arn,
                 protocol: "HTTP",
                 port: "80",
                 default_actions: [
                   %Action{
                     type: "forward",
                     target_group_arn: tg_arn
                   }
                 ]
               })
    end

    test "given a non-existent listener, even with an arn provided it fails", %{
      default_aws_vpc: vpc
    } do
      {:ok, %LoadBalancer{load_balancer_arn: lb_arn}} =
        LoadBalancers.create(
          %{
            load_balancer_name: Faker.Person.name(),
            scheme: "internet-facing",
            subnets: [vpc.subnet.id],
            security_groups: [vpc.security_group.id]
          }
        )

      {:ok, %TargetGroup{target_group_arn: tg_arn}} =
        TargetGroups.insert_or_update(%TargetGroup{
          target_group_name: Faker.Person.first_name(),
          vpc_id: vpc.id
        })

      assert {:error, :resource_not_found} =
               Listeners.insert_or_update(%Listener{
                 listener_arn: "not_there",
                 load_balancer_arn: lb_arn,
                 protocol: "HTTP",
                 port: "80",
                 default_actions: [
                   %Action{
                     type: "forward",
                     target_group_arn: tg_arn
                   }
                 ]
               })
    end

    test "given an existing listener, with an arn provided it updates the listener", %{
      default_aws_vpc: vpc
    } do
      {:ok, %LoadBalancer{load_balancer_arn: lb_arn}} =
        LoadBalancers.create(
          %{
            load_balancer_name: Faker.Person.name(),
            scheme: "internet-facing",
            subnets: [vpc.subnet.id],
            security_groups: [vpc.security_group.id]
          }
        )

      {:ok, %TargetGroup{target_group_arn: tg_arn}} =
        TargetGroups.insert_or_update(%TargetGroup{
          target_group_name: Faker.Person.first_name(),
          vpc_id: vpc.id
        })

      {:ok, %{listener_arn: arn}} =
        Listeners.insert_or_update(%Listener{
          load_balancer_arn: lb_arn,
          protocol: "HTTP",
          port: 80,
          default_actions: [%{type: "forward", target_group_arn: tg_arn}]
        })

      %{"CertificateArn" => certificate_arn} =
        ExAws.ACM.request_certificate("helloworld.example.com", validation_method: "DNS")
        |> ExAws.request!()

      assert {:ok, %Listener{listener_arn: ^arn, port: 81, protocol: "HTTPS"}} =
               Listeners.insert_or_update(%Listener{
                 listener_arn: arn,
                 load_balancer_arn: lb_arn,
                 protocol: "HTTPS",
                 certificates: [%Certificate{certificate_arn: certificate_arn, is_default: true}],
                 ssl_policy: "ELBSecurityPolicy-TLS-1-2-2017-01",
                 port: 81,
                 default_actions: [
                   %Action{
                     type: "forward",
                     target_group_arn: tg_arn
                   }
                 ]
               })
    end
  end

  describe "delete/1" do
    test "given a listener that exists, deletes it", %{default_aws_vpc: vpc} do
      {:ok, %LoadBalancer{load_balancer_arn: lb_arn}} =
        LoadBalancers.create(
          %{
            load_balancer_name: Faker.Person.name(),
            scheme: "internet-facing",
            subnets: [vpc.subnet.id],
            security_groups: [vpc.security_group.id]
          }
        )

      {:ok, %TargetGroup{target_group_arn: tg_arn}} =
        TargetGroups.insert_or_update(%TargetGroup{
          target_group_name: Faker.Person.first_name(),
          vpc_id: vpc.id
        })

      {:ok, %{listener_arn: arn}} =
        Listeners.insert_or_update(%Listener{
          load_balancer_arn: lb_arn,
          protocol: "HTTP",
          port: 80,
          default_actions: [%{type: "forward", target_group_arn: tg_arn}]
        })

      assert :ok =
               Listeners.delete(%Listener{
                 listener_arn: arn
               })

      assert {:ok, []} == Listeners.list(load_balancer_arn: lb_arn)
    end
  end
end
