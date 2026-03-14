{
  flake.modules.homeManager.network-managing =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        # Traffic analysis
        termshark # TUI frontend for tshark, full packet analysis
        bandwhich # Real-time bandwidth usage by process and connection
        iftop # Real-time bandwidth usage by host
        bmon # Network bandwidth monitor with graphs

        # Diagnostics & scanning
        nmap # Network scanner and security auditing tool
        netcat-gnu # Read/write data across network connections
        traceroute # Trace packet route to a host
        mtr # Combines ping and traceroute in one TUI tool
        dig # DNS lookup utility
        whois # Query domain registration info

        # HTTP
        curl # Transfer data with URLs, supports many protocols
        httpie # User-friendly HTTP client for the terminal
        wget # Non-interactive network downloader

        # Tunneling & proxy
        socat # Multipurpose relay for bidirectional data transfer
        sshuttle # Transparent proxy over SSH (poor man's VPN)
      ];
    };
}
