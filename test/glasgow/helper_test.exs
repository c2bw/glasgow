defmodule Glasgow.HelperTest do
  use ExUnit.Case
  alias Glasgow.Helper

  describe "metadata/2" do
    test "returns all metadata when :all is specified" do
      metadata = %{name: "John", age: 30, city: "Glasgow"}
      result = Helper.metadata(metadata, :all)
      assert Enum.sort(result) == [age: 30, city: "Glasgow", name: "John"]
    end

    test "returns only specified keys" do
      metadata = %{name: "John", age: 30, city: "Glasgow"}
      result = Helper.metadata(metadata, [:name, :age])
      assert Enum.sort(result) == [age: 30, name: "John"]
    end

    test "returns empty list when no keys match" do
      metadata = %{name: "John", age: 30}
      result = Helper.metadata(metadata, [:city])
      assert result == []
    end

    test "handles empty metadata" do
      result = Helper.metadata(%{}, :all)
      assert result == []
      result = Helper.metadata(%{}, [:city])
      assert result == []
    end
  end
end
