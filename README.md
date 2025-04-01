# Glasgow [![Hex Version](https://img.shields.io/hexpm/v/glasgow.svg)](https://hex.pm/packages/glasgow) [![Hex Docs](https://img.shields.io/badge/docs-hexpm-blue.svg)](https://hexdocs.pm/glasgow/)

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

