defmodule NewsBite.Repo do
  use Ecto.Repo,
    otp_app: :news_bite,
    adapter: Ecto.Adapters.Postgres
end
