{ pkgs, ... }:
{
  home.packages = with pkgs; [
    staging.go
    gopls
    cmake
    gofumpt
    unstable.buf
    unstable.protobuf
    unstable.protoc-gen-go
  ];
}
