//
//  TwitterFeedLLD.swift
//  DevAscent
//
//  Social Network / Twitter Feed LLD Problem
//

import Foundation

struct TwitterFeedLLD {
    static func create() -> LLDProblem {
        return LLDProblem(
            title: "Social Network (Twitter Feed)",
            requirements: """
            **Core Domain Requirements:**
            • **User Management:** Create users, manage friendships (bidirectional)
            • **Post Management:** Create posts, like posts, add comments
            • **News Feed:** Generate personalized feed for users
            • **Recursive Comments:** Comments can have sub-comments (nested replies)
            • **Real-time Notifications:** Notify users on likes, comments

            **Design Patterns (Mandatory):**
            • **Facade Pattern:** SocialNetworkFacade as single entry point
            • **Repository Pattern (Singleton):** UserRepository, PostRepository
            • **Observer Pattern:** PostObserver for notifications
            • **Strategy Pattern:** NewsFeedGenerationStrategy for feed algorithms

            **Thread-Safety Requirements:**
            • ConcurrentHashMap for repositories
            • Set<User> for likes (prevent duplicates)
            • Synchronized lists where needed
            """,
            solutionStrategy: """
            **Architecture:**

            **A. Facade Layer:**
            • SocialNetworkFacade - Single API gateway
            • Delegates to UserService, PostService, NewsFeedService

            **B. Service Layer:**
            • UserService - User CRUD, friendship graph
            • PostService - Post creation, likes, comments + Observer notifications
            • NewsFeedService - Strategy-based feed generation

            **C. Domain Models:**
            • CommentableEntity (Abstract) - Base for Post & Comment
            • Post extends CommentableEntity
            • Comment extends CommentableEntity (enables recursive replies)
            • User - Core user entity with friends Set

            **D. Infrastructure:**
            • UserRepository (Singleton) - ConcurrentHashMap storage
            • PostRepository (Singleton) - Thread-safe post storage

            **Key Design Decisions:**
            • Facade simplifies client to single entry point
            • CommentableEntity hierarchy enables recursive comments
            • Strategy allows swapping Chronological → Algorithmic feed
            • Observer decouples notification logic from post operations
            """,
            mermaidGraph: """
            classDiagram
                class SocialNetworkDemo {
                    +main(args)
                }
                class SocialNetworkFacade {
                    -UserService userService
                    -PostService postService
                    -NewsFeedService newsFeedService
                    +createUser(String, String)
                    +addFriend(String, String)
                    +createPost(String, String)
                    +likePost(String, String)
                    +addComment(String, String, String)
                    +getNewsFeed(String)
                }
                class UserService {
                    -UserRepository userRepository
                    +createUser(String, String)
                    +addFriend(String, String)
                    +getUserById(String)
                }
                class PostService {
                    -PostRepository postRepository
                    -List observers
                    +likePost(User, String)
                    +createPost(User, String)
                    +addComment(User, String, String)
                    +addObserver(PostObserver)
                }
                class NewsFeedService {
                    -NewsFeedGenerationStrategy strategy
                    -PostRepository postRepository
                    +setStrategy(NewsFeedGenerationStrategy)
                    +getNewsFeed(User)
                }
                class PostRepository {
                    -INSTANCE PostRepository
                    -posts Map
                    +getInstance()
                    +save(Post)
                    +findById(String)
                }
                class UserRepository {
                    -INSTANCE UserRepository
                    -users Map
                    +save(User)
                    +getInstance()
                    +findById(String)
                }
                class PostObserver {
                    +onPostCreated(Post)
                    +onLike(Post, User)
                    +onComment(Post, Comment)
                }
                class UserNotifier {
                    +onLike(Post, User)
                    +onPostCreated(Post)
                    +onComment(Post, Comment)
                }
                class CommentableEntity {
                    #id String
                    #author User
                    #content String
                    #likes Set
                    #comments List
                    #timestamp LocalDateTime
                    +addLike(User)
                    +addComment(Comment)
                }
                class User {
                    -id String
                    -name String
                    -email String
                    -friends Set
                    -posts List
                    +addPost(Post)
                    +addFriend(User)
                }
                class Post
                class Comment {
                    +getReplies()
                }
                class NewsFeedGenerationStrategy {
                    +generateFeed(User, List)
                }
                class ChronologicalStrategy {
                    +generateFeed(User, List)
                }
                SocialNetworkDemo --> SocialNetworkFacade
                SocialNetworkFacade --> UserService
                SocialNetworkFacade --> PostService
                SocialNetworkFacade --> NewsFeedService
                NewsFeedService --> PostRepository
                NewsFeedService ..> NewsFeedGenerationStrategy
                NewsFeedGenerationStrategy <|.. ChronologicalStrategy
                PostService --> PostRepository
                PostService --> PostObserver
                PostObserver <|.. UserNotifier
                UserService --> UserRepository
                UserRepository --> User
                PostRepository --> Post
                User --> Post
                CommentableEntity --> User
                CommentableEntity --> Comment
                CommentableEntity <|-- Post
                CommentableEntity <|-- Comment
            """,
            codeSnippet: """
            // ═══════════════════════════════════════════════════════════════
            // FILE: domain/CommentableEntity.java (Abstract Base)
            // ═══════════════════════════════════════════════════════════════
            @Getter
            public abstract class CommentableEntity {
                protected final String id;
                protected final User author;
                protected final String content;
                protected final Set<User> likes = Collections.synchronizedSet(new HashSet<>());
                protected final List<Comment> comments = Collections.synchronizedList(new ArrayList<>());
                protected final Instant timestamp;
                
                protected CommentableEntity(User author, String content) {
                    this.id = UUID.randomUUID().toString();
                    this.author = author;
                    this.content = content;
                    this.timestamp = Instant.now();
                }
                
                public boolean addLike(User user) {
                    return likes.add(user);  // Returns false if already liked
                }
                
                public void addComment(Comment comment) {
                    comments.add(comment);
                }
                
                public int getLikeCount() { return likes.size(); }
            }

            // ═══════════════════════════════════════════════════════════════
            // FILE: domain/Post.java & Comment.java
            // ═══════════════════════════════════════════════════════════════
            public class Post extends CommentableEntity {
                public Post(User author, String content) {
                    super(author, content);
                }
            }

            public class Comment extends CommentableEntity {
                // Comment can have sub-comments via inherited 'comments' list
                public Comment(User author, String content) {
                    super(author, content);
                }
            }

            // ═══════════════════════════════════════════════════════════════
            // FILE: repository/UserRepository.java (Singleton)
            // ═══════════════════════════════════════════════════════════════
            public class UserRepository {
                private static final UserRepository INSTANCE = new UserRepository();
                private final ConcurrentHashMap<String, User> users = new ConcurrentHashMap<>();
                
                private UserRepository() {}
                
                public static UserRepository getInstance() { return INSTANCE; }
                
                public void save(User user) {
                    users.put(user.getId(), user);
                }
                
                public Optional<User> findById(String id) {
                    return Optional.ofNullable(users.get(id));
                }
            }

            // ═══════════════════════════════════════════════════════════════
            // FILE: observer/PostObserver.java (Observer Interface)
            // ═══════════════════════════════════════════════════════════════
            public interface PostObserver {
                void onPostCreated(Post post);
                void onLike(Post post, User user);
                void onComment(Post post, Comment comment);
            }

            public class UserNotifier implements PostObserver {
                @Override
                public void onPostCreated(Post post) {
                    // Notify all friends of the author
                    post.getAuthor().getFriends().forEach(friend ->
                        System.out.println("📢 " + friend.getName() + 
                            ": Your friend " + post.getAuthor().getName() + " posted!")
                    );
                }
                
                @Override
                public void onLike(Post post, User user) {
                    System.out.println("❤️ " + post.getAuthor().getName() + 
                        ": " + user.getName() + " liked your post!");
                }
                
                @Override
                public void onComment(Post post, Comment comment) {
                    System.out.println("💬 " + post.getAuthor().getName() + 
                        ": " + comment.getAuthor().getName() + " commented!");
                }
            }

            // ═══════════════════════════════════════════════════════════════
            // FILE: strategy/NewsFeedGenerationStrategy.java
            // ═══════════════════════════════════════════════════════════════
            public interface NewsFeedGenerationStrategy {
                List<Post> generateFeed(User user, List<Post> allPosts);
            }

            public class ChronologicalStrategy implements NewsFeedGenerationStrategy {
                @Override
                public List<Post> generateFeed(User user, List<Post> allPosts) {
                    Set<User> relevantUsers = new HashSet<>(user.getFriends());
                    relevantUsers.add(user);  // Include user's own posts
                    
                    return allPosts.stream()
                        .filter(post -> relevantUsers.contains(post.getAuthor()))
                        .sorted(Comparator.comparing(Post::getTimestamp).reversed())
                        .limit(20)
                        .collect(Collectors.toList());
                }
            }

            // ═══════════════════════════════════════════════════════════════
            // FILE: service/PostService.java (With Observer)
            // ═══════════════════════════════════════════════════════════════
            public class PostService {
                private final PostRepository repository = PostRepository.getInstance();
                private final List<PostObserver> observers = new CopyOnWriteArrayList<>();
                
                public void addObserver(PostObserver observer) {
                    observers.add(observer);
                }
                
                public Post createPost(User author, String content) {
                    Post post = new Post(author, content);
                    repository.save(post);
                    author.addPost(post);
                    notifyObservers(obs -> obs.onPostCreated(post));
                    return post;
                }
                
                public boolean likePost(User user, String postId) {
                    Post post = repository.findById(postId)
                        .orElseThrow(() -> new IllegalArgumentException("Post not found"));
                    
                    boolean liked = post.addLike(user);  // False if already liked
                    if (liked) {
                        notifyObservers(obs -> obs.onLike(post, user));
                    }
                    return liked;
                }
                
                public Comment addComment(User user, String postId, String content) {
                    Post post = repository.findById(postId)
                        .orElseThrow(() -> new IllegalArgumentException("Post not found"));
                    
                    Comment comment = new Comment(user, content);
                    post.addComment(comment);
                    notifyObservers(obs -> obs.onComment(post, comment));
                    return comment;
                }
                
                private void notifyObservers(Consumer<PostObserver> action) {
                    observers.forEach(action);
                }
            }

            // ═══════════════════════════════════════════════════════════════
            // FILE: facade/SocialNetworkFacade.java (Entry Point)
            // ═══════════════════════════════════════════════════════════════
            public class SocialNetworkFacade {
                private final UserService userService;
                private final PostService postService;
                private final NewsFeedService feedService;
                
                public SocialNetworkFacade() {
                    this.userService = new UserService();
                    this.postService = new PostService();
                    this.feedService = new NewsFeedService(new ChronologicalStrategy());
                    
                    // Register default observers
                    this.postService.addObserver(new UserNotifier());
                }
                
                public User createUser(String name, String email) {
                    return userService.createUser(name, email);
                }
                
                public void addFriend(String userId1, String userId2) {
                    userService.addFriend(userId1, userId2);
                }
                
                public Post createPost(String userId, String content) {
                    User user = userService.getUser(userId);
                    return postService.createPost(user, content);
                }
                
                public boolean likePost(String userId, String postId) {
                    User user = userService.getUser(userId);
                    return postService.likePost(user, postId);
                }
                
                public Comment addComment(String userId, String postId, String content) {
                    User user = userService.getUser(userId);
                    return postService.addComment(user, postId, content);
                }
                
                public List<Post> getNewsFeed(String userId) {
                    User user = userService.getUser(userId);
                    return feedService.getNewsFeed(user);
                }
            }

            // ═══════════════════════════════════════════════════════════════
            // FILE: SocialNetworkDemo.java (Main)
            // ═══════════════════════════════════════════════════════════════
            public class SocialNetworkDemo {
                public static void main(String[] args) {
                    SocialNetworkFacade social = new SocialNetworkFacade();
                    
                    // Create users
                    User alice = social.createUser("Alice", "alice@example.com");
                    User bob = social.createUser("Bob", "bob@example.com");
                    
                    // Add friendship
                    social.addFriend(alice.getId(), bob.getId());
                    
                    // Alice posts
                    Post post = social.createPost(alice.getId(), "Hello Twitter!");
                    // Output: 📢 Bob: Your friend Alice posted!
                    
                    // Bob likes
                    social.likePost(bob.getId(), post.getId());
                    // Output: ❤️ Alice: Bob liked your post!
                    
                    // Bob comments
                    Comment comment = social.addComment(bob.getId(), post.getId(), "Great post!");
                    // Output: 💬 Alice: Bob commented!
                    
                    // Recursive comment (reply to comment)
                    Comment reply = new Comment(alice, "Thanks!");
                    comment.addComment(reply);  // CommentableEntity hierarchy!
                    
                    // Get feed
                    List<Post> feed = social.getNewsFeed(bob.getId());
                }
            }
            """,
            gsSpecificTwist: """
            **Goldman Sachs Twist: Algorithmic Feed with Ranking**

            **Requirement:** Swap ChronologicalStrategy with RankedFeedStrategy.

            **Solution:** Strategy Pattern allows easy swap:

            ```java
            public class RankedFeedStrategy implements NewsFeedGenerationStrategy {
                @Override
                public List<Post> generateFeed(User user, List<Post> allPosts) {
                    Set<User> relevantUsers = new HashSet<>(user.getFriends());
                    relevantUsers.add(user);
                    
                    return allPosts.stream()
                        .filter(post -> relevantUsers.contains(post.getAuthor()))
                        .sorted(Comparator.comparingDouble(this::calculateScore).reversed())
                        .limit(20)
                        .collect(Collectors.toList());
                }
                
                private double calculateScore(Post post) {
                    long ageHours = Duration.between(post.getTimestamp(), Instant.now()).toHours();
                    int engagement = post.getLikeCount() + post.getComments().size();
                    
                    // Reddit-style hot ranking
                    return engagement / Math.pow(ageHours + 2, 1.8);
                }
            }

            // Easy swap in Facade
            feedService.setStrategy(new RankedFeedStrategy());
            ```

            **Why Facade Pattern?**
            • Single entry point for clients (SocialNetworkDemo)
            • Hides complexity of UserService, PostService, NewsFeedService
            • Easy to add logging, rate limiting, authentication

            **Why CommentableEntity?**
            • Enables infinite nesting of comments (reply to reply)
            • Both Post and Comment can be liked
            • DRY principle - shared like/comment logic
            """
        )
    }
}
