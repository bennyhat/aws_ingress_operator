defmodule AwsIngressOperator.ExAws.Elbv2 do
  alias AwsIngressOperator.ExAws.XmlApi

  def make_request(model, action, unpacker \\ & &1) do
    main_params = %{
      "Action" => XmlApi.to_camel(action),
      "Version" => "2015-12-01"
    }

    %ExAws.Operation.Query{
      action: action,
      content_encoding: "identity",
      params: Map.merge(main_params, XmlApi.build_params(model)),
      parser: &XmlApi.parser(&1, &2, unpacker),
      path: "/",
      service: :elasticloadbalancing
    }
  end
end
