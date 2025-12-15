//
//  SnakeLadderLLD.swift
//  DevAscent
//
//  Snake and Ladder Game LLD Problem
//

import Foundation

struct SnakeLadderLLD {
    static func create() -> LLDProblem {
        return LLDProblem(
            title: "Snake and Ladder Game",
            requirements: """
            **Core Domain Requirements:**
            • **Game Management:** Create game, add players, play turns
            • **Board Setup:** Configurable board with snakes and ladders
            • **Turn Management:** Dice rolling, player movement, win detection
            • **Entity Placement:** Snakes move down, ladders move up
            • **Multiple Setup Strategies:** Random, Standard, Custom placement
            • **Notifications:** Observer pattern for game events

            **Design Patterns (Mandatory):**
            • **Factory Pattern:** GameFactory creates configured games
            • **Strategy Pattern:** SetupStrategy for board configuration
            • **Strategy Pattern:** Rules for game logic (move validation, win check)
            • **Observer Pattern:** IObserver for game event notifications
            • **Template Method:** BoardEntity hierarchy (Snake, Ladder)

            **Key Constraints:**
            • Snake head > tail (always moves down)
            • Ladder start < end (always moves up)
            • No snake/ladder at position 1 or 100
            • Multiple difficulty levels (Easy, Medium, Hard)
            """,
            solutionStrategy: """
            **Architecture:**

            **A. Game Controller:**
            • Game - Main controller with Board, Dice, Players queue
            • Manages turn order using Deque<Player>
            • Holds Rules reference for game logic
            • Maintains list of IObservers for notifications

            **B. Board & Entities:**
            • Board - Grid with entities map, setup via SetupStrategy
            • BoardEntity (Abstract) - Base with start, end positions
            • Snake extends BoardEntity - Moves player down
            • Ladder extends BoardEntity - Moves player up

            **C. Strategy Pattern (Board Setup):**
            • SetupStrategy (Abstract) - setupBoard(Board)
            • RandomBoardStrat - Random placement based on difficulty
            • StandardStrat - Fixed classic placement
            • CustomCountStrat - User-defined positions

            **D. Strategy Pattern (Rules):**
            • Rules (Abstract) - isValidMove, calcNewPos, checkWin
            • StandardRules - Classic rules implementation

            **E. Factory Pattern:**
            • GameFactory - createGame() with configuration

            **F. Observer Pattern:**
            • IObserver - update(message)
            • ConsoleNotifier - Prints game events
            """,
            mermaidGraph: """
            classDiagram
                class Game {
                    -Board board
                    -Dice dice
                    -Deque players
                    -Rules rules
                    -List observers
                    -bool gameOver
                    +addPlayer(Player)
                    +addObserver(IObserver)
                    +notify(String)
                    +play()
                }
                class Board {
                    -int size
                    -List entities
                    -Map entityMap
                    +canAddEntity(int)
                    +addBoardEntity(BoardEntity)
                    +setupBoard(SetupStrategy)
                    +display()
                }
                class BoardEntity {
                    #int start
                    #int end
                    +display()
                }
                class Snake {
                    +display()
                    +Snake(int, int)
                }
                class Ladder {
                    +Ladder(int, int)
                }
                class Dice {
                    -int faces
                    +roll()
                }
                class Player {
                    -int id
                    -String name
                    -int pos
                    -int score
                }
                class Difficulty {
                    EASY
                    MEDIUM
                    HARD
                }
                class GameFactory {
                    +createGame()
                }
                class IObserver {
                    +update(String)
                }
                class ConsoleNotifier {
                    +update(String)
                }
                class SetupStrategy {
                    +setupBoard(Board)
                }
                class RandomBoardStrat {
                    -Difficulty difficulty
                    +setupBoard(Board)
                }
                class StandardStrat {
                    +setupBoard(Board)
                }
                class CustomCountStrat {
                    -int snakes
                    -int ladders
                    -bool randomPos
                    -List snakePos
                    -List ladderPos
                    +addSnakePos(int, int)
                    +addLadderPos(int, int)
                    +setupBoard(Board)
                }
                class Rules {
                    +isValidMove(int, int, int)
                    +calcNewPos(int, int, Board)
                    +checkWin(int, int)
                }
                class StandardRules {
                    +isValidMove(int, int, int)
                    +calcNewPos(int, int, Board)
                    +checkWin(int, int)
                }
                Game --> Board
                Game --> Dice
                Game --> Player
                Game --> Rules
                Game --> IObserver
                GameFactory --> Game
                Board --> BoardEntity
                Board --> SetupStrategy
                BoardEntity <|-- Snake
                BoardEntity <|-- Ladder
                IObserver <|.. ConsoleNotifier
                SetupStrategy <|-- RandomBoardStrat
                SetupStrategy <|-- StandardStrat
                SetupStrategy <|-- CustomCountStrat
                RandomBoardStrat --> Difficulty
                Rules <|-- StandardRules
            """,
            codeSnippet: """
            // ═══════════════════════════════════════════════════════════════
            // FILE: domain/BoardEntity.java (Abstract Base)
            // ═══════════════════════════════════════════════════════════════
            public abstract class BoardEntity {
                protected final int start;
                protected final int end;
                
                protected BoardEntity(int start, int end) {
                    this.start = start;
                    this.end = end;
                }
                
                public int getStart() { return start; }
                public int getEnd() { return end; }
                public abstract void display();
            }

            public class Snake extends BoardEntity {
                public Snake(int head, int tail) {
                    super(head, tail);
                    if (head <= tail) {
                        throw new IllegalArgumentException("Snake head must be > tail");
                    }
                }
                
                @Override
                public void display() {
                    System.out.println("🐍 Snake: " + start + " → " + end);
                }
            }

            public class Ladder extends BoardEntity {
                public Ladder(int bottom, int top) {
                    super(bottom, top);
                    if (bottom >= top) {
                        throw new IllegalArgumentException("Ladder bottom must be < top");
                    }
                }
                
                @Override
                public void display() {
                    System.out.println("🪜 Ladder: " + start + " → " + end);
                }
            }

            // ═══════════════════════════════════════════════════════════════
            // FILE: strategy/SetupStrategy.java
            // ═══════════════════════════════════════════════════════════════
            public abstract class SetupStrategy {
                public abstract void setupBoard(Board board);
            }

            public class RandomBoardStrat extends SetupStrategy {
                private final Difficulty difficulty;
                private final Random random = new Random();
                
                public RandomBoardStrat(Difficulty difficulty) {
                    this.difficulty = difficulty;
                }
                
                @Override
                public void setupBoard(Board board) {
                    int snakeCount = difficulty.getSnakeCount();
                    int ladderCount = difficulty.getLadderCount();
                    
                    // Add random snakes
                    for (int i = 0; i < snakeCount; i++) {
                        int head = random.nextInt(90) + 10;  // 10-99
                        int tail = random.nextInt(head - 2) + 2;  // 2 to head-1
                        if (board.canAddEntity(head)) {
                            board.addBoardEntity(new Snake(head, tail));
                        }
                    }
                    
                    // Add random ladders
                    for (int i = 0; i < ladderCount; i++) {
                        int bottom = random.nextInt(80) + 2;  // 2-81
                        int top = bottom + random.nextInt(99 - bottom) + 1;
                        if (board.canAddEntity(bottom)) {
                            board.addBoardEntity(new Ladder(bottom, top));
                        }
                    }
                }
            }

            public class StandardStrat extends SetupStrategy {
                @Override
                public void setupBoard(Board board) {
                    // Classic snake positions
                    board.addBoardEntity(new Snake(99, 54));
                    board.addBoardEntity(new Snake(70, 55));
                    board.addBoardEntity(new Snake(52, 42));
                    board.addBoardEntity(new Snake(25, 2));
                    
                    // Classic ladder positions
                    board.addBoardEntity(new Ladder(6, 25));
                    board.addBoardEntity(new Ladder(11, 40));
                    board.addBoardEntity(new Ladder(60, 85));
                    board.addBoardEntity(new Ladder(46, 90));
                }
            }

            public class CustomCountStrat extends SetupStrategy {
                private final List<Pair<Integer, Integer>> snakePos = new ArrayList<>();
                private final List<Pair<Integer, Integer>> ladderPos = new ArrayList<>();
                
                public void addSnakePos(int start, int end) {
                    snakePos.add(new Pair<>(start, end));
                }
                
                public void addLadderPos(int start, int end) {
                    ladderPos.add(new Pair<>(start, end));
                }
                
                @Override
                public void setupBoard(Board board) {
                    snakePos.forEach(p -> board.addBoardEntity(new Snake(p.first, p.second)));
                    ladderPos.forEach(p -> board.addBoardEntity(new Ladder(p.first, p.second)));
                }
            }

            // ═══════════════════════════════════════════════════════════════
            // FILE: rules/Rules.java (Strategy for Game Logic)
            // ═══════════════════════════════════════════════════════════════
            public abstract class Rules {
                public abstract boolean isValidMove(int pos, int diceValue, int boardSize);
                public abstract int calcNewPos(int pos, int diceValue, Board board);
                public abstract boolean checkWin(int pos, int boardSize);
            }

            public class StandardRules extends Rules {
                @Override
                public boolean isValidMove(int pos, int diceValue, int boardSize) {
                    return pos + diceValue <= boardSize;
                }
                
                @Override
                public int calcNewPos(int pos, int diceValue, Board board) {
                    int newPos = pos + diceValue;
                    
                    // Check for snake or ladder at new position
                    BoardEntity entity = board.getEntityAt(newPos);
                    if (entity != null) {
                        entity.display();
                        return entity.getEnd();
                    }
                    return newPos;
                }
                
                @Override
                public boolean checkWin(int pos, int boardSize) {
                    return pos == boardSize;
                }
            }

            // ═══════════════════════════════════════════════════════════════
            // FILE: observer/IObserver.java
            // ═══════════════════════════════════════════════════════════════
            public interface IObserver {
                void update(String message);
            }

            public class ConsoleNotifier implements IObserver {
                @Override
                public void update(String message) {
                    System.out.println("📢 " + message);
                }
            }

            // ═══════════════════════════════════════════════════════════════
            // FILE: Game.java (Main Controller)
            // ═══════════════════════════════════════════════════════════════
            public class Game {
                private final Board board;
                private final Dice dice;
                private final Deque<Player> players = new ArrayDeque<>();
                private final Rules rules;
                private final List<IObserver> observers = new ArrayList<>();
                private boolean gameOver = false;
                
                public Game(Board board, Dice dice, Rules rules) {
                    this.board = board;
                    this.dice = dice;
                    this.rules = rules;
                }
                
                public void addPlayer(Player player) {
                    players.add(player);
                    notify(player.getName() + " joined the game!");
                }
                
                public void addObserver(IObserver observer) {
                    observers.add(observer);
                }
                
                private void notify(String message) {
                    observers.forEach(obs -> obs.update(message));
                }
                
                public void play() {
                    notify("Game started!");
                    
                    while (!gameOver) {
                        Player current = players.poll();  // Get next player
                        
                        int diceValue = dice.roll();
                        notify(current.getName() + " rolled " + diceValue);
                        
                        int currentPos = current.getPos();
                        
                        if (rules.isValidMove(currentPos, diceValue, board.getSize())) {
                            int newPos = rules.calcNewPos(currentPos, diceValue, board);
                            current.setPos(newPos);
                            notify(current.getName() + " moved to " + newPos);
                            
                            if (rules.checkWin(newPos, board.getSize())) {
                                notify("🎉 " + current.getName() + " WINS!");
                                gameOver = true;
                                return;
                            }
                        } else {
                            notify(current.getName() + " cannot move, stays at " + currentPos);
                        }
                        
                        players.add(current);  // Add back to queue
                    }
                }
            }

            // ═══════════════════════════════════════════════════════════════
            // FILE: factory/GameFactory.java
            // ═══════════════════════════════════════════════════════════════
            public class GameFactory {
                public static Game createGame(SetupStrategy strategy, int numPlayers) {
                    Board board = new Board(100);
                    strategy.setupBoard(board);
                    
                    Dice dice = new Dice(6);
                    Rules rules = new StandardRules();
                    
                    Game game = new Game(board, dice, rules);
                    game.addObserver(new ConsoleNotifier());
                    
                    for (int i = 1; i <= numPlayers; i++) {
                        game.addPlayer(new Player(i, "Player " + i));
                    }
                    
                    return game;
                }
            }

            // ═══════════════════════════════════════════════════════════════
            // FILE: SnakeLadderDemo.java (Main)
            // ═══════════════════════════════════════════════════════════════
            public class SnakeLadderDemo {
                public static void main(String[] args) {
                    // Create game with random setup (Medium difficulty)
                    Game game1 = GameFactory.createGame(
                        new RandomBoardStrat(Difficulty.MEDIUM), 
                        2
                    );
                    game1.play();
                    
                    // Or with standard classic setup
                    Game game2 = GameFactory.createGame(
                        new StandardStrat(),
                        4
                    );
                    game2.play();
                    
                    // Or with custom positions
                    CustomCountStrat custom = new CustomCountStrat();
                    custom.addSnakePos(50, 10);
                    custom.addSnakePos(75, 25);
                    custom.addLadderPos(5, 45);
                    custom.addLadderPos(30, 95);
                    
                    Game game3 = GameFactory.createGame(custom, 3);
                    game3.play();
                }
            }
            """,
            gsSpecificTwist: """
            **Goldman Sachs Twist: Multiplayer with Special Dice Rules**

            **Requirement:** Add special rules:
            1. Roll 6 → Extra turn
            2. Three consecutive 6s → Go back to start
            3. Power-ups at certain positions

            **Solution: Decorator for Rules + Command Pattern for Turns**

            ```java
            public class ExtendedRules extends StandardRules {
                private final Map<Player, Integer> consecutiveSixes = new HashMap<>();
                
                @Override
                public TurnResult processTurn(Player player, int diceValue) {
                    if (diceValue == 6) {
                        int count = consecutiveSixes.merge(player, 1, Integer::sum);
                        
                        if (count >= 3) {
                            // Three 6s - reset to start
                            consecutiveSixes.put(player, 0);
                            player.setPos(1);
                            return new TurnResult(false, "Three 6s! Back to start!");
                        }
                        
                        // Bonus turn
                        return new TurnResult(true, "Rolled 6! Extra turn!");
                    } else {
                        consecutiveSixes.put(player, 0);
                        return super.processTurn(player, diceValue);
                    }
                }
            }

            // Power-up entities
            public class PowerUp extends BoardEntity {
                private final PowerUpType type;  // DOUBLE_ROLL, TELEPORT, SHIELD
                
                @Override
                public int getEnd() {
                    return switch(type) {
                        case TELEPORT -> new Random().nextInt(90) + 10;
                        case DOUBLE_ROLL -> start;  // Stay, but next roll doubled
                        default -> start;
                    };
                }
            }
            ```

            **Why Strategy for SetupStrategy?**
            • Easy to add new board configurations
            • RandomBoardStrat for replayability
            • CustomCountStrat for custom game modes

            **Why Deque for Players?**
            • O(1) poll and add for turn rotation
            • Natural queue behavior for player order
            """
        )
    }
}
