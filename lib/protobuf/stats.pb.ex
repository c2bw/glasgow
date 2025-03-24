defmodule Stats.Result do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.14.0", syntax: :proto3

  field :summary, 1, type: Stats.Summary, deprecated: false
  field :querier, 2, type: Stats.Querier, deprecated: false
  field :ingester, 3, type: Stats.Ingester, deprecated: false
  field :caches, 4, type: Stats.Caches, deprecated: false
  field :index, 5, type: Stats.Index, deprecated: false
end

defmodule Stats.Caches do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.14.0", syntax: :proto3

  field :chunk, 1, type: Stats.Cache, deprecated: false
  field :index, 2, type: Stats.Cache, deprecated: false
  field :result, 3, type: Stats.Cache, deprecated: false
  field :statsResult, 4, type: Stats.Cache, deprecated: false
  field :volumeResult, 5, type: Stats.Cache, deprecated: false
  field :seriesResult, 6, type: Stats.Cache, deprecated: false
  field :labelResult, 7, type: Stats.Cache, deprecated: false
  field :instantMetricResult, 8, type: Stats.Cache, deprecated: false
end

defmodule Stats.Summary do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.14.0", syntax: :proto3

  field :bytesProcessedPerSecond, 1, type: :int64, deprecated: false
  field :linesProcessedPerSecond, 2, type: :int64, deprecated: false
  field :totalBytesProcessed, 3, type: :int64, deprecated: false
  field :totalLinesProcessed, 4, type: :int64, deprecated: false
  field :execTime, 5, type: :double, deprecated: false
  field :queueTime, 6, type: :double, deprecated: false
  field :subqueries, 7, type: :int64, deprecated: false
  field :totalEntriesReturned, 8, type: :int64, deprecated: false
  field :splits, 9, type: :int64, deprecated: false
  field :shards, 10, type: :int64, deprecated: false
  field :totalPostFilterLines, 11, type: :int64, deprecated: false
  field :totalStructuredMetadataBytesProcessed, 12, type: :int64, deprecated: false
end

defmodule Stats.Index do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.14.0", syntax: :proto3

  field :totalChunks, 1, type: :int64, deprecated: false
  field :postFilterChunks, 2, type: :int64, deprecated: false
  field :shardsDuration, 3, type: :int64, deprecated: false
end

defmodule Stats.Querier do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.14.0", syntax: :proto3

  field :store, 1, type: Stats.Store, deprecated: false
end

defmodule Stats.Ingester do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.14.0", syntax: :proto3

  field :totalReached, 1, type: :int32, deprecated: false
  field :totalChunksMatched, 2, type: :int64, deprecated: false
  field :totalBatches, 3, type: :int64, deprecated: false
  field :totalLinesSent, 4, type: :int64, deprecated: false
  field :store, 5, type: Stats.Store, deprecated: false
end

defmodule Stats.Store do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.14.0", syntax: :proto3

  field :totalChunksRef, 1, type: :int64, deprecated: false
  field :totalChunksDownloaded, 2, type: :int64, deprecated: false
  field :chunksDownloadTime, 3, type: :int64, deprecated: false
  field :queryReferencedStructured, 13, type: :bool, deprecated: false
  field :chunk, 4, type: Stats.Chunk, deprecated: false
  field :chunkRefsFetchTime, 5, type: :int64, deprecated: false
  field :congestionControlLatency, 6, type: :int64, deprecated: false
  field :pipelineWrapperFilteredLines, 7, type: :int64, deprecated: false
end

defmodule Stats.Chunk do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.14.0", syntax: :proto3

  field :headChunkBytes, 4, type: :int64, deprecated: false
  field :headChunkLines, 5, type: :int64, deprecated: false
  field :decompressedBytes, 6, type: :int64, deprecated: false
  field :decompressedLines, 7, type: :int64, deprecated: false
  field :compressedBytes, 8, type: :int64, deprecated: false
  field :totalDuplicates, 9, type: :int64, deprecated: false
  field :postFilterLines, 10, type: :int64, deprecated: false
  field :headChunkStructuredMetadataBytes, 11, type: :int64, deprecated: false
  field :decompressedStructuredMetadataBytes, 12, type: :int64, deprecated: false
end

defmodule Stats.Cache do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.14.0", syntax: :proto3

  field :entriesFound, 1, type: :int32, deprecated: false
  field :entriesRequested, 2, type: :int32, deprecated: false
  field :entriesStored, 3, type: :int32, deprecated: false
  field :bytesReceived, 4, type: :int64, deprecated: false
  field :bytesSent, 5, type: :int64, deprecated: false
  field :requests, 6, type: :int32, deprecated: false
  field :downloadTime, 7, type: :int64, deprecated: false
  field :queryLengthServed, 8, type: :int64, deprecated: false
end
