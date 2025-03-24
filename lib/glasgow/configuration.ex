defmodule Glasgow.Configuration do
  @moduledoc false
  defstruct level: :info,
            metadata: [],
            url: nil,
            labels: []

  @type t :: %__MODULE__{
          level: Logger.level(),
          metadata: list(atom()) | :all,
          url: String.t(),
          labels: [{String.t(), String.t()}]
        }

  @doc """
  Validates the user configuration for the Glasgow backend.

  Set defaults for missing keys.
  """
  @spec validate_and_set(map()) :: {:ok, t()} | {:error, String.t()}
  def validate_and_set(config) do
    config = %__MODULE__{
      level: Map.get(config, :level, :info),
      metadata: Map.get(config, :metadata, []),
      url: Map.get(config, :url, nil),
      labels: Map.get(config, :labels, [])
    }

    with :ok <- validate_level(config.level),
         :ok <- validate_metadata(config.metadata),
         :ok <- validate_url(config.url),
         :ok <- validate_labels(config.labels) do
      {:ok, config}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  defp validate_url(url) when is_binary(url), do: :ok
  defp validate_url(url), do: {:error, "invalid url: #{inspect(url)}"}

  defp validate_labels(labels) do
    labels
    |> Enum.all?(fn {k, v} -> is_binary(k) and is_binary(v) end)
    |> case do
      true -> :ok
      false -> {:error, "labels must be a list of binary {key, value} tuples"}
    end
  end

  defp validate_metadata(:all), do: :ok
  defp validate_metadata(other) when not is_list(other), do: {:error, "metadata must be a list of atoms or :all"}

  defp validate_metadata(metadata) when is_list(metadata) do
    metadata
    |> Enum.all?(fn m -> is_atom(m) end)
    |> case do
      true -> :ok
      false -> {:error, "metadata must be a list of atoms or :all"}
    end
  end

  defp validate_level(level) when is_atom(level), do: is_valid_level(level)
  defp validate_level(level), do: {:error, "invalid log level: #{inspect(level)}"}

  defp is_valid_level(level) do
    Logger.levels()
    |> Enum.member?(level)
    |> case do
      true -> :ok
      false -> {:error, "invalid log level: #{inspect(level)}"}
    end
  end
end
