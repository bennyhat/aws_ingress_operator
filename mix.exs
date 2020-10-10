defmodule AwsIngressOperator.MixProject do
  use Mix.Project

  def project do
    [
      app: :aws_ingress_operator,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env())
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:accessible, "~> 0.2.1"},
      {:atomic_map, "~> 0.9.3"},
      {:ecto, "~> 3.3.4"},
      {:ex_aws, "~> 2.1"},
      {:ex_aws_acm, "~> 1.0"},
      {:ex_aws_ec2, "~> 2.0"},
      {:ex_aws_elastic_load_balancing, "~> 2.0"},
      {:jaxon, "~> 1.0"},
      {:k8s, "~> 0.4"},
      {:xml_json, "~> 0.3"},
      {:checkov, "~> 1.0", only: :test},
      {:divo, "~> 1.1", only: :test},
      {:divo_moto, "~> 0.1.0", only: :test},
      {:faker, "~> 0.13", only: :test},
      {:netaddr_ex, "~> 1.2", only: :test},
      {:sweet_xml, "~> 0.6", only: :test},
      {:tesla, "~> 1.3.0", only: :test}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]
end
