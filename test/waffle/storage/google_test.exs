defmodule Waffle.Storage.GoogleTest do
  use ExUnit.Case, async: true

  alias Waffle.Storage.Google, as: CloudStorage

  @file_name "image.png"
  @file_path "test/support/#{@file_name}"
  @remote_dir "waffle-test"

  def env_bucket(), do: System.get_env("WAFFLE_BUCKET")

  def random_name(_) do
    name = 8 |> :crypto.strong_rand_bytes() |> Base.encode16()
    %{name: name, path: "#{@remote_dir}/#{name}.png"}
  end

  def create_wafile(_), do: %{wafile: Waffle.File.new(@file_path, DummyDefinition)}

  def setup_waffle(%{wafile: file, name: name}) do
    %{
      definition: DummyDefinition,
      version: :original,
      meta: {file, name}
    }
  end

  def cleanup(_) do
    # We should prefer, for performance reasons, to cleanup the bucket once
    # after all tests have run, but `after_suite/1` is only available starting
    # with Elixir version 1.8.0. Therefore, previous versions need to use the
    # `on_exit/1` function to register a callback that executes after each
    # individual test runs.
    if Version.compare(System.version(), "1.8.0") == :lt do
      on_exit(fn -> IO.puts("Cleanup invokved (#{inspect(self())})") end)
    else
      :ok
    end
  end

  describe "conn/1" do
    test "constructs a Tesla client" do
      assert %Tesla.Client{} = CloudStorage.conn()
    end
  end

  describe "utility functions" do
    setup [:random_name, :create_wafile, :setup_waffle]

    test "bucket/1 returns a bucket name based on a Waffle definition", %{definition: definition} do
      assert env_bucket() == CloudStorage.bucket(definition)
      assert "invalid" == CloudStorage.bucket(DummyDefinitionInvalidBucket)
    end

    test "storage_dir/3 returns the remote storage directory (not the bucket)", %{
      definition: definition,
      version: ver,
      meta: meta
    } do
      assert @remote_dir == CloudStorage.storage_dir(definition, ver, meta)
    end

    test "path_for/3 returns the file full path (storage directory plus filename)", %{
      definition: definition,
      version: ver,
      meta: meta,
      path: path
    } do
      assert path == CloudStorage.path_for(definition, ver, meta)
    end
  end

  describe "waffle functions" do
    setup [:random_name, :create_wafile, :setup_waffle]

    test "put/3 uploads a valid file", %{definition: definition, version: ver, meta: meta} do
      assert {:ok, _} = CloudStorage.put(definition, ver, meta)
    end

    test "put/3 uploads binary data", %{definition: definition, version: ver, name: name} do
      assert {:ok, _} =
               CloudStorage.put(
                 definition,
                 ver,
                 {%Waffle.File{binary: File.read!(@file_path), file_name: "#{name}.png"}, name}
               )
    end

    test "put/3 fails for an invalid file", %{version: ver, meta: meta} do
      assert {:error, _} = CloudStorage.put(DummyDefinitionInvalidBucket, ver, meta)
    end

    test "delete/3 successfully deletes existing object", %{
      definition: definition,
      version: ver,
      meta: meta
    } do
      assert {:ok, _} = CloudStorage.put(definition, ver, meta)
      assert {:ok, _} = CloudStorage.delete(definition, ver, meta)
    end

    test "delete/3 fails for invalid bucket or object", %{
      definition: definition,
      version: ver,
      meta: meta
    } do
      assert {:error, _} = CloudStorage.delete(definition, ver, meta)
      assert {:error, _} = CloudStorage.delete(DummyDefinitionInvalidBucket, ver, meta)
    end

    test "url/3 returns regular URLs", %{
      definition: definition,
      version: ver,
      meta: meta,
      name: name
    } do
      assert CloudStorage.url(definition, ver, meta) =~ "/#{env_bucket()}/#{@remote_dir}/#{name}"
    end

    test "url/3 returns signed URLs (v2)", %{definition: definition, version: ver, meta: meta} do
      assert {:ok, _} = CloudStorage.put(definition, ver, meta)
      url = CloudStorage.url(definition, ver, meta, signed: true)
      assert url =~ "&Signature="
      assert {:ok, %{status: 200}} = Tesla.get(url)
    end

    test "url/3 returns CDN URL without bucket name in path", %{
      definition: definition,
      version: ver,
      meta: meta,
      name: name
    } do
      Application.put_env(:waffle, :asset_host, "cdn-domain.com")

      assert CloudStorage.url(definition, ver, meta) ==
               "https://cdn-domain.com/#{@remote_dir}/#{name}.png"

      Application.delete_env(:waffle, :asset_host)
    end
  end
end
