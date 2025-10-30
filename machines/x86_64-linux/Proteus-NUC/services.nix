{pkgs, ...}: {
  services.openldap = {
    enable = true;
    urlList = ["ldaps:///"];
    settings = {
      # TODO
      children = {
        "cn=schema".includes = [
          "${pkgs.openldap}/etc/schema/core.ldif"
          "${pkgs.openldap}/etc/openldap/schema/cosine.ldif"
          "${pkgs.openldap}"
          "${pkgs.openldap}"
          "${pkgs.openldap}"
        ];
      };
      "olcDatabase={1}mdb" = {
        attrs = {
          objectClass = ["olcDatabaseConfig" "olcMdbConfig"];
          olcDatabase = "{1}mdb";
        };
      };
    };
  };
}
