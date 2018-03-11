defmodule AuthEngine.MixProject do
  use Mix.Project

  def project do
    [
      app: :auth_engine,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      applications: [:couchdb_connector, :bamboo],
      extra_applications: [:logger],
      mod: {AuthEngine.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:bcrypt_elixir, "~> 1.0"},
      {:ace, "~> 0.15.10"},
      {:poison, "~> 3.1"},
      {:couchdb_connector, "~> 0.5.0"},
      {:uuid, "~> 1.1"},
      {:bamboo, "~> 0.8"},
      {:raxx_static, "~> 0.6.0"}
      # {:sibling_app_in_umbrella, in_umbrella: true},
    ]
  end
end
