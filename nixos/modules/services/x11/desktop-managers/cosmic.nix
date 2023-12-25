{ config, pkgs, lib, utils, ... }:

let
  cfg = config.services.xserver.desktopManager.cosmic;
in
{
  meta.maintainers = with lib.maintainers; [ nyanbinary ];

  options.services.xserver.desktopManager.cosmic = {
    enable = lib.mkEnableOption (lib.mdDoc "COSMIC desktop environment");
  };

  config = lib.mkIf cfg.enable {
    # components that need to be in PATH
    environment.systemPackages = with pkgs; [
      cosmic-applibrary
      cosmic-applets
      cosmic-bg
      cosmic-comp
      cosmic-greeter
      cosmic-icons
      cosmic-launcher
      cosmic-notifications
      cosmic-osd
      cosmic-panel
      cosmic-screenshot
      cosmic-settings
      cosmic-settings-daemon
      cosmic-workspaces-epoch
      xdg-desktop-portal-cosmic
    ];

    xdg.portal.extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-cosmic
    ];

    xdg.portal.configPackages = [
      (pkgs.writeTextDir "share/xdg-desktop-portal/cosmic-portals.conf" ''
        [preferred]
        default=gtk
        org.freedesktop.impl.portal.Screencast=cosmic
        org.freedesktop.impl.portal.Screenshot=cosmic
      '')
    ];

    # session files for display manager and systemd
    services.xserver.displayManager.sessionPackages = with pkgs; [ cosmic-session ];
    systemd.packages = with pkgs; [ cosmic-session ];
  };
}
