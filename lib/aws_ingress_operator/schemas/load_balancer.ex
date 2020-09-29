defmodule AwsIngressOperator.Schemas.AvailabilityZone do
  use Ecto.Schema
  import Ecto.Changeset

  alias AwsIngressOperator.Schemas.Address

  @primary_key {:zone_name, :string, autogenerate: false}
  embedded_schema do
    field :subnet_id, :string
    embeds_many :load_balancer_addresses, Address
  end

  use Accessible
end

defmodule AwsIngressOperator.Schemas.Address do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:allocation_id, :string, autogenerate: false}
  embedded_schema do
    field :ip_address, :string
    field :private_ipv4_address, :string
  end

  use Accessible
end

defmodule AwsIngressOperator.Schemas.State do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:code, :string, autogenerate: false}
  embedded_schema do
    field :reason, :string
  end

  use Accessible
end

defmodule AwsIngressOperator.Schemas.LoadBalancer do
  use Ecto.Schema
  import Ecto.Changeset

  alias AwsIngressOperator.Schemas.AvailabilityZone
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

    embeds_one(:state, State)
    embeds_many(:availability_zones, AvailabilityZone)
    embeds_many(:security_groups, :string)
  end

  use Accessible

  def changeset(changes), do: changeset(%__MODULE__{}, changes)
  def changeset(original, changes) do
    original
    |> cast(changes, [:load_balancer_arn, :load_balancer_name])
  end
end
