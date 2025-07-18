{ lib
, config
, pkgs
, ...
}:
with lib;
let
  cfg = config.mySystem.services.adguardhome;
  app = "adguard-home";
  yaml_schema_version = 28;
  port = 53;
  port_webui = 3000;
  adguardUser = "adguardhome";

  # blockListUrl = "https://v.firebog.net/hosts/lists.php?type=tick";
  # TODO: This wont work in pure mode due to a lack of sha256?
  # blockListraw = builtins.readFile(builtins.fetchurl { url = blockListUrl; });
  # blockLists = lists.init (strings.splitString "\n" blockListraw);
in
{
  options.mySystem.services.adguardhome = {
    enable = mkEnableOption "Adguard Home";
    addToHomepage = mkEnableOption "Add ${app} to homepage" // { default = true; };
    openFirewall = mkEnableOption "Open firewall for ${app}" // {
      default = true;
    };
  };

  config = mkIf cfg.enable {
    # Warn if backups are disable and machine isnt a dev box
    warnings = mkIf (yaml_schema_version != pkgs.adguardhome.schema_version) [ "WARNING: Adguard upstream YAML schema is version ${builtins.toString pkgs.adguardhome.schema_version}, this config is set to ${builtins.toString config.services.adguardhome.settings.schema_version}" ];

    sops.secrets."services/adguardhome/password" = {
      sopsFile = ./secrets.sops.yaml;
      owner = adguardUser;
      restartUnits = [ "adguardhome.service" ];
    };

    services.adguardhome = {
      enable = true;
      host = "0.0.0.0";
      port = port_webui;

      mutableSettings = false;
      settings = {
        schema_version = yaml_schema_version; # Just to be cautious, defualt is pkgs.adguardhome.schema_version.

        users = [{
          name = "admin";
          password = "ADGUARDPASS"; # placeholder
        }];

        auth_attempts = 3;
        block_auth_min = 3600;

        dns = {
          # dns server bind deets
          bind_host = "127.0.0.1";
          inherit port;

          protection_enabled = true;
          filtering_enabled = true;

          # bootstrap DNS - used for resolving upstream dns deets
          bootstrap_dns = [
            # quad9
            "9.9.9.10"
            "149.112.112.10"
            "2620:fe::10"
            "2620:fe::fe:10"

            # cloudflare
            "1.1.1.1"
            "2606:4700:4700::1111"
          ];

          # upstream DNS
          upstream_dns = [
            # split brain dns - forward to UDMP
            "[/nnhome.eu/]172.16.1.254"

            # reverse dns setup
            "[/in-addr.arpa/]172.16.1.254" # reverse dns lookup to UDMP
            "[/ip6.arpa/]172.16.1.254" # reverse dns lookup to UDMP

            # primary dns - cloudflare
            "https://dns.cloudflare.com/dns-query"

          ];
          upstream_mode = "load_balance";

          # fallback dns - quad9 and mullvad
          fallback_dns = [
            "https://dns10.quad9.net/dns-query"
            "https://doh.mullvad.net/dns-query"
          ];

          # resolving local addresses
          local_ptr_upstreams = [ "172.16.1.254" ]; # UDMP router
          use_private_ptr_resolvers = true;
          hostsfile_enabled = false;

          # security
          enable_dnssec = true;
          ratelimit = 0;

          # local cache settings
          cache_size = 100000000; # 100MB - unnessecary but hey
          cache_ttl_min = 60;
          cache_optimistic = true;

          theme = "auto";
        };


        filters =
          let
            urls = [
              { name = "AdGuard DNS filter"; url = "https://adguardteam.github.io/AdGuardSDNSFilter/Filters/filter.txt"; }
              { name = "AdAway Default Blocklist"; url = "https://adaway.org/hosts.txt"; }
              { name = "Big OSID"; url = "https://big.oisd.nl"; }
              { name = "1Hosts Lite"; url = "https://o0.pages.dev/Lite/adblock.txt"; }
              { name = "hagezi multi pro"; url = "https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/adblock/pro.txt"; }
              { name = "osint"; url = "https://osint.digitalside.it/Threat-Intel/lists/latestdomains.txt"; }
              { name = "phishing army"; url = "https://phishing.army/download/phishing_army_blocklist_extended.txt"; }
              { name = "notrack malware"; url = "https://gitlab.com/quidsup/notrack-blocklists/raw/master/notrack-malware.txt"; }
              { name = "EasyPrivacy"; url = "https://v.firebog.net/hosts/Easyprivacy.txt"; }
              { name = "NNHome Blacklist"; url = "https://forgejo.nnhome.eu/NNHome/dnslists/raw/branch/main/blocklist.txt"; }
            ];

            buildList = id: url: {
              enabled = true;
              inherit id;
              inherit (url) name;
              inherit (url) url;
            };
          in
          lib.imap1 buildList urls;

        # filters =
        #   let
        #     buildList = id: url: {
        #       enabled = true;
        #       inherit id;
        #       name = "List ${builtins.toString id}";
        #       inherit url;
        #     };
        #   in
        #     lib.imap1 buildList blockLists;

        whitelist_filters =
          let
            urls = [
              { name = "Hagezi Whitelist-Referral"; url = "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/whitelist-referral.txt"; }
              { name = "Hagezi Whitelist-UrlShortener"; url = "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/whitelist-urlshortener.txt"; }
              { name = "additional-hosts duckduckgo"; url = "https://raw.githubusercontent.com/DRSDavidSoft/additional-hosts/master/domains/whitelist/duckduckgo.txt"; }
              { name = "AnudeepND Whitelist"; url = "https://raw.githubusercontent.com/anudeepND/whitelist/master/domains/whitelist.txt"; }
              { name = "NNHome Whitelist"; url = "https://forgejo.nnhome.eu/NNHome/dnslists/raw/branch/main/allowlist.txt"; }
            ];

            buildList = idx: url: {
              enabled = true;
              id = builtins.add idx 1000000;
              inherit (url) name;
              inherit (url) url;
            };
          in

          lib.imap1 buildList urls;

      };
    };

    # add user, needed to access the secret
    users.users.${adguardUser} = {
      isSystemUser = true;
      group = adguardUser;
    };
    users.groups.${adguardUser} = { };


    # insert password before service starts
    # password in sops is unencrypted, so we bcrypt it
    # and insert it as per config requirements
    systemd.services.adguardhome = {
      preStart = lib.mkAfter ''
        HASH=$(cat ${config.sops.secrets."services/adguardhome/password".path} | ${pkgs.apacheHttpd}/bin/htpasswd -niB "" | cut -c 2-)
        ${pkgs.gnused}/bin/sed -i "s,ADGUARDPASS,$HASH," "$STATE_DIRECTORY/AdGuardHome.yaml"
      '';
      serviceConfig.User = adguardUser;
    };

    networking.firewall = mkIf cfg.openFirewall {

      allowedTCPPorts = [ port port_webui ];
      allowedUDPPorts = [ port port_webui ];

    };

    mySystem.services.gatus.monitors = [
      {
        name = "${config.networking.hostName} external dns";
        group = "dns";
        url = "${config.networking.hostName}.${config.mySystem.internalDomain}:${builtins.toString port}";
        dns = {
          query-name = "cloudflare.com";
          query-type = "A";
        };
        interval = "1m";
        alerts = [{ type = "telegram"; }];
        conditions = [ "[DNS_RCODE] == NOERROR" ];
      }
      {
        name = "${config.networking.hostName} internal dns";
        group = "dns";
        url = "${config.networking.hostName}.${config.mySystem.internalDomain}:${builtins.toString port}";
        dns = {
          query-name = "unifi.${config.mySystem.internalDomain}";
          query-type = "A";
        };
        interval = "1m";
        alerts = [{ type = "telegram"; }];
        conditions = [ "[DNS_RCODE] == NOERROR" ];
      }
    ];
  };

  imports = [
    ./exporter.nix
  ];
}
