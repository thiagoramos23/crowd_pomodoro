defmodule CrowdPomodoro.Repo.Migrations.CreateTasks do
  use Ecto.Migration

  def change do
    create table(:tasks) do
      add :description, :string, null: false
      add :status, :string, null: false 
      add :started_at, :utc_datetime, null: false
      add :end_at, :utc_datetime, null: false
      add :completed_at, :utc_datetime

      timestamps()
    end

  end
end
