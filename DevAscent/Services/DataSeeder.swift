//
//  DataSeeder.swift
//  DevAscent
//
//  Seeds the database with GS Interview preparation data
//  Created by Rishiraj on 13/12/24.
//

import Foundation
import SwiftData

/// Seeds the database with Goldman Sachs interview preparation content
struct DataSeeder {
    
    /// Check if data needs to be seeded (first launch)
    static func needsSeeding(context: ModelContext) -> Bool {
        let lldCount = (try? context.fetchCount(FetchDescriptor<LLDProblem>())) ?? 0
        let csCount = (try? context.fetchCount(FetchDescriptor<CSConcept>())) ?? 0
        return lldCount == 0 && csCount == 0
    }
    
    /// Seed all data
    static func seedIfNeeded(context: ModelContext) {
        guard needsSeeding(context: context) else { return }
        
        seedLLDProblems(context: context)
        seedCSConcepts(context: context)
    }
    
    // MARK: - LLD Problems (Goldman Sachs Question Bank)
    
    private static func seedLLDProblems(context: ModelContext) {
        let problems = [
            // 1. Car Rental System
            LLDProblem(
                title: "Car Rental System",
                requirements: """
                • Multiple vehicle types (Sedan, SUV, Luxury)
                • Dynamic pricing based on demand/season
                • Reservation management with pick-up/drop-off
                • Vehicle status tracking (Available, Reserved, Rented, Maintenance)
                • Payment processing with multiple methods
                """,
                solutionStrategy: """
                **Patterns Used:**
                - **Strategy Pattern**: Dynamic pricing algorithms
                - **State Pattern**: Vehicle status transitions
                - **Factory Pattern**: Vehicle creation
                
                **Key Classes:**
                Vehicle, Reservation, PricingStrategy, RentalService, PaymentProcessor
                """,
                mermaidGraph: """
                classDiagram
                    class RentalService {
                        -VehicleInventory inventory
                        -ReservationRepository reservations
                        -PricingStrategy pricingStrategy
                        +searchVehicles(criteria) List
                        +createReservation(customer, vehicle) Reservation
                        +completePickup(reservationId) void
                        +completeReturn(reservationId) Bill
                    }
                    
                    class VehicleInventory {
                        -Map vehicles
                        +addVehicle(vehicle) void
                        +findAvailable(type, dates) List
                    }
                    
                    class Vehicle {
                        -String vehicleId
                        -String licensePlate
                        -VehicleType type
                        -VehicleState state
                        -double baseRatePerDay
                        +reserve() void
                        +pickup() void
                        +returnVehicle() void
                    }
                    
                    class VehicleState {
                        <<interface>>
                        +reserve(Vehicle) void
                        +pickup(Vehicle) void
                        +returnVehicle(Vehicle) void
                    }
                    
                    class AvailableState {
                        +reserve(Vehicle) void
                    }
                    class ReservedState {
                        -DateTime reservedUntil
                    }
                    class RentedState {
                        -Customer rentedBy
                    }
                    class MaintenanceState
                    
                    class Reservation {
                        -String reservationId
                        -Customer customer
                        -Vehicle vehicle
                        -Branch pickupBranch
                        -Branch dropoffBranch
                        -DateTime pickupTime
                        -DateTime dropoffTime
                        -ReservationStatus status
                        +confirm() void
                        +cancel() void
                    }
                    
                    class Customer {
                        -String customerId
                        -String name
                        -DrivingLicense license
                        +isLicenseValid() boolean
                    }
                    
                    class PricingStrategy {
                        <<interface>>
                        +calculatePrice(vehicle, days) double
                    }
                    class WeekdayPricing
                    class WeekendPricing
                    class HolidayPricing
                    class SurgePricing
                    
                    class Branch {
                        -String branchId
                        -Address address
                        -List vehicles
                    }
                    
                    class PaymentProcessor {
                        <<interface>>
                        +process(amount) PaymentResult
                    }
                    
                    RentalService "1" *-- "1" VehicleInventory
                    RentalService o-- Reservation
                    RentalService ..> PricingStrategy
                    RentalService ..> PaymentProcessor
                    VehicleInventory *-- Vehicle
                    Vehicle *-- VehicleState
                    VehicleState <|.. AvailableState
                    VehicleState <|.. ReservedState
                    VehicleState <|.. RentedState
                    VehicleState <|.. MaintenanceState
                    Reservation --> Vehicle
                    Reservation --> Customer
                    Reservation --> Branch
                    PricingStrategy <|.. WeekdayPricing
                    PricingStrategy <|.. WeekendPricing
                    PricingStrategy <|.. HolidayPricing
                    PricingStrategy <|.. SurgePricing
                    Branch o-- Vehicle
                """,
                codeSnippet: """
                // ═══════════════════════════════════════
                // FILE: model/Vehicle.java
                // ═══════════════════════════════════════
                public class Vehicle {
                    private final String vehicleId;
                    private final VehicleType type;
                    private VehicleState state;
                    private final double baseRatePerDay;
                    
                    public Vehicle(String id, VehicleType type, double rate) {
                        this.vehicleId = id;
                        this.type = type;
                        this.baseRatePerDay = rate;
                        this.state = new AvailableState();
                    }
                    
                    public void reserve() { state.reserve(this); }
                    public void pickup() { state.pickup(this); }
                    public void returnVehicle() { state.returnVehicle(this); }
                    public void setState(VehicleState s) { this.state = s; }
                }

                // ═══════════════════════════════════════
                // FILE: state/VehicleState.java
                // ═══════════════════════════════════════
                public interface VehicleState {
                    void reserve(Vehicle vehicle);
                    void pickup(Vehicle vehicle);
                    void returnVehicle(Vehicle vehicle);
                }

                // ═══════════════════════════════════════
                // FILE: state/AvailableState.java
                // ═══════════════════════════════════════
                public class AvailableState implements VehicleState {
                    @Override
                    public void reserve(Vehicle v) {
                        v.setState(new ReservedState());
                    }
                    @Override
                    public void pickup(Vehicle v) {
                        throw new IllegalStateException("Must reserve first");
                    }
                    @Override
                    public void returnVehicle(Vehicle v) {
                        throw new IllegalStateException("Not rented");
                    }
                }

                // ═══════════════════════════════════════
                // FILE: pricing/PricingStrategy.java
                // ═══════════════════════════════════════
                public interface PricingStrategy {
                    double calculatePrice(Vehicle vehicle, int days);
                }

                // ═══════════════════════════════════════
                // FILE: pricing/WeekendPricing.java
                // ═══════════════════════════════════════
                public class WeekendPricing implements PricingStrategy {
                    private static final double SURGE = 1.5;
                    @Override
                    public double calculatePrice(Vehicle v, int days) {
                        return v.getBaseRate() * days * SURGE;
                    }
                }

                // ═══════════════════════════════════════
                // FILE: service/RentalService.java
                // ═══════════════════════════════════════
                public class RentalService {
                    private final VehicleInventory inventory;
                    private PricingStrategy pricingStrategy;
                    
                    public Reservation createReservation(
                            Customer customer, Vehicle vehicle, 
                            LocalDate start, LocalDate end) {
                        if (!customer.isLicenseValid()) 
                            throw new InvalidLicenseException();
                        
                        vehicle.reserve();
                        int days = (int) ChronoUnit.DAYS.between(start, end);
                        double cost = pricingStrategy.calculatePrice(vehicle, days);
                        return new Reservation(customer, vehicle, start, end, cost);
                    }
                }
                """,
                gsSpecificTwist: "Add support for corporate fleet discounts and loyalty program integration"
            ),
            
            // 2. Snake & Ladder (Distributed)
            LLDProblem(
                title: "Snake & Ladder (Distributed)",
                requirements: """
                • Multi-player game with 2-6 players
                • Board with configurable snakes and ladders
                • Dice rolling and piece movement
                • Turn-based gameplay
                • **Distributed**: Event-driven architecture for real-time updates
                """,
                solutionStrategy: """
                **Patterns Used:**
                - **Observer Pattern**: Real-time game state updates
                - **Singleton Pattern**: Game board instance
                - **Command Pattern**: Move execution and undo
                
                **Distributed Twist:**
                - Event-Driven Architecture
                - Message Queue (Kafka) for move events
                - Eventual consistency for game state
                """,
                mermaidGraph: """
                sequenceDiagram
                    participant Player
                    participant GameService
                    participant Kafka
                    participant BoardService
                    participant NotificationService
                    
                    Player->>GameService: rollDice()
                    GameService->>Kafka: publish(MoveEvent)
                    Kafka->>BoardService: consume(MoveEvent)
                    BoardService->>BoardService: validateMove()
                    BoardService->>BoardService: applySnakesLadders()
                    BoardService->>Kafka: publish(StateUpdated)
                    Kafka->>NotificationService: consume(StateUpdated)
                    NotificationService->>Player: broadcastState()
                """,
                codeSnippet: """
                // Observer Pattern for Game State
                public interface GameObserver {
                    void onPlayerMoved(Player player, int newPosition);
                    void onGameWon(Player winner);
                }

                public class Board {
                    private static Board instance;
                    private final Map<Integer, Integer> snakes = new HashMap<>();
                    private final Map<Integer, Integer> ladders = new HashMap<>();
                    private final List<GameObserver> observers = new ArrayList<>();
                    
                    private Board() {
                        // Initialize snakes and ladders
                        snakes.put(99, 7);
                        snakes.put(95, 56);
                        ladders.put(3, 22);
                        ladders.put(8, 30);
                    }
                    
                    public static synchronized Board getInstance() {
                        if (instance == null) {
                            instance = new Board();
                        }
                        return instance;
                    }
                    
                    public int getFinalPosition(int position) {
                        if (snakes.containsKey(position)) {
                            return snakes.get(position);  // Slide down
                        }
                        if (ladders.containsKey(position)) {
                            return ladders.get(position);  // Climb up
                        }
                        return position;
                    }
                    
                    public void notifyMove(Player p, int pos) {
                        observers.forEach(o -> o.onPlayerMoved(p, pos));
                    }
                }

                // Event for Kafka
                public class MoveEvent {
                    private final String playerId;
                    private final int diceValue;
                    private final long timestamp;
                    
                    // Constructor, getters
                }
                """,
                gsSpecificTwist: "Handle network partitions - what if a player disconnects mid-move? Implement idempotent move processing."
            ),
            
            // 3. Stock Exchange
            LLDProblem(
                title: "Stock Exchange / Order Matching",
                requirements: """
                • Support BUY and SELL orders
                • Price-Time priority matching
                • Order types: Market, Limit, Stop-Loss
                • Real-time trade execution
                • Order book management
                """,
                solutionStrategy: """
                **Patterns Used:**
                - **Single Writer Principle** (LMAX Disruptor)
                - **Observer Pattern**: Price ticker updates
                - **Strategy Pattern**: Different order matching algorithms
                
                **Data Structures:**
                - PriorityQueue for order book (Price/Time priority)
                - TreeMap for price levels
                """,
                mermaidGraph: """
                classDiagram
                    class MatchingEngine {
                        -OrderBook orderBook
                        -List~MatchingStrategy~ strategies
                        -TradeExecutor executor
                        +processOrder(Order) List~Trade~
                        -match(Order, OrderBook) List~Trade~
                        +registerStrategy(MatchingStrategy)
                    }
                    
                    class OrderBook {
                        -String symbol
                        -TreeMap buyOrders
                        -TreeMap sellOrders
                        -ReentrantLock lock
                        +addOrder(Order) void
                        +cancelOrder(orderId) boolean
                        +modifyOrder(orderId, newQty) boolean
                        +getBestBid() Double
                        +getBestAsk() Double
                        +getSpread() double
                    }
                    
                    class Order {
                        -String orderId
                        -String symbol
                        -OrderType type
                        -OrderSide side
                        -double price
                        -int quantity
                        -int filledQty
                        -OrderStatus status
                        -long timestamp
                        +isFilled() boolean
                        +getRemainingQty() int
                    }
                    
                    class OrderType {
                        <<enumeration>>
                        MARKET
                        LIMIT
                        STOP_LOSS
                        STOP_LIMIT
                        IOC
                        FOK
                    }
                    
                    class MatchingStrategy {
                        <<interface>>
                        +canMatch(Order, Order) boolean
                        +getExecutionPrice(Order, Order) double
                    }
                    class PriceTimePriority
                    class ProRataMatching
                    
                    class Trade {
                        -String tradeId
                        -Order buyOrder
                        -Order sellOrder
                        -double executionPrice
                        -int quantity
                        -long executedAt
                    }
                    
                    class TradeExecutor {
                        +execute(Order, Order, price, qty) Trade
                        +settle(Trade) void
                    }
                    
                    class CircuitBreaker {
                        -double upperLimit
                        -double lowerLimit
                        -boolean isTripped
                        +checkPrice(price) boolean
                        +trip() void
                        +reset() void
                    }
                    
                    MatchingEngine *-- OrderBook
                    MatchingEngine *-- TradeExecutor
                    MatchingEngine o-- CircuitBreaker
                    MatchingEngine ..> MatchingStrategy
                    OrderBook *-- Order
                    Order --> OrderType
                    MatchingStrategy <|.. PriceTimePriority
                    MatchingStrategy <|.. ProRataMatching
                    TradeExecutor --> Trade
                    Trade --> Order
                """,
                codeSnippet: """
                public class OrderBook {
                    // Best prices at the front
                    private final TreeMap<Double, Queue<Order>> buyOrders = 
                        new TreeMap<>(Collections.reverseOrder());  // Highest first
                    private final TreeMap<Double, Queue<Order>> sellOrders = 
                        new TreeMap<>();  // Lowest first
                    
                    public void addOrder(Order order) {
                        TreeMap<Double, Queue<Order>> book = 
                            order.getSide() == Side.BUY ? buyOrders : sellOrders;
                        
                        book.computeIfAbsent(order.getPrice(), 
                            k -> new LinkedList<>()).offer(order);
                    }
                    
                    public Double getBestBid() {
                        return buyOrders.isEmpty() ? null : buyOrders.firstKey();
                    }
                    
                    public Double getBestAsk() {
                        return sellOrders.isEmpty() ? null : sellOrders.firstKey();
                    }
                }

                public class MatchingEngine {
                    private final OrderBook orderBook = new OrderBook();
                    
                    public List<Trade> processOrder(Order incoming) {
                        List<Trade> trades = new ArrayList<>();
                        
                        if (incoming.getSide() == Side.BUY) {
                            // Match against sell orders
                            while (incoming.getQuantity() > 0 && canMatch(incoming)) {
                                Trade trade = executeMatch(incoming, getBestSellOrder());
                                trades.add(trade);
                            }
                        }
                        
                        // Add remaining to book
                        if (incoming.getQuantity() > 0) {
                            orderBook.addOrder(incoming);
                        }
                        
                        return trades;
                    }
                }
                """,
                gsSpecificTwist: "Implement circuit breakers for 10% price swings and handle order priority during system restarts"
            ),
            
            // 4. Parking Lot
            LLDProblem(
                title: "Parking Lot System",
                requirements: """
                • Multiple floors with different spot sizes
                • Vehicle types: Motorcycle, Car, Truck
                • Find nearest available spot
                • Hourly rate pricing
                • Entry/Exit gate management
                """,
                solutionStrategy: """
                **Patterns Used:**
                - **Strategy Pattern**: Pricing algorithms
                - **Factory Pattern**: Ticket generation
                - **Singleton Pattern**: Parking lot instance

                **Key Algorithms:**
                - Nearest spot: Min-heap by distance from entry
                """,
                mermaidGraph: """
                classDiagram
                    class ParkingLot {
                        <<Singleton>>
                        -String name
                        -Address address
                        -List~Floor~ floors
                        -List~Gate~ entryGates
                        -List~Gate~ exitGates
                        -PricingStrategy pricingStrategy
                        +getInstance() ParkingLot
                        +findSpot(VehicleType) ParkingSpot
                        +parkVehicle(Vehicle, Gate) Ticket
                        +unparkVehicle(Ticket) Payment
                        +getAvailableCount() Map
                    }
                    
                    class Floor {
                        -int floorNumber
                        -List~ParkingSpot~ spots
                        -DisplayBoard displayBoard
                        +getAvailableSpots(VehicleType) List
                        +updateDisplay() void
                    }
                    
                    class ParkingSpot {
                        <<abstract>>
                        -String spotId
                        -int floorNumber
                        -int distanceFromEntry
                        -boolean isOccupied
                        -Vehicle vehicle
                        +canFit(VehicleType) boolean
                        +occupy(Vehicle) void
                        +vacate() void
                    }
                    class CompactSpot
                    class LargeSpot
                    class HandicappedSpot
                    class MotorcycleSpot
                    class EVSpot {
                        -ChargingStation charger
                    }
                    
                    class Vehicle {
                        -String licensePlate
                        -VehicleType type
                        -String color
                    }
                    
                    class Gate {
                        -int gateId
                        -GateType type
                        -boolean isOperational
                        +processEntry(Vehicle) Ticket
                        +processExit(Ticket) Payment
                    }
                    
                    class Ticket {
                        -String ticketId
                        -Vehicle vehicle
                        -ParkingSpot spot
                        -Gate entryGate
                        -DateTime entryTime
                        -TicketStatus status
                    }
                    
                    class PricingStrategy {
                        <<interface>>
                        +calculate(duration) double
                    }
                    class HourlyPricing
                    class FlatRatePricing
                    class DynamicPricing
                    
                    class Payment {
                        -double amount
                        -PaymentMethod method
                        -PaymentStatus status
                        +process() boolean
                    }
                    
                    class DisplayBoard {
                        -Map availableSpots
                        +update(Floor) void
                        +show() void
                    }
                    
                    ParkingLot *-- Floor
                    ParkingLot *-- Gate
                    ParkingLot ..> PricingStrategy
                    Floor *-- ParkingSpot
                    Floor *-- DisplayBoard
                    ParkingSpot <|-- CompactSpot
                    ParkingSpot <|-- LargeSpot
                    ParkingSpot <|-- HandicappedSpot
                    ParkingSpot <|-- MotorcycleSpot
                    ParkingSpot <|-- EVSpot
                    ParkingSpot o-- Vehicle
                    Gate --> Ticket
                    Ticket --> ParkingSpot
                    Ticket --> Vehicle
                    PricingStrategy <|.. HourlyPricing
                    PricingStrategy <|.. FlatRatePricing
                    PricingStrategy <|.. DynamicPricing
                    Gate --> Payment
                """,
                codeSnippet: """
                public class ParkingLot {
                    private static ParkingLot instance;
                    private final List<Floor> floors;
                    private final PriorityQueue<ParkingSpot> availableSpots;
                    
                    public ParkingSpot findNearestSpot(VehicleType type) {
                        return availableSpots.stream()
                            .filter(spot -> spot.canFit(type))
                            .findFirst()
                            .orElse(null);
                    }
                    
                    public Ticket parkVehicle(Vehicle vehicle) {
                        ParkingSpot spot = findNearestSpot(vehicle.getType());
                        if (spot == null) throw new ParkingFullException();
                        
                        spot.occupy(vehicle);
                        return new Ticket(vehicle, spot, LocalDateTime.now());
                    }
                    
                    public double unparkVehicle(Ticket ticket) {
                        Duration parked = Duration.between(
                            ticket.getEntryTime(), LocalDateTime.now());
                        ticket.getSpot().vacate();
                        return pricingStrategy.calculate(parked);
                    }
                }
                """,
                gsSpecificTwist: "Add EV charging spots with reservation system"
            ),
            
            // 5. Air Traffic Control
            LLDProblem(
                title: "Air Traffic Control",
                requirements: """
                • Manage runway allocation
                • Flight queue with priority (Emergency > International > Domestic)
                • Landing/Takeoff scheduling
                • Weather delay handling
                • Collision avoidance
                """,
                solutionStrategy: """
                **Patterns Used:**
                - **Command Pattern**: Flight commands (Land, Takeoff, Hold)
                - **Strategy Pattern**: Scheduling algorithms
                - **State Pattern**: Runway status

                **Data Structures:**
                - PriorityQueue for flight scheduling
                """,
                mermaidGraph: """
                classDiagram
                    class ATCController {
                        -List~Runway~ runways
                        -PriorityQueue~Flight~ landingQueue
                        +requestLanding(Flight)
                        +requestTakeoff(Flight)
                        +assignRunway(Flight)
                    }
                    class Runway {
                        -String id
                        -RunwayState state
                        -Flight currentFlight
                        +allocate(Flight)
                        +release()
                    }
                    class Flight {
                        -String flightNumber
                        -FlightPriority priority
                        -FlightStatus status
                    }
                    ATCController --> Runway
                    ATCController --> Flight
                """,
                codeSnippet: """
                public class ATCController {
                    private final PriorityQueue<Flight> landingQueue = 
                        new PriorityQueue<>(Comparator.comparing(Flight::getPriority));
                    private final List<Runway> runways;
                    
                    public void requestLanding(Flight flight) {
                        landingQueue.offer(flight);
                        processQueue();
                    }
                    
                    private void processQueue() {
                        while (!landingQueue.isEmpty()) {
                            Flight next = landingQueue.peek();
                            Runway available = findAvailableRunway();
                            
                            if (available != null) {
                                landingQueue.poll();
                                available.allocate(next);
                                scheduleRelease(available, next.getEstimatedLandingTime());
                            } else {
                                break;  // No runway available
                            }
                        }
                    }
                }

                enum FlightPriority {
                    EMERGENCY(0), INTERNATIONAL(1), DOMESTIC(2);
                    private final int value;
                }
                """,
                gsSpecificTwist: "Handle simultaneous emergency landings on single runway"
            ),
            
            // 6. Twitter/Social Feed
            LLDProblem(
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
                        -Set~User~ followers
                        -Set~User~ following
                        +follow(User)
                        +post(Tweet)
                    }
                    class Tweet {
                        -String tweetId
                        -User author
                        -String content
                        -DateTime timestamp
                        -List~String~ hashtags
                    }
                    class FeedService {
                        +generateFeed(User)
                        +fanOutTweet(Tweet)
                    }
                    class TrendingService {
                        -Map~String,Integer~ hashtagCounts
                        +updateTrending(Tweet)
                        +getTopK(int k)
                    }
                    User --> Tweet
                    FeedService --> Tweet
                    TrendingService --> Tweet
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
            ),
            
            // 7. E-Commerce Checkout
            LLDProblem(
                title: "E-Commerce Checkout",
                requirements: """
                • Shopping cart management
                • Inventory reservation
                • Multiple payment methods
                • Coupon/Discount application
                • Order confirmation
                """,
                solutionStrategy: """
                **Patterns Used:**
                - **Strategy Pattern**: Payment processing
                - **Decorator Pattern**: Discount stacking
                - **Command Pattern**: Order operations
                - **Saga Pattern**: Distributed transaction

                **Key Concern:**
                - Inventory locking during checkout
                """,
                mermaidGraph: """
                classDiagram
                    class Cart {
                        -List~CartItem~ items
                        +addItem(Product, quantity)
                        +removeItem(Product)
                        +getTotal()
                    }
                    class Order {
                        -String orderId
                        -List~OrderItem~ items
                        -PaymentInfo payment
                        -OrderStatus status
                    }
                    class CheckoutService {
                        +initiateCheckout(Cart)
                        +applyDiscount(Coupon)
                        +processPayment(PaymentInfo)
                        +confirmOrder()
                    }
                    class InventoryService {
                        +reserve(Product, quantity)
                        +release(Product, quantity)
                        +commit(Reservation)
                    }
                    CheckoutService --> Cart
                    CheckoutService --> Order
                    CheckoutService --> InventoryService
                """,
                codeSnippet: """
                public class CheckoutService {
                    private final InventoryService inventory;
                    private final PaymentService payment;
                    
                    @Transactional
                    public Order checkout(Cart cart, PaymentInfo paymentInfo) {
                        // 1. Reserve inventory
                        Reservation reservation = inventory.reserve(cart.getItems());
                        
                        try {
                            // 2. Calculate total with discounts
                            double total = calculateTotal(cart);
                            
                            // 3. Process payment
                            PaymentResult result = payment.process(paymentInfo, total);
                            if (!result.isSuccess()) {
                                throw new PaymentFailedException();
                            }
                            
                            // 4. Commit inventory
                            inventory.commit(reservation);
                            
                            // 5. Create order
                            return createOrder(cart, result);
                            
                        } catch (Exception e) {
                            inventory.release(reservation);
                            throw e;
                        }
                    }
                }
                """,
                gsSpecificTwist: "Handle flash sale with 1000 concurrent checkouts for 100 items"
            ),
            
            // 8. URL Shortener
            LLDProblem(
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
                        +shorten(String longUrl)
                        +resolve(String shortCode)
                        +getAnalytics(String shortCode)
                    }
                    class URLMapping {
                        -String shortCode
                        -String longUrl
                        -DateTime createdAt
                        -DateTime expiresAt
                        -long clickCount
                    }
                    class CodeGenerator {
                        <<interface>>
                        +generate(long id)
                    }
                    class Base62Generator {
                        +generate(long id)
                    }
                    URLService --> URLMapping
                    URLService --> CodeGenerator
                    CodeGenerator <|.. Base62Generator
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
            ),
            
