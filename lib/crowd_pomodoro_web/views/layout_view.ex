defmodule CrowdPomodoroWeb.LayoutView do
  use CrowdPomodoroWeb, :view

  def humanize(string) do
    Phoenix.Naming.humanize(string)
  end
end
