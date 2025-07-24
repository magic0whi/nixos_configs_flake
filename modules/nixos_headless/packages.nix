{pkgs, ...}: { # List packages installed in system profile. To search, run: `nix search wget`
  environment.systemPackages = with pkgs; [
    # Archives
    zip
    xz
    zstd
    unzipNLS
    p7zip

    # Text Processing, ref: https://github.com/learnbyexample/Command-line-text-processing
    gnused # GNU sed, very powerful(mainly for replacing text in files)
    gawk # GNU awk, a pattern scanning and processing language
    jq # A lightweight and flexible command-line JSON processor

    # Networking tools
    mtr # A network diagnostic tool
    iperf3
    # dnsutils # `dig` + `nslookup`
    ldns # replacement of `dig`, it provide the command `drill`
    wget
    socat # replacement of openbsd-netcat
    nmap # A utility for network discovery and security auditing
    ipcalc # it is a calculator for the IPv4/v6 addresses

    # Misc
    file
    which

    # System call monitoring
    strace # system call monitoring
    ltrace # library call monitoring
    # tcpdump # network sniffer
    lsof # list open files

    # ebpf related tools
    # https://github.com/bpftrace/bpftrace
    bpftrace # powerful tracing tool
    bpftop # monitor BPF programs
    bpfmon # BPF based visual packet rate monitor

    # System monitoring
    # sysstat
    # iotop
    # iftop
    # nmon
    # sysbench

    # System tools
    psmisc # killall/pstree/prtstat/fuser/...
    lm_sensors # for `sensors` command
    # ethtool
    pciutils # lspci
    usbutils # lsusb
    hdparm # for disk performance, command
    dmidecode # a tool that reads information about your system's hardware from the BIOS according to the SMBIOS/DMI standard
    parted
    cryptsetup # dm-crypt tools
  ];
  # BCC - Tools for BPF-based Linux IO analysis, # networking, monitoring, and more.
  # Ref: https://github.com/iovisor/bcc
  programs.bcc.enable = true;
}
