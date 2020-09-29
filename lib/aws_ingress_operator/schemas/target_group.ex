defmodule AwsIngressOperator.Schemas.TargetGroup.Tuple do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :target_group_arn, :string
    field :weight, :integer
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
    field :duration_seconds, :integer
    field :enabled, :boolean
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
