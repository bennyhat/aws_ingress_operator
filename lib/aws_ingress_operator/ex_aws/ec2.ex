defmodule AwsIngressOperator.ExAws.EC2 do
  alias AwsIngressOperator.ExAws.XmlApi

  def make_request(model, action, unpacker \\ & &1) do
    main_params = %{
      "Action" => XmlApi.to_camel(action),
      "Version" => "2016-11-15"
    }

    %ExAws.Operation.Query{
      action: action,
      content_encoding: "identity",
      params: Map.merge(main_params, XmlApi.build_params(model, [""])),
      parser: &XmlApi.parser(&1, &2, unpacker, ["item"]),
      path: "/",
      service: :ec2
    }
  end
end
