defmodule Glasgow.Loki.Request do
  @moduledoc false
  alias Glasgow.Timestamp
  alias Logproto.PushRequest
  alias Logproto.EntryAdapter
  alias Logproto.StreamAdapter

  @typedoc """
   Loki labels are key-value pairs that are attached to log entries.

   Example:
       [
         {"job", "my-job"},
         {"host", "my-host"}
       ]
  """
  @type labels :: list({String.t(), String.t()})

  @doc """
    A log entry is a tuple consisting of a log message and a timestamp.
  """
  @spec entry(term(), DateTime.t() | NaiveDateTime.t() | Timestamp.t()) :: EntryAdapter.t()
  def entry(line), do: entry(line, Timestamp.now())
  def entry(line, %DateTime{} = timestamp), do: entry(line, Timestamp.from(timestamp))
  def entry(line, %NaiveDateTime{} = timestamp), do: entry(line, Timestamp.from(timestamp))
  def entry(line, %Google.Protobuf.Timestamp{} = timestamp), do: %EntryAdapter{timestamp: timestamp, line: line}

  @doc """
    Create a stream from a list of log entries.
  """
  @spec stream(EntryAdapter.t() | list(EntryAdapter.t()), labels()) :: StreamAdapter.t()
  def stream(%EntryAdapter{} = entry, labels), do: stream(List.wrap(entry), labels)

  def stream(entries, labels) when is_list(entries) do
    labels_string =
      labels
      |> Enum.reverse()
      |> Enum.map(fn {l, v} -> ~s(#{l}="#{v}") end)
      |> Enum.join(",")

    %StreamAdapter{
      labels: "{#{labels_string}}",
      entries: entries |> Enum.sort_by(fn %EntryAdapter{timestamp: t} -> t end, :asc)
    }
  end

  @doc """
    Create a push request from a stream or a list of streams.
  """
  @spec push_request(StreamAdapter.t() | list(StreamAdapter.t())) :: PushRequest.t()
  def push_request(%StreamAdapter{} = stream), do: push_request(List.wrap(stream))
  def push_request(streams) when is_list(streams), do: %PushRequest{streams: streams}

  @spec from_entry(EntryAdapter.t(), labels()) :: PushRequest.t()
  def from_entry(%EntryAdapter{} = entry, labels) do
    entry
    |> stream(labels)
    |> push_request()
  end
end
