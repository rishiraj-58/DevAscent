//
//  TwitterFeedLLD.swift
//  DevAscent
//
//  Twitter Feed / Social Network LLD Problem
//

import Foundation

struct TwitterFeedLLD {
    static func create() -> LLDProblem {
        return LLDProblem(
            title: "Twitter Feed / Social Network",
            requirements: """
            • Post tweets (280 chars)
            • Follow/Unfollow users
            • News feed generation
            • Like and Retweet
            • Trending hashtags
            """,
            solutionStrategy: """
            **Patterns Used:**
            - **Observer Pattern**: Follower notifications
            - **Fan-out on Write vs Read**: Feed generation strategy
            - **Decorator Pattern**: Tweet features (media, poll)

            **Scalability:**
            - Cache hot users' feeds
            - Async fan-out for celebrities
            """,
            mermaidGraph: """
            classDiagram
                class User {
                    -String userId
                    -String username
                    -String email
                    -Set followers
                    -Set following
                    -List tweets
                    +follow(User) void
                    +unfollow(User) void
                    +post(Tweet) void
                    +getTimeline() List
                }
                
                class Tweet {
                    
                    -String tweetId
                    -User author
                    -String content
                    -DateTime createdAt
                    -int likeCount
                    -int retweetCount
                    +like(User) void
                    +retweet(User) Tweet
                    +getContent() String
                }
                
                class TextTweet {
                    -String text
                }
                
                class MediaTweet {
                    -List mediaUrls
                    -MediaType type
                }
                
                class TweetDecorator {
                    
                    -Tweet wrappedTweet
                    +getContent() String
                }
                
                class HashtagDecorator {
                    -List hashtags
                    +extractHashtags() List
                }
                
                class MentionDecorator {
                    -List mentionedUsers
                    +notifyMentioned() void
                }
                
                class FeedService {
                    -FanOutStrategy fanOutStrategy
                    -FeedCache feedCache
                    +generateFeed(User, int limit) List
                    +publishTweet(Tweet) void
                }
                
                class FanOutStrategy {
                    
                    +distribute(Tweet, Set followers) void
                }
                
                class FanOutOnWrite {
                    +distribute(Tweet, Set) void
                }
                
                class FanOutOnRead {
                    +distribute(Tweet, Set) void
                }
                
                class HybridFanOut {
                    -int followerThreshold
                    +distribute(Tweet, Set) void
                }
                
                class FeedCache {
                    -RedisClient redis
                    +getFeed(userId) List
                    +invalidate(userId) void
                    +prependTweet(userId, Tweet) void
                }
                
                class TrendingService {
                    -MinHeap topK
                    -Map hashtagCounts
                    +updateTrending(hashtag) void
                    +getTopK(k) List
                }
                
                User *-- Tweet : creates
                User o-- User : follows
                Tweet <|-- TextTweet
                Tweet <|-- MediaTweet
                Tweet <|-- TweetDecorator
                TweetDecorator <|-- HashtagDecorator
                TweetDecorator <|-- MentionDecorator
                TweetDecorator o-- Tweet : wraps
                FeedService *-- FeedCache
                FeedService ..> FanOutStrategy
                FanOutStrategy <|.. FanOutOnWrite
                FanOutStrategy <|.. FanOutOnRead
                FanOutStrategy <|.. HybridFanOut
                FeedService ..> TrendingService
            """,
            codeSnippet: """
            public class FeedService {
                private final Map<String, List<Tweet>> userFeeds = new ConcurrentHashMap<>();
                
                // Fan-out on write
                public void fanOutTweet(Tweet tweet) {
                    Set<User> followers = tweet.getAuthor().getFollowers();
                    
                    for (User follower : followers) {
                        userFeeds.computeIfAbsent(follower.getId(), 
                            k -> new ArrayList<>()).add(0, tweet);
                    }
                }
                
                // Fan-out on read (for celebrities)
                public List<Tweet> generateFeed(User user) {
                    return user.getFollowing().stream()
                        .flatMap(u -> u.getTweets().stream())
                        .sorted(Comparator.comparing(Tweet::getTimestamp).reversed())
                        .limit(100)
                        .collect(Collectors.toList());
                }
            }
            """,
            gsSpecificTwist: "Design for 100M users with real-time feed updates"
        )
    }
}
