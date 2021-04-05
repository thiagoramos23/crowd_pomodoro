defmodule CrowdPomodoroWeb.TaskLive.Index do
  use CrowdPomodoroWeb, :live_view

  alias CrowdPomodoro.Pomodoros
  alias CrowdPomodoro.Pomodoros.Task

  @impl true
  def mount(_params, _session, socket) do
    tasks = list_tasks()
    completed_tasks = list_completed_tasks()

    if connected?(socket) do 
      Process.send_after(self(), :update_time, 1000)
      Phoenix.PubSub.subscribe(CrowdPomodoro.PubSub, "task_created")
    end

    assigns = [
      tasks:           tasks,
      task:            %Task{},
      completed_tasks: completed_tasks,
      changeset:       Pomodoros.change_task(%Task{}),
      page_title:      'Tasks'
    ]
    {:ok, assign(socket, assigns)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Tasks")
    |> assign(:task, %Task{})
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    task = Pomodoros.get_task!(id)
    {:ok, _} = Pomodoros.delete_task(task)

    {:noreply, assign(socket, :tasks, list_tasks())}
  end

  def handle_info({CrowdPomodoro.Pomodoros, :task_created, %Task{} = task}, socket) do
    assigns = [
      changeset: Pomodoros.change_task(%Task{}),
      task:      %Task{},
      tasks:     [task | socket.assigns.tasks]
    ]
    {:noreply, assign(socket, assigns)}
  end

  @impl true
  def handle_info(:update_time, socket) do
    tasks = process_tasks_time(socket.assigns.tasks)
    Process.send_after(self(), :update_time, 1000)

    {:noreply, assign(socket, :tasks, tasks)}
  end

  # Private methods

  defp list_tasks do
    Pomodoros.list_tasks()
  end

  defp list_completed_tasks() do
    Pomodoros.list_completed_tasks()
  end

  defp process_tasks_time(tasks) do
      tasks
      |> Enum.map(&update_timer/1)
      |> Enum.map(&complete_ended_task/1)
  end

  defp complete_ended_task(%Task{status: "in_progress"} = task) do
    now = DateTime.utc_now |> DateTime.truncate(:second)
    if task.end_at <= now do
      {:ok, completed_task} = Pomodoros.complete_task(task)
      completed_task
    else
      task
    end
  end
  defp complete_ended_task(task), do: task

  defp update_timer(%Task{status: "in_progress"} = task) do
    time_elapsed = DateTime.diff(task.end_at, DateTime.utc_now) 
    {:ok, time_zero} = Time.new(0,0,0,0)
    time = time_zero |> Time.add(time_elapsed)
    %{task | time_as_string: format_time(time)}
  end
  defp update_timer(task), do: task

  defp format_time(time) do
    "#{zero_pad(time.minute)}:#{zero_pad(time.second)}"
  end

  defp zero_pad(number) do
    string = number |> Integer.to_string
    add_leading(string)
  end

  defp add_leading(string_time) when byte_size(string_time) > 1, do: string_time
  defp add_leading(string_time), do: String.pad_leading(string_time, 2, "0")
end
