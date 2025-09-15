{ pkgs, ... }:
{
  home.packages = with pkgs; [
    go
    gopls
    cmake
    gofumpt
    unstable.buf
    unstable.protobuf
    unstable.protoc-gen-go
  ];
}
