defmodule AwsIngressOperator.Test.Support.MotoCase do
  @moduledoc """
  This module defines the setup for tests requiring a fake AWS API.

  It will create a default VPC and subnet and provide these in the test context. It will also alias the Moto.TestHelper module as Moto for use in tests.

  Additionally, it will reset moto's inventory after every test run.

  You may define functions here to be used as helpers in your tests.
  """

  use ExUnit.CaseTemplate
  import SweetXml

  alias AwsIngressOperator.Addresses
  alias AwsIngressOperator.Listeners
  alias AwsIngressOperator.LoadBalancers
  alias AwsIngressOperator.TargetGroups

  alias AwsIngressOperator.Schemas.Address
  alias AwsIngressOperator.Schemas.Listener
  alias AwsIngressOperator.Schemas.LoadBalancer
  alias AwsIngressOperator.Schemas.TargetGroup

  using opts do
    url = Keyword.get(opts, :url)

    quote do
      import AwsIngressOperator.Test.Support.MotoCase

      @moduletag moto_url: unquote(url)
    end
  end

  setup tags do
    url = Map.get(tags, :moto_url)

    reset(url)
    on_exit(fn -> reset(url) end)

    {vpc_id, subnet_id, security_group_id, elastic_ip_allocation_id, random_address} =
      default_network_details()

    [
      default_aws_vpc: %{
        id: vpc_id,
        subnet: %{
          id: subnet_id,
          random_address: random_address
        },
        security_group: %{
          id: security_group_id
        },
        eip: %{
          id: elastic_ip_allocation_id
        }
      }
    ]
  end

  def default_network_details(az \\ "us-east-1a") do
    [
      %{
        subnet_id: subnet_id,
        vpc_id: vpc_id,
        cidr_block: cidr_block
      }
    ] =
      ExAws.EC2.describe_subnets(filters: ["availability-zone": [az]])
      |> ExAws.request!()
      |> Map.get(:body)
      |> SweetXml.xpath(
        ~x"/DescribeSubnetsResponse/subnetSet/item"l,
        subnet_id: ~x"./subnetId/text()"s,
        vpc_id: ~x"./vpcId/text()"s,
        cidr_block: ~x"./cidrBlock/text()"s
      )

    [
      %{
        group_id: security_group_id
      }
    ] =
      ExAws.EC2.describe_security_groups(filters: ["vpc-id": [vpc_id]])
      |> ExAws.request!()
      |> Map.get(:body)
      |> SweetXml.xpath(
        ~x"/DescribeSecurityGroupsResponse/securityGroupInfo/item"l,
        group_id: ~x"./groupId/text()"s
      )

    {:ok,
     %Address{
       allocation_id: elastic_ip_allocation_id
     }} = Addresses.create(%Address{domain: "vpc"})

    random_address = random_address_in_block(cidr_block)

    {vpc_id, subnet_id, security_group_id, elastic_ip_allocation_id, random_address}
  end

  defp random_address_in_block(cidr_block) do
    as_netaddr = NetAddr.ip(cidr_block)

    first =
      as_netaddr
      |> NetAddr.first_address()
      |> Map.get(:address)
      |> NetAddr.aton()

    last =
      as_netaddr
      |> NetAddr.last_address()
      |> Map.get(:address)
      |> NetAddr.aton()

    where = Enum.random(Range.new(first + 1, last - 1))

    where
    |> NetAddr.ntoa(4)
    |> NetAddr.netaddr()
    |> NetAddr.address()
  end

  def reset(url) do
    Tesla.post("#{url}/moto-api/reset", "")
  end

  def create_load_balancer!(vpc) do
    {:ok, %LoadBalancer{load_balancer_arn: arn, load_balancer_name: name}} =
      LoadBalancers.create(%LoadBalancer{
        load_balancer_name: Faker.Person.first_name(),
        scheme: "internal",
        subnets: [vpc.subnet.id],
        security_groups: [vpc.security_group.id]
      })

    {arn, name}
  end

  def create_target_group!(vpc) do
    name = Faker.Person.first_name()

    {:ok, %TargetGroup{target_group_arn: arn}} =
      TargetGroups.insert_or_update(%TargetGroup{
        target_group_name: name,
        vpc_id: vpc.id
      })

    {arn, name}
  end

  def create_listener!(lb_arn, tg_arn) do
    {:ok, %{listener_arn: arn}} =
      Listeners.insert_or_update(%Listener{
        load_balancer_arn: lb_arn,
        protocol: "HTTP",
        port: 80,
        default_actions: [%{type: "forward", target_group_arn: tg_arn}]
      })

    arn
  end
end
