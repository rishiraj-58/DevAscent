//
//  URLShortenerLLD.swift
//  DevAscent
//
//  URL Shortener (TinyURL) LLD Problem
//

import Foundation

struct URLShortenerLLD {
    static func create() -> LLDProblem {
        return LLDProblem(
            title: "URL Shortener (TinyURL)",
            requirements: """
            • Generate short URL from long URL
            • Redirect short URL to original
            • Custom alias support
            • Expiration time
            • Analytics (click count)
            """,
            solutionStrategy: """
            **Patterns Used:**
            - **Factory Pattern**: Short URL generation
            
            **Key Algorithm:**
            - Base62 encoding of auto-increment ID
            - Consistent hashing for distributed storage

            **Scale:**
            - Read-heavy: 100:1 read/write ratio
            - Cache short→long mappings
            """,
            mermaidGraph: """
            classDiagram
                class URLService {
                    -CodeGenerator codeGenerator
                    -URLRepository repository
                    -CacheLayer cache
                    -RateLimiter rateLimiter
                    +shorten(ShortenRequest) ShortenResponse
                    +resolve(shortCode) String
                    +getAnalytics(shortCode) Analytics
                    +deleteUrl(shortCode) boolean
                }
                
                class ShortenRequest {
                    -String longUrl
                    -String customAlias
                    -DateTime expiresAt
                    -String userId
                }
                
                class URLMapping {
                    -String shortCode
                    -String longUrl
                    -String userId
                    -DateTime createdAt
                    -DateTime expiresAt
                    -boolean isActive
                    +isExpired() boolean
                }
                
                class CodeGenerator {
                    
                    +generate() String
                }
                
                class Base62Generator {
                    -IdGenerator idGenerator
                    +generate() String
                    -encode(long) String
                }
                
                class HashGenerator {
                    +generate() String
                    -hash(String) String
                }
                
                class IdGenerator {
                    
                    +nextId() long
                }
                
                class SnowflakeIdGenerator {
                    -long machineId
                    -long sequence
                    -long lastTimestamp
                    +nextId() long
                }
                
                class ZookeeperIdGenerator {
                    -ZkClient zkClient
                    -AtomicLong counter
                    +nextId() long
                }
                
                class CacheLayer {
                    -RedisClient redis
                    -int ttlSeconds
                    +get(key) String
                    +put(key, value) void
                    +invalidate(key) void
                }
                
                class AnalyticsService {
                    -ClickRepository clickRepo
                    -TimeSeriesDB tsdb
                    +recordClick(Click) void
                    +getStats(shortCode) Analytics
                    +getTopUrls(n) List
                }
                
                class Click {
                    -String shortCode
                    -DateTime timestamp
                    -String userAgent
                    -String referrer
                    -String ipAddress
                    -GeoLocation location
                }
                
                class RateLimiter {
                    -Map buckets
                    +isAllowed(userId) boolean
                    +consume(userId) void
                }
                
                URLService *-- CodeGenerator
                URLService *-- CacheLayer
                URLService *-- RateLimiter
                URLService ..> URLRepository
                URLService ..> AnalyticsService
                CodeGenerator <|.. Base62Generator
                CodeGenerator <|.. HashGenerator
                Base62Generator *-- IdGenerator
                IdGenerator <|.. SnowflakeIdGenerator
                IdGenerator <|.. ZookeeperIdGenerator
                AnalyticsService *-- Click
            """,
            codeSnippet: """
            public class URLService {
                private static final String BASE62 = 
                    "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
                
                private final AtomicLong counter = new AtomicLong(1000000);
                
                public String shorten(String longUrl) {
                    long id = counter.incrementAndGet();
                    String shortCode = encode(id);
                    
                    // Store mapping
                    urlRepository.save(new URLMapping(shortCode, longUrl));
                    
                    return "https://tiny.url/" + shortCode;
                }
                
                private String encode(long num) {
                    StringBuilder sb = new StringBuilder();
                    while (num > 0) {
                        sb.append(BASE62.charAt((int)(num % 62)));
                        num /= 62;
                    }
                    return sb.reverse().toString();
                }
                
                public String resolve(String shortCode) {
                    URLMapping mapping = cache.get(shortCode);
                    if (mapping == null) {
                        mapping = urlRepository.findByCode(shortCode);
                        cache.put(shortCode, mapping);
                    }
                    mapping.incrementClicks();
                    return mapping.getLongUrl();
                }
            }
            """,
            gsSpecificTwist: "Handle 1B URLs with collision-free generation"
        )
    }
}
