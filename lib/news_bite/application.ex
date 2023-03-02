defmodule NewsBite.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      NewsBiteWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: NewsBite.PubSub},
      # Start the Endpoint (http/https)
      NewsBiteWeb.Endpoint,
      # Start a worker by calling: NewsBite.Worker.start_link(arg)
      # {NewsBite.Worker, arg}
      NewsBite.BiteCache
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: NewsBite.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    NewsBiteWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
