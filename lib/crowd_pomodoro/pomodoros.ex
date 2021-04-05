defmodule CrowdPomodoro.Pomodoros do
  @moduledoc """
  The Pomodoros context.
  """

  import Ecto.Query, warn: false
  alias CrowdPomodoro.Repo

  alias CrowdPomodoro.Pomodoros.Task

  @doc """
  Returns the list of tasks in progress or completed

  ## Examples

  iex> list_tasks()
  [%Task{}, ...]

  """
  def list_tasks do
    Repo.all(Task.all_tasks_with_status("in_progress"))
  end

  def list_completed_tasks do
    Repo.all(Task.all_completed_tasks_ordered_by_completed_at())
  end

  @doc """
  Gets a single task.

  Raises `Ecto.NoResultsError` if the Task does not exist.

  ## Examples

  iex> get_task!(123)
  %Task{}

  iex> get_task!(456)
  ** (Ecto.NoResultsError)

  """
  def get_task!(id), do: Repo.get!(Task, id)

  @doc """
  Creates a task.

  ## Examples

  iex> create_task(%{field: value})
  {:ok, %Task{}}

  iex> create_task(%{field: bad_value})
  {:error, %Ecto.Changeset{}}

  """
  def create_task(attrs \\ %{}) do
    %Task{}
    |> Task.changeset(attrs)
    |> Repo.insert()
    |> publish_creation()
  end

  defp publish_creation({:ok, task} = result) do
    Phoenix.PubSub.broadcast(CrowdPomodoro.PubSub, "task_created", {__MODULE__, :task_created, task})
    result
  end
  defp publish_creation(result), do: result

  @doc """
  Updates a task.

  ## Examples

  iex> update_task(task, %{field: new_value})
  {:ok, %Task{}}

  iex> update_task(task, %{field: bad_value})
  {:error, %Ecto.Changeset{}}

  """
  def update_task(%Task{} = task, attrs) do
    task
    |> Task.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Completes a task.

  ## Examples

  iex> complete_task(task)
  {:ok, %Task{completed_at: DateTime.utc_now, status: "completed"}}

  iex> complete_task(task, %{field: bad_value})
  {:error, %Ecto.Changeset{}}

  """
  def complete_task(%Task{} = task) do
    attrs = %{completed_at: DateTime.utc_now, status: "completed"}
    task
    |> Task.changeset(attrs)
    |> Repo.update()
  end


  @doc """
  Deletes a task.

  ## Examples

  iex> delete_task(task)
  {:ok, %Task{}}

  iex> delete_task(task)
  {:error, %Ecto.Changeset{}}

  """
  def delete_task(%Task{} = task) do
    Repo.delete(task)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking task changes.

  ## Examples

  iex> change_task(task)
  %Ecto.Changeset{data: %Task{}}

  """
  def change_task(%Task{} = task, attrs \\ %{}) do
    Task.changeset(task, attrs)
  end
end
