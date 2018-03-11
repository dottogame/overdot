# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

# By default, the umbrella project as well as each child
# application will require this configuration file, ensuring
# they all use the same configuration. While one could
# configure all applications here, we prefer to delegate
# back to each application for organization purposes.
import_config "../apps/*/config/config.exs"

# Sample configuration (overrides the imported configuration above):
#
#     config :logger, :console,
#       level: :info,
#       format: "$date $time [$level] $metadata$message\n",
#       metadata: [:user_id]

config :auth_engine, AuthEngine.MailEngine.Mailer,
  adapter: Bamboo.MailgunAdapter,
  api_key: "key-baf22869a4904b98bb3dd8b26a90130d",
  domain: "sandbox22a29181b68c44f59e655ac23ddb7d5c.mailgun.org"
