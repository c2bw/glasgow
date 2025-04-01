defmodule Glasgow do
  @moduledoc """
  An Elixir logger handler for sending logs to [`Grafana Loki`](https://github.com/grafana/loki).

  ## Installation

  The package can be installed by adding `glasgow` to your list of dependencies in `mix.exs`:

  ```elixir
  def deps do
  [
    {:glasgow, "~> 0.1.2"}
  ]
  end
  ```

  ## Configuration

  Example of a basic configuration for `config.exs` or `runtime.exs`:

  ```elixir
  config :my_app, :logger, [
  {:handler, :glasgow, Glasgow,
   %{
     config: %{
       level: :info,
       url: System.get_env("URL", "http://localhost:3100"),
       labels: [
         {"service_name", "service_1"},
         {"env", "env_1"}
       ]
     },
     formatter: Logger.Formatter.new()
   }}
  ]
  ```

  Once defined, the handler can be explicitly attached with `add_handlers/1`.

  For example, in your `Application.start/2`:
  ```elixir
  @impl true
  def start(_type, _args) do
    ...

    :ok = Logger.add_handlers(:my_app)

    ...

    Supervisor.start_link(children, opts)
  end
  ```

  #### Advanced Configuration
  Elixir `Logger` handlers can be configured with [`filters`](https://hexdocs.pm/logger/Logger.html#module-filtering) and `metadata` to provide control and context.

  ```elixir
  config :my_app, :logger, [
  {:handler, :glasgow, Glasgow,
   %{
     config: %{
       level: :info,
       url: System.get_env("URL", "http://localhost:3100"),
       labels: [
         {"service_name", "service_1"},
         {"env", "env_1"}
       ],
       metadata: [:my_metadata_key]
     },
     formatter: Logger.Formatter.new(),
     filters: [filter_name: {&MyModule.filter/2, []}]
   }}
  ]
  ```

  ## Usage

  Once the handler has been configured and attached, logs can be sent to Loki using the standard `Logger` module.

  ```elixir
  Logger.info("Hello, world!")
  ```

  The library also provides a `send/4` function for sending messages directly and bypass the `Logger`.

  ```elixir
  Glasgow.send("http://localhost:3100", [{"label1","value1"}], "message", DateTime.utc_now())
  ```


  ## Requirements
  The library requires the `Rust` toolchain because it depends on [`Snappyrex`](https://github.com/c2bw/snappyrex) for Snappy compression.
  """
  @behaviour :logger_handler

  @impl true
  def log(
        %{level: lvl, msg: msg, meta: %{time: time} = meta},
        %{formatter: formatter, config: %{level: want_lvl, url: url, labels: labels, metadata: want_md}} = _
      ) do
    Logger.compare_levels(lvl, want_lvl)
    |> case do
      :lt -> :ok
      _ -> Glasgow.Log.push(lvl, msg, time, formatter, url, labels, Glasgow.Helper.metadata(meta, want_md))
    end

    :ok
  end

  @impl true
  def adding_handler(handler_config), do: validate_handler_config(handler_config)

  @impl true
  def changing_config(_setOrUpdate, _old_config, new_config), do: validate_handler_config(new_config)

  @impl true
  def removing_handler(_config) do
    # There is no need to clean up here, Loki client does not create a permanent connection.
    :ok
  end

  defp validate_handler_config(handler_config) do
    handler_config
    |> validate_callback_config()
    |> case do
      {:ok, validated_config} -> validate_formatter(validated_config)
      {:error, reason} -> {:error, reason}
    end
  end

  defp validate_callback_config(handler_config) do
    # Validate the handler configuration and set defaults for missing keys.
    handler_config
    |> Map.get(:config, %{})
    |> Glasgow.Configuration.validate_and_set()
    |> case do
      {:ok, callback_config} -> {:ok, %{handler_config | config: callback_config}}
      {:error, reason} -> {:error, reason}
    end
  end

  defp validate_formatter(handler_config) do
    handler_config
    |> Map.get(:formatter, nil)
    |> case do
      nil -> {:error, "formatter configuration is missing"}
      {Logger.Formatter, %Logger.Formatter{}} -> {:ok, handler_config}
      other -> {:error, "formatter configuration is invalid, got: #{inspect(other)}"}
    end
  end

  @doc """
  Send a single entry to Loki.

  ## Parameters

  * `base_url` - The base URL of the Loki server.
  * `labels` - A list of labels to attach to the log entry.
  * `msg` - The log message.
  * `time` - The timestamp of the log entry. If not provided, the current time is used.
  """
  @spec send(String.t(), list(), String.t(), DateTime.t() | NaiveDateTime.t() | non_neg_integer() | nil) ::
          :ok | {:error, non_neg_integer(), term()}
  def send(base_url, labels, msg, time \\ nil) when is_binary(base_url) and is_binary(msg) do
    loki_timestamp =
      case time do
        nil -> Glasgow.Timestamp.now()
        t -> Glasgow.Timestamp.from(t)
      end

    Glasgow.Loki.Request.entry(msg, loki_timestamp)
    |> Glasgow.Loki.Request.from_entry(labels)
    |> Glasgow.Loki.Client.push(base_url)
  end
end
