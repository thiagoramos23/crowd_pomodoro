defmodule CrowdPomodoroWeb.TaskLive.FormComponent do
  use CrowdPomodoroWeb, :live_component

  alias CrowdPomodoro.Pomodoros
  alias CrowdPomodoro.Pomodoros.Task, as: PomodoroTask

  @impl true
  def update(%{task: task} = assigns, socket) do
    changeset = Pomodoros.change_task(task)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"task" => task_params}, socket) do
    changeset =
      socket.assigns.task
      |> Pomodoros.change_task(task_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"task" => task_params}, socket) do
    save_task(socket, socket.assigns.action, task_params)
  end

  defp save_task(socket, :edit, task_params) do
    case Pomodoros.update_task(socket.assigns.task, task_params) do
      {:ok, _task} ->
        {:noreply,
         socket
         |> put_flash(:info, "Task updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_task(socket, :index, task_params) do
    case Pomodoros.create_task(task_params) do
      {:ok, _task} ->
        {:noreply,
         socket
         |> assign(:changeset, Pomodoros.change_task(%PomodoroTask{}))
         |> put_flash(:info, "Task created successfully")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
