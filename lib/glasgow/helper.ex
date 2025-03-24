defmodule Glasgow.Helper do
  @moduledoc false

  @doc """
    Extracts the metadata.
  """
  @spec metadata(map(), [atom()] | :all) :: list({atom(), any()})
  def metadata(metadata, :all) do
    metadata
    |> Map.to_list()
    |> Enum.map(fn {k, v} -> {k, v} end)
  end

  def metadata(metadata, keys) do
    metadata
    |> Map.filter(fn {k, _} -> k in keys end)
    |> metadata(:all)
  end
end
