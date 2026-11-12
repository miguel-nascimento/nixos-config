# go2rtc turns the house cameras into streams Home Assistant can show. It
# talks to each camera over RTSP on the LAN and only listens on 127.0.0.1;
# HA reaches it there, nothing else does.
#
# Câmera do quarto (Jortan/iCSee, 192.168.31.202, IP fixo no OpenWrt): RTSP
# ligado no app iCSee, Digest admin + a senha em secrets/camera-quarto.age.
# It sends H.265 1080p + G.711 over RTP/UDP only (no RTSP over TCP), and its
# SDP has H.264 parameter sets under an H.265 rtpmap, which trips ffmpeg/PyAV
# but not go2rtc. Browsers rarely play H.265, so `quarto` is re-encoded to
# H.264 + AAC with the Mac's hardware encoder, only while someone watches.
{
  config,
  pkgs,
  lib,
  user,
  inputs,
  ...
}:
let
  settings = {
    api.listen = "127.0.0.1:1984";
    rtsp.listen = "127.0.0.1:8554";
    webrtc.listen = "";
    ffmpeg.bin = "${pkgs.ffmpeg-headless}/bin/ffmpeg";
    streams = {
      # ${VAR} is filled in by go2rtc from the environment
      quarto_raw = "rtsp://admin:\${CAMERA_QUARTO_PASSWORD}@192.168.31.202:554/onvif1";
      quarto = "ffmpeg:quarto_raw#video=h264#hardware#audio=aac";
    };
  };
  configFile = (pkgs.formats.yaml { }).generate "go2rtc.yaml" settings;

  start = pkgs.writeShellScript "go2rtc" ''
    # agenix may still be decrypting right after boot
    for _ in $(seq 30); do [ -r ${config.age.secrets.camera-quarto.path} ] && break; sleep 1; done
    CAMERA_QUARTO_PASSWORD="$(cat ${config.age.secrets.camera-quarto.path})"
    export CAMERA_QUARTO_PASSWORD
    exec ${pkgs.go2rtc}/bin/go2rtc -c ${configFile}
  '';
in
{
  # URL-encoded RTSP password of the bedroom camera
  age.secrets.camera-quarto = {
    file = "${inputs.self}/secrets/camera-quarto.age";
    owner = user;
  };

  # A root daemon: macOS's Local Network privacy blocks anything run as the
  # user without an app behind it (agents and user daemons alike) from reaching
  # the LAN ("no route to host"); root is exempt. It only listens on 127.0.0.1.
  launchd.daemons.go2rtc.serviceConfig = {
    ProgramArguments = [ "${start}" ];
    RunAtLoad = true;
    KeepAlive = true;
    StandardOutPath = "/var/log/go2rtc.log";
    StandardErrorPath = "/var/log/go2rtc.log";
  };
}
