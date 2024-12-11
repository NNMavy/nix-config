{ lib
, config
, pkgs
, ...
}:
with lib;
let
  cfg = config.mySystem.${category}.${app};
  app = "omni";
  category = "services";
  description = "The Sidero Omni Kubernetes management platform";
  image = "ghcr.io/siderolabs/omni:v0.44.0";
  user = "root";
  group = "root";
  port = 8080; #int
  apiPort = 8090;
  kubePort = 8100;
  appFolder = "/var/lib/${app}";
  # persistentFolder = "${config.mySystem.persistentFolder}/var/lib/${appFolder}";
  host = "${app}" + (if cfg.dev then "-dev" else "");
  url = "${host}.${config.networking.domain}";
  apiUrl = "api.${url}";
  kubeUrl = "kube.${url}";
in
{
  options.mySystem.${category}.${app} =
    {
      enable = mkEnableOption "${app}";
      #addToHomepage = mkEnableOption "Add ${app} to homepage" // { default = true; };
      openFirewall = mkEnableOption "Open firewall for ${app}" // {
        default = true;
      };
      monitor = mkOption
        {
          type = lib.types.bool;
          description = "Enable gatus monitoring";
          default = true;
        };
      prometheus = mkOption
        {
          type = lib.types.bool;
          description = "Enable prometheus scraping";
          default = true;
        };
      addToDNS = mkOption
        {
          type = lib.types.bool;
          description = "Add to DNS list";
          default = true;
        };
      dev = mkOption
        {
          type = lib.types.bool;
          description = "Development instance";
          default = false;
        };
      backup = mkOption
        {
          type = lib.types.bool;
          description = "Enable backups";
          default = true;
        };

    };

  config = mkIf cfg.enable {

    ## Secrets
    sops.secrets = {
      "services/omni/saml_metadata".sopsFile = ./secrets.sops.yaml;
      "services/omni/pgp_key".sopsFile = ./secrets.sops.yaml;
    };

    # ensure folder exist and has correct owner/group
    systemd.tmpfiles.rules = [
      "d ${appFolder}/etcd 0750 ${user} ${group} -"
    ];

    environment.persistence."${config.mySystem.system.impermanence.persistPath}" = lib.mkIf config.mySystem.system.impermanence.enable {
      directories = [{ directory = appFolder; inherit user; inherit group; mode = "750"; }];
    };

    virtualisation.oci-containers.containers.${app} = {
      image = "${image}";
      extraOptions = [ "--network=host" "--cap-add=NET_ADMIN" "--device=/dev/net/tun" ]; # Required for omni
      cmd = [
        "--account-id=20e42ade-d500-4494-9419-6d47bd042512"
        "--name=nnhome-omni"
        "--private-key-source=file:///omni.asc"
        "--advertised-api-url=https://${url}"
        "--bind-addr=127.0.0.1:${builtins.toString port}"
        "--siderolink-api-bind-addr=127.0.0.1:${builtins.toString apiPort}"
        "--siderolink-api-advertised-url=https://${apiUrl}:443"
        "--k8s-proxy-bind-addr=127.0.0.1:${builtins.toString kubePort}"
        "--advertised-kubernetes-proxy-url=https://${kubeUrl}/"
        "--siderolink-use-grpc-tunnel=true"
        "--auth-saml-enabled=true"
        "--auth-saml-metadata=/secrets/metadata.xml"
        "--enable-break-glass-configs=true"
      ];
      volumes = [
        "${appFolder}/etcd:/_out/etcd:rw"
        "${config.sops.secrets."services/omni/pgp_key".path}:/omni.asc:ro"
        "${config.sops.secrets."services/omni/saml_metadata".path}:/secrets/metadata.xml:ro"
        "/etc/localtime:/etc/localtime:ro"
      ];
    };

    ### gatus integration
    mySystem.services.gatus.monitors = mkIf cfg.monitor [
      {
        name = app;
        group = "${category}";
        url = "https://${url}";
        interval = "1m";
        conditions = [ "[CONNECTED] == true" "[STATUS] == 200" "[RESPONSE_TIME] < 50" ];
      }
    ];

    ### Ingress
    services.nginx.virtualHosts.${url} = {
      forceSSL = true;
      useACMEHost = config.networking.domain;
      locations."^~ /" = {
        proxyPass = "http://127.0.0.1:${builtins.toString port}";
        extraConfig = ''
          resolver 10.88.0.1;
          proxy_http_version 1.1;
          proxy_set_header Upgrade $http_upgrade;
          proxy_set_header Connection $connection_upgrade;
          grpc_pass grpc://127.0.0.1:${builtins.toString port};
        '';
      };
    };

    services.nginx.virtualHosts.${apiUrl} = {
      forceSSL = true;
      useACMEHost = config.networking.domain;
      locations."^~ /" = {
        #proxyPass = "http://127.0.0.1:${builtins.toString apiPort}";
        extraConfig = ''
          grpc_pass grpc://127.0.0.1:${builtins.toString apiPort};
        '';
      };
    };

    services.nginx.virtualHosts.${kubeUrl} = {
      forceSSL = true;
      useACMEHost = config.networking.domain;
      locations."^~ /" = {
        proxyPass = "http://127.0.0.1:${builtins.toString kubePort}";
        extraConfig = ''
          proxy_http_version 1.1;
          proxy_set_header Upgrade $http_upgrade;
          proxy_set_header Connection $connection_upgrade;
        '';
      };
    };

    ### firewall config
    networking.firewall.interfaces."siderolink" = mkIf cfg.openFirewall {
      allowedTCPPorts = [ 8090 8092 8093 10000 10001 ];
    };

    ### backups
    warnings = [
      (mkIf (!cfg.backup && config.mySystem.purpose != "Development")
        "WARNING: Backups for ${app} are disabled!")
    ];

    services.restic.backups = mkIf cfg.backup (config.lib.mySystem.mkRestic
      {
        inherit app user;
        paths = [ appFolder ];
        inherit appFolder;
      });

  };
}
