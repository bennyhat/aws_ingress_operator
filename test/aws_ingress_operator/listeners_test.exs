defmodule AwsIngressOperator.ListenersTest do
  @moduledoc false
  use ExUnit.Case
  import SweetXml
  use AwsIngressOperator.Test.Support.MotoCase, url: "http://localhost:5000"

  alias AwsIngressOperator.LoadBalancers
  alias AwsIngressOperator.Listeners
  alias AwsIngressOperator.Schemas.Listener

  describe "list/0" do
    test "given some listeners, returns list of them", %{default_aws_vpc: vpc} do
      {:ok, load_balancer} = LoadBalancers.create(
        name: Faker.Person.name(),
        schema: "internet-facing",
        subnets: [vpc.subnet.id],
        security_groups: [vpc.security_group.id]
      )

      [target_group_arn] = ExAws.ElasticLoadBalancingV2.create_target_group(
        Faker.Person.first_name(),
        vpc.id
      )
      |> ExAws.request!()
      |> Map.get(:body)
      |> SweetXml.xpath(~x"//TargetGroupArn/text()"ls)

      lb_arn = load_balancer.load_balancer_arn
      ExAws.ElasticLoadBalancingV2.create_listener(
        lb_arn,
        "HTTP",
        80,
        [%{type: "forward", target_group_arn: target_group_arn}]
      )
      |> ExAws.request!()

      assert {:ok, [
        %Listener{
          load_balancer_arn: ^lb_arn
        }
      ]} = Listeners.list(load_balancer_arn: lb_arn)
    end

  end

  describe "list/1" do
  end
  describe "get/1" do
  end
  describe "create/1" do
  end
  describe "delete/1" do
  end
end