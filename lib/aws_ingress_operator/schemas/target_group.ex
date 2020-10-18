defmodule AwsIngressOperator.Schemas.TargetGroup.Tuple do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field(:target_group_arn, :string)
    field(:weight, :integer)
  end

  @cast_fields [
    :target_group_arn,
    :weight
  ]

  use Accessible

  def changeset(changes), do: changeset(%__MODULE__{}, changes)

  def changeset(original, changes) do
    original
    |> cast(changes, @cast_fields)
  end
end

defmodule AwsIngressOperator.Schemas.TargetGroup.StickinessConfig do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field(:duration_seconds, :integer)
    field(:enabled, :boolean)
  end

  @cast_fields [
    :duration_seconds,
    :integer
  ]

  use Accessible

  def changeset(changes), do: changeset(%__MODULE__{}, changes)

  def changeset(original, changes) do
    original
    |> cast(changes, @cast_fields)
  end
end

defmodule AwsIngressOperator.Schemas.Matcher do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field(:http_code, :string)
  end

  @cast_fields [
    :http_code
  ]

  use Accessible

  def changeset(changes), do: changeset(%__MODULE__{}, changes)

  def changeset(original, changes) do
    changes = Map.update(changes, :http_code, nil, &to_string/1)

    original
    |> cast(changes, @cast_fields)
  end
end

defmodule AwsIngressOperator.Schemas.TargetGroup do
  use Ecto.Schema
  import Ecto.Changeset

  alias AwsIngressOperator.Schemas.Matcher

  @primary_key {:target_group_arn, :string, autogenerate: false}
  embedded_schema do
    field(:health_check_enabled, :boolean)
    field(:health_check_interval_seconds, :integer)
    field(:health_check_path, :string)
    field(:health_check_port, :string)
    field(:health_check_protocol, :string)
    field(:health_check_timeout_seconds, :integer)
    field(:healthy_threshold_count, :integer)
    field(:load_balancer_arns, {:array, :string})
    field(:port, :integer)
    field(:protocol, :string)
    field(:target_group_name, :string)
    field(:name, :string)
    field(:target_type, :string)
    field(:unhealthy_threshold_count, :integer)
    field(:vpc_id, :string)

    embeds_one(:matcher, Matcher)
  end

  @cast_fields [
    :health_check_enabled,
    :health_check_interval_seconds,
    :health_check_path,
    :health_check_port,
    :health_check_protocol,
    :health_check_timeout_seconds,
    :healthy_threshold_count,
    :load_balancer_arns,
    :port,
    :protocol,
    :target_group_arn,
    :target_group_name,
    :name,
    :target_type,
    :unhealthy_threshold_count,
    :vpc_id
  ]

  use Accessible

  def changeset(changes), do: changeset(%__MODULE__{}, changes)
  def changeset(original, %_struct{} = changes), do: write_changeset(original, Map.from_struct(changes))

  def changeset(original, changes) do
    changes = Map.update(changes, :health_check_port, nil, &to_string/1)

    original
    |> cast(changes, @cast_fields)
    |> cast_embed(:matcher)
  end

  @protocols [
    "HTTP",
    "HTTPS",
    "TCP",
    "TLS",
    "UDP",
    "TCP_UDP"
  ]
  def write_changeset(original, changes) do
    changeset(original, changes)
    |> validate_inclusion(:health_check_interval_seconds, 5..300)
    |> validate_length(:health_check_path, min: 1, max: 1024)
    |> validate_inclusion(:health_check_protocol, @protocols)
    |> validate_inclusion(:health_check_timeout_seconds, 2..120)
    |> validate_inclusion(:healthy_threshold_count, 2..10)
    |> validate_inclusion(:port, 1..65535)
    |> validate_inclusion(:protocol, @protocols)
    |> validate_inclusion(:target_type, ["instance", "ip", "lambda"])
    |> validate_inclusion(:unhealthy_threshold_count, 2..10)
  end
end