            // 9. Splitwise / Expense Sharing
            LLDProblem(
                title: "Splitwise / Expense Sharing",
                requirements: """
                • Create groups with members
                • Add expenses with different split types (Equal, Exact, Percentage)
                • Calculate balances and simplify debts
                • Settle up transactions
                • Expense history
                """,
                solutionStrategy: """
                **Patterns Used:**
                - **Strategy Pattern**: Split calculation
                - **Observer Pattern**: Balance updates
                
                **Key Algorithm:**
                - Debt simplification using min-heap greedy
                - Graph representation of debts
                """,
                mermaidGraph: """
                classDiagram
                    class Group {
                        -String groupId
                        -List~User~ members
                        -List~Expense~ expenses
                        +addExpense(Expense)
                        +getBalances()
                    }
                    class Expense {
                        -String expenseId
                        -User paidBy
                        -double amount
                        -SplitStrategy split
                        -List~Split~ splits
                    }
                    class SplitStrategy {
                        <<interface>>
                        +calculateSplits(amount, users)
                    }
                    class BalanceService {
                        +getBalance(User, Group)
                        +simplifyDebts(Group)
                    }
                    Group --> Expense
                    Expense --> SplitStrategy
                    BalanceService --> Group
                """,
                codeSnippet: """
                public interface SplitStrategy {
                    Map<User, Double> calculateSplits(double amount, List<User> users);
                }

                public class EqualSplit implements SplitStrategy {
                    @Override
                    public Map<User, Double> calculateSplits(double amount, List<User> users) {
                        double perPerson = amount / users.size();
                        return users.stream()
                            .collect(Collectors.toMap(u -> u, u -> perPerson));
                    }
                }

                public class BalanceService {
                    // Debt simplification - minimize transactions
                    public List<Transaction> simplifyDebts(Map<User, Double> balances) {
                        PriorityQueue<Map.Entry<User, Double>> creditors = 
                            new PriorityQueue<>((a, b) -> Double.compare(b.getValue(), a.getValue()));
                        PriorityQueue<Map.Entry<User, Double>> debtors = 
                            new PriorityQueue<>(Comparator.comparing(Map.Entry::getValue));
                        
                        balances.forEach((user, balance) -> {
                            if (balance > 0) creditors.offer(Map.entry(user, balance));
                            else if (balance < 0) debtors.offer(Map.entry(user, balance));
                        });
                        
                        List<Transaction> transactions = new ArrayList<>();
                        while (!creditors.isEmpty() && !debtors.isEmpty()) {
                            var creditor = creditors.poll();
                            var debtor = debtors.poll();
                            
                            double amount = Math.min(creditor.getValue(), -debtor.getValue());
                            transactions.add(new Transaction(debtor.getKey(), creditor.getKey(), amount));
                            
                            // Re-add if not settled
                            if (creditor.getValue() > amount) {
                                creditors.offer(Map.entry(creditor.getKey(), creditor.getValue() - amount));
                            }
                            if (-debtor.getValue() > amount) {
                                debtors.offer(Map.entry(debtor.getKey(), debtor.getValue() + amount));
                            }
                        }
                        return transactions;
                    }
                }
                """,
                gsSpecificTwist: "Handle multi-currency expenses with real-time forex rates"
            )
        ]
        
        for problem in problems {
            context.insert(problem)
        }
    }
    
    // MARK: - CS Concepts (Kernel)
    
    private static func seedCSConcepts(context: ModelContext) {
        let concepts = [
            // OS Concepts
            CSConcept(
                category: .os,
                question: "Process vs Thread - Key Differences",
                answer: """
                **Process:**
                - Independent execution unit with own memory space
                - Heavy context switch (TLB flush, page tables)
                - Inter-process communication via IPC (pipes, shared memory)

                **Thread:**
                - Lightweight, shares process memory
                - Faster context switch (same address space)
                - Communication via shared variables (need synchronization)

                **Key Point:** Threads within a process share heap but have separate stacks.
                """,
                tags: ["process", "thread", "concurrency"]
            ),
            CSConcept(
                category: .os,
                question: "Deadlock - 4 Necessary Conditions",
                answer: """
                All 4 conditions must hold simultaneously (Coffman conditions):

                1. **Mutual Exclusion:** Resource can only be held by one process
                2. **Hold and Wait:** Process holds resources while waiting for others
                3. **No Preemption:** Resources cannot be forcibly taken
                4. **Circular Wait:** Circular chain of processes waiting for each other

                **Prevention:** Break any one condition
                **Detection:** Resource allocation graph with cycle detection
                """,
                tags: ["deadlock", "concurrency", "synchronization"]
            ),
            CSConcept(
                category: .os,
                question: "Virtual Memory - Page Fault Handling",
                answer: """
                1. CPU generates virtual address
                2. MMU checks page table → Page not in RAM (invalid bit)
                3. **Page Fault** trap to OS
                4. OS finds page on disk (swap space)
                5. If no free frame → Page replacement (LRU/FIFO)
                6. Load page from disk to RAM
                7. Update page table, set valid bit
                8. Restart instruction

                **Thrashing:** When system spends more time paging than executing
                """,
                tags: ["virtual memory", "paging", "page fault"]
            ),
            
            // Java Concepts
            CSConcept(
                category: .java,
                question: "HashMap Internals (Java 8+)",
                answer: """
                **Structure:**
                - Array of buckets (default 16)
                - Each bucket: LinkedList → TreeMap (when >8 nodes)

                **Hashing:**
                ```
                index = (n-1) & hash(key.hashCode())
                ```

                **Collision Handling:**
                - Java 7: Linked List (O(n) worst case)
                - Java 8+: Red-Black Tree (O(log n) when ≥8 nodes)

                **Resize:**
                - Load Factor: 0.75
                - When exceeded: Double capacity, rehash all entries

                **Key Methods:**
                - `put()`: hash → bucket → traverse/insert
                - `get()`: hash → bucket → equals() check
                """,
                tags: ["HashMap", "data structures", "hashing"]
            ),
            CSConcept(
                category: .java,
                question: "volatile vs synchronized",
                answer: """
                **volatile:**
                - Visibility guarantee only
                - Reads/writes go to main memory
                - No atomicity for compound operations (i++)
                - No blocking

                **synchronized:**
                - Visibility + Atomicity + Mutual exclusion
                - Acquires lock (monitor)
                - Blocking (other threads wait)
                - Can cause deadlock

                **Use volatile when:**
                - Single writer, multiple readers
                - Simple flag/status variable
                - Happens-before relationship needed

                **Use synchronized when:**
                - Multiple writers
                - Compound operations (check-then-act)
                - Need mutual exclusion
                """,
                tags: ["volatile", "synchronized", "concurrency", "visibility"]
            ),
            CSConcept(
                category: .java,
                question: "Garbage Collection - Generations",
                answer: """
                **Generational Hypothesis:** Most objects die young

                **Heap Structure:**
                1. **Young Generation:**
                   - Eden (new objects allocated here)
                   - Survivor 0 & Survivor 1 (survivors of minor GC)
                   - Minor GC: Fast, stop-the-world pause

                2. **Old Generation (Tenured):**
                   - Objects surviving multiple minor GCs
                   - Major GC: Slower, longer pause

                3. **Metaspace (Java 8+):**
                   - Class metadata (replaced PermGen)

                **Common Collectors:**
                - G1 (default in Java 9+)
                - ZGC (ultra-low latency)
                - Shenandoah (concurrent compaction)
                """,
                tags: ["GC", "garbage collection", "heap", "memory"]
            ),
            CSConcept(
                category: .java,
                question: "ReentrantLock vs synchronized",
                answer: """
                **ReentrantLock advantages:**
                - `tryLock()` - non-blocking attempt
                - `lockInterruptibly()` - can be interrupted
                - Fairness policy (FIFO ordering)
                - Multiple Condition objects
                - `tryLock(timeout)` - timed waiting

                **synchronized advantages:**
                - Simpler syntax
                - Automatic release (even on exception)
                - JVM optimizations (biased locking, lock elision)

                **When to use ReentrantLock:**
                - Need tryLock or timed lock
                - Need fairness
                - Need multiple conditions
                - Need interruptible locking
                """,
                tags: ["ReentrantLock", "synchronized", "concurrency", "locks"]
            ),
            
            // DBMS Concepts
            CSConcept(
                category: .dbms,
                question: "ACID Properties",
                answer: """
                **A - Atomicity:**
                All or nothing. If any part fails, entire transaction rolls back.
                *Implementation:* Write-ahead logging (WAL)

                **C - Consistency:**
                Database moves from one valid state to another.
                *Implementation:* Constraints, triggers, rules

                **I - Isolation:**
                Concurrent transactions don't interfere.
                *Levels:* Read Uncommitted → Read Committed → Repeatable Read → Serializable

                **D - Durability:**
                Committed data survives system crash.
                *Implementation:* WAL + checkpointing
                """,
                tags: ["ACID", "transactions", "database"]
            ),
            CSConcept(
                category: .dbms,
                question: "B-Tree Indexing - How it Works",
                answer: """
                **Structure:**
                - Balanced tree with sorted keys
                - Each node has multiple keys and children
                - Leaf nodes at same level

                **Properties:**
                - Order m: max m children per node
                - Min ⌈m/2⌉ children (except root)
                - Keys in each node are sorted

                **Operations:**
                - Search: O(log n)
                - Insert: O(log n) with possible splits
                - Delete: O(log n) with possible merges

                **B+ Tree (used in databases):**
                - Only leaves contain data pointers
                - Leaves linked for range queries
                - Better for disk I/O (more keys per node)

                **Why not Hash Index for range queries:**
                Hash doesn't preserve order, B-Tree does
                """,
                tags: ["B-Tree", "indexing", "database", "data structures"]
            ),
            CSConcept(
                category: .dbms,
                question: "Database Normalization (1NF to BCNF)",
                answer: """
                **1NF (First Normal Form):**
                - No repeating groups
                - Atomic values only
                - Each row unique (primary key)

                **2NF:**
                - 1NF + No partial dependencies
                - Non-key attributes depend on entire primary key

                **3NF:**
                - 2NF + No transitive dependencies
                - Non-key attributes depend only on primary key

                **BCNF (Boyce-Codd):**
                - 3NF + Every determinant is a candidate key

                **Denormalization:**
                - Add redundancy for read performance
                - Trade-off: Write complexity vs Read speed
                """,
                tags: ["normalization", "1NF", "2NF", "3NF", "BCNF", "database"]
            ),
            
            // Networking
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
            )
        ]
        
        for concept in concepts {
            context.insert(concept)
        }
    }
}
