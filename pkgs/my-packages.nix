{ stdenv, pkgs, ... }:

pkgs.buildEnv {
  name = "my-packages";
  paths = let
    darwinPackages = with pkgs; [
      alacritty
      reattach-to-user-namespace
    ];
    linuxPackages = with pkgs; [
      texlive.combined.scheme-tetex
    ];
    osPackages = if stdenv.isDarwin
                 then darwinPackages
                 else linuxPackages;
  in with pkgs; [
    awscli
    jq
    plan9port
  ] ++ osPackages;
}
