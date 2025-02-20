defmodule Waffle.Storage.Google.MixProject do
  use Mix.Project

  def project do
    [
      app: :waffle_storage_google,
      name: "Waffle backend for Google Cloud Storage",
      description: description(),
      version: "0.0.2",
      elixir: "~> 1.4",
      elixirc_paths: elixirc_paths(Mix.env()),
      deps: deps(),
      package: package(),
      source_url: "https://github.com/hubertlepicki/waffle_storage_google",
      homepage_url: "https://github.com/hubertlepicki/waffle_storage_google"
    ]
  end

  def application do
    [
      mod: {Waffle.Storage.Google.Application, []}
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp description do
    "Google Cloud Storage integration for Waffle file uploader library."
  end

  defp package do
    [
      files: ~w(config/config.exs lib LICENSE mix.exs README.md),
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => "https://github.com/hubertlepicki/waffle_storage_google"}
    ]
  end

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:waffle, "~> 1.1"},
      {:goth, "~> 1.4 or ~> 1.3"},
      {:google_api_storage, "~> 0.34"},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end
end
