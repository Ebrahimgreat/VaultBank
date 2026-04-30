defmodule Bankaccount.Repo do
  use Ecto.Repo,
    otp_app: :bankaccount,
    adapter: Ecto.Adapters.Postgres
end
