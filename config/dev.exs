import Config

config :glasgow, :logger, [
  {:handler, :glasgow, Glasgow,
   %{
     config: %{
       level: :debug,
       url: System.get_env("URL", "http://localhost:3100"),
       labels: [
         {"service_name", "service_1"},
         {"env", "dev"}
       ]
     },
     formatter: Logger.Formatter.new()
   }}
]
