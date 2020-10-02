defmodule AwsIngressOperator.Listeners do
  @moduledoc """
  A repository pattern wrapper for a Listener inventory
  """
  import SweetXml

  alias AwsIngressOperator.Schemas.Listener

  @option_aliases %{
    load_balancer_arn: %{
      name: :load_balancer_arn,
      list: false
    },
    arn: %{
      name: :listener_arns,
      list: true
    },
    arns: %{
      name: :listener_arns,
      list: true
    },
    listener_arns: %{
      name: :listener_arns,
      list: true
    }
  }

  defp alias_options(opts) do
    Enum.map(opts, fn {k, v} ->
      case Map.get(@option_aliases, k) do
        %{name: name, list: true} -> {name, List.wrap(v)}
        %{name: name, list: false} -> {name, v}
      end
    end)
  end

  def list(opts \\ []) do
    opts = alias_options(opts)

    case ExAws.ElasticLoadBalancingV2.describe_listeners(opts) |> ExAws.request() do
        {:ok, %{body: body}} ->
    listeners =
      xpath(body, ~x"//Listeners/member"l,
        certificates: [
          ~x"./Certificates/member"l,
          certificate_arn: ~x"./CertificateArn/text()"s,
          is_default: ~x"./IsDefault/text()"b
        ],
        default_actions: [
          ~x"./DefaultActions/member"l,
          order: ~x"./Order/text()"oi,
          target_group_arn: ~x"./TargetGroupArn/text()"s,
          type: ~x"./Type/text()"s,
          authenticate_cognito_config: [
            ~x"./AuthenticateCognitoConfig"o,
            on_unauthenticated_request: ~x"./OnUnAuthenticatedRequest/text()"s,
            scope: ~x"./Scope/text()"s,
            session_cookie_name: ~x"./SessionCookieName/text()"s,
            session_timeout: ~x"./SessionTimeout/text()"oi,
            user_pool_arn: ~x"./UserPoolArn/text()"s,
            user_pool_client_id: ~x"./UserPoolClientId/text()"s,
            user_pool_domain: ~x"./UserPoolDomain/text()"s,
            authenticate_request_extra_params: [
              ~x"./AuthenticateRequestExtraParams/entry"l,
              key: ~x"./key/text()"s,
              value: ~x"./value/text()"s
            ]
          ],
          authenticate_oidc_config: [
            ~x"./AuthenticateOidcConfig"o,
            on_unauthenticated_request: ~x"./OnUnAuthenticatedRequest/text()"s,
            scope: ~x"./Scope/text()"s,
            session_cookie_name: ~x"./SessionCookieName/text()"s,
            session_timeout: ~x"./SessionTimeout/text()"oi,
            authorization_endpoint: ~x"./AuthorizationEndpoint/text()"s,
            token_endpoint: ~x"./TokenEndpoint/text()"s,
            user_info_endpoint: ~x"./UserInfoEndpoint/text()"s,
            client_id: ~x"./ClientId/text()"s,
            client_secret: ~x"./ClientSecret/text()"s,
            issuer: ~x"./Issuer/text()"s,
            use_existing_client_secret: ~x"./Issuer/text()"s,
            user_pool_domain: ~x"./UseExistingClientSecret/text()"b,
            authenticate_request_extra_params: [
              ~x"./AuthenticateRequestExtraParams/entry"l,
              key: ~x"./key/text()"s,
              value: ~x"./value/text()"s
            ]
          ],
          fixed_response_config: [
            ~x"./FixedResponseConfig"o,
            content_type: ~x"./ContentType/text()"s,
            message_body: ~x"./MessageBody/text()"s,
            status_code: ~x"./StatusCode/text()"s
          ],
          forward_config: [
            ~x"./ForwardConfig"o,
            target_groups: [
              ~x"./TargetGroups/member"l,
              target_group_arn: ~x"./TargetGroupArn/text()"s,
              weight: ~x"./Weight/text()"i
            ],
            target_group_stickiness_config: [
              ~x"./TargetGroupStickinessConfig",
              duration_seconds: ~x"./DurationSeconds/text()"i,
              enabled: ~x"./Enabled/text()"b
            ]
          ],
          redirect_config: [
            ~x"./RedirectConfig"o,
            host: ~x"./Host/text()"s,
            path: ~x"./Path/text()"s,
            port: ~x"./Port/text()"s,
            protocol: ~x"./Protocol/text()"s,
            query: ~x"./Query/text()"s,
            status_code: ~x"./StatusCode/text()"s
          ]
        ],
        port: ~x"./Port/text()"i,
        protocol: ~x"./Protocol/text()"s,
        ssl_policy: ~x"./SslPolicy/text()"s,
        load_balancer_arn: ~x"./LoadBalancerArn/text()"s,
        listener_arn: ~x"./ListenerArn/text()"s
      )
      |> Enum.map(&Listener.changeset/1)
      |> Enum.map(&Ecto.Changeset.apply_changes/1)

    {:ok, listeners}
        error -> error
    end

  end

  def get(opts \\ []) do
    case list(opts) do
      {:ok, [listener]} -> {:ok, listener}
      error -> error
    end
  end

  def insert_or_update(listener) do
    case Map.get(listener, :listener_arn) do
      nil -> insert(listener)
      arn ->
        case get(arn: arn) do
          {:ok, existing_listener} -> update(existing_listener, listener)
          {:error, _} -> {:error, :listener_not_found}
        end
    end
  end

  defp insert(listener) do
    [arn] = ExAws.ElasticLoadBalancingV2.create_listener(
      listener.load_balancer_arn,
      listener.protocol,
      listener.port,
      listener.default_actions
    )
    |> ExAws.request!()
    |> Map.get(:body)
    |> SweetXml.xpath(~x"//ListenerArn/text()"ls)

    get(arn: arn)
  end

  defp update(existing_listener, updated_listener) do
    ExAws.ElasticLoadBalancingV2.modify_listener(
      existing_listener.listener_arn, [
        protocol: updated_listener.protocol,
        port: updated_listener.port,
        default_actions: updated_listener.default_actions,
        ssl_policy: updated_listener.ssl_policy,
        certificates: updated_listener.certificates
      ]
    )
    |> ExAws.request!()
    |> Map.get(:body)

    get(arn: existing_listener.listener_arn)
  end
end
