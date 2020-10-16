defmodule AwsIngressOperator.SecurityGroupsTest do
  @moduledoc false
  use ExUnit.Case
  import SweetXml
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

    test "given some security groups, returns list of them by id" do
      name = Faker.Person.first_name()
      description = Faker.Person.first_name()

      id =
        ExAws.EC2.create_security_group(name, description)
        |> ExAws.request!()
        |> Map.get(:body)
        |> SweetXml.xpath(~x"//groupId/text()"s)

      assert {:ok, [%SecurityGroup{group_id: ^id}]} = SecurityGroups.list(group_id: id)
    end

    test "given some security groups, returns list of them by name" do
      name = Faker.Person.first_name()
      description = Faker.Person.first_name()

      ExAws.EC2.create_security_group(name, description)
      |> ExAws.request!()

      assert {:ok, [%SecurityGroup{group_name: ^name}]} = SecurityGroups.list(group_name: name)
    end

    test "given some security groups, returns list of them by filter" do
      name = Faker.Person.first_name()
      description = Faker.Person.first_name()

      ExAws.EC2.create_security_group(name, description)
      |> ExAws.request!()

      assert {:ok, [%SecurityGroup{group_name: ^name}]} =
               SecurityGroups.list(filter: [%{name: "description", value: description}])
    end
  end

  describe "get/1" do
    test "given some security groups, returns one by id" do
      name = Faker.Person.first_name()
      description = Faker.Person.first_name()

      id =
        ExAws.EC2.create_security_group(name, description)
        |> ExAws.request!()
        |> Map.get(:body)
        |> SweetXml.xpath(~x"//groupId/text()"s)

      assert {:ok, %SecurityGroup{group_id: ^id}} = SecurityGroups.get(group_id: id)
    end

    test "given some security groups, returns one by name" do
      name = Faker.Person.first_name()
      description = Faker.Person.first_name()

      id =
        ExAws.EC2.create_security_group(name, description)
        |> ExAws.request!()
        |> Map.get(:body)
        |> SweetXml.xpath(~x"//groupId/text()"s)

      assert {:ok, %SecurityGroup{group_id: ^id}} = SecurityGroups.get(group_name: name)
    end

    test "does not blow up when security group doesn't exist" do
      assert {:error, _} = SecurityGroups.get(id: "cannot-exist")
    end
  end
end
