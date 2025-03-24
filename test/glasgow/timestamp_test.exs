defmodule Glasgow.TimestampTest do
  use ExUnit.Case
  alias Glasgow.Timestamp
  alias Google.Protobuf.Timestamp, as: PbTimestamp

  test "new/1 creates timestamp with only seconds" do
    assert %PbTimestamp{seconds: 123, nanos: 0} == Timestamp.new(123)
  end

  test "new/2 creates timestamp with seconds and nanos" do
    assert %PbTimestamp{seconds: 123, nanos: 456} == Timestamp.new(123, 456)
  end

  test "now/0 returns current time as timestamp" do
    timestamp = Timestamp.now()
    assert %PbTimestamp{} = timestamp
    assert timestamp.seconds > 0
  end

  test "from/1 converts NaiveDateTime" do
    naive = ~N[2023-01-01 12:00:00]
    timestamp = Timestamp.from(naive)
    assert %PbTimestamp{} = timestamp
    assert timestamp.seconds == 1_672_574_400
  end

  test "from/1 converts DateTime" do
    dt = DateTime.from_naive!(~N[2023-01-01 12:00:00], "Etc/UTC")
    timestamp = Timestamp.from(dt)
    assert %PbTimestamp{} = timestamp
    assert timestamp.seconds == 1_672_574_400
  end

  test "from/1 converts unix timestamp" do
    # 2023-01-01 12:00:00 in microseconds
    unix_ts = 1_672_574_400_000_000
    timestamp = Timestamp.from(unix_ts)
    assert %PbTimestamp{} = timestamp
    assert timestamp.seconds == 1_672_574_400
  end

  test "from/1 converts datetime_erl tuple" do
    datetime = {{2023, 1, 1}, {12, 0, 0, 0}}
    timestamp = Timestamp.from(datetime)
    assert %PbTimestamp{} = timestamp
    assert timestamp.seconds == 1_672_574_400
  end
end
