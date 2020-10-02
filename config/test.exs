import Config

access_key_id = "server_key"
secret_access_key = "server_secret"
port = 5000

config :aws_ingress_operator,
  divo: [
    {DivoMoto,
     [
       port: port,
       service: :all,
       aws_access_key_id: access_key_id,
       aws_secret_access_key: secret_access_key
     ]}
  ]

config :ex_aws,
  # debug_requests: true,
  access_key_id: access_key_id,
  secret_access_key: secret_access_key,
  ec2: [
    scheme: "http://",
    host: "localhost",
    port: port
  ],
  elasticloadbalancing: [
    scheme: "http://",
    host: "localhost",
    port: port
  ],
  acm: [
    scheme: "http://",
    host: "localhost",
    port: port
  ]
