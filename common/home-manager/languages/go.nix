{ pkgs, ... }:
{
  home.packages = with pkgs; [
    staging.go
    gopls
    cmake
    unstable.buf
    unstable.protobuf
    unstable.protoc-gen-go
  ];
}
