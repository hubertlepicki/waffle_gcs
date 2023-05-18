defmodule Waffle.Storage.Google.Application do
  @moduledoc false
  use Application

  @full_control_scope "https://www.googleapis.com/auth/devstorage.full_control"


  def start(_type, _args) do
    credentials = Application.get_env(:waffle_storage_google, :credentials)
    scopes = Application.get_env(:waffle_storage_google, :scopes, [@full_control_scope])
    source = {:service_account, credentials, scopes: scopes}

    children = [
      {Goth, name: Waffle.Storage.Google.Goth, source: source}
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
