{ pkgs, config, lib, ... }:

with lib;
with builtins;

{
  programs.fish = rec {
    enable = true;
    shellInit = let
      initFile = readFile (toString ./config.fish);
      functionSignaled = func: typeOf func == "set" &&
        any (hasPrefix "on") (attrNames func);
      functionPreload = "type -q " + concatStringsSep " "
        (attrNames (filterAttrs (_: functionSignaled) functions));
    in initFile + "\n" + functionPreload;
    shellAbbrs = { };
    shellAliases = {
      tree = "tree -C";
      ls = "ls --all --color=tty --group-directories-first";
    };
    functions = let
      isFishFile = file: type: type == "regular" &&
        (hasSuffix ".nix" file || hasSuffix ".fish" file);
      fileToAttr = file: {
        name = head (splitString "." (baseNameOf file));
        value = if hasSuffix ".nix" file
          then import (./functions + "/${file}") { inherit pkgs config lib; }
          else readFile (toString (./functions + "/${file}"));
      };
    in listToAttrs (map fileToAttr (attrNames
      (filterAttrs isFishFile (readDir ./functions))));
    plugins = with pkgs.fishPlugins; [
      (with fzf-fish; {inherit name src;})
      (with done; {inherit name src;})
    ];
  };
  home.packages = with pkgs; with pkgs.fishPlugins; [
    bat fzf fd fzf-fish
  ];
}

