defmodule CrowdPomodoro.Pomodoros.Task do
  use Ecto.Schema
  import Ecto.{Changeset, Query}

  alias CrowdPomodoro.Pomodoros.Task

  schema "tasks" do
    field :description, :string
    field :status, :string, default: "in_progress"
    field :started_at, :utc_datetime 
    field :end_at, :utc_datetime 
    field :completed_at, :utc_datetime
    field :time_as_string, :string, virtual: true

    timestamps()
  end

  @doc false
  def changeset(task, attrs) do
    task
    |> cast(attrs, [:description, :status, :started_at, :end_at, :completed_at])
    |> validate_required([:description])
    |> add_started_and_end_at()
  end

  def all_tasks_with_status(status \\ "in_progress") do
    from t in Task, where: t.status == ^status
  end

  def all_completed_tasks_ordered_by_completed_at do
    all_completed_query = Task.all_tasks_with_status("completed")
    from t in all_completed_query, order_by: [asc: t.completed_at]
  end

  defp add_started_and_end_at(%Ecto.Changeset{valid?: true} = changeset) do
    started_at = DateTime.utc_now |> DateTime.truncate(:second)
    end_at = started_at |> DateTime.add(1500, :second) |> DateTime.truncate(:second)
    changeset = put_change(changeset, :started_at, started_at)
    put_change(changeset, :end_at, end_at)
  end
  defp add_started_and_end_at(changeset), do: changeset
end
