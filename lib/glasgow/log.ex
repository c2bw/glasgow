defmodule Glasgow.Log do
  @moduledoc false

  @doc """
    [async] Push the log to Loki.
  """
  def push(level, {:string, msg}, ts, {_, %{template: template}} = _formatter, base_url, labels, metadata) when is_integer(ts) do
    Task.Supervisor.start_child(Glasgow.TaskSupervisor, fn -> do_push(level, msg, ts, template, base_url, labels, metadata) end)
  end

  def push(_, msg, _, _, _, _), do: IO.puts("Glasgow: Ignoring log message: unsupported format: #{inspect(msg)}")

  defp do_push(level, msg, ts, template, base_url, labels, metadata) do
    format_entry(template, level, msg, ts, metadata)
    |> Glasgow.Loki.Request.stream(labels)
    |> Glasgow.Loki.Request.push_request()
    |> Glasgow.Loki.Client.push(base_url)
    |> case do
      :ok -> :ok
      {:error, status, error} -> IO.puts("Glasgow: Failed to send log to Loki: #{status}: #{error |> inspect()}")
    end
  end

  defp format_entry(template, level, msg, timestamp, metadata) when is_integer(timestamp) do
    loki_timestamp = Glasgow.Timestamp.from(timestamp)
    # Create the log entry with the formatted string
    template
    |> to_log_string(level, msg, timestamp, metadata)
    |> Glasgow.Loki.Request.entry(loki_timestamp)
  end

  # Create a formatted string for the log event
  defp to_log_string(template, level, msg, timestamp, metadata) when is_integer(timestamp) do
    template
    |> Logger.Formatter.format(level, msg, timestamp |> microseconds_to_date_time_ms(), metadata)
    |> IO.chardata_to_string()
  end

  # microseconds timestamp to Erlang timestamp
  defp microseconds_to_date_time_ms(timestamp) do
    milliseconds = timestamp |> div(1_000) |> rem(1_000)
    dt = DateTime.from_unix!(timestamp, :microsecond)
    date = dt |> DateTime.to_date() |> Date.to_erl()
    {hour, minute, second} = dt |> DateTime.to_time() |> Time.to_erl()
    {date, {hour, minute, second, milliseconds}}
  end
end
