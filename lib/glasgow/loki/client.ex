defmodule Glasgow.Loki.Client do
  @moduledoc false
  alias Logproto.PushRequest

  @api_ready_path "/ready"
  @api_push_path "/loki/api/v1/push"

  @doc """
    Check if Loki server ready.
  """
  @spec ready(String.t()) :: {:ok, non_neg_integer()} | :error
  def ready(base_url) do
    Req.new(method: :get, base_url: base_url, url: @api_ready_path)
    |> Req.get()
    |> case do
      {:ok, %Req.Response{status: status}} -> {:ok, status}
      {:error, %Req.TransportError{reason: reason}} -> {:error, 500, reason}
      {:error, _err} -> {:error, 500, "Internal Server Error"}
    end
  end

  @doc """
    Send a push request to Loki.
  """
  @spec push(PushRequest.t(), String.t(), Keyword.t()) :: :ok | {:error, non_neg_integer(), term()}
  def push(%PushRequest{} = request, base_url, opts \\ []) do
    path = Keyword.get(opts, :path, @api_push_path)
    {:ok, encoded} = PushRequest.encode(request) |> Snappyrex.compress(format: :raw)

    Req.new(method: :post, base_url: base_url, url: path, headers: headers(opts), body: encoded, retry: retry(opts))
    |> Req.post()
    |> case do
      {:ok, %Req.Response{status: 204}} -> :ok
      {:ok, %Req.Response{status: status, body: body}} -> {:error, status, body}
      {:error, %Req.TransportError{reason: reason}} -> {:error, 500, reason}
      {:error, _err} -> {:error, 500, "Internal Server Error"}
    end
  end

  defp headers(opts) do
    opts
    |> Keyword.get(:org_id)
    |> case do
      nil -> []
      org_id -> [{"X-Scope-OrgID", org_id}]
    end
    |> Enum.concat([{"Content-Type", "application/x-protobuf"}])
  end

  defp retry(opts), do: Keyword.get(opts, :retry, :safe_transient)
end
