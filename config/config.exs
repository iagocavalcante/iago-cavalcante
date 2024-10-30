# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :iagocavalcante,
  ecto_repos: [Iagocavalcante.Repo]

# Configures the endpoint
config :iagocavalcante, IagocavalcanteWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [
    formats: [html: IagocavalcanteWeb.ErrorHTML, json: IagocavalcanteWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Iagocavalcante.PubSub,
  live_view: [signing_salt: "qUw5XrZT"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :iagocavalcante, Iagocavalcante.Mailer, adapter: Swoosh.Adapters.Local

config :iagocavalcante,
  aws_access_key: {:system, "AWS_ACCESS_KEY_ID", nil},
  secret_access_key: {:system, "AWS_SECRET_ACCESS_KEY", nil},
  bucket_name: {:system, "BUCKET_NAME", nil},
  region: {:system, "REGION", nil}

config :iagocavalcante,
  cloudflare_base_url: System.get_env("CLOUDFLARE_BASE_URL"),
  cloudflare_api_token: System.get_env("CLOUDFLARE_API_TOKEN"),
  cloudflare_account_id: System.get_env("CLOUDFLARE_ACCOUNT_ID")

config :iagocavalcante,
  ff_donate: System.get_env("FF_DONATE"),
  ff_video: System.get_env("FF_VIDEO")

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.14.41",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.2.4",
  default: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

config :iagocavalcante, IagocavalcanteWeb.Gettext, default_locale: "en", locales: ~w(en pt_BR)

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
