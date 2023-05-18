import Config

config :waffle,
  bucket: System.get_env("WAFFLE_BUCKET")

config :waffle_storage_google,
  credentials: System.get_env("GCP_CREDENTIALS") |> Jason.decode!()

