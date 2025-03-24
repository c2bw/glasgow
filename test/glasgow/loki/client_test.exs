defmodule Glasgow.Loki.ClientTest do
  use ExUnit.Case, async: false
  alias Glasgow.Loki.Client
  alias Logproto.PushRequest

  @base_url "http://localhost:3100"

  setup_all do
    Mimic.stub(Req)
    :ok
  end

  describe "ready/1" do
    test "returns {:ok, status} when the server is ready" do
      Mimic.expect(Req, :get, 1, fn _req -> {:ok, %Req.Response{status: 200}} end)
      res = Client.ready(@base_url)
      assert {:ok, 200} == res
    end
  end

  describe "push/3" do
    setup do
      {:ok, request: %PushRequest{}}
    end

    test "returns :ok when the push is successful", %{request: request} do
      Mimic.expect(Req, :post, 1, fn _req -> {:ok, %Req.Response{status: 204}} end)
      res = Client.push(request, @base_url, org_id: "org1")
      assert :ok == res
    end

    test "returns {:error, status, body} when the push fails", %{request: request} do
      Mimic.expect(Req, :post, 1, fn _req -> {:ok, %Req.Response{status: 400, body: ""}} end)
      res = Client.push(request, @base_url)
      assert {:error, 400, ""} == res
    end
  end
end
