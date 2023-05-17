import Config

config :waffle,
  bucket: System.get_env("WAFFLE_BUCKET")

config :goth, json: System.get_env("GCP_CREDENTIALS")
