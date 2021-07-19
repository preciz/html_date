defmodule HTMLDate.MixProject do
  use Mix.Project

  def project do
    [
      app: :html_date,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:floki, "~> 0.31.0"},
      {:jason, "~> 1.2"}
    ]
  end
end
