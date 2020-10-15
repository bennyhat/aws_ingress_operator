defmodule AwsIngressOperator.Schemas.SubnetCidrBlockState do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field(:state, :string)
    field(:status_message, :string)
  end

  @cast_fields [
    :state,
    :status_message
  ]

  use Accessible

  def changeset(changes), do: changeset(%__MODULE__{}, changes)

  def changeset(original, changes) do
    original
    |> cast(changes, @cast_fields)
  end
end

defmodule AwsIngressOperator.Schemas.SubnetIpv6CidrBlockAssociation do
  use Ecto.Schema
  import Ecto.Changeset

  alias AwsIngressOperator.Schemas.SubnetCidrBlockState

  embedded_schema do
    field(:association_id, :string)
    field(:ipv6_cidr_block, :string)

    embeds_one(:ipv6_cidr_block_state, SubnetCidrBlockState)
  end

  @cast_fields [
    :association_id,
    :ipv6_cidr_block
  ]

  use Accessible

  def changeset(changes), do: changeset(%__MODULE__{}, changes)

  def changeset(original, changes) do
    original
    |> cast(changes, @cast_fields)
    |> cast_embed(:ipv6_cidr_block_state)
  end
end

defmodule AwsIngressOperator.Schemas.Subnet do
  use Ecto.Schema
  import Ecto.Changeset

  alias AwsIngressOperator.Schemas.SubnetIpv6CidrBlockAssociation
  alias AwsIngressOperator.Schemas.Tag

  embedded_schema do
    field(:assign_ipv6_address_on_creation, :boolean)
    field(:availability_zone, :string)
    field(:availability_zone_id, :string)
    field(:available_ip_address_count, :integer)
    field(:cidr_block, :string)
    field(:customer_owned_ipv4_pool, :string)
    field(:default_for_az, :boolean)
    field(:map_public_ip_on_launch, :boolean)
    field(:map_customer_owned_ip_on_launch, :boolean)
    field(:outpost_arn, :string)
    field(:owner_id, :string)
    field(:state, :string)
    field(:subnet_arn, :string)
    field(:subnet_id, :string)
    field(:vpc_id, :string)

    embeds_many(:tag_set, Tag)
    embeds_many(:ipv6_cidr_block_association_set, SubnetIpv6CidrBlockAssociation)
  end

  @cast_fields [
    :assign_ipv6_address_on_creation,
    :availability_zone,
    :availability_zone_id,
    :available_ip_address_count,
    :cidr_block,
    :customer_owned_ipv4_pool,
    :default_for_az,
    :map_public_ip_on_launch,
    :map_customer_owned_ip_on_launch,
    :outpost_arn,
    :owner_id,
    :state,
    :subnet_arn,
    :subnet_id,
    :vpc_id
  ]

  use Accessible

  def changeset(changes), do: changeset(%__MODULE__{}, changes)

  def changeset(original, changes) do
    original
    |> cast(changes, @cast_fields)
    |> cast_embed(:ipv6_cidr_block_association_set)
    |> cast_embed(:tag_set)
  end
end
