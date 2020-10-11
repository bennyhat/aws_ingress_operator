defmodule AwsIngressOperator.Schemas.AvailabilityZone do
  use Ecto.Schema
  import Ecto.Changeset

  alias AwsIngressOperator.Schemas.Address

  @primary_key {:zone_name, :string, autogenerate: false}
  embedded_schema do
    field(:subnet_id, :string)
    embeds_many(:load_balancer_addresses, Address)
  end

  use Accessible

  @cast_fields [
    :zone_name,
    :subnet_id
  ]

  def changeset(changes), do: changeset(%__MODULE__{}, changes)

  def changeset(original, changes) do
    original
    |> cast(changes, @cast_fields)
    |> cast_embed(:load_balancer_addresses)
  end
end

defmodule AwsIngressOperator.Schemas.Address do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:allocation_id, :string, autogenerate: false}
  embedded_schema do
    field(:ip_address, :string)
    field(:private_ipv4_address, :string)
  end

  use Accessible

  @cast_fields [
    :allocation_id,
    :ip_address,
    :private_ipv4_address
  ]

  def changeset(changes), do: changeset(%__MODULE__{}, changes)

  def changeset(original, changes) do
    original
    |> cast(changes, @cast_fields)
  end
end

defmodule AwsIngressOperator.Schemas.State do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:code, :string, autogenerate: false}
  embedded_schema do
    field(:reason, :string)
  end

  use Accessible

  @cast_fields [
    :code,
    :reason
  ]

  def changeset(changes), do: changeset(%__MODULE__{}, changes)

  def changeset(original, changes) do
    original
    |> cast(changes, @cast_fields)
  end
end

defmodule AwsIngressOperator.Schemas.LoadBalancer do
  use Ecto.Schema
  import Ecto.Changeset

  alias AwsIngressOperator.Schemas.AvailabilityZone
  alias AwsIngressOperator.Schemas.Listener
  alias AwsIngressOperator.Schemas.State

  @primary_key {:load_balancer_arn, :string, autogenerate: false}
  embedded_schema do
    field(:load_balancer_name, :string)
    field(:canonical_hosted_zone_id, :string)
    field(:created_time, :utc_datetime)
    field(:dns_name, :string)
    field(:ip_address_type, :string)
    field(:scheme, :string)
    field(:type, :string)
    field(:vpc_id, :string)
    field(:security_groups, {:array, :string})
    field(:subnets, {:array, :string})

    embeds_one(:state, State)
    embeds_many(:availability_zones, AvailabilityZone)
    embeds_many(:listeners, Listener)
  end

  @cast_fields [
    :load_balancer_arn,
    :load_balancer_name,
    :canonical_hosted_zone_id,
    :created_time,
    :dns_name,
    :ip_address_type,
    :scheme,
    :type,
    :vpc_id,
    :security_groups,
    :subnets
  ]

  use Accessible

  def changeset(changes), do: changeset(%__MODULE__{}, changes)

  def changeset(original, changes) do
    original
    |> cast(changes, @cast_fields)
    |> cast_embed(:availability_zones)
    |> cast_embed(:state)
  end
end
