{ pkgs ? import <nixpkgs> {} }:

{
  legacy = import (fetchTarball https://github.com/NixOS/nixpkgs/archive/nixos-24.05.tar.gz) {};
}
