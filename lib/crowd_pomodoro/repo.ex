defmodule CrowdPomodoro.Repo do
  use Ecto.Repo,
    otp_app: :crowd_pomodoro,
    adapter: Ecto.Adapters.Postgres
end
