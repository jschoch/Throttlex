defmodule Throttlex.Mixfile do
  use Mix.Project

  def project do
    [ app: :throttlex,
      version: "0.0.1",
      deps: deps ]
  end

  # Configuration for the OTP application
  def application do
    [applications: [:lager]]
  end

  # Returns the list of dependencies in the format:
  # { :foobar, "0.1", git: "https://github.com/elixir-lang/foobar.git" }
  defp deps do
    [{:exlager,%r".*",[github: "khia/exlager"]},
    {:benchmark,"0.0.1",git: "https://github.com/meh/elixir-benchmark.git"}]
  end
end
