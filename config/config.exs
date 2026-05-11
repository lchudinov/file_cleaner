import Config

# Configure the default logger formatter
config :logger, :default_formatter,
  # Log output format:
  # $date    - current date
  # $time    - current time
  # $level   - log level (info, debug, error, etc.)
  # $message - log message
  format: "$date $time [$level] $message\n"

# Configure the logger application
config :logger,
  # Minimum log level to display
  # Messages below this level will be ignored
  level: :info
