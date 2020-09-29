defmodule AwsIngressOperator.Listeners do
  @moduledoc """
  A repository pattern wrapper for a Listener inventory
  """
  import SweetXml

  alias AwsIngressOperator.Schemas.Listener

  @option_aliases %{
    load_balancer_arns: :load_balancer_arns,
    load_balancer_arn: :load_balancer_arns,
    arns: :load_balancer_arns,
    arn: :load_balancer_arns,
    load_balancer_names: :names,
    load_balancer_name: :names,
    name: :names,
    names: :names
  }

  def list(opts \\ []) do
    listeners = ExAws.ElasticLoadBalancingV2.describe_listeners(opts)
    |> ExAws.request!()
    |> Map.get(:body)
    |> xpath(~x"//Listeners/member"l, [
          certificates: [~x"./Certificates/member"l,
            certificate_arn: ~x"./CertificateArn/text()"s,
            is_default: ~x"./IsDefault/text()"b,
          ],
          default_actions: [~x"./DefaultActions/member"l,
            order: ~x"./Order/text()"oi,
            target_group_arn: ~x"./TargetGroupArn/text()"s,
            type: ~x"./Type/text()"s,

            authenticate_cognito_config: [~x"./AuthenticateCognitoConfig"o,
                                             on_unauthenticated_request: ~x"./OnUnAuthenticatedRequest/text()"s,
                                             scope: ~x"./Scope/text()"s,
                                             session_cookie_name: ~x"./SessionCookieName/text()"s,
                                             session_timeout: ~x"./SessionTimeout/text()"oi,
                                             user_pool_arn: ~x"./UserPoolArn/text()"s,
                                             user_pool_client_id: ~x"./UserPoolClientId/text()"s,
                                             user_pool_domain: ~x"./UserPoolDomain/text()"s,
                                             authenticate_request_extra_params: [~x"./AuthenticateRequestExtraParams/entry"l, key: ~x"./key/text()"s, value: ~x"./value/text()"s]
            ],
            authenticate_oidc_config: [~x"./AuthenticateOidcConfig"o,
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
                                          authenticate_request_extra_params: [~x"./AuthenticateRequestExtraParams/entry"l, key: ~x"./key/text()"s, value: ~x"./value/text()"s]
            ],
            fixed_response_config: [~x"./FixedResponseConfig"o,
                                       content_type: ~x"./ContentType/text()"s,
                                       message_body: ~x"./MessageBody/text()"s,
                                       status_code: ~x"./StatusCode/text()"s
            ],
            forward_config: [~x"./ForwardConfig"o,
                                target_groups: [~x"./TargetGroups/member"l, target_group_arn: ~x"./TargetGroupArn/text()"s, weight: ~x"./Weight/text()"i],
                                target_group_stickiness_config: [~x"./TargetGroupStickinessConfig", duration_seconds: ~x"./DurationSeconds/text()"i, enabled: ~x"./Enabled/text()"b]
            ],
            redirect_config: [~x"./RedirectConfig"o,
                                 host: ~x"./Host/text()"s,
                                 path: ~x"./Path/text()"s,
                                 port: ~x"./Port/text()"s,
                                 protocol: ~x"./Protocol/text()"s,
                                 query: ~x"./Query/text()"s,
                                 status_code: ~x"./StatusCode/text()"s
            ],
          ],
          port: ~x"./Port/text()"i,
          protocol: ~x"./Protocol/text()"s,
          ssl_policy: ~x"./SslPolicy/text()"s,
          load_balancer_arn: ~x"./LoadBalancerArn/text()"s
    ])
    |> Enum.map(&Listener.changeset/1)
    |> Enum.map(&Ecto.Changeset.apply_changes/1)

    {:ok, listeners}
  end
end
