defmodule Logproto.PushRequest do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.14.0", syntax: :proto3

  field :streams, 1, repeated: true, type: Logproto.StreamAdapter, deprecated: false
end

defmodule Logproto.PushResponse do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.14.0", syntax: :proto3
end

defmodule Logproto.StreamAdapter do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.14.0", syntax: :proto3

  field :labels, 1, type: :string, deprecated: false
  field :entries, 2, repeated: true, type: Logproto.EntryAdapter, deprecated: false
  field :hash, 3, type: :uint64, deprecated: false
end

defmodule Logproto.LabelPairAdapter do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.14.0", syntax: :proto3

  field :name, 1, type: :string
  field :value, 2, type: :string
end

defmodule Logproto.EntryAdapter do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.14.0", syntax: :proto3

  field :timestamp, 1, type: Google.Protobuf.Timestamp, deprecated: false
  field :line, 2, type: :string, deprecated: false
  field :structuredMetadata, 3, repeated: true, type: Logproto.LabelPairAdapter, deprecated: false
  field :parsed, 4, repeated: true, type: Logproto.LabelPairAdapter, deprecated: false
end
