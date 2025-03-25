
### Compile protos to Elixir

	protoc --proto_path=./protobuf --elixir_out=./lib/protobuf protobuf/push.proto
	protoc --proto_path=./protobuf --elixir_out=./lib/protobuf protobuf/stats.proto
	protoc --proto_path=./protobuf --elixir_out=./lib/protobuf protobuf/logproto.proto


### Protos sources

[logproto.proto](https://raw.githubusercontent.com/grafana/loki/refs/tags/v3.1.0/pkg/logproto/logproto.proto)

[push.proto](https://raw.githubusercontent.com/grafana/loki/refs/tags/v3.1.0/pkg/push/push.proto)

[stats.proto](https://raw.githubusercontent.com/grafana/loki/refs/tags/v3.1.0/pkg/logqlmodel/stats/stats.proto)

[gogo.proto](https://github.com/grafana/loki/archive/refs/tags/v3.1.0.zip) - vendor\github.com\gogo\protobuf\gogoproto\gogo.proto
