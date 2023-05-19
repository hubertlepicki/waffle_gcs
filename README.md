# Waffle Storage Google (forked from waffle_gcs)

Google Cloud Storage for Waffle, suppirting Goth 1.3+ and JSON credentials
for Service Accounts.

## What's Waffle?

[Waffle](https://github.com/elixir-waffle/waffle) (formerly _Arc_) is a file
uploading library for Elixir. It's main goal is to provide "plug and play" file
uploading and retrieval functionality for any storage provider (e.g. AWS S3,
Google Cloud Storage, etc).

## What's Waffle Storage Google?

Waffle Storage Google provides an integration between Waffle and Google Cloud Storage. It
is (in my opinion) a fork of
[waffle_gcs](https://github.com/tyler-eon/waffle_gcs
). If you want to easily upload and
retrieve files using Google Cloud Storage as your provider, and you also use
Waffle, then this library is for you.

## Installation

Add it to your mix dependencies:

```elixir
defp deps do
  [
    ...,
    {:waffle_storage_google, "~> 0.0.2"}
  ]
end
```

## Configuration

All configuration values are stored under the `:waffle` adn `:waffle_storage_google`

```elixir
config :waffle,
  storage: Waffle.Storage.Google,
  bucket: "gcs-bucket",
  storage_dir: "uploads/waffle"
```

```
config :waffle_storage_google,
  credentials: System.get_env("GCP_CREDENTIALS") |> Jason.decode!()
```

**Note**: a valid bucket name is a required config. This can either be a
hard-coded string (e.g. `"gcs-bucket"`) or a system env tuple (e.g.
`{:system, "WAFFLE_BUCKET"}`). You can also override this in your definition
module (e.g. `def bucket(), do: "my-bucket"`).

Authentication is done through a custom Goth instance initialized at startup
from the service account credentials, decoded and stored in configuration
(`:waffle_storage_google` -> `:credentials`).

## URL Signing

If your bucket/object permissions do not allow for public access, you will need
to use signed URLs to give people access to the uploaded files. This is done by
either passing `signed: true` to `Waffle.Storage.Google.url/4` or by setting it in the
configs (`config :waffle, signed: true`). The default expiration time is one
hour but can be changed by setting the `:expires_in` config/option value. The
value is **the number of seconds** the URL should remain valid for after
generation.

## GCS object headers

You can specify custom object headers by defining `gcs_object_headers/2` in your definition which returns keyword list or map. E.g.

```
def gcs_object_headers(_version, {_file, _scope}) do
  [contentType: "image/jpeg"]
end
```

The list of all the supported attributes can be found here: https://hexdocs.pm/google_api_storage/GoogleApi.Storage.V1.Model.Object.html.

## Roadmap

Currently this is just a fork fixed to use Goth v4 but the plan is to:

- support service accounts / metadata
- switch URL signing algorithm to V4 by default (service accounts)
- more flexible configuration, to allow reusing application's own Goth instance
- configuration for requested scopes


