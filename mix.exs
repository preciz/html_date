defmodule HTMLDate.MixProject do
  use Mix.Project

  @version "0.5.1"
  @github "https://github.com/preciz/html_date"

  def project do
    [
      app: :html_date,
      version: @version,
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs(),
      package: package(),
      homepage_url: @github,
      description: """
      Extract date strings from HTML documents or articles
      """
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.37", only: :dev, runtime: false},
      {:lazy_html, "~> 0.1.0"}
    ]
  end

  defp docs do
    [
      main: "HTMLDate",
      source_ref: "v#{@version}",
      source_url: @github
    ]
  end

  defp package do
    [
      maintainers: ["Barna Kovacs"],
      licenses: ["MIT"],
      links: %{"GitHub" => @github}
    ]
  end
end
