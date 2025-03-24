import Config

config :glasgow, :logger, [
  {:handler, :glasgow, Glasgow,
   %{
     config: %{
       level: :info,
       metadata: [:test],
       url: "http://localhost:3100",
       labels: [
         {"service_name", "service_1"},
         {"env", "test"}
       ]
     },
     formatter: Logger.Formatter.new()
   }}
]
