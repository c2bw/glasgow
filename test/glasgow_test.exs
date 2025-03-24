defmodule GlasgowTest do
  use ExUnit.Case, async: false
  use Mimic
  doctest Glasgow
  alias GlasgowTest.Support
  require Logger

  defmodule Support do
    @doc """
      Wait for the Glasgow.TaskSupervisor childrens to finish.
    """
    def wait_for_supervisor() do
      pids = Task.Supervisor.children(Glasgow.TaskSupervisor)
      Enum.each(pids, &Process.monitor/1)
      wait_for_pids(pids)
    end

    defp wait_for_pids([]), do: nil

    defp wait_for_pids(pids) do
      receive do
        {:DOWN, _ref, :process, pid, _reason} -> wait_for_pids(List.delete(pids, pid))
      end
    end
  end

  setup_all do
    Mimic.stub(Req)
    :ok = :logger.add_handlers(:glasgow)
  end

  describe "logging" do
    test "HTTP request" do
      Mimic.expect(Req, :post, 1, fn _req -> {:ok, %Req.Response{status: 204}} end)
      Logger.info("hello")
      Support.wait_for_supervisor()
    end

    test "HTTP request not done when level is below required" do
      Mimic.reject(Req, :post, 1)
      Logger.debug("hello")
      Support.wait_for_supervisor()
    end

    test "payload" do
      input = "hello123test"

      Mimic.expect(Req, :post, fn %{body: payload} = _req ->
        line = extract_line_from_push_request(payload)
        assert line =~ input
        assert line =~ "[info]"
        {:ok, %Req.Response{status: 204}}
      end)

      Logger.info(input)
      Support.wait_for_supervisor()
    end

    test "metadata in payload" do
      input = "hello_metadata"
      metadata_input = "test123"

      Mimic.expect(Req, :post, fn %{body: payload} = _req ->
        line = extract_line_from_push_request(payload)
        assert line =~ input
        assert line =~ "[info]"
        assert line =~ "test=#{metadata_input}"
        {:ok, %Req.Response{status: 204}}
      end)

      Logger.metadata(test: metadata_input)
      Logger.info(input)
      Support.wait_for_supervisor()
    end
  end

  describe "configuration" do
    setup do
      :ok = :logger.remove_handler(:glasgow)
      :ok = :logger.add_handlers(:glasgow)
      :ok
    end

    test "setup correctly sets config values according to test.exs" do
      {:ok, handler_config} = :logger.get_handler_config(:glasgow)
      assert handler_config.config.level == :info
      assert handler_config.config.metadata == [:test]
      assert handler_config.config.url == "http://localhost:3100"
      assert handler_config.config.labels == [{"service_name", "service_1"}, {"env", "test"}]
    end

    test "correctly change config values" do
      :ok =
        :logger.set_handler_config(:glasgow, %{
          config: %{level: :debug, metadata: [], url: "http://test:3100", labels: []},
          formatter: Logger.Formatter.new()
        })

      {:ok, handler_config} = :logger.get_handler_config(:glasgow)
      assert handler_config.config.level == :debug
      assert handler_config.config.metadata == []
      assert handler_config.config.url == "http://test:3100"
      assert handler_config.config.labels == []
    end

    test "validation: url" do
      {:error, reason} = :logger.set_handler_config(:glasgow, %{config: %{url: nil}})
      assert reason =~ "invalid url"
    end

    test "validation: label" do
      {:error, reason} = :logger.set_handler_config(:glasgow, %{config: %{url: "test", labels: [{"1", 2}]}})
      assert reason =~ "labels must be a list of binary {key, value} tuples"
    end

    test "validation: level" do
      {:error, reason} = :logger.set_handler_config(:glasgow, %{config: %{level: :invalid, url: "test", labels: []}})
      assert reason =~ "invalid log level"
    end

    test "validation: metadata" do
      {:error, reason} =
        :logger.set_handler_config(:glasgow, %{config: %{url: "test", metadata: :fail}, formatter: Logger.Formatter.new()})

      assert reason =~ "metadata must be a list of atoms or :all"
      res = :logger.set_handler_config(:glasgow, %{config: %{url: "test", metadata: :all}, formatter: Logger.Formatter.new()})
      assert :ok == res
      {:ok, handler_config} = :logger.get_handler_config(:glasgow)
      assert handler_config.config.metadata == :all

      res =
        :logger.set_handler_config(:glasgow, %{config: %{url: "test", metadata: [:one, :two]}, formatter: Logger.Formatter.new()})

      assert :ok == res
      {:ok, handler_config} = :logger.get_handler_config(:glasgow)
      assert handler_config.config.metadata == [:one, :two]
    end
  end

  describe "handler_removal" do
    setup do
      on_exit(fn -> :ok = :logger.add_handlers(:glasgow) end)
    end

    test "remove handler successfully" do
      assert :ok == :logger.remove_handler(:glasgow)
    end
  end

  describe "send" do
    test "simple message" do
      Mimic.expect(Req, :post, 2, fn _req -> {:ok, %Req.Response{status: 204}} end)
      res = Glasgow.send("http://localhost:3100", [{"label", "value"}], "hello")
      assert :ok == res
      res = Glasgow.send("http://localhost:3100", [{"label", "value"}], "hello", 123_456_789)
      assert :ok == res
    end
  end

  defp extract_line_from_push_request(payload) do
    {:ok, decompressed} = Snappyrex.decompress(payload, format: :raw)
    push_req = decompressed |> Logproto.PushRequest.decode()
    [stream] = push_req.streams
    [entry] = stream.entries
    entry.line
  end
end
