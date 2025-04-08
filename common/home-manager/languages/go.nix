{ pkgs, ... }:
{
  home.packages = with pkgs; [
    go
    gopls
    cmake
    unstable.buf
    unstable.protobuf
    unstable.protoc-gen-go
  ];
}
