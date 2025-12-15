//
//  SpringBootConcepts.swift
//  DevAscent
//
//  Spring Boot CS Concepts - Comprehensive Interview Questions
//

import Foundation

struct SpringBootConcepts {
    static func all() -> [CSConcept] {
        return [
            // MARK: - Spring Boot Fundamentals
            CSConcept(
                category: .springBoot,
                question: "What is Spring Boot?",
                answer: """
                Framework for building production-ready Spring applications.

                **Main Features:**
                - Auto-configuration
                - Starter POMs (dependency bundles)
                - Embedded servers (Tomcat, Jetty)
                - Actuator (monitoring)
                - Spring CLI

                **Benefits:**
                - Minimal configuration
                - Fast development
                - Production-ready defaults
                """,
                tags: ["fundamentals", "overview"]
            ),
            CSConcept(
                category: .springBoot,
                question: "What is @SpringBootApplication?",
                answer: """
                Combines 3 annotations:

                **@Configuration:**
                - Source of bean definitions
                - Allows @Bean methods

                **@EnableAutoConfiguration:**
                - Auto-configures based on classpath
                - Reads META-INF/spring.factories

                **@ComponentScan:**
                - Scans current + sub-packages
                - Finds @Component, @Service, @Repository
                """,
                tags: ["annotation", "entry point"]
            ),
            CSConcept(
                category: .springBoot,
                question: "What are Spring Boot Starters?",
                answer: """
                Pre-configured dependency bundles.

                **Common Starters:**
                - spring-boot-starter-web: Web apps + Tomcat
                - spring-boot-starter-data-jpa: JPA + Hibernate
                - spring-boot-starter-security: Spring Security
                - spring-boot-starter-test: Testing libraries

                **Benefits:**
                - Simplify dependency management
                - Ensure compatible versions
                - Quick project setup
                """,
                tags: ["starters", "dependencies"]
            ),
            CSConcept(
                category: .springBoot,
                question: "application.properties vs application.yml?",
                answer: """
                Configuration files for Spring Boot.

                **application.properties:**
                ```
                server.port=8081
                spring.datasource.url=jdbc:mysql://localhost/db
                ```

                **application.yml:**
                ```yaml
                server:
                  port: 8081
                spring:
                  datasource:
                    url: jdbc:mysql://localhost/db
                ```

                **Default port:** 8080
                """,
                tags: ["configuration", "properties"]
            ),
            CSConcept(
                category: .springBoot,
                question: "What is JDK, JRE, and JVM in Spring context?",
                answer: """
                **JDK:** Development Kit (compile + run)
                **JRE:** Runtime Environment (run only)
                **JVM:** Virtual Machine (executes bytecode)

                Spring Boot runs on any JVM platform.

                **Embedded Servers:**
                - Tomcat (default)
                - Jetty
                - Undertow
                """,
                tags: ["JVM", "runtime"]
            ),
            
            // MARK: - Annotations
            CSConcept(
                category: .springBoot,
                question: "@Component vs @Service vs @Repository?",
                answer: """
                **@Component:**
                - Generic Spring-managed bean
                - Base stereotype annotation

                **@Service:**
                - Specialized @Component
                - For business logic layer
                - Semantic clarity

                **@Repository:**
                - Specialized @Component
                - For data access layer (DAO)
                - Exception translation to DataAccessException
                """,
                tags: ["annotations", "stereotypes"]
            ),
            CSConcept(
                category: .springBoot,
                question: "What is @Autowired?",
                answer: """
                Auto-injects dependencies.

                **Types:**
                - Field injection (not recommended)
                - Setter injection
                - Constructor injection (recommended)

                **Constructor Injection (Best):**
                ```java
                private final UserService userService;
                public MyController(UserService userService) {
                    this.userService = userService;
                }
                ```

                **Benefits:** Immutable, testable, no nulls
                """,
                tags: ["autowired", "DI"]
            ),
            CSConcept(
                category: .springBoot,
                question: "What is @Value annotation?",
                answer: """
                Injects values from properties files.

                **Usage:**
                ```java
                @Value("${app.name}")
                private String appName;

                @Value("${app.timeout:30}")
                private int timeout; // default 30
                ```

                **Alternative:** @ConfigurationProperties for type-safe binding
                """,
                tags: ["value", "properties"]
            ),
            CSConcept(
                category: .springBoot,
                question: "@RestController vs @Controller?",
                answer: """
                **@Controller:**
                - Returns view names (HTML, JSP)
                - Needs @ResponseBody for JSON

                **@RestController:**
                - @Controller + @ResponseBody
                - Returns JSON/XML directly
                - Used for REST APIs

                ```java
                @RestController
                public class UserController {
                    @GetMapping("/users")
                    public List<User> getUsers() {
                        return userService.findAll();
                    }
                }
                ```
                """,
                tags: ["controller", "REST"]
            ),
            CSConcept(
                category: .springBoot,
                question: "HTTP Method Annotations?",
                answer: """
                **@GetMapping:** Retrieve resource
                **@PostMapping:** Create resource
                **@PutMapping:** Replace resource
                **@PatchMapping:** Partial update
                **@DeleteMapping:** Delete resource

                **@RequestMapping:** General purpose
                ```java
                @RequestMapping(value="/users", method=RequestMethod.GET)
                ```
                """,
                tags: ["HTTP", "methods", "REST"]
            ),
            CSConcept(
                category: .springBoot,
                question: "@PathVariable vs @RequestParam?",
                answer: """
                **@PathVariable:** Extract from URL path
                ```java
                @GetMapping("/users/{id}")
                public User getUser(@PathVariable Long id)
                // URL: /users/123
                ```

                **@RequestParam:** Extract from query string
                ```java
                @GetMapping("/users")
                public List<User> getUsers(@RequestParam String name)
                // URL: /users?name=John
                ```
                """,
                tags: ["path", "request", "parameters"]
            ),
            CSConcept(
                category: .springBoot,
                question: "@RequestBody vs @ResponseBody?",
                answer: """
                **@RequestBody:**
                - Deserializes JSON to object
                - Used in POST/PUT methods

                **@ResponseBody:**
                - Serializes object to JSON
                - Included in @RestController

                ```java
                @PostMapping("/users")
                public User create(@RequestBody User user) {
                    return userService.save(user);
                }
                ```
                """,
                tags: ["body", "JSON", "serialization"]
            ),
            
            // MARK: - Dependency Injection
            CSConcept(
                category: .springBoot,
                question: "What is Dependency Injection?",
                answer: """
                Design pattern where dependencies are provided externally.

                **Types in Spring:**
                1. Constructor Injection (recommended)
                2. Setter Injection
                3. Field Injection (avoid)

                **Benefits:**
                - Loose coupling
                - Easy testing
                - Flexible configuration
                """,
                tags: ["DI", "IoC"]
            ),
            CSConcept(
                category: .springBoot,
                question: "How to define a Bean?",
                answer: """
                **Using @Bean:**
                ```java
                @Configuration
                public class AppConfig {
                    @Bean
                    public DataSource dataSource() {
                        return new HikariDataSource();
                    }
                }
                ```

                **Using Stereotype:**
                ```java
                @Component
                public class MyService { }
                ```
                """,
                tags: ["bean", "configuration"]
            ),
            CSConcept(
                category: .springBoot,
                question: "Bean Scopes?",
                answer: """
                **Singleton (default):**
                - One instance per container
                - Shared across requests

                **Prototype:**
                - New instance on each injection
                - For stateful beans

                **Request:**
                - One per HTTP request

                **Session:**
                - One per HTTP session

                ```java
                @Scope("prototype")
                @Component
                public class MyBean { }
                ```
                """,
                tags: ["scope", "singleton", "prototype"]
            ),
            
            // MARK: - Exception Handling
            CSConcept(
                category: .springBoot,
                question: "How to handle exceptions globally?",
                answer: """
                **@ControllerAdvice + @ExceptionHandler:**
                ```java
                @ControllerAdvice
                public class GlobalExceptionHandler {
                    @ExceptionHandler(Exception.class)
                    public ResponseEntity<String> handle(Exception e) {
                        return new ResponseEntity<>(
                            e.getMessage(),
                            HttpStatus.INTERNAL_SERVER_ERROR
                        );
                    }
                }
                ```

                **@RestControllerAdvice:**
                - @ControllerAdvice + @ResponseBody
                - Returns JSON directly
                """,
                tags: ["exception", "error handling"]
            ),
            CSConcept(
                category: .springBoot,
                question: "How to customize error responses?",
                answer: """
                **Custom Error Controller:**
                ```java
                @Controller
                public class CustomErrorController implements ErrorController {
                    @RequestMapping("/error")
                    public String handleError() {
                        return "error";
                    }
                }
                ```

                **Custom Error Pages:**
                - Place in src/main/resources/templates/
                - error.html (generic)
                - 404.html, 500.html (specific)
                """,
                tags: ["error", "custom"]
            ),
            
            // MARK: - JPA & Database
            CSConcept(
                category: .springBoot,
                question: "What is Spring Data JPA?",
                answer: """
                Abstraction over JPA for data access.

                **Repository Interface:**
                ```java
                public interface UserRepository 
                    extends JpaRepository<User, Long> {
                    List<User> findByName(String name);
                }
                ```

                **Auto-generated queries:**
                - findByEmail()
                - findByAgeGreaterThan()
                - findByNameContaining()

                **Hierarchy:** Spring Data JPA → JPA → Hibernate
                """,
                tags: ["JPA", "data", "repository"]
            ),
            CSConcept(
                category: .springBoot,
                question: "What is @Entity annotation?",
                answer: """
                Marks class as JPA entity (database table).

                ```java
                @Entity
                @Table(name = "users")
                public class User {
                    @Id
                    @GeneratedValue(strategy = GenerationType.IDENTITY)
                    private Long id;
                    
                    private String name;
                    private String email;
                }
                ```

                **Key Annotations:**
                - @Id: Primary key
                - @Table: Custom table name
                - @Column: Custom column settings
                """,
                tags: ["entity", "JPA", "database"]
            ),
            CSConcept(
                category: .springBoot,
                question: "Database initialization?",
                answer: """
                **Auto DDL:**
                ```
                spring.jpa.hibernate.ddl-auto=create-drop
                ```
                - create: Create on startup
                - update: Update schema
                - validate: Validate only
                - none: Do nothing

                **SQL Scripts:**
                - schema.sql: DDL statements
                - data.sql: DML statements
                - Place in src/main/resources/
                """,
                tags: ["database", "initialization"]
            ),
            CSConcept(
                category: .springBoot,
                question: "How to configure Multiple DataSources?",
                answer: """
                **Primary DataSource:**
                ```java
                @Primary
                @Bean("primaryDataSource")
                @ConfigurationProperties("spring.datasource.primary")
                public DataSource primaryDataSource() {
                    return DataSourceBuilder.create().build();
                }
                ```

                **Secondary DataSource:**
                ```java
                @Bean("secondaryDataSource")
                @ConfigurationProperties("spring.datasource.secondary")
                public DataSource secondaryDataSource() {
                    return DataSourceBuilder.create().build();
                }
                ```
                """,
                tags: ["datasource", "multiple"]
            ),
            CSConcept(
                category: .springBoot,
                question: "Pagination and Sorting?",
                answer: """
                **Using Pageable:**
                ```java
                Page<User> findByName(String name, Pageable pageable);

                Pageable pageable = PageRequest.of(0, 10, Sort.by("name"));
                Page<User> users = userRepository.findByName("John", pageable);
                ```

                **Returns:**
                - Content (list of items)
                - Total elements
                - Total pages
                - Page number
                """,
                tags: ["pagination", "sorting"]
            ),
            CSConcept(
                category: .springBoot,
                question: "Embedded Database (H2)?",
                answer: """
                **Add Dependency:**
                ```xml
                <dependency>
                    <groupId>com.h2database</groupId>
                    <artifactId>h2</artifactId>
                </dependency>
                ```

                **Configuration:**
                ```
                spring.datasource.url=jdbc:h2:mem:testdb
                spring.h2.console.enabled=true
                ```

                **Access console:** http://localhost:8080/h2-console
                """,
                tags: ["H2", "embedded", "database"]
            ),
            CSConcept(
                category: .springBoot,
                question: "Database Migrations?",
                answer: """
                **Flyway:**
                - SQL-based migrations
                - V1__initial.sql, V2__add_column.sql
                - Tracks in flyway_schema_history table

                **Liquibase:**
                - XML/YAML/JSON changelogs
                - More control over refactorings

                ```xml
                <dependency>
                    <groupId>org.flywaydb</groupId>
                    <artifactId>flyway-core</artifactId>
                </dependency>
                ```
                """,
                tags: ["flyway", "liquibase", "migration"]
            ),
            
            // MARK: - Transactions
            CSConcept(
                category: .springBoot,
                question: "What is @Transactional?",
                answer: """
                Manages database transactions declaratively.

                **How it works:**
                - Spring creates AOP proxy
                - Proxy starts transaction
                - Method executes
                - Commit or rollback

                **Propagation:**
                - REQUIRED (default): Use or create
                - REQUIRES_NEW: Always new
                - NESTED: Savepoint

                **Pitfall:** Self-invocation bypasses proxy!
                """,
                tags: ["transactional", "AOP"]
            ),
            
            // MARK: - Profiles
            CSConcept(
                category: .springBoot,
                question: "What are Spring Profiles?",
                answer: """
                Environment-specific configurations.

                **Files:**
                - application-dev.properties
                - application-prod.properties

                **Activate:**
                ```
                spring.profiles.active=dev
                ```
                Or: -Dspring.profiles.active=prod

                **@Profile annotation:**
                ```java
                @Bean
                @Profile("dev")
                public DataSource devDataSource() { }
                ```
                """,
                tags: ["profiles", "environment"]
            ),
            
            // MARK: - Actuator
            CSConcept(
                category: .springBoot,
                question: "What is Spring Boot Actuator?",
                answer: """
                Production-ready monitoring features.

                **Endpoints:**
                - /actuator/health: Health status
                - /actuator/metrics: JVM, HTTP stats
                - /actuator/info: Build info
                - /actuator/env: Environment properties
                - /actuator/loggers: Change log levels

                **Add Dependency:**
                spring-boot-starter-actuator
                """,
                tags: ["actuator", "monitoring"]
            ),
            CSConcept(
                category: .springBoot,
                question: "How to customize Actuator?",
                answer: """
                **Expose endpoints:**
                ```
                management.endpoints.web.exposure.include=health,info,metrics
                ```

                **Change base path:**
                ```
                management.endpoints.web.base-path=/manage
                ```

                **Custom health check:**
                ```java
                @Component
                public class CustomHealth implements HealthIndicator {
                    public Health health() {
                        return Health.up().withDetail("key", "value").build();
                    }
                }
                ```
                """,
                tags: ["actuator", "custom"]
            ),
            
            // MARK: - Testing
            CSConcept(
                category: .springBoot,
                question: "What is @SpringBootTest?",
                answer: """
                Loads full application context for integration testing.

                ```java
                @SpringBootTest
                public class MyTests {
                    @Autowired
                    private UserService userService;
                    
                    @Test
                    void contextLoads() {
                        assertNotNull(userService);
                    }
                }
                ```

                **Includes:** JUnit 5, Mockito, AssertJ
                """,
                tags: ["testing", "integration"]
            ),
            CSConcept(
                category: .springBoot,
                question: "What is @DataJpaTest?",
                answer: """
                Tests JPA repositories in isolation.

                ```java
                @DataJpaTest
                public class UserRepositoryTest {
                    @Autowired
                    private UserRepository userRepository;
                    
                    @Test
                    void testFindByName() {
                        User user = userRepository.findByName("John");
                        assertNotNull(user);
                    }
                }
                ```

                **Uses:** In-memory database, rollback after each test
                """,
                tags: ["testing", "JPA"]
            ),
            CSConcept(
                category: .springBoot,
                question: "Testing with MockMvc?",
                answer: """
                Test controllers without starting server.

                ```java
                @WebMvcTest(UserController.class)
                public class UserControllerTest {
                    @Autowired
                    private MockMvc mockMvc;

                    @Test
                    public void testGetUser() throws Exception {
                        mockMvc.perform(get("/user"))
                            .andExpect(status().isOk())
                            .andExpect(jsonPath("$.name").value("John"));
                    }
                }
                ```
                """,
                tags: ["testing", "MockMvc"]
            ),
            
            // MARK: - Security
            CSConcept(
                category: .springBoot,
                question: "Spring Security Basics?",
                answer: """
                **Core Concepts:**
                - Authentication: Who are you?
                - Authorization: What can you do?

                **Configuration:**
                ```java
                @EnableWebSecurity
                public class SecurityConfig {
                    @Bean
                    SecurityFilterChain filterChain(HttpSecurity http) {
                        return http
                            .authorizeRequests()
                            .antMatchers("/public/**").permitAll()
                            .anyRequest().authenticated()
                            .and()
                            .formLogin()
                            .build();
                    }
                }
                ```
                """,
                tags: ["security", "authentication"]
            ),
            CSConcept(
                category: .springBoot,
                question: "JWT Authentication?",
                answer: """
                Stateless token-based authentication.

                **Flow:**
                1. User logs in with credentials
                2. Server validates and returns JWT
                3. Client stores JWT
                4. Client sends JWT in Authorization header
                5. Server validates JWT on each request

                **Header format:**
                Authorization: Bearer <token>
                """,
                tags: ["JWT", "authentication"]
            ),
            CSConcept(
                category: .springBoot,
                question: "How to enable CORS?",
                answer: """
                **Global Configuration:**
                ```java
                @Configuration
                public class WebConfig implements WebMvcConfigurer {
                    @Override
                    public void addCorsMappings(CorsRegistry registry) {
                        registry.addMapping("/**")
                            .allowedOrigins("http://example.com")
                            .allowedMethods("GET", "POST", "PUT");
                    }
                }
                ```

                **Per-controller:**
                @CrossOrigin(origins = "http://example.com")
                """,
                tags: ["CORS", "security"]
            ),
            
            // MARK: - Async & Scheduling
            CSConcept(
                category: .springBoot,
                question: "What is @Async?",
                answer: """
                Execute methods asynchronously.

                **Enable:** @EnableAsync

                **Usage:**
                ```java
                @Async
                public void sendEmail(String to) {
                    // Runs in separate thread
                }

                @Async
                public CompletableFuture<User> findUser(Long id) {
                    return CompletableFuture.completedFuture(user);
                }
                ```

                **Pitfall:** Self-invocation bypasses proxy!
                """,
                tags: ["async", "threading"]
            ),
            CSConcept(
                category: .springBoot,
                question: "What is @Scheduled?",
                answer: """
                Schedule background tasks.

                **Enable:** @EnableScheduling

                **Fixed Rate (start to start):**
                @Scheduled(fixedRate = 5000)

                **Fixed Delay (end to start):**
                @Scheduled(fixedDelay = 5000)

                **Cron Expression:**
                @Scheduled(cron = "0 0 8 * * MON-FRI")

                **Cron:** second minute hour day month weekday
                """,
                tags: ["scheduled", "cron", "tasks"]
            ),
            
            // MARK: - Caching
            CSConcept(
                category: .springBoot,
                question: "How to implement Caching?",
                answer: """
                **Enable:** @EnableCaching

                **Annotations:**
                - @Cacheable("cache"): Cache result
                - @CachePut("cache"): Update cache
                - @CacheEvict("cache"): Remove from cache

                ```java
                @Cacheable(value="users", key="#id")
                public User findById(Long id) {
                    return userRepository.findById(id);
                }
                ```

                **Providers:** Redis, Ehcache, Caffeine
                """,
                tags: ["caching", "performance"]
            ),
            
            // MARK: - DevTools & Logging
            CSConcept(
                category: .springBoot,
                question: "What is Spring Boot DevTools?",
                answer: """
                Developer productivity tools.

                **Features:**
                - Automatic restart on file changes
                - LiveReload browser refresh
                - Disabled caching
                - Enhanced logging

                **Add Dependency:**
                spring-boot-devtools (scope: runtime)

                **Note:** Don't use in production!
                """,
                tags: ["devtools", "development"]
            ),
            CSConcept(
                category: .springBoot,
                question: "Logging Configuration?",
                answer: """
                **Default:** SLF4J + Logback

                **Set Levels:**
                ```
                logging.level.root=INFO
                logging.level.com.example=DEBUG
                ```

                **Log to file:**
                ```
                logging.file.name=app.log
                ```

                **Usage:**
                ```java
                private static final Logger log = 
                    LoggerFactory.getLogger(MyClass.class);
                log.info("Message");
                ```
                """,
                tags: ["logging", "SLF4J"]
            ),
            
            // MARK: - File Upload
            CSConcept(
                category: .springBoot,
                question: "How to handle File Upload?",
                answer: """
                **Controller:**
                ```java
                @PostMapping("/upload")
                public String upload(@RequestParam("file") MultipartFile file) {
                    Path path = Paths.get("uploads/" + file.getOriginalFilename());
                    Files.copy(file.getInputStream(), path);
                    return "Uploaded: " + file.getOriginalFilename();
                }
                ```

                **HTML form:**
                enctype="multipart/form-data"

                **Config:**
                spring.servlet.multipart.max-file-size=10MB
                """,
                tags: ["file", "upload"]
            ),
            
            // MARK: - Auto Configuration
            CSConcept(
                category: .springBoot,
                question: "What is Auto-Configuration?",
                answer: """
                Spring Boot auto-configures beans based on classpath.

                **How it works:**
                - Reads META-INF/spring.factories
                - Conditional annotations determine loading

                **Disable specific:**
                ```java
                @SpringBootApplication(
                    exclude = DataSourceAutoConfiguration.class
                )
                ```

                **Conditional annotations:**
                - @ConditionalOnClass
                - @ConditionalOnMissingBean
                - @ConditionalOnProperty
                """,
                tags: ["auto-configuration", "conditional"]
            ),
            CSConcept(
                category: .springBoot,
                question: "What is @ConditionalOnMissingBean?",
                answer: """
                Load bean only if NOT already defined.

                ```java
                @Bean
                @ConditionalOnMissingBean
                public DataSource dataSource() {
                    return new HikariDataSource();
                }
                ```

                **Use case:**
                - Provide default implementation
                - Allow user to override
                - Auto-configuration classes
                """,
                tags: ["conditional", "bean"]
            ),
            
            // MARK: - AOP
            CSConcept(
                category: .springBoot,
                question: "What is Spring AOP?",
                answer: """
                Aspect-Oriented Programming for cross-cutting concerns.

                **Concepts:**
                - Aspect: Class with cross-cutting logic
                - Advice: Action (before, after, around)
                - Pointcut: Where to apply
                - JoinPoint: Point in execution

                **Advice Types:**
                - @Before, @After
                - @AfterReturning, @AfterThrowing
                - @Around (most powerful)
                """,
                tags: ["AOP", "aspect"]
            ),
            
            // MARK: - Microservices
            CSConcept(
                category: .springBoot,
                question: "What is Spring Cloud?",
                answer: """
                Tools for building distributed systems.

                **Components:**
                - Spring Cloud Config: Externalized config
                - Eureka: Service discovery
                - Ribbon/LoadBalancer: Client-side load balancing
                - Spring Cloud Gateway: API gateway
                - Resilience4j: Circuit breaker

                Spring Boot is foundation for Spring Cloud.
                """,
                tags: ["microservices", "Spring Cloud"]
            ),
            CSConcept(
                category: .springBoot,
                question: "Circuit Breaker Pattern?",
                answer: """
                Prevent cascading failures in microservices.

                **Using Resilience4j:**
                ```java
                @CircuitBreaker(name = "userService", fallbackMethod = "fallback")
                public User getUser(Long id) {
                    return restTemplate.getForObject(url, User.class);
                }

                public User fallback(Long id, Throwable t) {
                    return new User("Default");
                }
                ```

                **States:** Closed → Open → Half-Open
                """,
                tags: ["circuit breaker", "resilience"]
            ),
            CSConcept(
                category: .springBoot,
                question: "Distributed Tracing?",
                answer: """
                Track requests across microservices.

                **Spring Cloud Sleuth:**
                - Adds trace/span IDs to logs
                - Auto-propagates through HTTP headers

                **Configuration:**
                ```
                spring.zipkin.base-url=http://localhost:9411
                spring.sleuth.sampler.probability=1.0
                ```

                **Visualization:** Zipkin, Jaeger
                """,
                tags: ["tracing", "Sleuth"]
            ),
            
            // MARK: - API Documentation
            CSConcept(
                category: .springBoot,
                question: "Swagger/OpenAPI Documentation?",
                answer: """
                API documentation and testing.

                **Add Dependency:**
                springdoc-openapi-ui

                **Access:** /swagger-ui.html

                **Annotate:**
                ```java
                @Operation(summary = "Get all users")
                @GetMapping("/users")
                public List<User> getUsers() { }
                ```
                """,
                tags: ["Swagger", "OpenAPI"]
            ),
            
            // MARK: - REST Client
            CSConcept(
                category: .springBoot,
                question: "RestTemplate vs WebClient?",
                answer: """
                **RestTemplate:**
                - Synchronous, blocking
                - Simple API
                - Deprecated

                **WebClient:**
                - Asynchronous, non-blocking
                - Reactive programming
                - Modern approach

                ```java
                WebClient client = WebClient.create();
                Mono<User> user = client.get()
                    .uri("/users/1")
                    .retrieve()
                    .bodyToMono(User.class);
                ```
                """,
                tags: ["RestTemplate", "WebClient"]
            ),
            CSConcept(
                category: .springBoot,
                question: "What is @FeignClient?",
                answer: """
                Declarative REST client.

                ```java
                @FeignClient(name = "user-service")
                public interface UserClient {
                    @GetMapping("/users/{id}")
                    User getUser(@PathVariable Long id);
                }
                ```

                **Benefits:**
                - No boilerplate code
                - Integrates with Eureka
                - Built-in load balancing
                """,
                tags: ["Feign", "REST client"]
            ),
            
            // MARK: - Command Line
            CSConcept(
                category: .springBoot,
                question: "CommandLineRunner vs ApplicationRunner?",
                answer: """
                Execute code after application starts.

                **CommandLineRunner:**
                ```java
                @Component
                public class MyRunner implements CommandLineRunner {
                    public void run(String... args) {
                        System.out.println("Args: " + Arrays.toString(args));
                    }
                }
                ```

                **ApplicationRunner:**
                - Access to ApplicationArguments
                - More detailed argument parsing
                """,
                tags: ["CommandLineRunner", "startup"]
            ),
            
            // MARK: - Deployment
            CSConcept(
                category: .springBoot,
                question: "Running Spring Boot App?",
                answer: """
                **Methods:**
                1. java -jar myapp.jar
                2. mvn spring-boot:run
                3. gradle bootRun
                4. IDE main() method

                **Embedded Servers:**
                - Tomcat (default)
                - Jetty
                - Undertow

                **Change server:**
                Exclude spring-boot-starter-tomcat
                Add spring-boot-starter-jetty
                """,
                tags: ["deployment", "running"]
            ),
            CSConcept(
                category: .springBoot,
                question: "Docker Deployment?",
                answer: """
                **Dockerfile:**
                ```dockerfile
                FROM openjdk:17-jre
                COPY target/app.jar /app.jar
                ENTRYPOINT ["java", "-jar", "/app.jar"]
                ```

                **Build & Run:**
                ```
                docker build -t myapp .
                docker run -p 8080:8080 myapp
                ```

                **Challenges:**
                - Environment variables
                - Health checks
                - Secrets management
                """,
                tags: ["Docker", "containers"]
            ),
            CSConcept(
                category: .springBoot,
                question: "Kubernetes Integration?",
                answer: """
                **Spring Cloud Kubernetes:**
                - ConfigMaps as properties
                - Service discovery
                - Load balancing

                **Health Probes:**
                ```yaml
                livenessProbe:
                  httpGet:
                    path: /actuator/health/liveness
                readinessProbe:
                  httpGet:
                    path: /actuator/health/readiness
                ```
                """,
                tags: ["Kubernetes", "cloud"]
            ),
            
            // MARK: - Performance
            CSConcept(
                category: .springBoot,
                question: "Performance Optimization?",
                answer: """
                **Strategies:**
                1. **Caching:** @Cacheable, Redis
                2. **Connection Pool:** HikariCP (default)
                3. **Lazy Init:** spring.main.lazy-initialization=true
                4. **Async:** @Async for non-blocking
                5. **Pagination:** Limit data fetched
                6. **Indexes:** Database query optimization

                **Monitoring:**
                - Actuator metrics
                - Micrometer + Prometheus
                """,
                tags: ["performance", "optimization"]
            ),
            
            // MARK: - Reactive
            CSConcept(
                category: .springBoot,
                question: "What is Spring WebFlux?",
                answer: """
                Reactive, non-blocking web framework.

                **Core Types:**
                - Mono<T>: 0 or 1 element
                - Flux<T>: 0 to N elements

                ```java
                @GetMapping("/users")
                public Flux<User> getUsers() {
                    return userRepository.findAll();
                }
                ```

                **Benefits:**
                - High concurrency
                - Backpressure support
                - Better resource utilization
                """,
                tags: ["WebFlux", "reactive"]
            )
        ]
    }
}
