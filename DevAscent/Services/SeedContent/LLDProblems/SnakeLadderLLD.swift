//
//  SnakeLadderLLD.swift
//  DevAscent
//
//  Snake & Ladder (Distributed) LLD Problem
//

import Foundation

struct SnakeLadderLLD {
    static func create() -> LLDProblem {
        return LLDProblem(
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
                        
                        // 2. Calculate new position
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
                        
                        // 5. Create and publish event
                        GameEvent event = GameEvent.builder()
                            .gameId(gameId)
                            .type(eventType)
                            .playerId(currentPlayer.getId())
                            .diceRoll(diceRoll)
                            .fromPosition(fromPos)
                            .toPosition(toPos)
                            .timestamp(System.currentTimeMillis())
                            .idempotencyKey(gameId + "-" + System.nanoTime())
                            .build();
                        
                        notifyObservers(event);
                        
                        if (status != GameStatus.COMPLETED) {
                            currentPlayerIndex = (currentPlayerIndex + 1) % players.size();
                        }
                        
                        return event;
                    } finally {
                        turnLock.unlock();
                    }
                }
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

            3. **Idempotency:**
               - Each event has `idempotencyKey`
               - Redis `SETNX` for exactly-once processing

            4. **Edge Case - Simultaneous Rolls:**
               - Kafka partition by gameId ensures ordering
               - Single consumer per partition = sequential processing
            """
        )
    }
}
