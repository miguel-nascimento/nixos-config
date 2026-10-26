{ pkgs, ... }:
{
  home.packages = with pkgs; [
    staging.go
    gopls
    cmake
    gofumpt
    unstable.gotools # goimports
    unstable.goimports-reviser
    unstable.golangci-lint
    unstable.buf
    unstable.protobuf
    unstable.protoc-gen-go
  ];
}
