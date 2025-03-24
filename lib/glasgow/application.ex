defmodule Glasgow.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      {Task.Supervisor, name: Glasgow.TaskSupervisor}
    ]

    opts = [strategy: :one_for_one, name: Glasgow.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
