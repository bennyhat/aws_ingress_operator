defmodule AwsIngressOperator.Schemas.PrefixListId do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field(:prefix_list_id, :string)
    field(:description, :string)
  end

  @cast_fields [
    :prefix_list_id,
    :description
  ]

  use Accessible

  def changeset(changes), do: changeset(%__MODULE__{}, changes)

  def changeset(original, changes) do
    original
    |> cast(changes, @cast_fields)
  end
end

defmodule AwsIngressOperator.Schemas.Ipv6Range do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field(:cidr_ipv6, :string)
    field(:description, :string)
  end

  @cast_fields [
    :cidr_ipv6,
    :description
  ]

  use Accessible

  def changeset(changes), do: changeset(%__MODULE__{}, changes)

  def changeset(original, changes) do
    original
    |> cast(changes, @cast_fields)
  end
end

defmodule AwsIngressOperator.Schemas.IpRange do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field(:cidr_ip, :string)
    field(:description, :string)
  end

  @cast_fields [
    :cidr_ip,
    :description
  ]

  use Accessible

  def changeset(changes), do: changeset(%__MODULE__{}, changes)

  def changeset(original, changes) do
    original
    |> cast(changes, @cast_fields)
  end
end

defmodule AwsIngressOperator.Schemas.UserIdGroupPair do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field(:description, :string)
    field(:group_id, :string)
    field(:group_name, :string)
    field(:peering_status, :string)
    field(:user_id, :string)
    field(:vpc_id, :string)
  end

  @cast_fields [
    :description,
    :group_id,
    :group_name,
    :peering_status,
    :user_id,
    :vpc_id,
  ]

  use Accessible

  def changeset(changes), do: changeset(%__MODULE__{}, changes)

  def changeset(original, changes) do
    original
    |> cast(changes, @cast_fields)
  end
end

defmodule AwsIngressOperator.Schemas.Tag do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field(:key, :string)
    field(:value, :string)
  end

  @cast_fields [
    :key,
    :value
  ]

  use Accessible

  def changeset(changes), do: changeset(%__MODULE__{}, changes)

  def changeset(original, changes) do
    original
    |> cast(changes, @cast_fields)
  end
end

defmodule AwsIngressOperator.Schemas.IpPermission do
  use Ecto.Schema
  import Ecto.Changeset

  alias AwsIngressOperator.Schemas.UserIdGroupPair
  alias AwsIngressOperator.Schemas.IpRange
  alias AwsIngressOperator.Schemas.Ipv6Range
  alias AwsIngressOperator.Schemas.PrefixListId

  embedded_schema do
    field(:from_port, :integer)
    field(:to_port, :string)
    field(:ip_protocol, :string)

    embeds_many(:groups, UserIdGroupPair)
    embeds_many(:ip_ranges, IpRange)
    embeds_many(:ipv6_ranges, Ipv6Range)
    embeds_many(:prefix_list_ids, PrefixListId)
  end

  @cast_fields [
    :from_port,
    :to_port,
    :ip_protocol
  ]

  use Accessible

  def changeset(changes), do: changeset(%__MODULE__{}, changes)

  def changeset(original, changes) do
    original
    |> cast(changes, @cast_fields)
    |> cast_embed(:groups)
    |> cast_embed(:ip_ranges)
    |> cast_embed(:ipv6_ranges)
    |> cast_embed(:prefix_list_ids)
  end
end
defmodule AwsIngressOperator.Schemas.SecurityGroup do
  use Ecto.Schema
  import Ecto.Changeset

  alias AwsIngressOperator.Schemas.IpPermission
  alias AwsIngressOperator.Schemas.Tag

  embedded_schema do field(:group_description, :string)
    field(:group_id, :string)
    field(:group_name, :string)
    field(:owner_id, :string)
    field(:vpc_id, :string)

    embeds_many(:ip_permissions, IpPermission)
    embeds_many(:ip_permissions_egress, IpPermission)
    embeds_many(:tag_set, Tag)
  end

  @cast_fields [
    :group_description,
    :group_id,
    :group_name,
    :owner_id,
    :vpc_id
  ]

  use Accessible

  def changeset(changes), do: changeset(%__MODULE__{}, changes)

  def changeset(original, changes) do
    original
    |> cast(changes, @cast_fields)
    |> cast_embed(:ip_permissions)
    |> cast_embed(:ip_permissions_egress)
    |> cast_embed(:tag_set)
  end
end
