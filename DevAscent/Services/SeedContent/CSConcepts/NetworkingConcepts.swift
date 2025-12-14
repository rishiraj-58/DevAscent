//
//  NetworkingConcepts.swift
//  DevAscent
//
//  Computer Networks CS Concepts
//

import Foundation

struct NetworkingConcepts {
    static func all() -> [CSConcept] {
        return [
            CSConcept(
                category: .cn,
                question: "TCP 3-Way Handshake",
                answer: """
                **Purpose:** Establish reliable connection

                1. **SYN:** Client → Server
                   - Client sends SYN with sequence number x

                2. **SYN-ACK:** Server → Client
                   - Server sends SYN with sequence number y
                   - ACK = x + 1

                3. **ACK:** Client → Server
                   - Client sends ACK = y + 1
                   - Connection established

                **Why 3-way?**
                - Ensures both sides can send AND receive
                - Synchronizes sequence numbers
                - Prevents old duplicate connections

                **4-Way Termination:**
                FIN → ACK → FIN → ACK (with TIME_WAIT)
                """,
                tags: ["TCP", "handshake", "networking", "connection"]
            ),
            CSConcept(
                category: .cn,
                question: "HTTP vs HTTPS vs HTTP/2",
                answer: """
                **HTTP:**
                - Plaintext protocol
                - Stateless
                - Port 80

                **HTTPS:**
                - HTTP + TLS encryption
                - Certificate-based authentication
                - Port 443

                **HTTP/2:**
                - Binary protocol (faster parsing)
                - Multiplexing (multiple requests on one connection)
                - Header compression (HPACK)
                - Server push
                - Stream prioritization

                **HTTP/3:**
                - QUIC protocol (UDP-based)
                - 0-RTT connection establishment
                - Built-in encryption
                """,
                tags: ["HTTP", "HTTPS", "HTTP/2", "networking", "TLS"]
            ),
            CSConcept(
                category: .cn,
                question: "OSI Model - 7 Layers",
                answer: """
                7. Application (HTTP, FTP, SMTP, DNS)
                   • User-facing protocols

                6. Presentation (SSL/TLS, JPEG, encryption)
                   • Data format, encryption

                5. Session (NetBIOS, RPC)
                   • Session management

                4. Transport (TCP, UDP)
                   • End-to-end delivery, ports

                3. Network (IP, ICMP, routers)
                   • Logical addressing, routing

                2. Data Link (Ethernet, MAC, switches)
                   • Physical addressing, frames

                1. Physical (cables, hubs, bits)
                   • Raw bit transmission

                Mnemonic: "All People Seem To Need Data Processing"
                """,
                tags: ["OSI", "layers", "networking", "protocols"]
            ),
            CSConcept(
                category: .cn,
                question: "TCP vs UDP",
                answer: """
                TCP (Transmission Control Protocol):
                • Connection-oriented (3-way handshake)
                • Reliable (ACK, retransmission)
                • Ordered delivery
                • Flow control, congestion control
                • Use: HTTP, FTP, Email, Banking

                UDP (User Datagram Protocol):
                • Connectionless
                • Unreliable (no ACK)
                • No ordering guarantee
                • Faster, lower overhead
                • Use: Video streaming, Gaming, DNS, VoIP

                Why UDP for video?
                • Dropped frame < delayed frame
                • Real-time matters more than completeness
                • App handles error correction
                """,
                tags: ["TCP", "UDP", "transport", "protocols"]
            ),
            CSConcept(
                category: .cn,
                question: "HTTP Methods & Status Codes",
                answer: """
                Methods:
                GET: Retrieve resource (idempotent, safe)
                POST: Create resource (NOT idempotent)
                PUT: Replace resource (idempotent)
                PATCH: Partial update
                DELETE: Remove resource (idempotent)

                PUT vs POST:
                PUT /users/123 → Update user 123
                POST /users → Create new user

                Status Codes:
                2xx Success: 200 OK, 201 Created, 204 No Content
                3xx Redirect: 301 Moved Permanently, 304 Not Modified
                4xx Client Error: 400 Bad Request, 401 Unauthorized, 403 Forbidden, 404 Not Found
                5xx Server Error: 500 Internal Error, 502 Bad Gateway, 503 Service Unavailable

                Idempotent: Same request = same result (GET, PUT, DELETE)
                """,
                tags: ["HTTP", "REST", "status codes", "methods"]
            ),
            CSConcept(
                category: .cn,
                question: "HTTPS/TLS Handshake",
                answer: """
                1. Client Hello:
                   • TLS version, cipher suites, random

                2. Server Hello:
                   • Chosen cipher, server random
                   • Server certificate

                3. Certificate Verification:
                   • Client verifies with CA

                4. Key Exchange:
                   • Client generates pre-master secret
                   • Encrypts with server's public key
                   • Both derive session keys

                5. Finished:
                   • Both send encrypted "Finished"
                   • Symmetric encryption begins

                Symmetric vs Asymmetric:
                • Asymmetric (RSA): Key exchange only
                • Symmetric (AES): Data encryption (faster)

                TLS 1.3: Faster, 1-RTT or 0-RTT handshake
                """,
                tags: ["HTTPS", "TLS", "SSL", "handshake", "encryption"]
            ),
            CSConcept(
                category: .cn,
                question: "DNS Resolution Process",
                answer: """
                1. Browser cache check
                2. OS cache check
                3. Router cache check

                4. Recursive Query to ISP DNS:
                   a. Root DNS → .com TLD address
                   b. TLD DNS → google.com NS
                   c. Authoritative DNS → IP address

                5. Cache response at each level

                Record Types:
                • A: Domain → IPv4
                • AAAA: Domain → IPv6
                • CNAME: Alias
                • MX: Mail server
                • NS: Name server
                • TXT: Arbitrary text (SPF, DKIM)

                TTL: Time to cache
                DNS over HTTPS (DoH): Privacy
                """,
                tags: ["DNS", "resolution", "A record", "caching"]
            ),
            CSConcept(
                category: .cn,
                question: "Load Balancing Algorithms",
                answer: """
                Round Robin:
                • Rotate through servers
                • Simple, equal distribution

                Weighted Round Robin:
                • More requests to powerful servers
                • Weight based on capacity

                Least Connections:
                • Send to server with fewest active connections
                • Good for varying request times

                IP Hash:
                • Hash client IP → consistent server
                • Session affinity (sticky sessions)

                Least Response Time:
                • Active connections + response time
                • Best for performance

                Layer 4 (Transport): TCP/UDP level
                Layer 7 (Application): HTTP level, content-based

                Health Checks: Remove unhealthy servers
                """,
                tags: ["load balancing", "round robin", "nginx", "scaling"]
            ),
            CSConcept(
                category: .cn,
                question: "REST API Best Practices",
                answer: """
                URL Design:
                • Nouns, not verbs: /users not /getUsers
                • Plural: /users/123
                • Hierarchical: /users/123/orders

                HTTP Methods:
                GET /users - List
                POST /users - Create
                GET /users/123 - Read
                PUT /users/123 - Replace
                PATCH /users/123 - Update
                DELETE /users/123 - Delete

                Versioning:
                • URL: /api/v1/users
                • Header: Accept: application/vnd.api.v1+json

                Pagination:
                ?page=2&limit=20
                Return: { data: [], total: 100, page: 2 }

                Error Response:
                { "error": { "code": "NOT_FOUND", "message": "..." } }

                HATEOAS: Include links to related resources
                """,
                tags: ["REST", "API", "HTTP", "best practices"]
            )
        ]
    }
}
