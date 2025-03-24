import Config

# Use UTC for timestamps in logs
config :logger, utc_log: true

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
