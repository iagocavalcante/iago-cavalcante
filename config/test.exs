import Config

# Only in tests, remove the complexity from the password hashing algorithm
config :bcrypt_elixir, :log_rounds, 1

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :iagocavalcante, Iagocavalcante.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "iagocavalcante_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :iagocavalcante, IagocavalcanteWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "BU/p6RjWpQItdS7iRO2huW9L90/Cw7evzphTXgw3L2Rk/HDj9ZeKTWVdV36J+9Y8",
  server: false

# In test we don't send emails.
config :iagocavalcante, Iagocavalcante.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters.
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Oban testing mode
config :iagocavalcante, Oban, testing: :inline
