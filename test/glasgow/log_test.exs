defmodule Glasgow.LogTest do
  use ExUnit.Case
  alias Glasgow.Log

  setup do
    # Mock timestamp for consistent testing
    # 2023-05-12 12:00:00.000000
    timestamp = 1_683_900_000_000_000
    template = [:time, " ", :message]

    {:ok,
     %{
       timestamp: timestamp,
       template: template,
       base_url: "http://loki:3100",
       labels: %{"app" => "test"},
       metadata: []
     }}
  end

  describe "push/7" do
    test "handles valid log message", %{timestamp: ts, template: template} = context do
      result =
        Log.push(
          :info,
          {:string, "test message"},
          ts,
          {nil, %{template: template}},
          context.base_url,
          context.labels,
          context.metadata
        )

      assert match?({:ok, _}, result)
      assert is_pid(elem(result, 1))
    end

    test "handles invalid message format" do
      result = capture_io(fn -> Log.push(:info, {:invalid}, nil, nil, nil, nil) end)
      assert result =~ "Glasgow: Ignoring log message: unsupported format"
    end
  end

  # Helper to capture IO output
  defp capture_io(fun) do
    ExUnit.CaptureIO.capture_io(fun)
  end
end
