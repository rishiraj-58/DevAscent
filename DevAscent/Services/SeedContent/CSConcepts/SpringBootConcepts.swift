//
//  SpringBootConcepts.swift
//  DevAscent
//
//  Spring Boot CS Concepts
//

import Foundation

struct SpringBootConcepts {
    static func all() -> [CSConcept] {
        return [
            CSConcept(
                category: .springBoot,
                question: "@SpringBootApplication - What It Does",
                answer: """
                Combines 3 annotations:

                @Configuration
                • Marks class as source of bean definitions
                • Allows @Bean methods

                @EnableAutoConfiguration
                • Spring guesses config based on classpath
                • Reads META-INF/spring.factories

                @ComponentScan
                • Scans current package and sub-packages
                • Finds @Component, @Service, @Repository, @Controller

                Example:
                @SpringBootApplication
                public class MyApp {
                    public static void main(String[] args) {
                        SpringApplication.run(MyApp.class, args);
                    }
                }
                """,
                tags: ["SpringBoot", "annotations", "auto-configuration"]
            ),
            CSConcept(
                category: .springBoot,
                question: "Dependency Injection - Constructor vs Field",
                answer: """
                Field Injection (@Autowired on field):
                @Autowired
                private UserService userService;
                ❌ Hard to test, hides dependencies, allows nulls

                Constructor Injection (Recommended):
                private final UserService userService;
                public MyController(UserService userService) {
                    this.userService = userService;
                }
                ✅ Immutable, clear dependencies, easy testing

                Why Constructor is better:
                • Fields can be final (immutability)
                • Fails fast if dependency missing
                • No reflection needed
                • Easy to mock in tests
                • Prevents circular dependencies (fails at startup)
                """,
                tags: ["DI", "Autowired", "injection", "testing"]
            ),
            CSConcept(
                category: .springBoot,
                question: "Bean Scopes",
                answer: """
                @Scope("scopeName")

                Singleton (default):
                • One instance per Spring container
                • Shared across all requests
                • Stateless beans only!

                Prototype:
                • New instance on each injection
                • Use for stateful beans
                • Spring doesn't manage full lifecycle

                Request (Web):
                • One instance per HTTP request
                • @RequestScope

                Session (Web):
                • One instance per HTTP session
                • @SessionScope

                When to use Prototype:
                • Bean holds user-specific state
                • Bean is not thread-safe
                """,
                tags: ["Scope", "Singleton", "Prototype", "lifecycle"]
            ),
            CSConcept(
                category: .springBoot,
                question: "@Transactional - How It Works",
                answer: """
                Internal Mechanism:
                • Spring creates AOP proxy around bean
                • Proxy intercepts method call
                • Starts transaction → calls method → commit/rollback

                Propagation Types:
                • REQUIRED (default): Use existing or create new
                • REQUIRES_NEW: Always create new (suspend existing)
                • NESTED: Nested transaction with savepoint
                • SUPPORTS: Use if exists, else non-transactional

                Common Pitfalls:
                • Self-invocation bypasses proxy (no transaction!)
                • Only works on public methods
                • RuntimeException triggers rollback, checked doesn't

                @Transactional(
                    propagation = Propagation.REQUIRED,
                    isolation = Isolation.READ_COMMITTED,
                    rollbackFor = Exception.class
                )
                """,
                tags: ["Transactional", "AOP", "proxy", "propagation"]
            ),
            CSConcept(
                category: .springBoot,
                question: "JPA vs Hibernate",
                answer: """
                JPA (Java Persistence API):
                • Specification/Standard (JSR 338)
                • Defines annotations: @Entity, @Table, @Id
                • Defines EntityManager interface
                • No implementation!

                Hibernate:
                • JPA Implementation (most popular)
                • Provides SessionFactory, Session
                • Extra features: Caching, HQL, Lazy loading
                • Spring Boot default JPA provider

                Spring Data JPA:
                • Abstraction over JPA
                • Repository pattern out of box
                • Query derivation from method names:
                  findByEmailAndStatus(String email, Status status)

                Hierarchy: Spring Data JPA → JPA → Hibernate → JDBC
                """,
                tags: ["JPA", "Hibernate", "ORM", "persistence"]
            ),
            CSConcept(
                category: .springBoot,
                question: "Spring Actuator Endpoints",
                answer: """
                Production-ready features for monitoring:

                /actuator/health
                • Application health status
                • Database, disk space, custom checks

                /actuator/metrics
                • JVM memory, GC, threads
                • HTTP request stats

                /actuator/info
                • Build info, git commit

                /actuator/env
                • Environment properties

                /actuator/loggers
                • View/change log levels at runtime

                Security: Expose only needed endpoints
                management:
                  endpoints:
                    web:
                      exposure:
                        include: health,info,metrics
                """,
                tags: ["Actuator", "monitoring", "health", "metrics"]
            ),
            CSConcept(
                category: .springBoot,
                question: "Spring Profiles - Environment Config",
                answer: """
                What: Different configs for Dev/Test/Prod

                Files:
                • application.properties (default)
                • application-dev.properties
                • application-prod.properties

                Activating:
                • spring.profiles.active=dev
                • -Dspring.profiles.active=prod
                • SPRING_PROFILES_ACTIVE=prod

                @Profile annotation:
                @Bean
                @Profile("dev")
                public DataSource devDataSource() { ... }

                @Profile("!prod") - NOT production

                Best Practices:
                • Never put secrets in properties files
                • Use environment variables for secrets
                • Use Spring Cloud Config for central config
                """,
                tags: ["profiles", "configuration", "environment"]
            ),
            CSConcept(
                category: .springBoot,
                question: "Spring Security Basics",
                answer: """
                Core Concepts:
                • Authentication: Who are you?
                • Authorization: What can you do?
                • Principal: Currently authenticated user

                Filter Chain:
                SecurityFilterChain intercepts all requests
                1. UsernamePasswordAuthenticationFilter
                2. BasicAuthenticationFilter
                3. AuthorizationFilter

                Configuration:
                @EnableWebSecurity
                @Bean
                SecurityFilterChain filterChain(HttpSecurity http) {
                    return http
                        .authorizeHttpRequests(auth -> auth
                            .requestMatchers("/public/**").permitAll()
                            .requestMatchers("/admin/**").hasRole("ADMIN")
                            .anyRequest().authenticated()
                        )
                        .formLogin(withDefaults())
                        .build();
                }

                JWT: Stateless authentication
                """,
                tags: ["Security", "authentication", "authorization", "JWT"]
            ),
            CSConcept(
                category: .springBoot,
                question: "@Cacheable - Spring Caching",
                answer: """
                Enable: @EnableCaching on config class

                Annotations:
                @Cacheable("users") - Cache result
                @CachePut("users") - Update cache
                @CacheEvict("users") - Remove from cache
                @CacheEvict(allEntries=true) - Clear all

                Example:
                @Cacheable(value="users", key="#id")
                public User findById(Long id) {
                    return userRepository.findById(id);
                }

                Cache Providers:
                • ConcurrentHashMap (default, in-memory)
                • Redis (distributed)
                • Ehcache (local, advanced)
                • Caffeine (high performance)

                Conditional:
                @Cacheable(value="users", condition="#id > 10")
                @Cacheable(value="users", unless="#result == null")
                """,
                tags: ["Cacheable", "caching", "Redis", "performance"]
            ),
            CSConcept(
                category: .springBoot,
                question: "@Async - Async Method Execution",
                answer: """
                Enable: @EnableAsync on config class

                Usage:
                @Async
                public void sendEmail(String to) { ... }

                @Async
                public CompletableFuture<User> findUser(Long id) {
                    return CompletableFuture.completedFuture(user);
                }

                Custom Executor:
                @Bean("customExecutor")
                public Executor taskExecutor() {
                    ThreadPoolTaskExecutor e = new ThreadPoolTaskExecutor();
                    e.setCorePoolSize(2);
                    e.setMaxPoolSize(10);
                    e.setQueueCapacity(500);
                    return e;
                }

                @Async("customExecutor")
                public void process() { ... }

                Pitfall: Calling @Async from same class bypasses proxy!
                """,
                tags: ["Async", "threading", "executor", "performance"]
            ),
            CSConcept(
                category: .springBoot,
                question: "@Scheduled - Task Scheduling",
                answer: """
                Enable: @EnableScheduling

                Fixed Rate (start to start):
                @Scheduled(fixedRate = 5000)
                public void runEvery5Seconds() { ... }

                Fixed Delay (end to start):
                @Scheduled(fixedDelay = 5000)
                public void run5SecondsAfterLast() { ... }

                Cron Expression:
                @Scheduled(cron = "0 0 8 * * MON-FRI")
                public void runAt8amWeekdays() { ... }

                Cron format: second minute hour day month weekday
                • 0 0 * * * * = every hour
                • 0 0 8 * * * = 8am daily
                • 0 0 0 * * SUN = midnight Sunday

                Initial Delay:
                @Scheduled(fixedRate=5000, initialDelay=10000)
                """,
                tags: ["Scheduled", "cron", "tasks", "timer"]
            ),
            CSConcept(
                category: .springBoot,
                question: "Spring AOP Concepts",
                answer: """
                Aspect: Class containing cross-cutting concerns
                Advice: Action taken (before, after, around)
                Pointcut: WHERE to apply (expression)
                JoinPoint: Point in execution (method call)

                Advice Types:
                @Before - Before method
                @After - After method (always)
                @AfterReturning - After successful return
                @AfterThrowing - After exception
                @Around - Wraps method (most powerful)

                Example:
                @Aspect
                @Component
                public class LoggingAspect {
                    @Around("execution(* com.example.service.*.*(..))")
                    public Object logTime(ProceedingJoinPoint pjp) throws Throwable {
                        long start = System.currentTimeMillis();
                        Object result = pjp.proceed();
                        log.info("Time: {}ms", System.currentTimeMillis() - start);
                        return result;
                    }
                }
                """,
                tags: ["AOP", "Aspect", "proxy", "cross-cutting"]
            )
        ]
    }
}
