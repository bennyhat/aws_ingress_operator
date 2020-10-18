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

  @primary_key false
  embedded_schema do
    field(:http_code, :string)
  end

  @cast_fields [
    :http_code
  ]

  use Accessible

  def changeset(changes), do: changeset(%__MODULE__{}, changes)

  def changeset(original, %_struct{} = changes),
    do: write_changeset(original, Map.from_struct(changes))

  def changeset(original, changes) do
    changes = Map.update(changes, :http_code, nil, &to_string/1)

    original
    |> cast(changes, @cast_fields)
  end

  def write_changeset(original, changes) do
    changeset(original, changes)
    |> validate_code_interval(:http_code)
  end

  def validate_code_interval(changeset, field, options \\ []) do
    validate_change(changeset, field, fn _field_name, code_string ->
      case invalid_codes(code_string) do
        [] ->
          []

        invalid ->
          [
            {field,
             options[:message] ||
               "Field #{inspect(field)} has codes that are not in the range of 200-499: #{
                 Enum.join(invalid, ",")
               }"}
          ]
      end
    end)
  end

  defp invalid_codes(code_string) do
    String.split(code_string, ",")
    |> Enum.map(fn range ->
      with [x, y] <- String.split(range, "-"),
           {x_int, ""} <- Integer.parse(x),
           {y_int, ""} <- Integer.parse(y) do
        Range.new(x_int, y_int)
      else
        _ -> range
      end
    end)
    |> List.flatten()
    |> Enum.reject(fn
      x..y ->
        x in 200..499 and y in 200..499

      code when is_binary(code) ->
        case Integer.parse(code) do
          {int, ""} -> int in 200..499
          _ -> false
        end

      code ->
        code in 200..499
    end)
  end
end

defmodule AwsIngressOperator.Schemas.TargetGroup do
  use Ecto.Schema
  import Ecto.Changeset

  alias AwsIngressOperator.Schemas.Matcher
  import AwsIngressOperator.Schemas.Validations

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

  def changeset(original, %_struct{} = changes),
    do: write_changeset(original, Map.from_struct(changes))

  def changeset(original, changes) do
    changes = Map.update(changes, :health_check_port, nil, &to_string/1)

    original
    |> cast(changes, @cast_fields)
    |> cast_embed(:matcher)
  end

  def write_changeset(original, changes) do
    changeset(original, changes)
    |> validate_inclusion(:health_check_interval_seconds, 5..300)
    |> validate_length(:health_check_path, min: 1, max: 1024)
    |> validate_inclusion(:health_check_protocol, protocols())
    |> validate_inclusion(:health_check_timeout_seconds, 2..120)
    |> validate_inclusion(:healthy_threshold_count, 2..10)
    |> validate_inclusion(:port, protocols())
    |> validate_inclusion(:protocol, protocols())
    |> validate_inclusion(:target_type, ["instance", "ip", "lambda"])
    |> validate_inclusion(:unhealthy_threshold_count, 2..10)
    |> validate_aws_resource_exists(:vpc_id)
  end
end
