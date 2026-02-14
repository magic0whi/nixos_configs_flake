{pkgs, lib, config, myvars, ...}: let
  server_pub_crt = "${myvars.secrets_dir}/proteus_server.pub.pem";
  server_priv_crt_base = {
    file = "${myvars.secrets_dir}/proteus_server.priv.pem.age";
    mode = "0400";
  };
  server_priv_crt_proteus = config.age.secrets."proteus_server.priv.pem".path;
  server_priv_crt_postgresql = config.age.secrets."postgresql_server.priv.pem".path;
in {
  age.secrets."proteus_server.priv.pem" = server_priv_crt_base // {owner = myvars.username;};
  age.secrets."postgresql_server.priv.pem" = server_priv_crt_base // {
    owner = config.systemd.services.postgresql.serviceConfig.User;
  };
  age.secrets."atuin.env" = {file = "${myvars.secrets_dir}/atuin.env.age"; mode = "0400"; owner = myvars.username;};
  networking.firewall = {
    allowedTCPPorts = [
      443 # WebDAV
      636 # OpenLDAP
      5201 # iperf3
      8888 # Atuin Server
      22000 # Syncthing TCP transfers
      53317 # LocalSend (HTTP/TCP)
    ];
    allowedUDPPorts = [
      636 # OpenLDAP
      5201 # iperf3
      21027 # Syncthing discovery broadcasts on IPv4 and multicasts on IPv6
      22000 # Syncthing QUIC transfers
      53317 # LocalSend (Multicast/UDP)
    ];
  };
  ## START tor.nix
  services.tor = {
    enable = true;
    client.enable = true;
    # openFirewall = true;
    settings = {
      # ExitNodes = "{GB}";
      ExitPolicy = ["accept *:*"];
      AvoidDiskWrites = 1;
      HardwareAccel = 1;
      UseBridges = true;
      ClientTransportPlugin = "snowflake exec ${lib.getExe' pkgs.snowflake "client"} -url https://snowflake-broker.azureedge.net/ -front ajax.aspnetcdn.com -ice stun:stun.l.google.com:19302,stun:stun.antisip.com:3478,stun:stun.bluesip.net:3478,stun:stun.dus.net:3478,stun:stun.epygi.com:3478,stun:stun.sonetel.com:3478,stun:stun.uls.co.za:3478,stun:stun.voipgate.com:3478,stun:stun.voys.nl:3478 utls-imitate=hellorandomizedalpn -log /tmp/snowflake-client.log";
      Bridge = [
        "snowflake 192.0.2.3:80 2B280B23E1107BB62ABFC40DDCC8824814F80A72 fingerprint=2B280B23E1107BB62ABFC40DDCC8824814F80A72 url=https://1098762253.rsc.cdn77.org/ fronts=www.cdn77.com,www.phpmyadmin.net ice=stun:stun.l.google.com:19302,stun:stun.antisip.com:3478,stun:stun.bluesip.net:3478,stun:stun.dus.net:3478,stun:stun.epygi.com:3478,stun:stun.sonetel.com:3478,stun:stun.uls.co.za:3478,stun:stun.voipgate.com:3478,stun:stun.voys.nl:3478 utls-imitate=hellorandomizedalpn"
        "snowflake 192.0.2.4:80 8838024498816A039FCBBAB14E6F40A0843051FA fingerprint=8838024498816A039FCBBAB14E6F40A0843051FA url=https://1098762253.rsc.cdn77.org/ fronts=www.cdn77.com,www.phpmyadmin.net ice=stun:stun.l.google.com:19302,stun:stun.antisip.com:3478,stun:stun.bluesip.net:3478,stun:stun.dus.net:3478,stun:stun.epygi.com:3478,stun:stun.sonetel.net:3478,stun:stun.uls.co.za:3478,stun:stun.voipgate.com:3478,stun:stun.voys.nl:3478 utls-imitate=hellorandomizedalpn"
      ];
    };
  };
  ## END tor.nix
  services.openldap = {
    enable = true;
    urlList = ["ldaps:///"];
    user = myvars.username;
    settings = {
      # dn: cn=config
      attrs = {
        # cn: config
        # objectClass: olcGlobal
        olcLogLevel = ["stats"];
        olcTLSCertificateFile = server_pub_crt;
        olcTLSCertificateKeyFile = server_priv_crt_proteus;
        olcTLSCipherSuite = "DEFAULT:!kRSA:!kDHE";
        olcTLSProtocolMin = "3.3"; # 3.4 for tls1.3

      };
      children = {
        "cn=schema".includes = [
          "${pkgs.openldap}/etc/schema/core.ldif"
          "${pkgs.openldap}/etc/schema/cosine.ldif"
          "${myvars.secrets_dir}/rfc2307bis.ldif"
          "${pkgs.openldap}/etc/schema/inetorgperson.ldif"
          "${myvars.secrets_dir}/schema.olcSudo"
        ];
        "olcDatabase={0}config" = {
          attrs = {
            objectClass = "olcDatabaseConfig";
            olcDatabase = "{0}config";
            olcAccess = ["{0}to * by * none break"];
            olcRootDN = "cn=Manager,dc=tailba6c3f,dc=ts,dc=net";
          };
        };
        "olcDatabase={1}mdb" = {
          attrs = {
            objectClass = ["olcDatabaseConfig" "olcMdbConfig"];
            olcDatabase = "{1}mdb";
            olcAccess = [
              ''{0}to attrs=userPassword,shadowLastChange,photo by self write by anonymous auth by dn.base="cn=Manager,dc=tailba6c3f,dc=ts,dc=net" write by * none''
              ''{1}to * by self read by dn.base="cn=Manager,dc=tailba6c3f,dc=ts,dc=net" write by * read''
            ];
            olcSuffix = "dc=tailba6c3f,dc=ts,dc=net";
            olcRootDN = "cn=Manager,dc=tailba6c3f,dc=ts,dc=net";
            olcRootPW = "{SSHA}dLYbsD1XU8q1Av/0zLE8CCFJX6z/6cA3";
            olcDbDirectory = "/var/lib/openldap/openldap-data";
            olcDbIndex = [
              "objectClass eq"
              "uid pres,eq"
              "cn,sn,mail pres,sub,eq"
              "dc eq"
            ];
          };
        };
      };
    };
    declarativeContents = {
      "dc=tailba6c3f,dc=ts,dc=net" = ''
        dn: dc=tailba6c3f,dc=ts,dc=net
        objectClass: dcObject
        objectClass: organization
        dc: tailba6c3f
        o: Proteus' Organization

        dn: cn=Manager,dc=tailba6c3f,dc=ts,dc=net
        objectClass: top
        objectClass: organizationalRole
        cn: Manager
        description: LDAP administrator
        roleOccupant: dc=tailba6c3f,dc=ts,dc=net

        dn: ou=People,dc=tailba6c3f,dc=ts,dc=net
        objectClass: top
        objectClass: organizationalUnit
        ou: People

        dn: ou=Group,dc=tailba6c3f,dc=ts,dc=net
        objectClass: top
        objectClass: organizationalUnit
        ou: Group

        dn: ou=Sudoers,dc=tailba6c3f,dc=ts,dc=net
        objectClass: top
        objectClass: organizationalUnit
        ou: Sudoers

        dn: cn=defaults,ou=Sudoers,dc=tailba6c3f,dc=ts,dc=net
        objectClass: top
        objectClass: sudoRole
        cn: defaults
        description: Default sudoOption's go here
        sudoOption: env_keep+=SSH_AUTH_SOCK
        sudoOption: passwd_timeout=0

        # The Sudoer rules order matter
        dn: cn=allowMainUserNoPass,ou=Sudoers,dc=tailba6c3f,dc=ts,dc=net
        objectClass: top
        objectClass: sudoRole
        cn: allowMainUserNoPass
        sudoUser: ${myvars.username}
        sudoHost: ALL
        sudoRunAsUser: ALL
        sudoOption: !authenticate
        sudoCommand: /usr/bin/psd-overlay-helper
        # Note: paru hardcoded 'sudo install -dm755 $CHROOT'
        # https://github.com/Morganamilo/paru/blob/5355012aa3529014145b8940dd0c62b21e53095a/src/chroot.rs#L43
        sudoCommand: /usr/bin/arch-nspawn
        sudoCommand: /usr/bin/cp -auT /var/lib/pacman/sync /tmp/aur_chroot/overlay/root/var/lib/pacman/sync
        sudoCommand: /usr/bin/install -dm755 {{ .COMMON.aurChrootPath }}/overlay
        sudoCommand: /usr/bin/mkarchroot
        sudoCommand: /usr/bin/pacman

        dn: cn=allowMainUserNoPassSetenv,ou=Sudoers,dc=tailba6c3f,dc=ts,dc=net
        objectClass: top
        objectClass: sudoRole
        cn: allowMainUserNoPassSetenv
        sudoUser: ${myvars.username}
        sudoHost: ALL
        sudoRunAsUser: ALL
        sudoOption: !authenticate
        sudoOption: setenv
        sudoCommand: /usr/bin/makechrootpkg

        dn: cn=allowMainUser,ou=Sudoers,dc=tailba6c3f,dc=ts,dc=net
        objectClass: top
        objectClass: sudoRole
        cn: allowMainUser
        sudoUser: ${myvars.username}
        sudoHost: ALL
        sudoRunAsUser: ALL
        sudoCommand: ALL

        dn: uid=${myvars.username},ou=People,dc=tailba6c3f,dc=ts,dc=net
        objectClass: top
        objectClass: person
        objectClass: organizationalPerson
        objectClass: inetOrgPerson
        objectClass: posixAccount
        objectClass: shadowAccount
        uid: ${myvars.username}
        cn: ${myvars.userfullname}
        sn: Qian
        givenName: Proteus
        title: Qiansan
        mobile: {{ keepassxcAttribute "chezmoi/openldap" "proteus_phone" }}
        mail: ${myvars.useremail}
        postalAddress: Toukyouto$Setagayaku$Kitazawa3Choume23Ban14Gou
        userPassword: {SSHA}LbpR3GOQuhToaqzVejQOTJuOFEjlUHgK
        labeledURI: https://magic0whi.github.io/
        loginShell: /bin/zsh
        uidNumber: 1000
        gidNumber: 1000
        homeDirectory: ${config.users.users.${myvars.username}.home}
        description: This is me

        dn: uid=atuin,ou=People,dc=tailba6c3f,dc=ts,dc=net
        objectClass: top
        objectClass: person
        objectClass: organizationalPerson
        objectClass: inetOrgPerson
        objectClass: posixAccount
        objectClass: shadowAccount
        uid: atuin
        sn: Atuin
        cn: Atuinsh Atuin
        userPassword: {SSHA}Tf4S6QVwUiSbgXAHlzPKepNpv/lgAB+Y
        loginShell: /usr/bin/nologin
        uidNumber: 1001
        gidNumber: 1001
        homeDirectory: /mnt/overlay/Services/atuin
        description: Magical shell history

        dn: cn=${myvars.username},ou=Group,dc=tailba6c3f,dc=ts,dc=net
        objectClass: top
        objectClass: posixGroup
        objectClass: groupOfMembers
        cn: ${myvars.username}
        gidNumber: 1000
        member: uid=${myvars.username},ou=People,dc=tailba6c3f,dc=ts,dc=net
      '';
    };
  };
  services.monero = {
    # enable = true;
    # dataDir = "/mnt/storage1/monero";
    extraConfig = ''
      # log-file=/mnt/storage1/monero/monero.log
      # log-level=0
      p2p-use-ipv6=1
      rpc-use-ipv6=1
      public-node=1
      confirm-external-bind=1
      rpc-bind-ipv6-address=fd7a:115c:a1e0::d901:e013
    '';
    rpc.address = "100.109.224.13";
    rpc.restricted = true;
  };
  services.samba = {
    enable = true;
    openFirewall = true;
    settings = {
      global = {
        "workgroup" = "WORKGROUP";
        "server string" = "smbnix";
        "netbios name" = "smbnix";
        "security" = "user";
        #"use sendfile" = "
        #"max protocol" = "smb2";
        # note: localhost is the ipv6 localhost ::1
        # "hosts allow" = "192.168.0. 127.0.0.1 localhost";
        # "hosts deny" = "0.0.0.0/0";
        "guest account" = "nobody";
        "map to guest" = "bad user";
      };
      "private" = {
        "path" = "/srv";
        "browseable" = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = myvars.username;
        "force group" = myvars.username;
      };
    };
  };
  services.samba-wsdd = {
    enable = true;
    openFirewall = true;
  };
  services.sftpgo = {
    enable = true;
    user = myvars.username;
    group = myvars.username;
    extraReadWriteDirs = [/srv];
    settings = {
      httpd.bindings = [{
        address = "0.0.0.0";
        enable_https = true;
        certificate_file = server_pub_crt;
        certificate_key_file = server_priv_crt_proteus;
      }];
      webdavd.bindings = [{
        address = "0.0.0.0";
        port = 443;
        enable_https = true;
        certificate_file = server_pub_crt;
        certificate_key_file = server_priv_crt_proteus;
      }];
    };
  };
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql.override {ldapSupport = true;};
    enableJIT = true;
    enableTCPIP = true;
    settings = {
      ssl = true;
      ssl_cert_file = server_pub_crt;
      ssl_key_file = server_priv_crt_postgresql;
    };
    ensureDatabases = ["mydatabase" "atuin"]; # TODO: Learn
    ensureUsers = [
      {
        name = "proteus";
        ensureClauses = {
          login = true;
          # superuser = true;
          createdb = true;
        };
      }
      {name = "atuin"; ensureDBOwnership = true;}
    ];
    authentication = ''
      #type database DBuser auth-method [auth-options]
      local all all trust
      host all all 100.64.0.0/10 ldap ldapurl="ldaps://proteus-nuc.tailba6c3f.ts.net:636/ou=People,dc=tailba6c3f,dc=ts,dc=net?uid?sub"
      host all all fd7a:115c:a1e0::/48 ldap ldapurl="ldaps://proteus-nuc.tailba6c3f.ts.net:636/ou=People,dc=tailba6c3f,dc=ts,dc=net?uid?sub"
    '';
  };
  # TODO: TLS support, reverse proxy
  services.atuin = {
    enable = true;
    openFirewall = true;
    database.uri = null;
    host = "0.0.0.0";
    openRegistration = true;
  };
  systemd.services.atuin.serviceConfig.EnvironmentFile = config.age.secrets."atuin.env".path;
}
