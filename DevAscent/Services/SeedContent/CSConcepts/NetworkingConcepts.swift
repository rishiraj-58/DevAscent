//
//  NetworkingConcepts.swift
//  DevAscent
//
//  Computer Networks CS Concepts - Comprehensive Interview Questions
//

import Foundation

struct NetworkingConcepts {
    static func all() -> [CSConcept] {
        return [
            // MARK: - TCP/IP Fundamentals
            CSConcept(
                category: .cn,
                question: "What is TCP/IP?",
                answer: """
                Set of protocols for internet communication.

                **TCP (Transmission Control Protocol):**
                - Breaks data into packets
                - Ensures reliable, ordered delivery
                - Connection-oriented

                **IP (Internet Protocol):**
                - Address system for routing
                - Finds path to destination
                - Connectionless

                **TCP/IP Model:** 4 layers (Application, Transport, Internet, Network Access)
                """,
                tags: ["TCP/IP", "fundamentals"]
            ),
            CSConcept(
                category: .cn,
                question: "TCP vs UDP?",
                answer: """
                | TCP | UDP |
                |-----|-----|
                | Connection-oriented | Connectionless |
                | Reliable (ACK, retransmit) | Unreliable |
                | Ordered delivery | No ordering |
                | Slower (overhead) | Faster |
                | Flow/Congestion control | No control |
                | 20-60 byte header | 8 byte header |

                **TCP:** HTTP, FTP, SMTP, SSH
                **UDP:** DNS, DHCP, VoIP, Gaming, Streaming
                """,
                tags: ["TCP", "UDP", "comparison"]
            ),
            CSConcept(
                category: .cn,
                question: "TCP 3-Way Handshake?",
                answer: """
                **Connection Establishment:**
                1. **SYN:** Client → Server (seq=x)
                2. **SYN-ACK:** Server → Client (seq=y, ack=x+1)
                3. **ACK:** Client → Server (ack=y+1)

                **Why 3-way?**
                - Both sides confirm send & receive capability
                - Synchronize sequence numbers
                - Prevent old duplicates

                **4-Way Termination:**
                FIN → ACK → FIN → ACK (with TIME_WAIT)
                """,
                tags: ["TCP", "handshake", "connection"]
            ),
            CSConcept(
                category: .cn,
                question: "TCP Header Flags?",
                answer: """
                **6 TCP Flags:**
                - **SYN:** Synchronize sequence numbers
                - **ACK:** Acknowledgment valid
                - **FIN:** Terminate connection
                - **RST:** Reset connection
                - **PSH:** Push data immediately
                - **URG:** Urgent data

                **Header Size:** 20-60 bytes
                **Checksum:** Mandatory for error detection
                """,
                tags: ["TCP", "flags", "header"]
            ),
            CSConcept(
                category: .cn,
                question: "What is a Port?",
                answer: """
                Logical endpoint for communication.

                **Well-Known Ports (0-1023):**
                - 20/21: FTP
                - 22: SSH
                - 23: Telnet
                - 25: SMTP
                - 53: DNS
                - 80: HTTP
                - 443: HTTPS

                **Registered (1024-49151):** Application-specific
                **Dynamic (49152-65535):** Temporary client ports
                """,
                tags: ["port", "fundamentals"]
            ),
            
            // MARK: - IP Addressing
            CSConcept(
                category: .cn,
                question: "IP Address Classes?",
                answer: """
                **Class A:** 1.0.0.0 - 126.255.255.255 (Large networks)
                **Class B:** 128.0.0.0 - 191.255.255.255 (Medium)
                **Class C:** 192.0.0.0 - 223.255.255.255 (Small)
                **Class D:** 224.0.0.0 - 239.255.255.255 (Multicast)
                **Class E:** 240.0.0.0 - 255.255.255.255 (Reserved)

                **127.x.x.x:** Loopback (localhost)
                """,
                tags: ["IP", "classes", "addressing"]
            ),
            CSConcept(
                category: .cn,
                question: "Private vs Public IP?",
                answer: """
                **Private IP (Not routable on internet):**
                - 10.0.0.0 - 10.255.255.255
                - 172.16.0.0 - 172.31.255.255
                - 192.168.0.0 - 192.168.255.255

                **Public IP:**
                - Globally unique
                - Routable on internet
                - Assigned by ISP

                **NAT:** Translates private ↔ public
                """,
                tags: ["IP", "private", "public", "NAT"]
            ),
            CSConcept(
                category: .cn,
                question: "What is MAC Address?",
                answer: """
                Media Access Control - Physical hardware address.

                **Properties:**
                - 48 bits (6 bytes)
                - Format: AA:BB:CC:DD:EE:FF
                - Burned into NIC
                - Unique per device

                **Use:** Communication within local network (Layer 2)

                **MAC vs IP:** MAC for local, IP for routing
                """,
                tags: ["MAC", "addressing"]
            ),
            CSConcept(
                category: .cn,
                question: "What is NAT?",
                answer: """
                Network Address Translation - Maps private to public IP.

                **How it works:**
                1. Internal device sends packet
                2. Router replaces private IP with public IP
                3. Maintains translation table
                4. Routes response back to internal device

                **Types:**
                - Static NAT: One-to-one mapping
                - Dynamic NAT: Pool of public IPs
                - PAT (Port Address Translation): Many-to-one
                """,
                tags: ["NAT", "addressing"]
            ),
            CSConcept(
                category: .cn,
                question: "What is TTL (Time To Live)?",
                answer: """
                Limits packet lifespan in network.

                **How it works:**
                - Set by sender (e.g., 64)
                - Decremented by each router
                - Packet discarded when TTL = 0

                **Purpose:**
                - Prevent infinite loops
                - Avoid stale packets

                **Uses:** traceroute utility
                """,
                tags: ["TTL", "routing"]
            ),
            
            // MARK: - OSI Model
            CSConcept(
                category: .cn,
                question: "OSI Model - 7 Layers?",
                answer: """
                **7. Application:** HTTP, FTP, SMTP, DNS
                **6. Presentation:** SSL/TLS, encryption, compression
                **5. Session:** Session management, RPC
                **4. Transport:** TCP, UDP (ports)
                **3. Network:** IP, routing (logical addresses)
                **2. Data Link:** Ethernet, MAC (physical addresses)
                **1. Physical:** Cables, bits, signals

                **Mnemonic:** "All People Seem To Need Data Processing"
                """,
                tags: ["OSI", "layers", "model"]
            ),
            CSConcept(
                category: .cn,
                question: "TCP/IP Model vs OSI?",
                answer: """
                | TCP/IP | OSI |
                |--------|-----|
                | 4 layers | 7 layers |
                | Practical | Theoretical |
                | Internet standard | Reference model |

                **TCP/IP Layers:**
                4. Application (OSI 5-7)
                3. Transport (OSI 4)
                2. Internet (OSI 3)
                1. Network Access (OSI 1-2)
                """,
                tags: ["TCP/IP", "OSI", "comparison"]
            ),
            
            // MARK: - Network Devices
            CSConcept(
                category: .cn,
                question: "Hub vs Switch vs Router?",
                answer: """
                **Hub (Layer 1):**
                - Broadcasts to ALL ports
                - No intelligence
                - Creates collisions

                **Switch (Layer 2):**
                - Forwards to specific port
                - Uses MAC addresses
                - Reduces collisions

                **Router (Layer 3):**
                - Connects different networks
                - Uses IP addresses
                - Makes routing decisions
                """,
                tags: ["hub", "switch", "router"]
            ),
            CSConcept(
                category: .cn,
                question: "What is a Firewall?",
                answer: """
                Security system controlling network traffic.

                **Types:**
                - Packet Filtering: Check IP, port
                - Stateful: Track connection state
                - Application (Layer 7): Deep packet inspection
                - Next-Gen (NGFW): IPS + application awareness

                **Functions:**
                - Block unwanted traffic
                - Allow authorized traffic
                - Log activity
                """,
                tags: ["firewall", "security"]
            ),
            
            // MARK: - DNS
            CSConcept(
                category: .cn,
                question: "What is DNS?",
                answer: """
                Domain Name System - Translates names to IP addresses.

                **Resolution Process:**
                1. Browser cache
                2. OS cache
                3. Router cache
                4. ISP DNS → Root → TLD → Authoritative

                **Record Types:**
                - A: Domain → IPv4
                - AAAA: Domain → IPv6
                - CNAME: Alias
                - MX: Mail server
                - NS: Name server
                """,
                tags: ["DNS", "resolution"]
            ),
            CSConcept(
                category: .cn,
                question: "DNS Record Types?",
                answer: """
                **A Record:** Maps domain to IPv4 address
                **AAAA Record:** Maps domain to IPv6
                **CNAME:** Canonical name (alias)
                **MX:** Mail exchange server
                **NS:** Authoritative name servers
                **TXT:** Arbitrary text (SPF, DKIM)
                **PTR:** Reverse DNS lookup
                **SOA:** Start of Authority

                **TTL:** Cache duration for record
                """,
                tags: ["DNS", "records"]
            ),
            
            // MARK: - HTTP/HTTPS
            CSConcept(
                category: .cn,
                question: "HTTP vs HTTPS?",
                answer: """
                **HTTP:**
                - Plaintext, unencrypted
                - Port 80
                - Fast but insecure

                **HTTPS:**
                - HTTP + TLS encryption
                - Port 443
                - Certificate required
                - Protects data in transit

                **TLS:** Encrypts data, authenticates server
                """,
                tags: ["HTTP", "HTTPS", "security"]
            ),
            CSConcept(
                category: .cn,
                question: "HTTP/2 vs HTTP/3?",
                answer: """
                **HTTP/2:**
                - Binary protocol (faster parsing)
                - Multiplexing (multiple requests, one connection)
                - Header compression (HPACK)
                - Server push
                - Based on TCP

                **HTTP/3:**
                - Based on QUIC (UDP)
                - 0-RTT connection
                - Built-in encryption
                - No head-of-line blocking
                """,
                tags: ["HTTP/2", "HTTP/3", "QUIC"]
            ),
            CSConcept(
                category: .cn,
                question: "HTTP Methods?",
                answer: """
                **GET:** Retrieve resource (safe, idempotent)
                **POST:** Create resource (not idempotent)
                **PUT:** Replace resource (idempotent)
                **PATCH:** Partial update
                **DELETE:** Remove resource (idempotent)
                **HEAD:** GET without body
                **OPTIONS:** Supported methods

                **Idempotent:** Same request = same result
                """,
                tags: ["HTTP", "methods", "REST"]
            ),
            CSConcept(
                category: .cn,
                question: "HTTP Status Codes?",
                answer: """
                **2xx Success:**
                - 200 OK, 201 Created, 204 No Content

                **3xx Redirect:**
                - 301 Moved Permanently, 304 Not Modified

                **4xx Client Error:**
                - 400 Bad Request, 401 Unauthorized
                - 403 Forbidden, 404 Not Found

                **5xx Server Error:**
                - 500 Internal Error, 502 Bad Gateway
                - 503 Service Unavailable
                """,
                tags: ["HTTP", "status codes"]
            ),
            CSConcept(
                category: .cn,
                question: "TLS Handshake?",
                answer: """
                **Steps:**
                1. **Client Hello:** TLS version, cipher suites, random
                2. **Server Hello:** Chosen cipher, certificate
                3. **Certificate Verify:** Client validates with CA
                4. **Key Exchange:** Generate session keys
                5. **Finished:** Encrypted communication begins

                **Asymmetric (RSA):** Key exchange only
                **Symmetric (AES):** Data encryption (faster)

                **TLS 1.3:** Faster, 1-RTT handshake
                """,
                tags: ["TLS", "HTTPS", "handshake"]
            ),
            
            // MARK: - Routing & Protocols
            CSConcept(
                category: .cn,
                question: "What is Routing?",
                answer: """
                Process of selecting paths for data packets.

                **How it works:**
                1. Router receives packet
                2. Checks routing table
                3. Forwards to next hop
                4. Process repeats until destination

                **Static Routing:** Manually configured
                **Dynamic Routing:** Protocols update tables (OSPF, BGP)
                """,
                tags: ["routing", "fundamentals"]
            ),
            CSConcept(
                category: .cn,
                question: "What is ARP?",
                answer: """
                Address Resolution Protocol - Maps IP to MAC.

                **How it works:**
                1. Device knows destination IP
                2. Broadcasts ARP request: "Who has IP X?"
                3. Device with that IP responds with MAC
                4. Sender caches MAC for future use

                **ARP Cache:** Stores IP-MAC mappings
                **Reverse ARP (RARP):** MAC to IP
                """,
                tags: ["ARP", "addressing"]
            ),
            CSConcept(
                category: .cn,
                question: "What is DHCP?",
                answer: """
                Dynamic Host Configuration Protocol - Auto-assigns IP.

                **DORA Process:**
                1. **Discover:** Client broadcasts request
                2. **Offer:** Server offers IP address
                3. **Request:** Client requests offered IP
                4. **Acknowledge:** Server confirms assignment

                **Assigns:** IP, Subnet mask, Gateway, DNS
                """,
                tags: ["DHCP", "IP"]
            ),
            CSConcept(
                category: .cn,
                question: "What is ICMP?",
                answer: """
                Internet Control Message Protocol - Network diagnostics.

                **Uses:**
                - **ping:** Check host reachability
                - **traceroute:** Path to destination
                - Error reporting (unreachable, timeout)

                **Messages:**
                - Echo Request/Reply (ping)
                - Destination Unreachable
                - Time Exceeded (TTL = 0)
                """,
                tags: ["ICMP", "ping", "traceroute"]
            ),
            
            // MARK: - Congestion & Flow Control
            CSConcept(
                category: .cn,
                question: "TCP Congestion Control?",
                answer: """
                **Phases:**
                1. **Slow Start:** Window grows exponentially
                2. **Congestion Avoidance:** Linear growth after threshold
                3. **Fast Retransmit:** On 3 duplicate ACKs
                4. **Fast Recovery:** Reduce window, don't reset

                **Algorithms:** Tahoe, Reno, CUBIC, BBR

                **Congestion Window (cwnd):** Limits packets in flight
                """,
                tags: ["TCP", "congestion", "control"]
            ),
            CSConcept(
                category: .cn,
                question: "Stop-and-Wait vs Sliding Window?",
                answer: """
                **Stop-and-Wait:**
                - Send one frame, wait for ACK
                - Simple but inefficient
                - Half duplex

                **Sliding Window:**
                - Send multiple frames before ACK
                - More efficient
                - Full duplex

                **Window Size:** Number of unacknowledged frames
                """,
                tags: ["flow control", "sliding window"]
            ),
            CSConcept(
                category: .cn,
                question: "Leaky Bucket vs Token Bucket?",
                answer: """
                **Leaky Bucket:**
                - Output at constant rate
                - Smooths bursty traffic
                - Packets may be discarded

                **Token Bucket:**
                - Tokens generated at fixed rate
                - Packet sent only with token
                - Allows controlled bursts

                **Token Bucket advantage:** Can handle bursts better
                """,
                tags: ["traffic shaping", "congestion"]
            ),
            
            // MARK: - Error Control
            CSConcept(
                category: .cn,
                question: "TCP Error Control?",
                answer: """
                **Mechanisms:**
                1. **Checksum:** Detect corrupted segments
                2. **Acknowledgment:** Confirm receipt
                3. **Retransmission:** Resend lost/corrupted data

                **Retransmission Triggers:**
                - Timeout (RTO)
                - 3 duplicate ACKs (fast retransmit)

                **Sequence Numbers:** Detect duplicates, ordering
                """,
                tags: ["TCP", "error control"]
            ),
            CSConcept(
                category: .cn,
                question: "What is RTT (Round Trip Time)?",
                answer: """
                Time for packet to go and acknowledgment to return.

                **Includes:**
                - Propagation delay
                - Processing delay
                - Queuing delay
                - Transmission delay

                **Uses:**
                - Calculate retransmission timeout (RTO)
                - Network performance measurement

                **Formula:** RTT = 2 × Propagation time (approx)
                """,
                tags: ["RTT", "latency"]
            ),
            
            // MARK: - Data Link Layer
            CSConcept(
                category: .cn,
                question: "What is Fragmentation?",
                answer: """
                Breaking large packets into smaller fragments.

                **Why needed:**
                - Different networks have different MTU
                - Packet too large for next hop

                **MTU:** Maximum Transmission Unit (Ethernet = 1500 bytes)

                **Reassembly:** Done at destination, not intermediate routers
                """,
                tags: ["fragmentation", "MTU"]
            ),
            CSConcept(
                category: .cn,
                question: "Connection-Oriented vs Connectionless?",
                answer: """
                **Connection-Oriented (TCP):**
                - Setup connection first
                - Reliable, ordered
                - Higher overhead
                - Like telephone

                **Connectionless (UDP):**
                - No prior connection
                - Unreliable, unordered
                - Lower overhead
                - Like postal mail
                """,
                tags: ["connection", "comparison"]
            ),
            
            // MARK: - Advanced Topics
            CSConcept(
                category: .cn,
                question: "IPv4 vs IPv6?",
                answer: """
                | IPv4 | IPv6 |
                |------|------|
                | 32-bit address | 128-bit address |
                | 4.3 billion addresses | 340 undecillion |
                | Header checksum | No checksum |
                | NAT required | NAT not needed |
                | Dotted decimal | Hexadecimal |

                **IPv6 features:** Auto-configuration, Better security
                """,
                tags: ["IPv4", "IPv6", "addressing"]
            ),
            CSConcept(
                category: .cn,
                question: "What is Tunneling?",
                answer: """
                Encapsulating one protocol inside another.

                **Use cases:**
                - IPv6 over IPv4 networks
                - VPN (Virtual Private Network)
                - Bypassing firewalls

                **Types:**
                - 6to4: IPv6 in IPv4
                - IPSec: Secure tunneling
                - GRE: Generic Routing Encapsulation
                """,
                tags: ["tunneling", "VPN"]
            ),
            CSConcept(
                category: .cn,
                question: "Load Balancing Algorithms?",
                answer: """
                **Round Robin:** Rotate through servers
                **Weighted RR:** More to powerful servers
                **Least Connections:** Send to least busy
                **IP Hash:** Same client → same server
                **Least Response Time:** Fastest server

                **Layer 4:** TCP/UDP level (faster)
                **Layer 7:** HTTP level (content-aware)
                """,
                tags: ["load balancing", "scaling"]
            ),
            CSConcept(
                category: .cn,
                question: "What is SCTP?",
                answer: """
                Stream Control Transmission Protocol.

                **Features:**
                - Connection-oriented like TCP
                - Message-oriented like UDP
                - Multi-streaming (multiple data streams)
                - Multi-homing (multiple IP addresses)
                - Full-duplex

                **Use:** VoIP, telephony over internet
                """,
                tags: ["SCTP", "transport"]
            ),
            CSConcept(
                category: .cn,
                question: "REST API Best Practices?",
                answer: """
                **URL Design:**
                - Nouns, not verbs: /users not /getUsers
                - Plural: /users/123
                - Hierarchical: /users/123/orders

                **Versioning:** /api/v1/users

                **Pagination:** ?page=2&limit=20

                **HATEOAS:** Include links to related resources
                """,
                tags: ["REST", "API", "best practices"]
            ),
            CSConcept(
                category: .cn,
                question: "What is a Datagram?",
                answer: """
                Independent unit of data for transmission.

                **Properties:**
                - Self-contained with header + data
                - No prior connection needed
                - May take different paths
                - May arrive out of order

                **Used by:** IP, UDP (connectionless protocols)
                """,
                tags: ["datagram", "fundamentals"]
            ),
            CSConcept(
                category: .cn,
                question: "TCP Connection Phases?",
                answer: """
                **1. Connection Establishment:**
                - 3-way handshake (SYN, SYN-ACK, ACK)

                **2. Data Transfer:**
                - Reliable, ordered segment exchange
                - Acknowledgments and retransmissions

                **3. Connection Termination:**
                - 4-way handshake (FIN-ACK sequence)
                - TIME_WAIT state prevents old duplicates
                """,
                tags: ["TCP", "connection", "phases"]
            ),
            CSConcept(
                category: .cn,
                question: "TCP Header Size?",
                answer: """
                **Minimum:** 20 bytes (no options)
                **Maximum:** 60 bytes (with options)

                **Key Fields:**
                - Source/Destination Port (16 bits each)
                - Sequence Number (32 bits)
                - Acknowledgment Number (32 bits)
                - Flags (6 bits)
                - Window Size (16 bits)
                - Checksum (16 bits)
                """,
                tags: ["TCP", "header"]
            ),
            CSConcept(
                category: .cn,
                question: "Dual Stack for IPv4 to IPv6?",
                answer: """
                **Transition Strategies:**

                1. **Dual Stack:** Device supports both IPv4 and IPv6
                2. **Tunneling:** Encapsulate IPv6 in IPv4
                3. **Header Translation:** Convert headers between versions

                **Dual Stack:** Most common, gradual transition
                """,
                tags: ["IPv4", "IPv6", "transition"]
            ),
            CSConcept(
                category: .cn,
                question: "Why is Checksum removed in IPv6?",
                answer: """
                **Reasons:**
                - Upper layer protocols (TCP/UDP) already have checksums
                - Reduces processing overhead at routers
                - Faster forwarding

                **IPv4 checksum:** Only covers header
                **TCP/UDP checksum:** Covers data too

                **Design philosophy:** Keep IP simple, fast
                """,
                tags: ["IPv6", "checksum"]
            )
        ]
    }
}
