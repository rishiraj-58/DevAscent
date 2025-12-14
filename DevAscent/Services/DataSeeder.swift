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
    
    // Increment this when content changes to trigger re-seed
    private static let contentVersion = 7
    
    /// Check if data needs to be seeded (first launch or version change)
    static func needsSeeding(context: ModelContext) -> Bool {
        let lldCount = (try? context.fetchCount(FetchDescriptor<LLDProblem>())) ?? 0
        let csCount = (try? context.fetchCount(FetchDescriptor<CSConcept>())) ?? 0
        
        // Check if content version changed (stored in UserDefaults)
        let storedVersion = UserDefaults.standard.integer(forKey: "DataSeederVersion")
        if storedVersion < contentVersion {
            return true
        }
        
        return lldCount == 0 && csCount == 0
    }
    
    /// Seed all data
    static func seedIfNeeded(context: ModelContext) {
        guard needsSeeding(context: context) else { return }
        
        // Clear existing data first
        clearExistingData(context: context)
        
        // Seed fresh data
        seedLLDProblems(context: context)
        seedCSConcepts(context: context)
        
        // Update version
        UserDefaults.standard.set(contentVersion, forKey: "DataSeederVersion")
    }
    
    /// Clear existing seeded data
    private static func clearExistingData(context: ModelContext) {
        try? context.delete(model: LLDProblem.self)
        try? context.delete(model: CSConcept.self)
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
            
            // 2. Snake & Ladder (Event-Driven Distributed)
            LLDProblem(
                title: "Snake & Ladder (Distributed)",
                requirements: """
                **Core Requirements:**
                • Configurable Board (50, 100, 200 cells)
                • Entities: Snake (head→tail), Ladder (start→end)
                • Standard 6-sided Dice + Crooked Dice for testing
                • Multiple Players (2-6) with turn-based play
                • Winning: First to reach 100 (Exact landing vs. Bounce back)

                **Design Patterns (Mandatory):**
                • **Singleton:** GameManager (one game per session)
                • **Strategy:** BoardGenerationStrategy, WinningStrategy, DiceStrategy
                • **Factory:** BoardEntityFactory (Snake, Ladder, PowerUp)
                • **Observer:** Decouple Game state from UI (Console/Web/Mobile)

                **GS Twist (Distributed):**
                • Event-Driven: Process MoveEvent instead of player.move()
                • GameEvents: PlayerMoved, SnakeEncountered, LadderClimbed, GameWon
                • Redis for Game State, Kafka for Event Queue
                """,
                solutionStrategy: """
                **Architecture:**

                **A. Domain Model:**
                • Board: Grid of Cells with configurable size
                • Cell: Position + optional BoardEntity
                • BoardEntity (Abstract) → Snake, Ladder, PowerUp
                • Player: id, name, currentPosition

                **B. Strategy Pattern:**
                • BoardGenerationStrategy: RandomStrategy, FileBasedStrategy
                • WinningStrategy: ExactLandingStrategy, OvershootAllowedStrategy
                • DiceStrategy: StandardDice, CrookedDice, LoadedDice

                **C. Observer Pattern:**
                • GameObserver interface: onPlayerMoved(), onSnakeEncountered(), onGameWon()
                • Implementations: ConsoleUI, WebSocketHandler, MobileNotification

                **D. Event-Driven (Distributed):**
                • All actions produce GameEvent objects
                • Events published to Kafka topic
                • Consumers update Redis state & notify clients
                """,
                mermaidGraph: """
                classDiagram
                    class GameManager {
                        -static GameManager instance
                        -Board board
                        -List players
                        -Player currentPlayer
                        -Dice dice
                        -WinningStrategy winningStrategy
                        -List observers
                        -ReentrantLock turnLock
                        +getInstance() GameManager
                        +startGame(config) void
                        +playTurn() GameEvent
                        +addObserver(GameObserver) void
                        -notifyObservers(GameEvent) void
                        -nextPlayer() void
                    }
                    
                    class Board {
                        -int size
                        -Map cells
                        -BoardGenerationStrategy genStrategy
                        +getCell(position) Cell
                        +getEntityAt(position) BoardEntity
                        +isValidBoard() boolean
                    }
                    
                    class Cell {
                        -int position
                        -BoardEntity entity
                        +hasEntity() boolean
                        +getEntity() BoardEntity
                    }
                    
                    class BoardEntity {
                        -int startPosition
                        -int endPosition
                        +getDestination() int
                        +getType() EntityType
                    }
                    
                    class Snake {
                        -int head
                        -int tail
                        +getDestination() int
                    }
                    
                    class Ladder {
                        -int bottom
                        -int top
                        +getDestination() int
                    }
                    
                    class PowerUp {
                        -PowerUpType type
                        -int value
                        +apply(Player) void
                    }
                    
                    class Player {
                        -String id
                        -String name
                        -int position
                        -PlayerStatus status
                        +move(steps) void
                        +getPosition() int
                    }
                    
                    class Dice {
                        +roll() int
                        +getMaxValue() int
                    }
                    
                    class StandardDice {
                        +roll() int
                    }
                    
                    class CrookedDice {
                        -List allowedValues
                        +roll() int
                    }
                    
                    class BoardGenerationStrategy {
                        +generate(size) Map
                        +validate(Map) boolean
                    }
                    
                    class RandomBoardStrategy {
                        -int snakeCount
                        -int ladderCount
                        +generate(size) Map
                    }
                    
                    class FileBoardStrategy {
                        -String filePath
                        +generate(size) Map
                    }
                    
                    class WinningStrategy {
                        +isWinningMove(position, steps, boardSize) boolean
                        +getFinalPosition(position, steps, boardSize) int
                    }
                    
                    class ExactLandingStrategy {
                        +isWinningMove(position, steps, boardSize) boolean
                    }
                    
                    class BounceBackStrategy {
                        +getFinalPosition(position, steps, boardSize) int
                    }
                    
                    class GameObserver {
                        +onEvent(GameEvent) void
                    }
                    
                    class ConsoleUI {
                        +onEvent(GameEvent) void
                    }
                    
                    class WebSocketHandler {
                        -Session session
                        +onEvent(GameEvent) void
                    }
                    
                    class GameEvent {
                        -EventType type
                        -String playerId
                        -int fromPosition
                        -int toPosition
                        -long timestamp
                    }
                    
                    class BoardEntityFactory {
                        +create(EntityType, start, end) BoardEntity
                    }
                    
                    GameManager *-- Board
                    GameManager *-- Player
                    GameManager o-- Dice
                    GameManager o-- WinningStrategy
                    GameManager o-- GameObserver
                    Board *-- Cell
                    Board o-- BoardGenerationStrategy
                    Cell o-- BoardEntity
                    BoardEntity <|-- Snake
                    BoardEntity <|-- Ladder
                    BoardEntity <|-- PowerUp
                    Dice <|-- StandardDice
                    Dice <|-- CrookedDice
                    BoardGenerationStrategy <|-- RandomBoardStrategy
                    BoardGenerationStrategy <|-- FileBoardStrategy
                    WinningStrategy <|-- ExactLandingStrategy
                    WinningStrategy <|-- BounceBackStrategy
                    GameObserver <|-- ConsoleUI
                    GameObserver <|-- WebSocketHandler
                    BoardEntityFactory ..> BoardEntity
                    GameManager ..> GameEvent
                """,
                codeSnippet: """
                // ═══════════════════════════════════════════════════════════════
                // FILE: domain/BoardEntity.java (Abstract + Factory)
                // ═══════════════════════════════════════════════════════════════
                public abstract class BoardEntity {
                    protected final int startPosition;
                    protected final int endPosition;
                    
                    public abstract int getDestination();
                    public abstract EntityType getType();
                }

                public class Snake extends BoardEntity {
                    public Snake(int head, int tail) {
                        super(head, tail);
                        if (tail >= head) throw new InvalidEntityException("Snake must go DOWN");
                    }
                    
                    @Override
                    public int getDestination() { return endPosition; } // tail
                    
                    @Override
                    public EntityType getType() { return EntityType.SNAKE; }
                }

                public class Ladder extends BoardEntity {
                    public Ladder(int bottom, int top) {
                        super(bottom, top);
                        if (top <= bottom) throw new InvalidEntityException("Ladder must go UP");
                    }
                    
                    @Override
                    public int getDestination() { return endPosition; } // top
                    
                    @Override
                    public EntityType getType() { return EntityType.LADDER; }
                }

                // Factory Pattern
                public class BoardEntityFactory {
                    public static BoardEntity create(EntityType type, int start, int end) {
                        return switch (type) {
                            case SNAKE -> new Snake(start, end);
                            case LADDER -> new Ladder(start, end);
                            case POWERUP -> new PowerUp(start, PowerUpType.EXTRA_ROLL);
                        };
                    }
                }

                // ═══════════════════════════════════════════════════════════════
                // FILE: strategy/DiceStrategy.java
                // ═══════════════════════════════════════════════════════════════
                public interface Dice {
                    int roll();
                    int getMaxValue();
                }

                public class StandardDice implements Dice {
                    private final Random random = new Random();
                    
                    @Override
                    public int roll() { return random.nextInt(6) + 1; }
                    
                    @Override
                    public int getMaxValue() { return 6; }
                }

                public class CrookedDice implements Dice {
                    private final List<Integer> allowedValues;
                    private final Random random = new Random();
                    
                    public CrookedDice(List<Integer> values) {
                        this.allowedValues = values; // e.g., [2, 4, 6] only even
                    }
                    
                    @Override
                    public int roll() {
                        return allowedValues.get(random.nextInt(allowedValues.size()));
                    }
                    
                    @Override
                    public int getMaxValue() { return Collections.max(allowedValues); }
                }

                // ═══════════════════════════════════════════════════════════════
                // FILE: strategy/WinningStrategy.java
                // ═══════════════════════════════════════════════════════════════
                public interface WinningStrategy {
                    boolean isWinningMove(int currentPos, int diceRoll, int boardSize);
                    int getFinalPosition(int currentPos, int diceRoll, int boardSize);
                }

                public class ExactLandingStrategy implements WinningStrategy {
                    @Override
                    public boolean isWinningMove(int pos, int dice, int size) {
                        return pos + dice == size;
                    }
                    
                    @Override
                    public int getFinalPosition(int pos, int dice, int size) {
                        int newPos = pos + dice;
                        return newPos <= size ? newPos : pos; // Stay if overshoot
                    }
                }

                public class BounceBackStrategy implements WinningStrategy {
                    @Override
                    public boolean isWinningMove(int pos, int dice, int size) {
                        return pos + dice >= size;
                    }
                    
                    @Override
                    public int getFinalPosition(int pos, int dice, int size) {
                        int newPos = pos + dice;
                        if (newPos > size) {
                            return size - (newPos - size); // Bounce back
                        }
                        return newPos;
                    }
                }

                // ═══════════════════════════════════════════════════════════════
                // FILE: strategy/BoardGenerationStrategy.java
                // ═══════════════════════════════════════════════════════════════
                public interface BoardGenerationStrategy {
                    Map<Integer, BoardEntity> generate(int boardSize);
                    boolean validate(Map<Integer, BoardEntity> entities);
                }

                public class RandomBoardStrategy implements BoardGenerationStrategy {
                    private final int snakeCount;
                    private final int ladderCount;
                    
                    @Override
                    public Map<Integer, BoardEntity> generate(int boardSize) {
                        Map<Integer, BoardEntity> entities = new ConcurrentHashMap<>();
                        Random random = new Random();
                        
                        // Generate snakes (avoiding position 1 and boardSize)
                        for (int i = 0; i < snakeCount; i++) {
                            int head = random.nextInt(boardSize - 10) + 10;
                            int tail = random.nextInt(head - 1) + 1;
                            if (!entities.containsKey(head)) {
                                entities.put(head, new Snake(head, tail));
                            }
                        }
                        
                        // Generate ladders
                        for (int i = 0; i < ladderCount; i++) {
                            int bottom = random.nextInt(boardSize - 10) + 2;
                            int top = random.nextInt(boardSize - bottom) + bottom + 1;
                            if (!entities.containsKey(bottom) && top < boardSize) {
                                entities.put(bottom, new Ladder(bottom, top));
                            }
                        }
                        
                        // Validate no infinite loops
                        if (!validate(entities)) {
                            return generate(boardSize); // Regenerate
                        }
                        return entities;
                    }
                    
                    @Override
                    public boolean validate(Map<Integer, BoardEntity> entities) {
                        // Check for infinite loops: Snake tail == Ladder start
                        for (BoardEntity entity : entities.values()) {
                            int dest = entity.getDestination();
                            if (entities.containsKey(dest)) {
                                BoardEntity next = entities.get(dest);
                                if (entity instanceof Snake && next instanceof Ladder) {
                                    return false; // Potential infinite loop
                                }
                            }
                        }
                        return true;
                    }
                }

                // ═══════════════════════════════════════════════════════════════
                // FILE: observer/GameObserver.java
                // ═══════════════════════════════════════════════════════════════
                public interface GameObserver {
                    void onEvent(GameEvent event);
                }

                public class ConsoleUI implements GameObserver {
                    @Override
                    public void onEvent(GameEvent event) {
                        switch (event.getType()) {
                            case PLAYER_MOVED -> System.out.println(
                                event.getPlayerId() + " moved to " + event.getToPosition());
                            case SNAKE_ENCOUNTERED -> System.out.println(
                                "Oops! Snake bit " + event.getPlayerId());
                            case LADDER_CLIMBED -> System.out.println(
                                event.getPlayerId() + " climbed a ladder!");
                            case GAME_WON -> System.out.println(
                                "*** " + event.getPlayerId() + " WINS! ***");
                        }
                    }
                }

                // ═══════════════════════════════════════════════════════════════
                // FILE: event/GameEvent.java (For Kafka)
                // ═══════════════════════════════════════════════════════════════
                @Data
                @Builder
                public class GameEvent {
                    private final String gameId;
                    private final EventType type;
                    private final String playerId;
                    private final int diceRoll;
                    private final int fromPosition;
                    private final int toPosition;
                    private final long timestamp;
                    private final String idempotencyKey; // For exactly-once processing
                }

                public enum EventType {
                    DICE_ROLLED, PLAYER_MOVED, SNAKE_ENCOUNTERED, 
                    LADDER_CLIMBED, GAME_WON, PLAYER_DISCONNECTED
                }

                // ═══════════════════════════════════════════════════════════════
                // FILE: service/GameManager.java (Singleton + Facade)
                // ═══════════════════════════════════════════════════════════════
                public class GameManager {
                    private static volatile GameManager instance;
                    private static final Object lock = new Object();
                    
                    private final String gameId;
                    private final Board board;
                    private final List<Player> players;
                    private final Dice dice;
                    private final WinningStrategy winningStrategy;
                    private final List<GameObserver> observers = new CopyOnWriteArrayList<>();
                    private final ReentrantLock turnLock = new ReentrantLock();
                    
                    private int currentPlayerIndex = 0;
                    private GameStatus status = GameStatus.WAITING;
                    
                    private GameManager(GameConfig config) {
                        this.gameId = UUID.randomUUID().toString();
                        this.board = new Board(config.getBoardSize(), config.getBoardStrategy());
                        this.players = new ArrayList<>();
                        this.dice = config.getDice();
                        this.winningStrategy = config.getWinningStrategy();
                    }
                    
                    public static GameManager getInstance(GameConfig config) {
                        if (instance == null) {
                            synchronized (lock) {
                                if (instance == null) {
                                    instance = new GameManager(config);
                                }
                            }
                        }
                        return instance;
                    }
                    
                    public GameEvent playTurn() {
                        turnLock.lock();
                        try {
                            Player currentPlayer = players.get(currentPlayerIndex);
                            int fromPos = currentPlayer.getPosition();
                            
                            // 1. Roll dice
                            int diceRoll = dice.roll();
                            
                            // 2. Calculate new position using WinningStrategy
                            int toPos = winningStrategy.getFinalPosition(
                                fromPos, diceRoll, board.getSize());
                            
                            // 3. Check for snake/ladder
                            BoardEntity entity = board.getEntityAt(toPos);
                            EventType eventType = EventType.PLAYER_MOVED;
                            
                            if (entity != null) {
                                toPos = entity.getDestination();
                                eventType = entity instanceof Snake ? 
                                    EventType.SNAKE_ENCOUNTERED : EventType.LADDER_CLIMBED;
                            }
                            
                            // 4. Update player position
                            currentPlayer.setPosition(toPos);
                            
                            // 5. Check win condition
                            if (winningStrategy.isWinningMove(fromPos, diceRoll, board.getSize())) {
                                eventType = EventType.GAME_WON;
                                status = GameStatus.COMPLETED;
                            }
                            
                            // 6. Create event
                            GameEvent event = GameEvent.builder()
                                .gameId(gameId)
                                .type(eventType)
                                .playerId(currentPlayer.getId())
                                .diceRoll(diceRoll)
                                .fromPosition(fromPos)
                                .toPosition(toPos)
                                .timestamp(System.currentTimeMillis())
                                .idempotencyKey(gameId + "-" + currentPlayerIndex + "-" + System.nanoTime())
                                .build();
                            
                            // 7. Notify observers
                            notifyObservers(event);
                            
                            // 8. Next player (if game not won)
                            if (status != GameStatus.COMPLETED) {
                                currentPlayerIndex = (currentPlayerIndex + 1) % players.size();
                            }
                            
                            return event;
                        } finally {
                            turnLock.unlock();
                        }
                    }
                    
                    private void notifyObservers(GameEvent event) {
                        observers.forEach(o -> o.onEvent(event));
                    }
                    
                    public void addObserver(GameObserver observer) {
                        observers.add(observer);
                    }
                }

                // ═══════════════════════════════════════════════════════════════
                // FILE: domain/Board.java (Thread-Safe)
                // ═══════════════════════════════════════════════════════════════
                public class Board {
                    private final int size;
                    private final ConcurrentHashMap<Integer, BoardEntity> entities;
                    
                    public Board(int size, BoardGenerationStrategy strategy) {
                        this.size = size;
                        this.entities = new ConcurrentHashMap<>(strategy.generate(size));
                    }
                    
                    public BoardEntity getEntityAt(int position) {
                        return entities.get(position);
                    }
                    
                    public int getSize() { return size; }
                }
                """,
                gsSpecificTwist: """
                **Distributed Event Queue Architecture (GS Twist)**

                **Problem:** Millions of concurrent games across distributed servers.

                **Solution: Event-Sourced Architecture with Kafka + Redis**

                ```
                ┌─────────────┐     ┌─────────────┐     ┌─────────────┐
                │ Mobile App  │────▶│ API Gateway │────▶│ Game Service│
                └─────────────┘     └─────────────┘     └──────┬──────┘
                                                               │
                                    ┌──────────────────────────┼──────────────────────────┐
                                    ▼                          ▼                          ▼
                              ┌─────────┐               ┌─────────────┐           ┌─────────────┐
                              │  Kafka  │◀──────────────│ Redis State │           │ Event Store │
                              └────┬────┘               └─────────────┘           └─────────────┘
                                   │
                    ┌──────────────┼──────────────┐
                    ▼              ▼              ▼
                ┌─────────┐  ┌───────────┐  ┌────────────┐
                │Consumers│  │Leaderboard│  │Notification│
                └─────────┘  └───────────┘  │  Service   │
                                            └────────────┘
                ```

                **Key Components:**

                1. **Kafka Topics:**
                   - `game.moves` - All move events (partitioned by gameId)
                   - `game.state` - State change events
                   - `game.completed` - Finished games

                2. **Redis Storage:**
                   - `game:{gameId}:state` - Current game state (JSON)
                   - `game:{gameId}:players` - Player positions (Hash)
                   - `player:{playerId}:active` - Active session tracking

                3. **Idempotency:**
                   - Each event has `idempotencyKey`
                   - Redis `SETNX` for exactly-once processing
                   - Prevents duplicate moves on retry

                4. **Handling Disconnections:**
                   ```java
                   public void handleDisconnect(String playerId, String gameId) {
                       // 1. Mark player as disconnected in Redis
                       redis.hset("game:" + gameId + ":players", playerId, "DISCONNECTED");
                       
                       // 2. Set reconnection timeout (30 seconds)
                       redis.setex("player:" + playerId + ":timeout", 30, gameId);
                       
                       // 3. If timeout expires, auto-forfeit
                       // (Handled by Redis key expiration listener)
                   }
                   ```

                5. **Edge Case - Simultaneous Rolls:**
                   - Kafka partition by gameId ensures ordering
                   - Single consumer per partition = sequential processing
                   - Turn validation in Game Service rejects out-of-turn moves
                """
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
                        -List strategies
                        -TradeExecutor executor
                        +processOrder(Order) List
                        -match(Order, OrderBook) List
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
                        
                        MARKET
                        LIMIT
                        STOP_LOSS
                        STOP_LIMIT
                        IOC
                        FOK
                    }
                    
                    class MatchingStrategy {
                        
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
            
            // 4. Parking Lot System (Production-Ready)
            LLDProblem(
                title: "Parking Lot System",
                requirements: """
                **Core Requirements:**
                • Multi-Level Parking with floors and different spot types (Compact, Large, Handicapped, Motorcycle)
                • Multiple Entry/Exit gates - Entry issues ticket, Exit calculates cost
                • Flexible Allocation Strategies (Nearest to Elevator, Lowest Floor First)
                • Add-on Services using Decorator (Car Wash, EV Charging)
                • Dynamic Pricing based on vehicle type and duration

                **Design Patterns (Mandatory):**
                • **Singleton:** ParkingLot manager
                • **Abstract Factory:** Vehicle and Spot creation
                • **Strategy Pattern:** ParkingStrategy + PricingStrategy
                • **Observer Pattern:** DisplayBoard observes ParkingLot
                • **Decorator Pattern:** Services (CarWash, EVCharging)
                """,
                solutionStrategy: """
                **Architecture:**

                **A. Domain Model:**
                • Enums: VehicleType, SpotType, ParkingStatus
                • Entities: Vehicle, Ticket, Gate, ParkingFloor
                • Spot Hierarchy: ParkingSpot (Abstract) → CompactSpot, LargeSpot, HandicappedSpot, MotorcycleSpot

                **B. Service Layer:**
                • ParkingLotSystem (Singleton Facade): entry(Gate, Vehicle), exit(Gate, Ticket)
                • Concurrency: ReentrantLock per floor (NOT synchronized methods)
                • ParkingAllocationStrategy (Interface): LowestFloorFirstStrategy, NearestElevatorStrategy

                **C. Observer Pattern:**
                • ParkingEvent published on entry/exit
                • DisplayBoard subscribes to update "Free Spots" counter

                **D. Decorator Pattern:**
                • SpotDecorator wraps ParkingSpot
                • CarWashDecorator, EVChargingDecorator add services
                """,
                mermaidGraph: """
                classDiagram
                    class ParkingLotSystem {
                        
                        -static ParkingLotSystem instance
                        -List floors
                        -List entryGates
                        -List exitGates
                        -ParkingAllocationStrategy allocationStrategy
                        -PricingStrategy pricingStrategy
                        -List observers
                        +getInstance() ParkingLotSystem
                        +entry(Gate, Vehicle) Ticket
                        +exit(Gate, Ticket) Payment
                        +addObserver(ParkingObserver) void
                        -notifyObservers(ParkingEvent) void
                    }
                    
                    class ParkingFloor {
                        -int floorNumber
                        -Map spots
                        -ReentrantLock lock
                        -DisplayBoard displayBoard
                        +findAvailableSpot(VehicleType) ParkingSpot
                        +occupySpot(spotId, Vehicle) boolean
                        +vacateSpot(spotId) boolean
                        +getAvailableCount() Map
                    }
                    
                    class ParkingSpot {
                        
                        #String spotId
                        #SpotType type
                        #int floor
                        #int distanceFromElevator
                        #boolean isOccupied
                        #Vehicle vehicle
                        +canFit(VehicleType) boolean*
                        +occupy(Vehicle) void
                        +vacate() Vehicle
                        +getHourlyRate() double*
                    }
                    
                    class CompactSpot {
                        +canFit(VehicleType) boolean
                        +getHourlyRate() double
                    }
                    
                    class LargeSpot {
                        +canFit(VehicleType) boolean
                        +getHourlyRate() double
                    }
                    
                    class HandicappedSpot {
                        -boolean requiresPermit
                    }
                    
                    class MotorcycleSpot
                    
                    class SpotDecorator {
                        
                        #ParkingSpot wrappedSpot
                        +getServices() List
                        +getAdditionalCost() double
                    }
                    
                    class CarWashDecorator {
                        -CarWashType washType
                        +getAdditionalCost() double
                    }
                    
                    class EVChargingDecorator {
                        -ChargingStation station
                        -double kWhUsed
                        +startCharging() void
                        +stopCharging() void
                        +getAdditionalCost() double
                    }
                    
                    class Vehicle {
                        -String licensePlate
                        -VehicleType type
                        -String color
                        -String ownerName
                    }
                    
                    class Ticket {
                        -String ticketId
                        -Vehicle vehicle
                        -ParkingSpot spot
                        -Gate entryGate
                        -LocalDateTime entryTime
                        -TicketStatus status
                        +getDuration() Duration
                    }
                    
                    class Gate {
                        -int gateId
                        -GateType type
                        -boolean isOperational
                        -ParkingAttendant attendant
                    }
                    
                    class ParkingAllocationStrategy {
                        
                        +findSpot(List floors, VehicleType) ParkingSpot
                    }
                    
                    class LowestFloorFirstStrategy {
                        +findSpot(List floors, VehicleType) ParkingSpot
                    }
                    
                    class NearestElevatorStrategy {
                        +findSpot(List floors, VehicleType) ParkingSpot
                    }
                    
                    class PricingStrategy {
                        
                        +calculate(Duration, VehicleType) double
                    }
                    
                    class HourlyPricingStrategy {
                        -double firstHourRate
                        -double subsequentHourRate
                        +calculate(Duration, VehicleType) double
                    }
                    
                    class WeekendPricingStrategy {
                        -double weekendMultiplier
                    }
                    
                    class ParkingObserver {
                        
                        +onEvent(ParkingEvent) void
                    }
                    
                    class DisplayBoard {
                        -int floorNumber
                        -Map availableSpots
                        +onEvent(ParkingEvent) void
                        +display() void
                    }
                    
                    class ParkingEvent {
                        -EventType type
                        -ParkingSpot spot
                        -LocalDateTime timestamp
                    }
                    
                    class Payment {
                        -String paymentId
                        -double amount
                        -PaymentMethod method
                        -PaymentStatus status
                        +process() boolean
                    }
                    
                    class SpotFactory {
                        
                        +createSpot(SpotType, floor, id) ParkingSpot
                    }
                    
                    class VehicleFactory {
                        
                        +createVehicle(VehicleType, plate) Vehicle
                    }
                    
                    ParkingLotSystem *-- ParkingFloor
                    ParkingLotSystem *-- Gate
                    ParkingLotSystem o-- ParkingObserver
                    ParkingLotSystem ..> ParkingAllocationStrategy
                    ParkingLotSystem ..> PricingStrategy
                    ParkingFloor *-- ParkingSpot
                    ParkingFloor *-- DisplayBoard
                    ParkingSpot <|-- CompactSpot
                    ParkingSpot <|-- LargeSpot
                    ParkingSpot <|-- HandicappedSpot
                    ParkingSpot <|-- MotorcycleSpot
                    ParkingSpot <|-- SpotDecorator
                    SpotDecorator <|-- CarWashDecorator
                    SpotDecorator <|-- EVChargingDecorator
                    SpotDecorator o-- ParkingSpot : wraps
                    ParkingSpot o-- Vehicle
                    Ticket --> ParkingSpot
                    Ticket --> Vehicle
                    Ticket --> Gate
                    ParkingAllocationStrategy <|.. LowestFloorFirstStrategy
                    ParkingAllocationStrategy <|.. NearestElevatorStrategy
                    PricingStrategy <|.. HourlyPricingStrategy
                    PricingStrategy <|.. WeekendPricingStrategy
                    ParkingObserver <|.. DisplayBoard
                    DisplayBoard ..> ParkingEvent
                    SpotFactory ..> ParkingSpot
                    VehicleFactory ..> Vehicle
                """,
                codeSnippet: """
                // ═══════════════════════════════════════════════════════════════
                // FILE: enums/VehicleType.java
                // ═══════════════════════════════════════════════════════════════
                public enum VehicleType {
                    MOTORCYCLE, COMPACT, SEDAN, SUV, TRUCK;
                }

                public enum SpotType {
                    MOTORCYCLE, COMPACT, LARGE, HANDICAPPED, EV;
                }

                public enum TicketStatus {
                    ACTIVE, PAID, LOST;
                }

                // ═══════════════════════════════════════════════════════════════
                // FILE: domain/ParkingSpot.java (Abstract + Concrete)
                // ═══════════════════════════════════════════════════════════════
                @Getter
                public abstract class ParkingSpot {
                    protected final String spotId;
                    protected final SpotType type;
                    protected final int floor;
                    protected final int distanceFromElevator;
                    protected volatile boolean isOccupied;
                    protected Vehicle vehicle;
                    
                    public abstract boolean canFit(VehicleType vehicleType);
                    public abstract double getHourlyRate();
                    
                    public synchronized void occupy(Vehicle vehicle) {
                        if (this.isOccupied) throw new SpotOccupiedException();
                        this.vehicle = vehicle;
                        this.isOccupied = true;
                    }
                    
                    public synchronized Vehicle vacate() {
                        Vehicle v = this.vehicle;
                        this.vehicle = null;
                        this.isOccupied = false;
                        return v;
                    }
                }

                public class CompactSpot extends ParkingSpot {
                    private static final double HOURLY_RATE = 4.0;
                    
                    @Override
                    public boolean canFit(VehicleType type) {
                        return type == VehicleType.MOTORCYCLE || 
                               type == VehicleType.COMPACT;
                    }
                    
                    @Override
                    public double getHourlyRate() { return HOURLY_RATE; }
                }

                public class LargeSpot extends ParkingSpot {
                    private static final double HOURLY_RATE = 6.0;
                    
                    @Override
                    public boolean canFit(VehicleType type) {
                        return type != VehicleType.TRUCK; // All except truck
                    }
                    
                    @Override
                    public double getHourlyRate() { return HOURLY_RATE; }
                }

                // ═══════════════════════════════════════════════════════════════
                // FILE: decorator/SpotDecorator.java (Decorator Pattern)
                // ═══════════════════════════════════════════════════════════════
                public abstract class SpotDecorator extends ParkingSpot {
                    protected final ParkingSpot wrappedSpot;
                    
                    public SpotDecorator(ParkingSpot spot) {
                        super(spot.getSpotId(), spot.getType(), spot.getFloor(), 
                              spot.getDistanceFromElevator());
                        this.wrappedSpot = spot;
                    }
                    
                    public abstract double getAdditionalCost();
                    public abstract List<String> getServices();
                    
                    @Override
                    public boolean canFit(VehicleType type) {
                        return wrappedSpot.canFit(type);
                    }
                }

                public class EVChargingDecorator extends SpotDecorator {
                    private final ChargingStation station;
                    private double kWhUsed = 0;
                    private static final double COST_PER_KWH = 0.15;
                    
                    public void startCharging() { station.startCharging(); }
                    public void stopCharging() { 
                        kWhUsed = station.stopAndGetUsage(); 
                    }
                    
                    @Override
                    public double getAdditionalCost() {
                        return kWhUsed * COST_PER_KWH;
                    }
                    
                    @Override
                    public List<String> getServices() {
                        return List.of("EV_CHARGING");
                    }
                }

                // ═══════════════════════════════════════════════════════════════
                // FILE: strategy/ParkingAllocationStrategy.java
                // ═══════════════════════════════════════════════════════════════
                public interface ParkingAllocationStrategy {
                    Optional<ParkingSpot> findSpot(List<ParkingFloor> floors, VehicleType type);
                }

                public class LowestFloorFirstStrategy implements ParkingAllocationStrategy {
                    @Override
                    public Optional<ParkingSpot> findSpot(List<ParkingFloor> floors, VehicleType type) {
                        return floors.stream()
                            .sorted(Comparator.comparingInt(ParkingFloor::getFloorNumber))
                            .flatMap(floor -> floor.getAvailableSpots().stream())
                            .filter(spot -> spot.canFit(type))
                            .findFirst();
                    }
                }

                public class NearestElevatorStrategy implements ParkingAllocationStrategy {
                    @Override
                    public Optional<ParkingSpot> findSpot(List<ParkingFloor> floors, VehicleType type) {
                        return floors.stream()
                            .flatMap(floor -> floor.getAvailableSpots().stream())
                            .filter(spot -> spot.canFit(type))
                            .min(Comparator.comparingInt(ParkingSpot::getDistanceFromElevator));
                    }
                }

                // ═══════════════════════════════════════════════════════════════
                // FILE: strategy/PricingStrategy.java
                // ═══════════════════════════════════════════════════════════════
                public interface PricingStrategy {
                    double calculate(Duration duration, VehicleType type);
                }

                public class HourlyPricingStrategy implements PricingStrategy {
                    private final double firstHourRate;
                    private final double subsequentHourRate;
                    
                    @Override
                    public double calculate(Duration duration, VehicleType type) {
                        long hours = Math.max(1, duration.toHours());
                        if (hours == 1) return firstHourRate;
                        return firstHourRate + (hours - 1) * subsequentHourRate;
                    }
                }

                // ═══════════════════════════════════════════════════════════════
                // FILE: observer/ParkingObserver.java
                // ═══════════════════════════════════════════════════════════════
                public interface ParkingObserver {
                    void onEvent(ParkingEvent event);
                }

                public class DisplayBoard implements ParkingObserver {
                    private final int floorNumber;
                    private final Map<SpotType, AtomicInteger> availableCount = new ConcurrentHashMap<>();
                    
                    @Override
                    public void onEvent(ParkingEvent event) {
                        SpotType type = event.getSpot().getType();
                        if (event.getType() == EventType.ENTRY) {
                            availableCount.get(type).decrementAndGet();
                        } else {
                            availableCount.get(type).incrementAndGet();
                        }
                        display();
                    }
                    
                    public void display() {
                        System.out.println("Floor " + floorNumber + ": " + availableCount);
                    }
                }

                // ═══════════════════════════════════════════════════════════════
                // FILE: service/ParkingLotSystem.java (Singleton + Facade)
                // ═══════════════════════════════════════════════════════════════
                public class ParkingLotSystem {
                    private static volatile ParkingLotSystem instance;
                    private static final Object lock = new Object();
                    
                    private final List<ParkingFloor> floors;
                    private final Map<String, Ticket> activeTickets = new ConcurrentHashMap<>();
                    private final List<ParkingObserver> observers = new CopyOnWriteArrayList<>();
                    private ParkingAllocationStrategy allocationStrategy;
                    private PricingStrategy pricingStrategy;
                    
                    private ParkingLotSystem() {
                        this.floors = new ArrayList<>();
                        this.allocationStrategy = new LowestFloorFirstStrategy();
                        this.pricingStrategy = new HourlyPricingStrategy(4.0, 2.0);
                    }
                    
                    public static ParkingLotSystem getInstance() {
                        if (instance == null) {
                            synchronized (lock) {
                                if (instance == null) {
                                    instance = new ParkingLotSystem();
                                }
                            }
                        }
                        return instance;
                    }
                    
                    public Ticket entry(Gate gate, Vehicle vehicle) {
                        // Find available spot using strategy
                        ParkingSpot spot = allocationStrategy
                            .findSpot(floors, vehicle.getType())
                            .orElseThrow(() -> new ParkingFullException());
                        
                        // Thread-safe occupation
                        ParkingFloor floor = floors.get(spot.getFloor());
                        floor.getLock().lock();
                        try {
                            spot.occupy(vehicle);
                        } finally {
                            floor.getLock().unlock();
                        }
                        
                        // Create ticket
                        Ticket ticket = new Ticket(
                            UUID.randomUUID().toString(),
                            vehicle, spot, gate, LocalDateTime.now()
                        );
                        activeTickets.put(ticket.getTicketId(), ticket);
                        
                        // Notify observers
                        notifyObservers(new ParkingEvent(EventType.ENTRY, spot));
                        
                        return ticket;
                    }
                    
                    public Payment exit(Gate gate, Ticket ticket) {
                        ParkingSpot spot = ticket.getSpot();
                        ParkingFloor floor = floors.get(spot.getFloor());
                        
                        floor.getLock().lock();
                        try {
                            spot.vacate();
                        } finally {
                            floor.getLock().unlock();
                        }
                        
                        // Calculate cost
                        Duration duration = ticket.getDuration();
                        double baseCost = pricingStrategy.calculate(duration, ticket.getVehicle().getType());
                        
                        // Add decorator costs if applicable
                        double additionalCost = 0;
                        if (spot instanceof SpotDecorator) {
                            additionalCost = ((SpotDecorator) spot).getAdditionalCost();
                        }
                        
                        activeTickets.remove(ticket.getTicketId());
                        notifyObservers(new ParkingEvent(EventType.EXIT, spot));
                        
                        return new Payment(baseCost + additionalCost);
                    }
                    
                    public void addObserver(ParkingObserver observer) {
                        observers.add(observer);
                    }
                    
                    private void notifyObservers(ParkingEvent event) {
                        observers.forEach(o -> o.onEvent(event));
                    }
                }

                // ═══════════════════════════════════════════════════════════════
                // FILE: domain/ParkingFloor.java (Thread-Safe)
                // ═══════════════════════════════════════════════════════════════
                public class ParkingFloor {
                    private final int floorNumber;
                    private final Map<String, ParkingSpot> spots = new ConcurrentHashMap<>();
                    private final ReentrantLock lock = new ReentrantLock();
                    private final DisplayBoard displayBoard;
                    
                    public ReentrantLock getLock() { return lock; }
                    
                    public List<ParkingSpot> getAvailableSpots() {
                        return spots.values().stream()
                            .filter(spot -> !spot.isOccupied())
                            .collect(Collectors.toList());
                    }
                }
                """,
                gsSpecificTwist: """
                **Goldman Sachs Twist: Subscription Model for Corporate Reserved Spots**

                Requirement: Corporate employees have reserved spots that cannot be taken by regular customers.

                **Solution: Proxy Pattern + ReservationStrategy**

                The **Proxy Pattern** intercepts spot access and checks reservation status before allocation.

                ```java
                // ReservedSpotProxy wraps ParkingSpot
                public class ReservedSpotProxy extends ParkingSpot {
                    private final ParkingSpot realSpot;
                    private final String reservedForCompanyId;
                    private final LocalTime reservationStart;
                    private final LocalTime reservationEnd;
                    
                    @Override
                    public void occupy(Vehicle vehicle) {
                        if (isReservationActive() && !isAuthorized(vehicle)) {
                            throw new SpotReservedException(
                                "Spot reserved for " + reservedForCompanyId);
                        }
                        realSpot.occupy(vehicle);
                    }
                    
                    private boolean isReservationActive() {
                        LocalTime now = LocalTime.now();
                        return now.isAfter(reservationStart) && now.isBefore(reservationEnd);
                    }
                    
                    private boolean isAuthorized(Vehicle vehicle) {
                        return subscriptionService.isSubscribed(
                            vehicle.getLicensePlate(), reservedForCompanyId);
                    }
                }

                // Modified Strategy to skip reserved spots
                public class ReservationAwareStrategy implements ParkingAllocationStrategy {
                    private final ParkingAllocationStrategy delegate;
                    
                    @Override
                    public Optional<ParkingSpot> findSpot(List<ParkingFloor> floors, VehicleType type) {
                        return delegate.findSpot(floors, type)
                            .filter(spot -> !(spot instanceof ReservedSpotProxy) 
                                    || !((ReservedSpotProxy) spot).isReservationActive());
                    }
                }
                ```

                **Key Design Decisions:**
                1. Proxy wraps real spot - no changes to core ParkingSpot
                2. Strategy filters reserved spots for regular customers
                3. Subscription service validates corporate vehicles
                4. Time-based reservations (9AM-6PM weekdays)
                """
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
                        -List runways
                        -PriorityQueue landingQueue
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
                    
                    class NotificationService {
                        -List observers
                        +notify(event) void
                        +subscribe(Observer) void
                    }
                    
                    class FollowObserver {
                        +onEvent(FollowEvent) void
                    }
                    
                    class MentionObserver {
                        +onEvent(MentionEvent) void
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
                    NotificationService o-- FollowObserver
                    NotificationService o-- MentionObserver
                    FeedService ..> TrendingService
                    FeedService ..> NotificationService
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
                        -String cartId
                        -User user
                        -List cartItems
                        -CartStatus status
                        +addItem(Product, qty) void
                        +removeItem(productId) void
                        +updateQuantity(productId, qty) void
                        +getSubtotal() double
                        +clear() void
                    }
                    
                    class CartItem {
                        -Product product
                        -int quantity
                        -double priceSnapshot
                    }
                    
                    class Order {
                        -String orderId
                        -User user
                        -List orderItems
                        -Address shippingAddress
                        -OrderStatus status
                        -double totalAmount
                        -Payment payment
                    }
                    
                    class CheckoutService {
                        -InventoryService inventoryService
                        -PaymentService paymentService
                        -PriceCalculator priceCalculator
                        -CheckoutSaga saga
                        +checkout(Cart, PaymentInfo) Order
                    }
                    
                    class CheckoutSaga {
                        -List sagaSteps
                        +execute() SagaResult
                        +compensate() void
                    }
                    
                    class SagaStep {
                        
                        +execute() boolean
                        +rollback() void
                    }
                    
                    class ReserveInventoryStep
                    class ProcessPaymentStep
                    class CreateOrderStep
                    class NotifyUserStep
                    
                    class PaymentStrategy {
                        
                        +pay(amount) PaymentResult
                        +refund(transactionId) boolean
                    }
                    
                    class CreditCardPayment
                    class UPIPayment
                    class WalletPayment
                    class PayPalPayment
                    
                    class DiscountDecorator {
                        
                        -PriceCalculator wrapped
                        +calculate(Cart) double
                    }
                    
                    class PercentageDiscount {
                        -double percentage
                    }
                    
                    class FlatDiscount {
                        -double amount
                    }
                    
                    class CouponDiscount {
                        -Coupon coupon
                    }
                    
                    class InventoryService {
                        +reserve(items) Reservation
                        +confirm(Reservation) void
                        +release(Reservation) void
                        +checkAvailability(productId, qty) boolean
                    }
                    
                    class Reservation {
                        -String reservationId
                        -List items
                        -DateTime expiresAt
                        -ReservationStatus status
                    }
                    
                    Cart *-- CartItem
                    CartItem --> Product
                    Order *-- OrderItem
                    CheckoutService *-- CheckoutSaga
                    CheckoutService ..> PaymentStrategy
                    CheckoutService ..> InventoryService
                    CheckoutSaga o-- SagaStep
                    SagaStep <|.. ReserveInventoryStep
                    SagaStep <|.. ProcessPaymentStep
                    SagaStep <|.. CreateOrderStep
                    SagaStep <|.. NotifyUserStep
                    PaymentStrategy <|.. CreditCardPayment
                    PaymentStrategy <|.. UPIPayment
                    PaymentStrategy <|.. WalletPayment
                    PaymentStrategy <|.. PayPalPayment
                    DiscountDecorator <|-- PercentageDiscount
                    DiscountDecorator <|-- FlatDiscount
                    DiscountDecorator <|-- CouponDiscount
                    InventoryService --> Reservation
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
                    
                    class URLRepository {
                        +save(URLMapping) void
                        +findByCode(shortCode) URLMapping
                        +findByUser(userId) List
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
                    URLRepository --> URLMapping
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
            
            // 9. Splitwise / Expense Sharing (Production Ready)
            LLDProblem(
                title: "Splitwise / Expense Sharing",
                requirements: """
                **Core Requirements:**
                • User Management with balance sheets (who owes whom)
                • Groups: Users belong to multiple groups, group or individual expenses
                • Expense Types: EQUAL, EXACT, PERCENTAGE, SHARES splits
                • Balance Sheet: Detailed balances + Simplify Debt (minimize transactions)
                • Notifications: Observer pattern for expense alerts

                **Design Patterns (Mandatory):**
                • **Singleton:** SplitwiseService (ExpenseManager)
                • **Strategy:** SplitStrategy (Equal, Exact, Percentage, Share)
                • **Factory:** SplitFactory to create correct strategy
                • **Observer:** Group notifies Users of new expenses
                • **Command:** AddExpenseCommand, SettleDebtCommand for undo/redo

                **Critical Algorithm:**
                • Debt Simplification using Greedy Algorithm (minimize cash flow)
                """,
                solutionStrategy: """
                **Architecture:**

                **A. Domain Model:**
                • User: id, name, email, balances (Map<userId, amount>)
                • Group: members, expenses, activities
                • Expense: paidBy, amount, splits, splitStrategy
                • Split: user, amount, isPaid

                **B. Strategy Pattern (Split Types):**
                • EqualSplitStrategy: amount / users.size()
                • ExactSplitStrategy: validate sum == total
                • PercentageSplitStrategy: validate sum == 100%
                • ShareSplitStrategy: proportional by shares

                **C. Observer Pattern:**
                • Group implements Subject (Observable)
                • User implements Observer
                • Notify on: expense added, settlement, member joined

                **D. Debt Simplification (Greedy):**
                1. Calculate net balance for each user
                2. Separate into Debtors (net < 0) and Creditors (net > 0)
                3. Match max debtor with max creditor recursively
                4. Creates minimum number of transactions
                """,
                mermaidGraph: """
                classDiagram
                    class SplitwiseService {
                        -static SplitwiseService instance
                        -Map users
                        -Map groups
                        -CommandHistory commandHistory
                        -NotificationService notifications
                        +getInstance() SplitwiseService
                        +createUser(name, email) User
                        +createGroup(name, creator) Group
                        +addExpense(group, expense) void
                        +settleUp(from, to, amount) Transaction
                        +undo() void
                        +redo() void
                    }
                    
                    class User {
                        -String userId
                        -String name
                        -String email
                        -Map balances
                        -List groups
                        +updateBalance(userId, amount) void
                        +getNetBalance() double
                        +getBalanceWith(User) double
                        +onNotify(Event) void
                    }
                    
                    class Group {
                        -String groupId
                        -String name
                        -User createdBy
                        -List members
                        -List expenses
                        -List observers
                        -ReentrantLock lock
                        +addMember(User) void
                        +addExpense(Expense) void
                        +getBalances() Map
                        +getSimplifiedDebts() List
                        +attach(Observer) void
                        +notifyAll(Event) void
                    }
                    
                    class Expense {
                        -String expenseId
                        -String description
                        -User paidBy
                        -double amount
                        -LocalDateTime createdAt
                        -SplitStrategy strategy
                        -List splits
                        +getSplitForUser(User) Split
                    }
                    
                    class Split {
                        -User user
                        -double amount
                        -boolean isPaid
                        +markPaid() void
                    }
                    
                    class SplitStrategy {
                        +calculateSplits(amount, users) List
                        +validate(amount, splits) boolean
                    }
                    
                    class EqualSplitStrategy {
                        +calculateSplits(amount, users) List
                    }
                    
                    class ExactSplitStrategy {
                        -Map exactAmounts
                        +validate(amount, splits) boolean
                    }
                    
                    class PercentageSplitStrategy {
                        -Map percentages
                        +validate(amount, splits) boolean
                    }
                    
                    class ShareSplitStrategy {
                        -Map shares
                        +calculateSplits(amount, users) List
                    }
                    
                    class SplitFactory {
                        +create(SplitType, params) SplitStrategy
                    }
                    
                    class DebtSimplifier {
                        +simplify(Map balances) List
                        -matchDebtorToCreditor(debtors, creditors) Transaction
                    }
                    
                    class Command {
                        +execute() void
                        +undo() void
                    }
                    
                    class AddExpenseCommand {
                        -Group group
                        -Expense expense
                        +execute() void
                        +undo() void
                    }
                    
                    class SettleDebtCommand {
                        -User from
                        -User to
                        -double amount
                    }
                    
                    class ExpenseObserver {
                        +onExpenseAdded(Expense) void
                        +onSettlement(Transaction) void
                    }
                    
                    class Transaction {
                        -String id
                        -User from
                        -User to
                        -double amount
                        -TransactionStatus status
                    }
                    
                    SplitwiseService *-- User
                    SplitwiseService *-- Group
                    SplitwiseService o-- Command
                    Group *-- Expense
                    Group *-- User : members
                    Group o-- ExpenseObserver
                    Expense *-- Split
                    Expense o-- SplitStrategy
                    SplitStrategy <|-- EqualSplitStrategy
                    SplitStrategy <|-- ExactSplitStrategy
                    SplitStrategy <|-- PercentageSplitStrategy
                    SplitStrategy <|-- ShareSplitStrategy
                    SplitFactory ..> SplitStrategy
                    Command <|-- AddExpenseCommand
                    Command <|-- SettleDebtCommand
                    User ..|> ExpenseObserver
                    DebtSimplifier ..> Transaction
                """,
                codeSnippet: """
                // ═══════════════════════════════════════════════════════════════
                // FILE: strategy/SplitStrategy.java
                // ═══════════════════════════════════════════════════════════════
                public interface SplitStrategy {
                    List<Split> calculateSplits(double amount, List<User> users);
                    boolean validate(double amount, List<Split> splits);
                }

                public class EqualSplitStrategy implements SplitStrategy {
                    @Override
                    public List<Split> calculateSplits(double amount, List<User> users) {
                        int n = users.size();
                        double baseAmount = Math.floor(amount * 100 / n) / 100;
                        double remainder = amount - (baseAmount * n);
                        
                        List<Split> splits = new ArrayList<>();
                        for (int i = 0; i < n; i++) {
                            // Handle rounding: give extra cent to first users
                            double splitAmount = baseAmount;
                            if (i < Math.round(remainder * 100)) {
                                splitAmount += 0.01;
                            }
                            splits.add(new Split(users.get(i), splitAmount));
                        }
                        return splits;
                    }
                    
                    @Override
                    public boolean validate(double amount, List<Split> splits) {
                        return true; // Always valid for equal split
                    }
                }

                public class ExactSplitStrategy implements SplitStrategy {
                    private final Map<String, Double> exactAmounts;
                    
                    public ExactSplitStrategy(Map<String, Double> exactAmounts) {
                        this.exactAmounts = exactAmounts;
                    }
                    
                    @Override
                    public List<Split> calculateSplits(double amount, List<User> users) {
                        return users.stream()
                            .map(u -> new Split(u, exactAmounts.getOrDefault(u.getId(), 0.0)))
                            .collect(Collectors.toList());
                    }
                    
                    @Override
                    public boolean validate(double amount, List<Split> splits) {
                        double sum = splits.stream().mapToDouble(Split::getAmount).sum();
                        return Math.abs(sum - amount) < 0.01; // Tolerance for rounding
                    }
                }

                public class PercentageSplitStrategy implements SplitStrategy {
                    private final Map<String, Double> percentages;
                    
                    @Override
                    public List<Split> calculateSplits(double amount, List<User> users) {
                        return users.stream()
                            .map(u -> new Split(u, amount * percentages.get(u.getId()) / 100))
                            .collect(Collectors.toList());
                    }
                    
                    @Override
                    public boolean validate(double amount, List<Split> splits) {
                        double totalPct = percentages.values().stream().mapToDouble(d -> d).sum();
                        return Math.abs(totalPct - 100.0) < 0.01;
                    }
                }

                // ═══════════════════════════════════════════════════════════════
                // FILE: factory/SplitFactory.java
                // ═══════════════════════════════════════════════════════════════
                public class SplitFactory {
                    public static SplitStrategy create(SplitType type, Map<String, Double> params) {
                        return switch (type) {
                            case EQUAL -> new EqualSplitStrategy();
                            case EXACT -> new ExactSplitStrategy(params);
                            case PERCENTAGE -> new PercentageSplitStrategy(params);
                            case SHARE -> new ShareSplitStrategy(params);
                        };
                    }
                }

                // ═══════════════════════════════════════════════════════════════
                // FILE: service/DebtSimplifier.java (Greedy Algorithm)
                // ═══════════════════════════════════════════════════════════════
                public class DebtSimplifier {
                    
                    /**
                     * Greedy algorithm to minimize number of transactions.
                     * Time: O(n log n), Space: O(n)
                     */
                    public List<Transaction> simplify(Map<User, Double> balances) {
                        // Separate into creditors (owed money) and debtors (owe money)
                        PriorityQueue<UserBalance> creditors = new PriorityQueue<>(
                            (a, b) -> Double.compare(b.amount, a.amount)); // Max heap
                        PriorityQueue<UserBalance> debtors = new PriorityQueue<>(
                            Comparator.comparingDouble(a -> a.amount)); // Min heap (most negative first)
                        
                        balances.forEach((user, balance) -> {
                            if (balance > 0.01) {
                                creditors.offer(new UserBalance(user, balance));
                            } else if (balance < -0.01) {
                                debtors.offer(new UserBalance(user, balance));
                            }
                        });
                        
                        List<Transaction> transactions = new ArrayList<>();
                        
                        while (!creditors.isEmpty() && !debtors.isEmpty()) {
                            UserBalance creditor = creditors.poll();
                            UserBalance debtor = debtors.poll();
                            
                            // Amount to settle
                            double settleAmount = Math.min(creditor.amount, -debtor.amount);
                            
                            transactions.add(Transaction.builder()
                                .from(debtor.user)
                                .to(creditor.user)
                                .amount(settleAmount)
                                .build());
                            
                            // Re-add if not fully settled
                            double creditorRemaining = creditor.amount - settleAmount;
                            double debtorRemaining = debtor.amount + settleAmount;
                            
                            if (creditorRemaining > 0.01) {
                                creditors.offer(new UserBalance(creditor.user, creditorRemaining));
                            }
                            if (debtorRemaining < -0.01) {
                                debtors.offer(new UserBalance(debtor.user, debtorRemaining));
                            }
                        }
                        
                        return transactions;
                    }
                    
                    @AllArgsConstructor
                    private static class UserBalance {
                        User user;
                        double amount;
                    }
                }

                // ═══════════════════════════════════════════════════════════════
                // FILE: command/AddExpenseCommand.java (Command Pattern)
                // ═══════════════════════════════════════════════════════════════
                public interface Command {
                    void execute();
                    void undo();
                }

                @AllArgsConstructor
                public class AddExpenseCommand implements Command {
                    private final Group group;
                    private final Expense expense;
                    
                    @Override
                    public void execute() {
                        group.addExpense(expense);
                        
                        // Update balances
                        User paidBy = expense.getPaidBy();
                        for (Split split : expense.getSplits()) {
                            if (!split.getUser().equals(paidBy)) {
                                split.getUser().updateBalance(paidBy.getId(), -split.getAmount());
                                paidBy.updateBalance(split.getUser().getId(), split.getAmount());
                            }
                        }
                        
                        // Notify observers
                        group.notifyObservers(new ExpenseAddedEvent(expense));
                    }
                    
                    @Override
                    public void undo() {
                        group.removeExpense(expense);
                        
                        // Reverse balances
                        User paidBy = expense.getPaidBy();
                        for (Split split : expense.getSplits()) {
                            if (!split.getUser().equals(paidBy)) {
                                split.getUser().updateBalance(paidBy.getId(), split.getAmount());
                                paidBy.updateBalance(split.getUser().getId(), -split.getAmount());
                            }
                        }
                    }
                }

                // ═══════════════════════════════════════════════════════════════
                // FILE: service/SplitwiseService.java (Singleton)
                // ═══════════════════════════════════════════════════════════════
                public class SplitwiseService {
                    private static volatile SplitwiseService instance;
                    
                    private final ConcurrentHashMap<String, User> users = new ConcurrentHashMap<>();
                    private final ConcurrentHashMap<String, Group> groups = new ConcurrentHashMap<>();
                    private final Deque<Command> undoStack = new ConcurrentLinkedDeque<>();
                    private final Deque<Command> redoStack = new ConcurrentLinkedDeque<>();
                    private final DebtSimplifier debtSimplifier = new DebtSimplifier();
                    
                    private SplitwiseService() {}
                    
                    public static SplitwiseService getInstance() {
                        if (instance == null) {
                            synchronized (SplitwiseService.class) {
                                if (instance == null) {
                                    instance = new SplitwiseService();
                                }
                            }
                        }
                        return instance;
                    }
                    
                    public void addExpense(String groupId, User paidBy, double amount,
                                          SplitType type, Map<String, Double> splitParams) {
                        Group group = groups.get(groupId);
                        SplitStrategy strategy = SplitFactory.create(type, splitParams);
                        
                        Expense expense = Expense.builder()
                            .expenseId(UUID.randomUUID().toString())
                            .paidBy(paidBy)
                            .amount(amount)
                            .strategy(strategy)
                            .splits(strategy.calculateSplits(amount, group.getMembers()))
                            .createdAt(LocalDateTime.now())
                            .build();
                        
                        // Validate
                        if (!strategy.validate(amount, expense.getSplits())) {
                            throw new InvalidSplitException("Split amounts don't add up");
                        }
                        
                        Command cmd = new AddExpenseCommand(group, expense);
                        cmd.execute();
                        undoStack.push(cmd);
                        redoStack.clear();
                    }
                    
                    public void undo() {
                        if (!undoStack.isEmpty()) {
                            Command cmd = undoStack.pop();
                            cmd.undo();
                            redoStack.push(cmd);
                        }
                    }
                    
                    public List<Transaction> getSimplifiedDebts(String groupId) {
                        Map<User, Double> balances = groups.get(groupId).calculateNetBalances();
                        return debtSimplifier.simplify(balances);
                    }
                }
                """,
                gsSpecificTwist: """
                **Multi-Currency Support (GS Twist)**

                **Problem:** Expenses in different currencies with real-time forex.

                **Solution:**

                ```java
                public class CurrencyAwareExpense extends Expense {
                    private final Currency currency;
                    private final double originalAmount;
                    private final ForexService forexService;
                    
                    @Override
                    public double getAmountInBaseCurrency() {
                        return forexService.convert(originalAmount, currency, Currency.USD);
                    }
                }

                // At settlement time, lock the exchange rate
                public class Settlement {
                    private final double lockedRate;
                    private final Currency sourceCurrency;
                    private final Currency targetCurrency;
                    
                    public Settlement(User from, User to, double amount, Currency curr) {
                        this.lockedRate = forexService.getRate(curr, to.getPreferredCurrency());
                    }
                }
                ```

                **Edge Cases Handled:**

                1. **Rounding Errors ($100 / 3):**
                   - Use `Math.floor(amount * 100 / n) / 100` for base
                   - Distribute remainder cents to first N users
                   - Example: $100/3 = $33.33, $33.33, $33.34

                2. **Concurrency (simultaneous expenses):**
                   - `ReentrantLock` per Group for expense operations
                   - `ConcurrentHashMap` for users and groups
                   - Atomic balance updates with `updateBalance()`
                """
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
            ),
            
            // ══════════════════════════════════════════════════════════════
            // JAVA INTERNALS (Goldman Sachs Priority)
            // ══════════════════════════════════════════════════════════════
            CSConcept(
                category: .java,
                question: "HashMap Internals - Architecture",
                answer: """
                Structure: Array of Node<K,V> buckets

                Put Operation:
                1. Calculate hash: hash(key) = key.hashCode() ^ (h >>> 16)
                2. Find bucket: index = hash & (n-1)
                3. If empty → insert Node
                4. If collision → add to linked list
                5. If list size >= 8 → convert to Red-Black Tree (Java 8+)
                6. If size > threshold → resize (2x capacity)

                Get Operation: O(1) average, O(log n) worst (tree)

                Load Factor: 0.75 (default) - triggers resize at 75% capacity
                """,
                tags: ["HashMap", "hashing", "collections", "data structures"]
            ),
            CSConcept(
                category: .java,
                question: "hashCode() & equals() Contract",
                answer: """
                Contract Rules:
                • If a.equals(b) → a.hashCode() == b.hashCode()
                • If hashCode differs → objects are NOT equal
                • hashCode same does NOT mean equals (collision)

                Breaking the Contract:
                • Override equals() only → HashMap finds wrong bucket
                • Override hashCode() only → equals objects in different buckets

                Example broken behavior:
                Set<Person> set = new HashSet<>();
                set.add(new Person("John")); // bucket 5
                set.contains(new Person("John")); // false! different bucket

                Always override BOTH together!
                """,
                tags: ["hashCode", "equals", "collections", "contract"]
            ),
            CSConcept(
                category: .java,
                question: "Creating an Immutable Class",
                answer: """
                Rules for Immutability:
                1. Declare class as final (prevent subclassing)
                2. All fields private and final
                3. No setters
                4. Defensive copy in constructor
                5. Defensive copy in getters (for mutable fields)

                Example:
                public final class ImmutablePerson {
                    private final String name;
                    private final List<String> hobbies;
                    
                    public ImmutablePerson(String name, List<String> hobbies) {
                        this.name = name;
                        this.hobbies = new ArrayList<>(hobbies); // defensive copy
                    }
                    
                    public List<String> getHobbies() {
                        return Collections.unmodifiableList(hobbies);
                    }
                }

                Why String is immutable: Security, caching (String pool), thread-safety
                """,
                tags: ["immutability", "final", "thread-safety", "design"]
            ),
            CSConcept(
                category: .java,
                question: "volatile Keyword - What It Does",
                answer: """
                Guarantees:
                1. Visibility: Changes visible to all threads immediately
                2. Happens-before: All writes before volatile write visible after volatile read
                3. Prevents instruction reordering around volatile

                Does NOT guarantee:
                • Atomicity! count++ is NOT atomic even with volatile

                Use Cases:
                • Flag variables (boolean stop)
                • Double-checked locking (with synchronized)
                • Publishing immutable objects

                Example:
                volatile boolean running = true;
                // Thread 1: running = false;
                // Thread 2: while(running) {} // Will see false immediately

                For atomicity, use AtomicInteger or synchronized
                """,
                tags: ["volatile", "concurrency", "visibility", "memory model"]
            ),
            CSConcept(
                category: .java,
                question: "Executor Framework - Thread Pools",
                answer: """
                submit() vs execute():
                • execute(Runnable) - void, fire-and-forget
                • submit(Callable) - returns Future<T>, can get result

                Thread Pool Types:
                • FixedThreadPool(n): Fixed n threads, queue unbounded
                • CachedThreadPool: Creates threads as needed, reuses idle
                • SingleThreadExecutor: Single thread, sequential execution
                • ScheduledThreadPool: For delayed/periodic tasks

                Best Practices:
                • Fixed for CPU-bound (n = cores)
                • Cached for many short-lived tasks
                • Always shutdown() to prevent memory leaks

                ExecutorService executor = Executors.newFixedThreadPool(4);
                Future<String> result = executor.submit(() -> "Done");
                executor.shutdown();
                """,
                tags: ["Executor", "ThreadPool", "Future", "concurrency"]
            ),
            CSConcept(
                category: .java,
                question: "String Pool & Interning",
                answer: """
                String Literal vs new String:
                String s1 = "abc";        // String Pool (Heap special area)
                String s2 = "abc";        // Same reference as s1
                String s3 = new String("abc"); // New object on Heap

                s1 == s2    // true (same pool reference)
                s1 == s3    // false (different objects)
                s1.equals(s3) // true (same content)

                Interning:
                String s4 = s3.intern(); // Returns pool reference
                s1 == s4    // true!

                Memory: Pool prevents duplicate strings
                GC: Pool strings eligible for GC if no references
                """,
                tags: ["String", "Pool", "intern", "memory"]
            ),
            CSConcept(
                category: .java,
                question: "Stream API Pipeline",
                answer: """
                Stream Pipeline:
                Source → Intermediate Operations → Terminal Operation

                Intermediate (lazy, return Stream):
                • filter(Predicate) - select elements
                • map(Function) - transform elements
                • flatMap(Function) - flatten nested structures
                • sorted() - sort elements
                • distinct() - remove duplicates

                Terminal (trigger execution):
                • collect(Collector) - to List, Set, Map
                • forEach(Consumer) - side effects
                • reduce(BinaryOperator) - aggregate
                • count(), findFirst(), anyMatch()

                Example:
                employees.stream()
                    .filter(e -> e.getSalary() > 50000)
                    .map(Employee::getName)
                    .sorted()
                    .collect(Collectors.toList());
                """,
                tags: ["Stream", "Java 8", "functional", "collections"]
            ),
            
            // ══════════════════════════════════════════════════════════════
            // SPRING BOOT
            // ══════════════════════════════════════════════════════════════
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
            
            // ══════════════════════════════════════════════════════════════
            // SQL QUERIES
            // ══════════════════════════════════════════════════════════════
            CSConcept(
                category: .sql,
                question: "Find Nth Highest Salary",
                answer: """
                Method 1 - LIMIT OFFSET:
                SELECT DISTINCT salary 
                FROM Employee 
                ORDER BY salary DESC 
                LIMIT 1 OFFSET N-1;

                Method 2 - DENSE_RANK (handles ties):
                SELECT salary FROM (
                    SELECT salary, 
                           DENSE_RANK() OVER (ORDER BY salary DESC) as rnk 
                    FROM Employee
                ) ranked
                WHERE rnk = N;

                Method 3 - Subquery:
                SELECT MAX(salary) FROM Employee
                WHERE salary < (SELECT MAX(salary) FROM Employee);
                -- This gives 2nd highest

                DENSE_RANK vs RANK vs ROW_NUMBER:
                • DENSE_RANK: No gaps (1,2,2,3)
                • RANK: Gaps after ties (1,2,2,4)
                • ROW_NUMBER: Unique (1,2,3,4)
                """,
                tags: ["SQL", "ranking", "salary", "interview"]
            ),
            CSConcept(
                category: .sql,
                question: "Find & Delete Duplicates",
                answer: """
                Find Duplicates:
                SELECT email, COUNT(*) as cnt
                FROM Users
                GROUP BY email
                HAVING COUNT(*) > 1;

                Delete Duplicates (keep lowest ID):
                DELETE FROM Users
                WHERE id NOT IN (
                    SELECT MIN(id)
                    FROM Users
                    GROUP BY email
                );

                Using CTE and ROW_NUMBER:
                WITH CTE AS (
                    SELECT id, email,
                           ROW_NUMBER() OVER (PARTITION BY email ORDER BY id) as rn
                    FROM Users
                )
                DELETE FROM Users WHERE id IN (
                    SELECT id FROM CTE WHERE rn > 1
                );
                """,
                tags: ["SQL", "duplicates", "CTE", "delete"]
            ),
            CSConcept(
                category: .sql,
                question: "Types of Joins",
                answer: """
                INNER JOIN:
                • Only matching rows from both tables
                SELECT * FROM A INNER JOIN B ON A.id = B.a_id

                LEFT JOIN:
                • All rows from left + matching from right
                • NULL for non-matching right rows

                RIGHT JOIN:
                • All rows from right + matching from left

                FULL OUTER JOIN:
                • All rows from both, NULL where no match

                CROSS JOIN:
                • Cartesian product (every row × every row)

                SELF JOIN:
                • Table joined with itself
                • Use case: Employee-Manager hierarchy
                SELECT e.name, m.name as manager
                FROM Employee e
                LEFT JOIN Employee m ON e.manager_id = m.id
                """,
                tags: ["SQL", "joins", "tables", "relationships"]
            ),
            
            // ══════════════════════════════════════════════════════════════
            // DBMS
            // ══════════════════════════════════════════════════════════════
            CSConcept(
                category: .dbms,
                question: "Isolation Levels & Anomalies",
                answer: """
                Anomalies (low to high isolation):

                Dirty Read: Read uncommitted data
                Non-Repeatable Read: Same query, different results
                Phantom Read: New rows appear in range query

                Isolation Levels:
                1. READ UNCOMMITTED
                   • Allows dirty reads
                   • Fastest, least safe

                2. READ COMMITTED (Postgres default)
                   • No dirty reads
                   • May have non-repeatable reads

                3. REPEATABLE READ (MySQL default)
                   • Same row reads same value
                   • Phantoms possible

                4. SERIALIZABLE
                   • Full isolation
                   • Slowest, safest
                """,
                tags: ["isolation", "transactions", "ACID", "concurrency"]
            ),
            CSConcept(
                category: .dbms,
                question: "Normalization Forms",
                answer: """
                1NF (First Normal Form):
                • Atomic values (no arrays/lists in columns)
                • Each row unique (primary key)

                2NF:
                • 1NF + No partial dependencies
                • Non-key columns depend on ENTIRE primary key

                3NF:
                • 2NF + No transitive dependencies
                • Non-key columns depend ONLY on primary key

                BCNF (Boyce-Codd):
                • Every determinant is a candidate key

                When to Denormalize:
                • Read-heavy systems (analytics)
                • Reduce JOIN overhead
                • Caching/Materialized views
                """,
                tags: ["normalization", "1NF", "2NF", "3NF", "database design"]
            ),
            CSConcept(
                category: .dbms,
                question: "CAP Theorem",
                answer: """
                In distributed system, choose 2 of 3:

                Consistency:
                • All nodes see same data at same time
                • Every read gets most recent write

                Availability:
                • Every request gets a response
                • System always operational

                Partition Tolerance:
                • System works despite network failures
                • Required in distributed systems!

                Real choices (P is mandatory):
                • CP: Banks, financial systems (sacrifice availability)
                • AP: Social media, CDNs (sacrifice consistency)

                Examples:
                • CP: MongoDB, HBase, Redis Cluster
                • AP: Cassandra, DynamoDB, CouchDB
                """,
                tags: ["CAP", "distributed", "consistency", "availability"]
            ),
            
            // ══════════════════════════════════════════════════════════════
            // OOPS & SOLID
            // ══════════════════════════════════════════════════════════════
            CSConcept(
                category: .oops,
                question: "SOLID Principles - Overview",
                answer: """
                S - Single Responsibility:
                • Class should have ONE reason to change
                • Separate concerns (UserValidator vs UserRepository)

                O - Open/Closed:
                • Open for extension, closed for modification
                • Use interfaces/abstract classes

                L - Liskov Substitution:
                • Subclass must be substitutable for parent
                • Don't break parent's contract

                I - Interface Segregation:
                • Many specific interfaces > one general
                • Clients shouldn't depend on unused methods

                D - Dependency Inversion:
                • Depend on abstractions, not concretions
                • High-level modules don't depend on low-level
                """,
                tags: ["SOLID", "design principles", "clean code"]
            ),
            CSConcept(
                category: .oops,
                question: "Composition vs Inheritance",
                answer: """
                Inheritance (IS-A):
                class Dog extends Animal { }
                • Tight coupling
                • Fragile base class problem
                • Can't change at runtime

                Composition (HAS-A):
                class Car {
                    private Engine engine;
                }
                • Loose coupling
                • Change behavior at runtime
                • Easier testing (mock dependencies)

                Favor Composition because:
                • More flexible (swap implementations)
                • Avoids deep hierarchies
                • Encapsulation preserved
                • Diamond problem avoided

                Use Inheritance when:
                • True IS-A relationship
                • Need polymorphism
                • Template method pattern
                """,
                tags: ["composition", "inheritance", "design", "coupling"]
            ),
            CSConcept(
                category: .oops,
                question: "Abstract Class vs Interface",
                answer: """
                Abstract Class:
                • Can have state (instance variables)
                • Can have constructors
                • Can have concrete methods
                • Single inheritance only
                • Use for: Common base with shared code

                Interface:
                • No state (only constants)
                • No constructors
                • All methods abstract (before Java 8)
                • Multiple inheritance allowed
                • Use for: Defining contracts

                Java 8+ Interfaces:
                • default methods (with implementation)
                • static methods
                • Why added? Backward compatibility

                Diamond Problem:
                • Solved by explicit override required
                class C implements A, B {
                    void method() { A.super.method(); }
                }
                """,
                tags: ["abstract", "interface", "inheritance", "Java"]
            ),
            
            // ══════════════════════════════════════════════════════════════
            // NETWORKING
            // ══════════════════════════════════════════════════════════════
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
            
            // ══════════════════════════════════════════════════════════════
            // MORE JAVA CONCEPTS
            // ══════════════════════════════════════════════════════════════
            CSConcept(
                category: .java,
                question: "ConcurrentHashMap vs HashMap vs Hashtable",
                answer: """
                HashMap:
                • NOT thread-safe
                • Allows one null key, multiple null values
                • Best performance for single-threaded

                Hashtable (legacy):
                • Thread-safe (synchronized methods)
                • No null keys or values
                • Poor performance (locks entire table)

                ConcurrentHashMap:
                • Thread-safe with segment locking (Java 7)
                • Lock striping: 16 segments by default
                • Java 8+: CAS operations, no segments
                • No null keys or values
                • Best for concurrent access

                Read: Lock-free in ConcurrentHashMap
                Write: Only locks affected bucket/segment
                """,
                tags: ["ConcurrentHashMap", "thread-safety", "collections"]
            ),
            CSConcept(
                category: .java,
                question: "ThreadLocal - Use Cases & Dangers",
                answer: """
                What it does:
                • Each thread gets its own copy of variable
                • No synchronization needed
                • Accessed via ThreadLocal.get()/set()

                Use Cases:
                • User session context (Spring SecurityContextHolder)
                • Database connections per thread
                • SimpleDateFormat (not thread-safe)
                • Transaction context

                Dangers:
                • Memory leaks in thread pools!
                • Thread reuse keeps old values
                • ALWAYS use try-finally with remove()

                Example:
                ThreadLocal<User> currentUser = new ThreadLocal<>();
                try {
                    currentUser.set(user);
                    // ... use currentUser.get()
                } finally {
                    currentUser.remove(); // CRITICAL!
                }
                """,
                tags: ["ThreadLocal", "thread-safety", "memory leak"]
            ),
            CSConcept(
                category: .java,
                question: "CompletableFuture - Async Programming",
                answer: """
                Creating:
                CompletableFuture.supplyAsync(() -> compute())
                CompletableFuture.runAsync(() -> sideEffect())

                Chaining:
                • thenApply(fn) - transform result
                • thenAccept(consumer) - consume result
                • thenRun(runnable) - just run
                • thenCompose(fn) - flatMap (returns CF)

                Combining:
                • thenCombine(other, fn) - combine two
                • allOf(cf1, cf2, cf3) - wait for all
                • anyOf(cf1, cf2, cf3) - first to complete

                Error Handling:
                • exceptionally(fn) - recover from error
                • handle(bifn) - process result or error

                Example:
                CompletableFuture.supplyAsync(() -> fetchUser(id))
                    .thenApply(user -> enrichUser(user))
                    .thenAccept(user -> saveToCache(user))
                    .exceptionally(ex -> { log(ex); return null; });
                """,
                tags: ["CompletableFuture", "async", "Future", "concurrency"]
            ),
            CSConcept(
                category: .java,
                question: "ClassLoader - How Classes Are Loaded",
                answer: """
                Hierarchy (Parent-first delegation):
                1. Bootstrap ClassLoader (JRE classes)
                2. Extension ClassLoader (ext folder)
                3. Application ClassLoader (classpath)

                Loading Process:
                1. Loading: Read .class bytecode
                2. Linking: Verify → Prepare → Resolve
                3. Initialization: Run static blocks

                Class.forName() vs ClassLoader.loadClass():
                • forName() - loads AND initializes
                • loadClass() - loads only, no init

                Custom ClassLoader uses:
                • Hot reloading (Tomcat)
                • Plugin systems
                • Encryption/decryption of classes
                • Isolation (different versions)
                """,
                tags: ["ClassLoader", "JVM", "bytecode", "loading"]
            ),
            CSConcept(
                category: .java,
                question: "Functional Interface vs Regular Interface",
                answer: """
                Functional Interface:
                • Exactly ONE abstract method
                • Can have default/static methods
                • @FunctionalInterface annotation (optional)
                • Can be used with lambdas

                Built-in Functional Interfaces:
                • Predicate<T>: T → boolean
                • Function<T,R>: T → R
                • Consumer<T>: T → void
                • Supplier<T>: () → T
                • BiFunction<T,U,R>: (T,U) → R

                Why added to interfaces (Java 8)?
                Default methods: Backward compatibility
                • Add methods to interface without breaking implementations
                • Example: List.forEach() added without breaking old code

                Static methods: Utility methods in interface
                • Comparator.comparing()
                """,
                tags: ["functional interface", "lambda", "Java 8"]
            ),
            CSConcept(
                category: .java,
                question: "Serialization & Its Dangers",
                answer: """
                What: Convert object → byte stream

                Markers:
                • implements Serializable
                • serialVersionUID (version control)

                transient keyword:
                • Fields NOT serialized
                • Use for: passwords, derived fields, non-serializable refs

                Dangers:
                • Security: Deserialization attacks
                • Breaks encapsulation (bypasses constructors)
                • Versioning nightmares

                Alternatives:
                • JSON (Jackson, Gson)
                • Protocol Buffers
                • Externalization (manual control)

                Custom Serialization:
                private void writeObject(ObjectOutputStream)
                private void readObject(ObjectInputStream)
                """,
                tags: ["Serialization", "transient", "security"]
            ),
            
            // ══════════════════════════════════════════════════════════════
            // MORE SPRING BOOT
            // ══════════════════════════════════════════════════════════════
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
            ),
            
            // ══════════════════════════════════════════════════════════════
            // MORE DBMS
            // ══════════════════════════════════════════════════════════════
            CSConcept(
                category: .dbms,
                question: "Database Sharding",
                answer: """
                What: Horizontal partitioning across servers

                Strategies:
                1. Range-based: user_id 1-1M → Shard1
                2. Hash-based: hash(user_id) % N
                3. Directory-based: Lookup table

                Challenges:
                • Cross-shard queries (JOINs)
                • Transactions across shards
                • Resharding when adding nodes
                • Hotspots (uneven distribution)

                Consistent Hashing:
                • Minimizes redistribution on add/remove
                • Virtual nodes for balance

                When to shard:
                • Single DB can't handle load
                • Data too large for one server
                • Geographic distribution needed
                """,
                tags: ["sharding", "horizontal scaling", "partitioning"]
            ),
            CSConcept(
                category: .dbms,
                question: "Database Replication",
                answer: """
                Master-Slave (Primary-Replica):
                • Writes → Master only
                • Reads → Slaves (read replicas)
                • Async replication (eventual consistency)

                Master-Master:
                • Writes to any node
                • Conflict resolution needed
                • More complex

                Replication Lag:
                • Slave may have stale data
                • Read-after-write consistency issue
                • Solutions: Sticky sessions, read-your-writes

                Synchronous vs Async:
                • Sync: Wait for ACK, slower but consistent
                • Async: Faster but may lose data

                Failover:
                • Automatic promotion of slave to master
                • Split-brain prevention
                """,
                tags: ["replication", "master-slave", "high availability"]
            ),
            CSConcept(
                category: .dbms,
                question: "Query Optimization - EXPLAIN",
                answer: """
                EXPLAIN SELECT ... shows execution plan

                Key Columns:
                • type: ALL (bad), index, range, ref, eq_ref, const
                • rows: Estimated rows examined
                • key: Index used
                • Extra: Using where, Using index, Using filesort

                Optimization Tips:
                1. Add indexes on WHERE, JOIN, ORDER BY columns
                2. Use covering indexes (include all needed columns)
                3. Avoid SELECT * (fetch only needed)
                4. Avoid functions on columns in WHERE
                5. Use LIMIT for pagination
                6. Avoid OR (use UNION or IN)

                Bad: WHERE YEAR(created_at) = 2024
                Good: WHERE created_at >= '2024-01-01'
                """,
                tags: ["EXPLAIN", "query optimization", "index", "performance"]
            ),
            CSConcept(
                category: .dbms,
                question: "Database Locking Mechanisms",
                answer: """
                Lock Granularity:
                • Table lock: Locks entire table
                • Row lock: Locks specific rows
                • Page lock: Locks memory page

                Lock Types:
                • Shared (S): Read lock, multiple holders
                • Exclusive (X): Write lock, single holder

                MySQL InnoDB:
                • Row-level locking for DML
                • Gap locks (prevent phantom reads)
                • Next-key locks = row + gap

                Deadlock:
                • Two transactions waiting for each other
                • Detection: Wait-for graph
                • Resolution: Rollback one transaction

                FOR UPDATE: Acquire exclusive lock
                SELECT * FROM users WHERE id=1 FOR UPDATE;
                """,
                tags: ["locking", "deadlock", "row lock", "transactions"]
            ),
            
            // ══════════════════════════════════════════════════════════════
            // MORE SQL
            // ══════════════════════════════════════════════════════════════
            CSConcept(
                category: .sql,
                question: "Window Functions",
                answer: """
                Syntax: function() OVER (PARTITION BY ... ORDER BY ...)

                Ranking:
                ROW_NUMBER(): 1,2,3,4 (unique)
                RANK(): 1,2,2,4 (gaps after ties)
                DENSE_RANK(): 1,2,2,3 (no gaps)
                NTILE(n): Divide into n buckets

                Aggregate:
                SUM(), AVG(), COUNT(), MIN(), MAX()
                Running total: SUM(amount) OVER (ORDER BY date)

                Value:
                LAG(col, n): n rows before
                LEAD(col, n): n rows after
                FIRST_VALUE(), LAST_VALUE()

                Example:
                SELECT name, salary,
                    salary - LAG(salary) OVER (ORDER BY hire_date) as increase,
                    AVG(salary) OVER (PARTITION BY dept) as dept_avg
                FROM employees;
                """,
                tags: ["window functions", "OVER", "PARTITION BY", "analytics"]
            ),
            CSConcept(
                category: .sql,
                question: "Common Table Expressions (CTE)",
                answer: """
                Syntax:
                WITH cte_name AS (
                    SELECT ...
                )
                SELECT * FROM cte_name;

                Benefits:
                • Readability (name complex subqueries)
                • Reusability (reference multiple times)
                • Recursive queries

                Recursive CTE (hierarchies):
                WITH RECURSIVE hierarchy AS (
                    -- Base case
                    SELECT id, name, manager_id, 1 as level
                    FROM employees WHERE manager_id IS NULL
                    
                    UNION ALL
                    
                    -- Recursive case
                    SELECT e.id, e.name, e.manager_id, h.level + 1
                    FROM employees e
                    JOIN hierarchy h ON e.manager_id = h.id
                )
                SELECT * FROM hierarchy;

                Use Cases: Org charts, file trees, graph traversal
                """,
                tags: ["CTE", "WITH", "recursive", "hierarchy"]
            ),
            CSConcept(
                category: .sql,
                question: "Index Types & When to Use",
                answer: """
                B-Tree Index (default):
                • Balanced tree structure
                • Good for: =, <, >, <=, >=, BETWEEN, LIKE 'abc%'
                • Bad for: LIKE '%abc'

                Hash Index:
                • O(1) lookup
                • Only for equality (=)
                • Not for range queries

                Full-Text Index:
                • For text search
                • Supports MATCH AGAINST

                Composite Index:
                • Multiple columns
                • Leftmost prefix rule
                • INDEX(a,b,c) works for: a, a+b, a+b+c
                • NOT for: b, c, b+c

                Covering Index:
                • Contains all columns needed
                • No table lookup required
                • "Using index" in EXPLAIN
                """,
                tags: ["index", "B-Tree", "composite", "covering index"]
            ),
            
            // ══════════════════════════════════════════════════════════════
            // MORE OS
            // ══════════════════════════════════════════════════════════════
            CSConcept(
                category: .os,
                question: "CPU Scheduling Algorithms",
                answer: """
                FCFS (First Come First Serve):
                • Simple queue
                • Convoy effect (short jobs wait)

                SJF (Shortest Job First):
                • Optimal average wait time
                • Starvation possible

                Round Robin:
                • Time quantum per process
                • Fair, good for time-sharing
                • Context switch overhead

                Priority Scheduling:
                • Higher priority first
                • Starvation solved by aging

                Multilevel Queue:
                • Multiple queues (foreground/background)
                • Each queue has own algorithm

                Real-time:
                • Rate Monotonic (static priority)
                • EDF (Earliest Deadline First)
                """,
                tags: ["scheduling", "CPU", "round robin", "algorithms"]
            ),
            CSConcept(
                category: .os,
                question: "Memory Management - Paging vs Segmentation",
                answer: """
                Paging:
                • Fixed-size blocks (pages)
                • No external fragmentation
                • Internal fragmentation possible
                • Page table for address translation

                Segmentation:
                • Variable-size blocks (segments)
                • Logical division (code, data, stack)
                • External fragmentation
                • Segment table

                Page Table Entry:
                • Frame number
                • Valid bit
                • Protection bits
                • Dirty bit
                • Reference bit

                TLB (Translation Lookaside Buffer):
                • Cache for page table
                • TLB hit: Fast
                • TLB miss: Page table lookup

                Page Replacement: LRU, FIFO, Clock, Optimal
                """,
                tags: ["paging", "segmentation", "TLB", "memory"]
            ),
            CSConcept(
                category: .os,
                question: "Inter-Process Communication (IPC)",
                answer: """
                Pipes:
                • Unidirectional
                • Parent-child processes
                • Use: ls | grep

                Named Pipes (FIFO):
                • Bidirectional
                • Any processes
                • Persists in filesystem

                Message Queues:
                • Async communication
                • Structured messages
                • Kernel manages queue

                Shared Memory:
                • Fastest IPC
                • Processes map same memory
                • Need synchronization (semaphores)

                Sockets:
                • Network communication
                • Client-server model
                • TCP or UDP

                Semaphores:
                • Synchronization primitive
                • Binary (mutex) or counting
                """,
                tags: ["IPC", "pipes", "shared memory", "sockets"]
            ),
            CSConcept(
                category: .os,
                question: "File System Concepts",
                answer: """
                Inode:
                • Metadata: size, permissions, timestamps
                • Pointers to data blocks
                • Does NOT contain filename

                Directory:
                • List of (filename, inode number)
                • Special file

                Hard Link:
                • Same inode, different names
                • Can't cross filesystems
                • Deleting one doesn't affect other

                Symbolic Link (symlink):
                • Points to path name
                • Can cross filesystems
                • Breaks if target deleted

                File Allocation:
                • Contiguous: Fast, external fragmentation
                • Linked: No fragmentation, slow random access
                • Indexed (inode): Best of both
                """,
                tags: ["filesystem", "inode", "links", "storage"]
            ),
            
            // ══════════════════════════════════════════════════════════════
            // MORE OOPS
            // ══════════════════════════════════════════════════════════════
            CSConcept(
                category: .oops,
                question: "Polymorphism - Compile vs Runtime",
                answer: """
                Compile-time (Static):
                • Method Overloading
                • Same name, different parameters
                • Resolved at compile time

                class Calculator {
                    int add(int a, int b) { return a + b; }
                    double add(double a, double b) { return a + b; }
                }

                Runtime (Dynamic):
                • Method Overriding
                • Same signature in parent/child
                • Resolved at runtime
                • Needs inheritance

                Animal animal = new Dog();
                animal.speak(); // Calls Dog's speak()

                Virtual Method Table (vtable):
                • Table of method pointers
                • Each object has vtable pointer
                • Runtime lookup for overridden methods
                """,
                tags: ["polymorphism", "overloading", "overriding", "vtable"]
            ),
            CSConcept(
                category: .oops,
                question: "Encapsulation & Information Hiding",
                answer: """
                Encapsulation:
                • Bundling data + methods
                • Private fields, public methods
                • Control access via getters/setters

                Benefits:
                • Data validation in setters
                • Implementation can change
                • Invariants maintained

                Example:
                public class BankAccount {
                    private double balance;
                    
                    public void deposit(double amount) {
                        if (amount > 0) {
                            balance += amount;
                        }
                    }
                    
                    public void withdraw(double amount) {
                        if (amount > 0 && amount <= balance) {
                            balance -= amount;
                        }
                    }
                }

                Access Modifiers:
                private < default < protected < public
                """,
                tags: ["encapsulation", "access modifiers", "private", "getters"]
            ),
            CSConcept(
                category: .oops,
                question: "Design Patterns - Overview",
                answer: """
                Creational (Object Creation):
                • Singleton: One instance
                • Factory: Delegate creation
                • Builder: Step-by-step construction
                • Prototype: Clone objects

                Structural (Composition):
                • Adapter: Interface compatibility
                • Decorator: Add behavior dynamically
                • Facade: Simplified interface
                • Proxy: Placeholder/surrogate

                Behavioral (Communication):
                • Observer: Pub-sub notifications
                • Strategy: Interchangeable algorithms
                • Command: Encapsulate actions
                • State: State-dependent behavior

                When to use:
                • Singleton: Logger, Config, DB pool
                • Factory: Complex object creation
                • Strategy: Multiple algorithms
                • Observer: Event systems, MVC
                """,
                tags: ["design patterns", "creational", "structural", "behavioral"]
            ),
            CSConcept(
                category: .oops,
                question: "SOLID - Deep Dive with Examples",
                answer: """
                Single Responsibility:
                BAD: UserService handles auth + email + validation
                GOOD: AuthService, EmailService, ValidationService

                Open/Closed:
                BAD: if(type == "circle") else if(type == "square")
                GOOD: Shape interface with draw() method

                Liskov Substitution:
                BAD: Square extends Rectangle (breaks setWidth/setHeight)
                GOOD: Both implement Shape interface

                Interface Segregation:
                BAD: Worker interface with work() + eat() + sleep()
                GOOD: Workable, Eatable as separate interfaces

                Dependency Inversion:
                BAD: OrderService creates MySQLDatabase
                GOOD: OrderService depends on Database interface
                     Inject concrete implementation
                """,
                tags: ["SOLID", "SRP", "OCP", "LSP", "ISP", "DIP"]
            ),
            
            // ══════════════════════════════════════════════════════════════
            // MORE NETWORKING
            // ══════════════════════════════════════════════════════════════
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
        
        for concept in concepts {
            context.insert(concept)
        }
    }
}
