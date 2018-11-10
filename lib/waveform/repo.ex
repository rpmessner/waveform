defmodule Waveform.Repo do
  use Ecto.Repo,
    otp_app: :waveform,
    adapter: Ecto.Adapters.Postgres
end
