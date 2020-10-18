defmodule AwsIngressOperator.AddressesTest do
  @moduledoc false
  use ExUnit.Case
  use AwsIngressOperator.Test.Support.MotoCase, url: "http://localhost:5000"

  alias AwsIngressOperator.Addresses
  alias AwsIngressOperator.Schemas.Address

  describe "list/1" do
    test "given the default address created by the test case, returns it" do
      assert {:ok, [%Address{}]} = Addresses.list()
    end

    test "given an address allocation, returns it by id" do
      {:ok, %Address{allocation_id: id}} = Addresses.create(%Address{domain: "vpc"})

      Addresses.create(%Address{domain: "vpc"})

      assert {:ok, [%Address{allocation_id: ^id}]} = Addresses.list(allocation_id: id)
    end

    test "given some addresses, returns list of them by filter (including one created as part of moto)" do
      Addresses.create(%Address{domain: "vpc"})
      Addresses.create(%Address{domain: "vpc"})

      assert {:ok, addresses} = Addresses.list(filter: [%{name: "domain", value: "vpc"}])

      assert 2 == length(addresses)
    end
  end

  describe "get/1" do
    test "given some addresses, returns one by id" do
      {:ok, %Address{allocation_id: id}} = Addresses.create(%Address{domain: "vpc"})

      Addresses.create(%Address{domain: "vpc"})

      assert {:ok, %Address{allocation_id: ^id}} = Addresses.get(id: id)
    end

    test "does not blow up when subnet id doesn't exist" do
      assert {:error, _} = Addresses.get(id: "cannot-exist")
    end
  end

  describe "create/1" do
    test "creates a new address allocation" do
      {:ok, %Address{allocation_id: id, public_ip: address, domain: "vpc"}} = Addresses.create(%Address{domain: "vpc"})

      assert is_binary(id)
      assert is_binary(address)
    end
  end
end
