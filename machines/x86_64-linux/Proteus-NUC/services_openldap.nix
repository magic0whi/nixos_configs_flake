{myvars, config, pkgs, ...}: let
  # server_pub_crt = "${myvars.secrets_dir}/proteus_server.pub.pem";
  # server_priv_crt = config.age.secrets."openldap_server.priv.pem".path;
in {
  # age.secrets."openldap_server.priv.pem" = {
  #   file = "${myvars.secrets_dir}/proteus_server.priv.pem.age";
  #   mode = "0400";
  #   owner = config.services.openldap.user;
  # };
  services.openldap = {
    enable = true;
    # The `///` tells OpenLDAP to bind to the default port on all available
    # network interfaces (`0.0.0.0` and `::`)
    urlList = [/*"ldaps:///"*/ "ldap://127.0.0.1/"];
    settings = {
      # dn: cn=config
      attrs = {
        # cn: config
        # objectClass: olcGlobal
        olcLogLevel = ["stats"];
        # olcTLSCertificateFile = server_pub_crt;
        # olcTLSCertificateKeyFile = server_priv_crt;
        # olcTLSCipherSuite = "DEFAULT:!kRSA:!kDHE";
        # olcTLSProtocolMin = "3.3"; # 3.4 for tls1.3
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
        # sudoCommand: /usr/bin/arch-nspawn
        # sudoCommand: /usr/bin/pacman

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
        mobile: +44 1145114191
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
        loginShell: /run/current-system/sw/bin/nologin
        uidNumber: 1001
        gidNumber: 1001
        homeDirectory: /mnt/overlay/Services/atuin
        description: Magical shell history

        dn: uid=${config.services.immich.user},ou=People,dc=tailba6c3f,dc=ts,dc=net
        objectClass: top
        objectClass: person
        objectClass: organizationalPerson
        objectClass: inetOrgPerson
        objectClass: posixAccount
        objectClass: shadowAccount
        uid: ${config.services.immich.user}
        o: immich-app
        sn: Immich
        cn: Immich App
        userPassword: {SSHA}3zaMR2HtFO2t9FEI6BIiLEgddW6HGSol
        loginShell: /run/current-system/sw/bin/nologin
        uidNumber: 1002
        gidNumber: 1002
        homeDirectory: ${config.services.immich.mediaLocation}
        description: High performance self-hosted photo and video management solution.

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
}
