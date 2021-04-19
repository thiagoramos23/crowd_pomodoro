defmodule CrowdPomodoro.PomodorosTest do
  use CrowdPomodoro.DataCase

  alias CrowdPomodoro.Pomodoros

  describe "tasks" do
    alias CrowdPomodoro.Pomodoros.Task

    @valid_attrs %{description: "some description", status: "in_progress", started_at: ~U[2010-04-17 14:00:00Z]}
    @update_attrs %{description: "some updated description", status: "some updated status", started_at: ~N[2011-05-18 15:01:01]}
    @invalid_attrs %{description: nil, status: nil, started_at: nil}

    def task_fixture(attrs \\ %{}) do
      {:ok, task} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Pomodoros.create_task()

      task
    end

    test "list_tasks/0 returns all tasks" do
      utc_now = DateTime.utc_now
      in_progress_task = task_fixture(%{status: "in_progress"})
      completed_task = task_fixture(%{status: "completed", completed_at: utc_now})
      completed_task_older_than_10_minutes = task_fixture(%{status: "completed", completed_at: utc_now |> DateTime.add(-610, :second)})
      assert Pomodoros.list_tasks() == [in_progress_task]
    end

    test "list_completed_tasks/0 returns all completed tasks" do
      utc_now = DateTime.utc_now()
      task_fixture(%{status: "in_progress"})
      completed_task = task_fixture(%{status: "completed", completed_at: utc_now})
      old_completed_task = task_fixture(%{status: "completed", completed_at: utc_now |> DateTime.add(-85000, :second)})
      more_than_a_day_old_completed_task = task_fixture(%{status: "completed", completed_at: utc_now |> DateTime.add(-87000, :second)})
      assert Pomodoros.list_completed_tasks() == [old_completed_task, completed_task]
    end

    test "get_task!/1 returns the task with given id" do
      task = task_fixture()
      assert Pomodoros.get_task!(task.id) == task
    end

    test "create_task/1 with valid data creates a task" do
      assert {:ok, %Task{} = task} = Pomodoros.create_task(@valid_attrs)
      assert task.description == "some description"
      assert task.status == "in_progress"
      assert task.started_at > DateTime.truncate(DateTime.utc_now |> DateTime.add(-2, :second), :second)
      assert task.started_at < DateTime.truncate(DateTime.utc_now |> DateTime.add(2, :second), :second)
    end

    test "create_task/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Pomodoros.create_task(@invalid_attrs)
    end

    test "update_task/2 with valid data updates the task" do
      task = task_fixture()
      assert {:ok, %Task{} = task} = Pomodoros.update_task(task, @update_attrs)
      assert task.description == "some updated description"
      assert task.status == "some updated status"
      assert task.started_at > DateTime.truncate(DateTime.utc_now |> DateTime.add(-2, :second), :second)
      assert task.started_at < DateTime.truncate(DateTime.utc_now |> DateTime.add(2, :second), :second)
    end

    test "update_task/2 with invalid data returns error changeset" do
      task = task_fixture()
      assert {:error, %Ecto.Changeset{}} = Pomodoros.update_task(task, @invalid_attrs)
      assert task == Pomodoros.get_task!(task.id)
    end

    test "delete_task/1 deletes the task" do
      task = task_fixture()
      assert {:ok, %Task{}} = Pomodoros.delete_task(task)
      assert_raise Ecto.NoResultsError, fn -> Pomodoros.get_task!(task.id) end
    end

    test "change_task/1 returns a task changeset" do
      task = task_fixture()
      assert %Ecto.Changeset{} = Pomodoros.change_task(task)
    end

    test "complete_task/1 completes a task" do
      task = task_fixture()
      assert task.completed_at == nil
      assert task.status == "in_progress"

      {:ok, %Task{} = completed_task} = Pomodoros.complete_task(task)
      assert completed_task.status == "completed"
      refute completed_task.completed_at == nil
    end
  end
end
