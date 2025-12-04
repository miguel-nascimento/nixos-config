{ pkgs, ... }:
{
  home.packages = with pkgs; [
    unstable.go
    gopls
    cmake
    gofumpt
    unstable.buf
    unstable.protobuf
    unstable.protoc-gen-go
  ];
}
