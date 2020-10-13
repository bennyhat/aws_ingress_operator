defmodule AwsIngressOperator.Schemas.Certificate do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:certificate_arn, :string, autogenerate: false}
  embedded_schema do
    field :is_default, :boolean
  end

  @cast_fields [
    :certificate_arn,
    :is_default
  ]

  use Accessible

  def changeset(changes), do: changeset(%__MODULE__{}, changes)
  def changeset(original, changes) do
    original
    |> cast(changes, @cast_fields)
  end
end

defmodule AwsIngressOperator.Schemas.KeyValuePair do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :key, :string
    field :value, :string
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

defmodule AwsIngressOperator.Schemas.Action.AuthenticateCognitoConfig do
  use Ecto.Schema
  import Ecto.Changeset

  alias AwsIngressOperator.Schemas.KeyValuePair

  embedded_schema do
    field :on_unauthenticated_request, :string
    field :scope, :string
    field :session_cookie_name, :string
    field :session_timeout, :integer
    field :user_pool_arn, :string
    field :user_pool_client_id, :string
    field :user_pool_domain, :string

    embeds_many :authenticate_request_extra_params, KeyValuePair
  end

  @cast_fields [
    :on_unauthenticated_request,
    :scope,
    :session_cookie_name,
    :session_timeout,
    :user_pool_arn,
    :user_pool_client_id,
    :user_pool_domain
  ]

  use Accessible

  def changeset(changes), do: changeset(%__MODULE__{}, changes)
  def changeset(original, changes) do
    original
    |> cast(changes, @cast_fields)
    |> cast_embed(:authenticate_request_extra_params)
  end
end

defmodule AwsIngressOperator.Schemas.Action.AuthenticateOidcConfig do
  use Ecto.Schema
  import Ecto.Changeset

  alias AwsIngressOperator.Schemas.KeyValuePair

  embedded_schema do
    field :authorization_endpoint, :string
    field :client_id, :string
    field :client_secret, :string
    field :issuer, :string
    field :on_unauthenticated_request, :string
    field :scope, :string
    field :session_cookie_name, :string
    field :session_timeout, :integer
    field :token_endpoint, :string
    field :use_existing_client_secret, :boolean
    field :user_info_endpoint, :string

    embeds_many :authenticate_request_extra_params, KeyValuePair
  end

  @cast_fields [
    :authorization_endpoint,
    :client_id,
    :client_secret,
    :issuer,
    :on_unauthenticated_request,
    :scope,
    :session_cookie_name,
    :session_timeout,
    :token_endpoint,
    :use_existing_client_secret,
    :user_info_endpoint,
  ]

  use Accessible

  def changeset(changes), do: changeset(%__MODULE__{}, changes)
  def changeset(original, changes) do
    original
    |> cast(changes, @cast_fields)
    |> cast_embed(:authenticate_request_extra_params)
  end
end

defmodule AwsIngressOperator.Schemas.Action.FixedResponseConfig do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :content_type, :string
    field :message_body, :string
    field :status_code, :string
  end

  @cast_fields [
    :content_type,
    :message_body,
    :status_code
  ]

  use Accessible

  def changeset(changes), do: changeset(%__MODULE__{}, changes)
  def changeset(original, changes) do
    original
    |> cast(changes, @cast_fields)
  end
end

defmodule AwsIngressOperator.Schemas.Action.ForwardConfig do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    embeds_many :target_groups, TargetGroup.Tuple
    embeds_one :target_group_stickiness_config, TargetGroup.StickinessConfig
  end

  @cast_fields []

  use Accessible

  def changeset(changes), do: changeset(%__MODULE__{}, changes)
  def changeset(original, changes) do
    original
    |> cast(changes, @cast_fields)
    |> cast_embed(:target_groups)
    |> cast_embed(:target_group_stickiness_config)
  end
end

defmodule AwsIngressOperator.Schemas.Action.RedirectConfig do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :host, :string
    field :path, :string
    field :port, :string
    field :protocol, :string
    field :query, :string
    field :status_code, :string
  end

  @cast_fields [
    :host,
    :path,
    :port,
    :protocol,
    :query,
    :status_code,
  ]

  use Accessible

  def changeset(changes), do: changeset(%__MODULE__{}, changes)
  def changeset(original, changes) do
    original
    |> cast(changes, @cast_fields)
  end
end

defmodule AwsIngressOperator.Schemas.Action do
  use Ecto.Schema
  import Ecto.Changeset

  alias AwsIngressOperator.Schemas.Action.AuthenticateCognitoConfig
  alias AwsIngressOperator.Schemas.Action.AuthenticateOidcConfig
  alias AwsIngressOperator.Schemas.Action.FixedResponseConfig
  alias AwsIngressOperator.Schemas.Action.ForwardConfig
  alias AwsIngressOperator.Schemas.Action.RedirectConfig

  embedded_schema do
    field :order, :integer
    field :target_group_arn, :string
    field :type, :string

    embeds_one :authenticate_cognito_config, AuthenticateCognitoConfig
    embeds_one :authenticate_oidc_config, AuthenticateOidcConfig
    embeds_one :fixed_response_config, FixedResponseConfig
    embeds_one :forward_config, ForwardConfig
    embeds_one :redirect_config, RedirectConfig
  end

  @cast_fields [
    :order,
    :target_group_arn,
    :type
  ]

  use Accessible

  def changeset(changes), do: changeset(%__MODULE__{}, changes)
  def changeset(original, changes) do
    original
    |> cast(changes, @cast_fields)
  end
end

defmodule AwsIngressOperator.Schemas.Listener do
  use Ecto.Schema
  import Ecto.Changeset

  alias AwsIngressOperator.Schemas.Certificate
  alias AwsIngressOperator.Schemas.Action

  @primary_key {:listener_arn, :string, autogenerate: false}
  embedded_schema do
    embeds_many :certificates, Certificate
    embeds_many :default_actions, Action

    field :port, :integer
    field :protocol, :string
    field :ssl_policy, :string
    field :load_balancer_arn, :string
  end

  @cast_fields [
    :listener_arn,
    :port,
    :protocol,
    :ssl_policy,
    :load_balancer_arn
  ]

  use Accessible

  def changeset(changes), do: changeset(%__MODULE__{}, changes)
  def changeset(original, changes) do
    original
    |> cast(changes, @cast_fields)
    |> cast_embed(:certificates)
    |> cast_embed(:default_actions)
  end
end
