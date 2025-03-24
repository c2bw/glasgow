defmodule Glasgow.Timestamp do
  @moduledoc false

  #
  # Helper module for working with protobuf timestamps.
  #
  # Protobuf Timestamp explanation (Source: https://protobuf.dev/reference/protobuf/google.protobuf/#timestamp):
  # A Timestamp represents a point in time independent of any time zone or calendar,
  # represented as seconds and fractions of seconds at nanosecond resolution in UTC Epoch time.
  # It is encoded using the Proleptic Gregorian Calendar which extends the Gregorian calendar backwards to year one.
  # It is encoded assuming all minutes are 60 seconds long, i.e. leap seconds are “smeared” so that no leap second table is needed for interpretation.
  #

  alias Google.Protobuf.Timestamp
  @type t :: Google.Protobuf.Timestamp.t()

  def new(seconds), do: %Timestamp{seconds: seconds, nanos: 0}
  def new(seconds, nanos), do: %Timestamp{seconds: seconds, nanos: nanos}

  def now(), do: DateTime.utc_now() |> from()

  def from(%NaiveDateTime{} = time) do
    time
    |> DateTime.from_naive!("Etc/UTC")
    |> from()
  end

  def from(%DateTime{} = time) do
    time
    |> DateTime.to_unix(:nanosecond)
    |> from_nanoseconds()
  end

  def from(timestamp) when is_integer(timestamp) do
    timestamp
    |> DateTime.from_unix!(:microsecond)
    |> from()
  end

  def from({{_year, _month, _day} = date, {hour, minute, second, millisecond}} = _datetime) do
    {date, {hour, minute, second}}
    |> NaiveDateTime.from_erl!({millisecond * 1_000, 3})
    |> from()
  end

  @spec from_nanoseconds(non_neg_integer()) :: t()
  defp from_nanoseconds(nanoseconds) do
    seconds = div(nanoseconds, 1_000_000_000)
    nanos = rem(nanoseconds, 1_000_000_000)
    new(seconds, nanos)
  end
end
