//
//  ArsenalView.swift
//  DevAscent
//
//  The Knowledge Base - Drill, Blueprints, Vault
//  Created by Rishiraj on 13/12/24.
//

import SwiftUI
import SwiftData

// MARK: - Arsenal Mode

enum ArsenalMode: String, CaseIterable {
    case drill = "Drill"
    case blueprints = "Blueprints"
    case vault = "Vault"
}

// MARK: - Arsenal View

struct ArsenalView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selectedMode: ArsenalMode = .drill
    
    var body: some View {
        ZStack {
            Color.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header with mode picker
                headerView
                
                // Content based on selected mode
                switch selectedMode {
                case .drill:
                    DrillModeView()
                case .blueprints:
                    BlueprintsModeView()
                case .vault:
                    VaultModeView()
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: loadGSIntel) {
                    HStack(spacing: 6) {
                        Image(systemName: "square.and.arrow.down.fill")
                        Text("Load GS Intel")
                            .font(.operatorLabel(11))
                    }
                    .foregroundColor(.primaryAccent)
                }
            }
        }
    }
    
    // MARK: - Header
    
    private var headerView: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("[ ARSENAL ]")
                        .font(.operatorLabel(12))
                        .foregroundColor(.primaryAccent)
                        .tracking(1.2)
                    
                    Text("Knowledge Base")
                        .font(.operatorHeader(28))
                        .foregroundColor(.neonText)
                }
                
                Spacer()
                
                // Load GS Intel Button
                Button(action: loadGSIntel) {
                    HStack(spacing: 6) {
                        Image(systemName: "square.and.arrow.down.fill")
                        Text("GS Intel")
                            .font(.operatorLabel(10))
                    }
                    .foregroundColor(.background)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.primaryAccent)
                    .cornerRadius(8)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            
            // Segmented Control
            Picker("Mode", selection: $selectedMode) {
                ForEach(ArsenalMode.allCases, id: \.self) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 20)
            .padding(.bottom, 12)
        }
        .background(Color.background)
    }
    
    // MARK: - Load GS Intel
    
    private func loadGSIntel() {
        // Delete all existing data first to avoid duplicates
        let existingPatterns = (try? modelContext.fetch(FetchDescriptor<DesignPattern>())) ?? []
        let existingCards = (try? modelContext.fetch(FetchDescriptor<Flashcard>())) ?? []
        let existingStories = (try? modelContext.fetch(FetchDescriptor<StarStory>())) ?? []
        
        for pattern in existingPatterns {
            modelContext.delete(pattern)
        }
        for card in existingCards {
            modelContext.delete(card)
        }
        for story in existingStories {
            modelContext.delete(story)
        }
        
        // Design Patterns - Complete Gang of Four (23 patterns)
        let patterns = [
            // =====================
            // CREATIONAL PATTERNS (5)
            // =====================
            DesignPattern(
                name: "Singleton",
                type: .creational,
                summary: "Ensures a class has only one instance with a global access point.",
                whenToUse: "Use for configuration managers, connection pools, logging, or caches. Be ready to discuss thread-safety and double-checked locking.",
                javaCode: """
                public class Singleton {
                    private static volatile Singleton instance;
                    private Singleton() {}
                    
                    public static Singleton getInstance() {
                        if (instance == null) {
                            synchronized (Singleton.class) {
                                if (instance == null) {
                                    instance = new Singleton();
                                }
                            }
                        }
                        return instance;
                    }
                }
                """
            ),
            DesignPattern(
                name: "Factory Method",
                type: .creational,
                summary: "Defines an interface for creating objects, letting subclasses decide which class to instantiate.",
                whenToUse: "Use when you don't know ahead of time what class you need. Perfect for 'Design a notification system' where email/SMS/push are created differently.",
                javaCode: """
                public abstract class NotificationFactory {
                    public abstract Notification createNotification();
                    
                    public void send(String message) {
                        Notification n = createNotification();
                        n.notify(message);
                    }
                }

                public class EmailFactory extends NotificationFactory {
                    public Notification createNotification() {
                        return new EmailNotification();
                    }
                }
                """
            ),
            DesignPattern(
                name: "Abstract Factory",
                type: .creational,
                summary: "Creates families of related objects without specifying concrete classes.",
                whenToUse: "Use when products must be compatible. Perfect for 'Design a cross-platform UI toolkit' with Windows/Mac button+checkbox families.",
                javaCode: """
                public interface GUIFactory {
                    Button createButton();
                    Checkbox createCheckbox();
                }

                public class WindowsFactory implements GUIFactory {
                    public Button createButton() { return new WindowsButton(); }
                    public Checkbox createCheckbox() { return new WindowsCheckbox(); }
                }
                """
            ),
            DesignPattern(
                name: "Builder",
                type: .creational,
                summary: "Constructs complex objects step by step, allowing different representations.",
                whenToUse: "Use when objects have many optional parameters. Perfect for 'Design a query builder' or 'Design a meal ordering system'.",
                javaCode: """
                public class User {
                    private final String name;    // required
                    private final int age;        // optional
                    private final String email;   // optional
                    
                    private User(Builder b) {
                        this.name = b.name;
                        this.age = b.age;
                        this.email = b.email;
                    }
                    
                    public static class Builder {
                        private final String name;
                        private int age = 0;
                        private String email = "";
                        
                        public Builder(String name) { this.name = name; }
                        public Builder age(int age) { this.age = age; return this; }
                        public Builder email(String e) { this.email = e; return this; }
                        public User build() { return new User(this); }
                    }
                }
                // Usage: new User.Builder("John").age(25).build();
                """
            ),
            DesignPattern(
                name: "Prototype",
                type: .creational,
                summary: "Creates new objects by cloning an existing object (prototype).",
                whenToUse: "Use when object creation is expensive. Perfect for 'Design a document editor' where you clone templates instead of creating from scratch.",
                javaCode: """
                public abstract class Shape implements Cloneable {
                    public int x, y;
                    public String color;
                    
                    public Shape clone() {
                        try {
                            return (Shape) super.clone();
                        } catch (CloneNotSupportedException e) {
                            return null;
                        }
                    }
                }

                // Usage
                Shape circle = new Circle(10, 20, "red");
                Shape copy = circle.clone();
                """
            ),
            
            // =====================
            // STRUCTURAL PATTERNS (7)
            // =====================
            DesignPattern(
                name: "Adapter",
                type: .structural,
                summary: "Allows incompatible interfaces to work together by wrapping one interface.",
                whenToUse: "Use for legacy code integration or third-party libraries. Perfect for 'Integrate a new payment gateway with existing checkout'.",
                javaCode: """
                // Existing interface
                public interface MediaPlayer {
                    void play(String filename);
                }

                // Incompatible interface
                public interface AdvancedPlayer {
                    void playVlc(String filename);
                    void playMp4(String filename);
                }

                // Adapter
                public class MediaAdapter implements MediaPlayer {
                    private AdvancedPlayer advancedPlayer;
                    
                    public void play(String filename) {
                        if (filename.endsWith(".vlc")) {
                            advancedPlayer.playVlc(filename);
                        } else if (filename.endsWith(".mp4")) {
                            advancedPlayer.playMp4(filename);
                        }
                    }
                }
                """
            ),
            DesignPattern(
                name: "Bridge",
                type: .structural,
                summary: "Separates abstraction from implementation so both can vary independently.",
                whenToUse: "Use when you have multiple dimensions of variation. Perfect for 'Design shapes with colors' where both can change independently.",
                javaCode: """
                // Implementation hierarchy
                public interface Color {
                    void applyColor();
                }

                // Abstraction hierarchy
                public abstract class Shape {
                    protected Color color;
                    
                    public Shape(Color color) {
                        this.color = color;
                    }
                    
                    abstract void draw();
                }

                public class Circle extends Shape {
                    public void draw() {
                        System.out.print("Drawing Circle in ");
                        color.applyColor();
                    }
                }
                """
            ),
            DesignPattern(
                name: "Composite",
                type: .structural,
                summary: "Composes objects into tree structures to represent part-whole hierarchies.",
                whenToUse: "Use for tree structures. Perfect for 'Design a file system' with files and folders, or 'Design an org chart'.",
                javaCode: """
                public interface FileComponent {
                    void showDetails();
                    int getSize();
                }

                public class File implements FileComponent {
                    private String name;
                    private int size;
                    public int getSize() { return size; }
                }

                public class Folder implements FileComponent {
                    private List<FileComponent> children = new ArrayList<>();
                    
                    public void add(FileComponent c) { children.add(c); }
                    
                    public int getSize() {
                        return children.stream()
                            .mapToInt(FileComponent::getSize)
                            .sum();
                    }
                }
                """
            ),
            DesignPattern(
                name: "Decorator",
                type: .structural,
                summary: "Adds behavior to objects dynamically by wrapping them.",
                whenToUse: "Use to add features without subclassing. Perfect for 'Design a coffee ordering system' with milk, sugar, whip add-ons.",
                javaCode: """
                public interface Coffee {
                    double getCost();
                    String getDescription();
                }

                public class SimpleCoffee implements Coffee {
                    public double getCost() { return 2.0; }
                    public String getDescription() { return "Coffee"; }
                }

                public class MilkDecorator implements Coffee {
                    private Coffee coffee;
                    public MilkDecorator(Coffee c) { this.coffee = c; }
                    public double getCost() { return coffee.getCost() + 0.5; }
                    public String getDescription() { 
                        return coffee.getDescription() + ", Milk"; 
                    }
                }
                // Usage: new MilkDecorator(new SimpleCoffee())
                """
            ),
            DesignPattern(
                name: "Facade",
                type: .structural,
                summary: "Provides a simplified interface to a complex subsystem.",
                whenToUse: "Use to hide complexity. Perfect for 'Design a home theater system' with one remote controlling TV, speakers, lights.",
                javaCode: """
                public class HomeTheaterFacade {
                    private TV tv;
                    private SoundSystem sound;
                    private Lights lights;
                    
                    public void watchMovie(String movie) {
                        lights.dim(10);
                        tv.on();
                        sound.on();
                        sound.setVolume(5);
                        tv.play(movie);
                    }
                    
                    public void endMovie() {
                        lights.on();
                        tv.off();
                        sound.off();
                    }
                }
                """
            ),
            DesignPattern(
                name: "Flyweight",
                type: .structural,
                summary: "Shares common state between multiple objects to save memory.",
                whenToUse: "Use when you have millions of similar objects. Perfect for 'Design a text editor' sharing font/size for each character.",
                javaCode: """
                public class CharacterFlyweight {
                    private final char symbol;      // intrinsic (shared)
                    private final String font;      // intrinsic (shared)
                    
                    public void display(int x, int y) {  // x,y are extrinsic
                        // render character at position
                    }
                }

                public class FlyweightFactory {
                    private Map<String, CharacterFlyweight> cache = new HashMap<>();
                    
                    public CharacterFlyweight get(char c, String font) {
                        String key = c + font;
                        if (!cache.containsKey(key)) {
                            cache.put(key, new CharacterFlyweight(c, font));
                        }
                        return cache.get(key);
                    }
                }
                """
            ),
            DesignPattern(
                name: "Proxy",
                type: .structural,
                summary: "Provides a surrogate or placeholder for another object to control access.",
                whenToUse: "Use for lazy loading, access control, or caching. Perfect for 'Design an image gallery' that loads images on demand.",
                javaCode: """
                public interface Image {
                    void display();
                }

                public class RealImage implements Image {
                    private String filename;
                    
                    public RealImage(String f) {
                        this.filename = f;
                        loadFromDisk();  // expensive
                    }
                    
                    private void loadFromDisk() { /* heavy operation */ }
                    public void display() { /* show image */ }
                }

                public class ImageProxy implements Image {
                    private RealImage realImage;
                    private String filename;
                    
                    public void display() {
                        if (realImage == null) {
                            realImage = new RealImage(filename);  // lazy load
                        }
                        realImage.display();
                    }
                }
                """
            ),
            
            // =====================
            // BEHAVIORAL PATTERNS (11)
            // =====================
            DesignPattern(
                name: "Strategy",
                type: .behavioral,
                summary: "Defines a family of algorithms and makes them interchangeable at runtime.",
                whenToUse: "Use for dynamic algorithm selection. Perfect for 'Design a payment system' with credit card, PayPal, crypto options.",
                javaCode: """
                public interface PaymentStrategy {
                    void pay(double amount);
                }

                public class CreditCard implements PaymentStrategy {
                    public void pay(double amount) {
                        // charge credit card
                    }
                }

                public class PaymentContext {
                    private PaymentStrategy strategy;
                    
                    public void setStrategy(PaymentStrategy s) {
                        this.strategy = s;
                    }
                    
                    public void checkout(double amount) {
                        strategy.pay(amount);
                    }
                }
                """
            ),
            DesignPattern(
                name: "Observer",
                type: .behavioral,
                summary: "Defines a subscription mechanism to notify multiple objects about events.",
                whenToUse: "Use for event-driven systems. Perfect for 'Design a stock ticker' or 'Design a notification system'.",
                javaCode: """
                public interface Observer {
                    void update(double price);
                }

                public class Stock {
                    private List<Observer> observers = new ArrayList<>();
                    private double price;
                    
                    public void attach(Observer o) { observers.add(o); }
                    public void detach(Observer o) { observers.remove(o); }
                    
                    public void setPrice(double price) {
                        this.price = price;
                        notifyObservers();
                    }
                    
                    private void notifyObservers() {
                        for (Observer o : observers) {
                            o.update(price);
                        }
                    }
                }
                """
            ),
            DesignPattern(
                name: "Command",
                type: .behavioral,
                summary: "Encapsulates a request as an object, allowing parameterization and queuing.",
                whenToUse: "Use for undo/redo, task queues, or macro recording. Perfect for 'Design a text editor with undo'.",
                javaCode: """
                public interface Command {
                    void execute();
                    void undo();
                }

                public class InsertTextCommand implements Command {
                    private Editor editor;
                    private String text;
                    private int position;
                    
                    public void execute() {
                        editor.insert(position, text);
                    }
                    
                    public void undo() {
                        editor.delete(position, text.length());
                    }
                }

                public class CommandHistory {
                    private Stack<Command> history = new Stack<>();
                    
                    public void execute(Command cmd) {
                        cmd.execute();
                        history.push(cmd);
                    }
                    
                    public void undo() {
                        if (!history.isEmpty()) {
                            history.pop().undo();
                        }
                    }
                }
                """
            ),
            DesignPattern(
                name: "State",
                type: .behavioral,
                summary: "Allows an object to alter its behavior when its internal state changes.",
                whenToUse: "Use when behavior depends on state. Perfect for 'Design a vending machine' or 'Design an order status system'.",
                javaCode: """
                public interface OrderState {
                    void next(Order order);
                    void prev(Order order);
                    void printStatus();
                }

                public class Order {
                    private OrderState state = new OrderedState();
                    
                    public void setState(OrderState state) {
                        this.state = state;
                    }
                    
                    public void nextState() { state.next(this); }
                    public void prevState() { state.prev(this); }
                }

                public class OrderedState implements OrderState {
                    public void next(Order o) { o.setState(new ShippedState()); }
                    public void prev(Order o) { /* can't go back */ }
                    public void printStatus() { System.out.println("Ordered"); }
                }
                """
            ),
            DesignPattern(
                name: "Template Method",
                type: .behavioral,
                summary: "Defines the skeleton of an algorithm, letting subclasses override specific steps.",
                whenToUse: "Use when algorithms share structure but differ in details. Perfect for 'Design a data parser' for CSV/JSON/XML.",
                javaCode: """
                public abstract class DataParser {
                    // Template method
                    public final void parse(String file) {
                        openFile(file);
                        extractData();
                        parseData();
                        closeFile();
                    }
                    
                    // Common steps
                    private void openFile(String file) { /* ... */ }
                    private void closeFile() { /* ... */ }
                    
                    // Abstract steps for subclasses
                    protected abstract void extractData();
                    protected abstract void parseData();
                }

                public class CSVParser extends DataParser {
                    protected void extractData() { /* CSV logic */ }
                    protected void parseData() { /* CSV parsing */ }
                }
                """
            ),
            DesignPattern(
                name: "Iterator",
                type: .behavioral,
                summary: "Provides a way to access elements of a collection sequentially without exposing its structure.",
                whenToUse: "Use to traverse collections. Already built into Java (Iterable/Iterator). Know how to implement custom iterators.",
                javaCode: """
                public interface Iterator<T> {
                    boolean hasNext();
                    T next();
                }

                public class TreeIterator implements Iterator<Node> {
                    private Stack<Node> stack = new Stack<>();
                    
                    public TreeIterator(Node root) {
                        if (root != null) stack.push(root);
                    }
                    
                    public boolean hasNext() {
                        return !stack.isEmpty();
                    }
                    
                    public Node next() {
                        Node node = stack.pop();
                        if (node.right != null) stack.push(node.right);
                        if (node.left != null) stack.push(node.left);
                        return node;
                    }
                }
                """
            ),
            DesignPattern(
                name: "Mediator",
                type: .behavioral,
                summary: "Defines an object that encapsulates how a set of objects interact.",
                whenToUse: "Use to reduce chaotic dependencies. Perfect for 'Design a chat room' where users don't reference each other directly.",
                javaCode: """
                public interface ChatMediator {
                    void sendMessage(String msg, User user);
                    void addUser(User user);
                }

                public class ChatRoom implements ChatMediator {
                    private List<User> users = new ArrayList<>();
                    
                    public void addUser(User user) {
                        users.add(user);
                    }
                    
                    public void sendMessage(String msg, User sender) {
                        for (User u : users) {
                            if (u != sender) {
                                u.receive(msg);
                            }
                        }
                    }
                }
                """
            ),
            DesignPattern(
                name: "Memento",
                type: .behavioral,
                summary: "Captures and externalizes an object's internal state so it can be restored later.",
                whenToUse: "Use for snapshots/checkpoints. Perfect for 'Design a text editor with save states' or 'Design a game save system'.",
                javaCode: """
                public class EditorMemento {
                    private final String content;
                    private final int cursorPosition;
                    
                    public EditorMemento(String c, int p) {
                        this.content = c;
                        this.cursorPosition = p;
                    }
                    // getters only, immutable
                }

                public class Editor {
                    private String content;
                    private int cursor;
                    
                    public EditorMemento save() {
                        return new EditorMemento(content, cursor);
                    }
                    
                    public void restore(EditorMemento m) {
                        this.content = m.getContent();
                        this.cursor = m.getCursor();
                    }
                }
                """
            ),
            DesignPattern(
                name: "Chain of Responsibility",
                type: .behavioral,
                summary: "Passes requests along a chain of handlers until one handles it.",
                whenToUse: "Use for processing pipelines. Perfect for 'Design a logging system' with DEBUG→INFO→ERROR levels.",
                javaCode: """
                public abstract class Logger {
                    protected int level;
                    protected Logger nextLogger;
                    
                    public void setNext(Logger next) {
                        this.nextLogger = next;
                    }
                    
                    public void log(int level, String message) {
                        if (this.level <= level) {
                            write(message);
                        }
                        if (nextLogger != null) {
                            nextLogger.log(level, message);
                        }
                    }
                    
                    protected abstract void write(String message);
                }
                // Chain: console → file → email
                """
            ),
            DesignPattern(
                name: "Visitor",
                type: .behavioral,
                summary: "Separates an algorithm from the object structure it operates on.",
                whenToUse: "Use when you need to add operations to classes without modifying them. Perfect for 'Design a document exporter' (PDF, HTML, XML).",
                javaCode: """
                public interface Visitor {
                    void visit(Circle c);
                    void visit(Rectangle r);
                }

                public interface Shape {
                    void accept(Visitor v);
                }

                public class Circle implements Shape {
                    public void accept(Visitor v) {
                        v.visit(this);
                    }
                }

                public class AreaCalculator implements Visitor {
                    private double totalArea = 0;
                    
                    public void visit(Circle c) {
                        totalArea += Math.PI * c.radius * c.radius;
                    }
                    
                    public void visit(Rectangle r) {
                        totalArea += r.width * r.height;
                    }
                }
                """
            ),
            DesignPattern(
                name: "Interpreter",
                type: .behavioral,
                summary: "Defines a representation for a grammar and an interpreter to evaluate sentences.",
                whenToUse: "Use for simple languages/expressions. Perfect for 'Design a rule engine' or 'Design a calculator'.",
                javaCode: """
                public interface Expression {
                    int interpret();
                }

                public class NumberExpression implements Expression {
                    private int number;
                    public int interpret() { return number; }
                }

                public class AddExpression implements Expression {
                    private Expression left, right;
                    
                    public AddExpression(Expression l, Expression r) {
                        this.left = l;
                        this.right = r;
                    }
                    
                    public int interpret() {
                        return left.interpret() + right.interpret();
                    }
                }
                // Usage: (5 + 3) = new AddExpression(new NumberExpr(5), new NumberExpr(3))
                """
            )
        ]
        
        // Flashcards
        let flashcards = [
            Flashcard(
                question: "How does HashMap work internally in Java 8+?",
                answer: "HashMap uses an array of buckets. Each bucket is a linked list (or TreeMap when >8 nodes). Hash code determines bucket index via (n-1) & hash. Load factor 0.75 triggers resize. Java 8+ converts to red-black tree for O(log n) worst case.",
                topic: .java
            ),
            Flashcard(
                question: "ReentrantLock vs synchronized - when to use each?",
                answer: "ReentrantLock: tryLock(), timed waits, interruptible, fairness policy, multiple conditions. synchronized: simpler syntax, automatic release, no external object needed. Use ReentrantLock for advanced locking needs.",
                topic: .java
            ),
            Flashcard(
                question: "What are the ACID properties?",
                answer: "Atomicity: All or nothing. Consistency: Valid state to valid state. Isolation: Concurrent txns don't interfere. Durability: Committed data survives crashes. Key for DB design interviews.",
                topic: .systemDesign
            ),
            Flashcard(
                question: "Explain the CAP theorem.",
                answer: "Consistency: All nodes see same data. Availability: Every request gets response. Partition tolerance: System works despite network splits. Can only guarantee 2 of 3. Choose CP (banks) or AP (social media).",
                topic: .systemDesign
            ),
            Flashcard(
                question: "What is the difference between Abstract Factory and Factory Method?",
                answer: "Factory Method: Single method to create one product. Abstract Factory: Multiple factory methods to create families of related products. Use Abstract Factory when products must be compatible.",
                topic: .lld
            )
        ]
        
        // STAR Stories
        let stories = [
            StarStory(
                title: "Conflict Resolution - Code Review Disagreement",
                situation: "During a critical sprint, a senior developer and I had conflicting approaches to implementing a caching layer.",
                task: "Needed to resolve the disagreement quickly without derailing the sprint or damaging the relationship.",
                action: "I scheduled a 1:1 meeting, actively listened to their concerns, presented data from performance benchmarks, and proposed a hybrid approach incorporating both ideas.",
                result: "We implemented the hybrid solution, which performed 40% better than either original approach. The senior dev became a mentor and advocate for my work.",
                tags: ["conflict", "teamwork", "leadership"]
            )
        ]
        
        // Insert all data
        for pattern in patterns {
            modelContext.insert(pattern)
        }
        for card in flashcards {
            modelContext.insert(card)
        }
        for story in stories {
            modelContext.insert(story)
        }
    }
}

// MARK: - Drill Mode View (Flashcards)

struct DrillModeView: View {
    @Query(sort: \Flashcard.nextReviewDate) private var allCards: [Flashcard]
    
    @State private var currentIndex = 0
    @State private var isFlipped = false
    
    // Filter due cards in computed property (predicate can't use Date())
    private var dueCards: [Flashcard] {
        allCards.filter { $0.isDue }
    }
    
    var body: some View {
        if dueCards.isEmpty {
            emptyState
        } else {
            VStack(spacing: 24) {
                // Progress indicator
                HStack {
                    Text("CARDS DUE: \(dueCards.count)")
                        .font(.operatorLabel(12))
                        .foregroundColor(.textSecondary)
                    
                    Spacer()
                    
                    if currentIndex < dueCards.count {
                        Text("\(currentIndex + 1) / \(dueCards.count)")
                            .font(.operatorLabel(12))
                            .foregroundColor(.neonText)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                
                // Card Stack
                if currentIndex < dueCards.count {
                    FlashcardDrillView(
                        card: dueCards[currentIndex],
                        isFlipped: $isFlipped,
                        onReset: { handleGrade(.reset) },
                        onHard: { handleGrade(.hard) },
                        onEasy: { handleGrade(.easy) }
                    )
                }
                
                Spacer()
            }
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            
            Image(systemName: "trophy.fill")
                .font(.system(size: 80))
                .foregroundColor(.primaryAccent)
            
            Text("Systems All Green")
                .font(.operatorHeader(24))
                .foregroundColor(.neonText)
            
            Text("No cards due for review.\nCheck back later, Operator.")
                .font(.subheadline)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
            
            Spacer()
        }
    }
    
    private enum Grade {
        case reset, hard, easy
    }
    
    private func handleGrade(_ grade: Grade) {
        guard currentIndex < dueCards.count else { return }
        let card = dueCards[currentIndex]
        
        switch grade {
        case .reset: card.markReset()
        case .hard: card.markHard()
        case .easy: card.markEasy()
        }
        
        withAnimation(.spring(response: 0.3)) {
            isFlipped = false
            if currentIndex < dueCards.count - 1 {
                currentIndex += 1
            } else {
                currentIndex = 0
            }
        }
    }
}

// MARK: - Flashcard Drill View

struct FlashcardDrillView: View {
    @Bindable var card: Flashcard
    @Binding var isFlipped: Bool
    let onReset: () -> Void
    let onHard: () -> Void
    let onEasy: () -> Void
    
    @State private var degrees: Double = 0
    
    var body: some View {
        VStack(spacing: 24) {
            // Card
            ZStack {
                // Back (Answer)
                answerCard
                    .rotation3DEffect(.degrees(degrees + 180), axis: (x: 0, y: 1, z: 0))
                    .opacity(degrees < -90 ? 1 : 0)
                
                // Front (Question)
                questionCard
                    .rotation3DEffect(.degrees(degrees), axis: (x: 0, y: 1, z: 0))
                    .opacity(degrees > -90 ? 1 : 0)
            }
            .onTapGesture {
                flipCard()
            }
            .padding(.horizontal, 20)
            
            // Grade Buttons (only visible when flipped)
            if isFlipped {
                gradeButtons
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
    }
    
    private var questionCard: some View {
        VStack(spacing: 16) {
            // Topic Badge
            HStack {
                Text(card.topicEnum.displayName.uppercased())
                    .font(.operatorLabel(10))
                    .foregroundColor(.neonText)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.neonText.opacity(0.2))
                    .cornerRadius(4)
                
                Spacer()
                
                // Mastery dots
                HStack(spacing: 3) {
                    ForEach(0..<5, id: \.self) { i in
                        Circle()
                            .fill(i < card.masteryLevel ? Color.primaryAccent : Color.border)
                            .frame(width: 8, height: 8)
                    }
                }
            }
            
            Spacer()
            
            Text(card.question)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            Spacer()
            
            HStack(spacing: 6) {
                Image(systemName: "hand.tap.fill")
                Text("Tap to reveal")
            }
            .font(.system(size: 14))
            .foregroundColor(.textSecondary)
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .frame(height: 300)
        .background(Color.cardBackground)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.border, lineWidth: 1)
        )
    }
    
    private var answerCard: some View {
        VStack(spacing: 16) {
            HStack {
                Text("ANSWER")
                    .font(.operatorLabel(10))
                    .foregroundColor(.primaryAccent)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.primaryAccent.opacity(0.2))
                    .cornerRadius(4)
                
                Spacer()
            }
            
            Spacer()
            
            ScrollView {
                Text(card.answer)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
            }
            
            Spacer()
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .frame(height: 300)
        .background(Color.cardBackground)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.primaryAccent.opacity(0.5), lineWidth: 1)
        )
    }
    
    private var gradeButtons: some View {
        HStack(spacing: 16) {
            // Reset (Red)
            Button(action: onReset) {
                VStack(spacing: 4) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 24))
                    Text("RESET")
                        .font(.operatorLabel(10))
                    Text("10 min")
                        .font(.system(size: 10))
                        .foregroundColor(.textSecondary)
                }
                .foregroundColor(.alertRed)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.alertRed.opacity(0.15))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.alertRed.opacity(0.3), lineWidth: 1)
                )
            }
            
            // Hard (Orange)
            Button(action: onHard) {
                VStack(spacing: 4) {
                    Image(systemName: "flame")
                        .font(.system(size: 24))
                    Text("HARD")
                        .font(.operatorLabel(10))
                    Text("1 day")
                        .font(.system(size: 10))
                        .foregroundColor(.textSecondary)
                }
                .foregroundColor(.statusOA)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.statusOA.opacity(0.15))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.statusOA.opacity(0.3), lineWidth: 1)
                )
            }
            
            // Easy (Green)
            Button(action: onEasy) {
                VStack(spacing: 4) {
                    Image(systemName: "checkmark.circle")
                        .font(.system(size: 24))
                    Text("EASY")
                        .font(.operatorLabel(10))
                    Text("3 days")
                        .font(.system(size: 10))
                        .foregroundColor(.textSecondary)
                }
                .foregroundColor(.primaryAccent)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.primaryAccent.opacity(0.15))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.primaryAccent.opacity(0.3), lineWidth: 1)
                )
            }
        }
        .padding(.horizontal, 20)
    }
    
    private func flipCard() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            degrees = isFlipped ? 0 : -180
            isFlipped.toggle()
        }
    }
}

// MARK: - Blueprints Mode View (Design Patterns)

struct BlueprintsModeView: View {
    @Query(sort: \DesignPattern.name) private var patterns: [DesignPattern]
    @State private var selectedPattern: DesignPattern?
    
    private var groupedPatterns: [PatternType: [DesignPattern]] {
        Dictionary(grouping: patterns) { $0.typeEnum }
    }
    
    var body: some View {
        if patterns.isEmpty {
            emptyState
        } else {
            ScrollView {
                LazyVStack(spacing: 24, pinnedViews: .sectionHeaders) {
                    ForEach(PatternType.allCases, id: \.self) { type in
                        if let typePatterns = groupedPatterns[type], !typePatterns.isEmpty {
                            Section {
                                ForEach(typePatterns) { pattern in
                                    PatternListRow(pattern: pattern)
                                        .onTapGesture {
                                            selectedPattern = pattern
                                        }
                                }
                            } header: {
                                HStack {
                                    Text(type.displayName.uppercased())
                                        .font(.operatorLabel(12))
                                        .foregroundColor(.neonText)
                                        .tracking(1.2)
                                    Spacer()
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 8)
                                .background(Color.background)
                            }
                        }
                    }
                }
                .padding(.vertical, 16)
            }
            .sheet(item: $selectedPattern) { pattern in
                PatternSchematicView(pattern: pattern)
            }
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(.textSecondary)
            
            Text("No Blueprints Loaded")
                .font(.operatorHeader(20))
                .foregroundColor(.neonText)
            
            Text("Tap 'Load GS Intel' to add\ndesign pattern references")
                .font(.subheadline)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
            
            Spacer()
        }
    }
}

// MARK: - Pattern List Row

struct PatternListRow: View {
    let pattern: DesignPattern
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "puzzlepiece.extension.fill")
                .font(.system(size: 24))
                .foregroundColor(.neonText)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(pattern.name)
                    .font(.operatorHeader(18))
                    .foregroundColor(.white)
                
                Text(pattern.summary)
                    .font(.system(size: 14))
                    .foregroundColor(.textSecondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundColor(.textSecondary)
        }
        .padding(16)
        .background(Color.cardBackground)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.border, lineWidth: 1)
        )
        .padding(.horizontal, 20)
    }
}

// MARK: - Pattern Schematic View (Detail)

struct PatternSchematicView: View {
    let pattern: DesignPattern
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Header
                        VStack(alignment: .leading, spacing: 8) {
                            Text(pattern.typeEnum.displayName.uppercased())
                                .font(.operatorLabel(11))
                                .foregroundColor(.textSecondary)
                                .tracking(1.0)
                            
                            Text(pattern.name)
                                .font(.operatorHeader(32))
                                .foregroundColor(.neonText)
                            
                            Text(pattern.summary)
                                .font(.system(size: 16))
                                .foregroundColor(.textSecondary)
                        }
                        
                        // Tactical Usage Box
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 8) {
                                Image(systemName: "target")
                                    .foregroundColor(.primaryAccent)
                                Text("TACTICAL USAGE")
                                    .font(.operatorLabel(12))
                                    .foregroundColor(.primaryAccent)
                            }
                            
                            Text(pattern.whenToUse)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.primaryAccent.opacity(0.15))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.primaryAccent.opacity(0.3), lineWidth: 2)
                        )
                        
                        // Code Block
                        if !pattern.javaCode.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack(spacing: 8) {
                                    Image(systemName: "chevron.left.forwardslash.chevron.right")
                                        .foregroundColor(.neonText)
                                    Text("JAVA IMPLEMENTATION")
                                        .font(.operatorLabel(12))
                                        .foregroundColor(.neonText)
                                }
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    Text(pattern.javaCode)
                                        .font(.system(size: 13, design: .monospaced))
                                        .foregroundColor(.white)
                                        .padding(16)
                                }
                                .background(Color(hex: "#161B22"))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.border, lineWidth: 1)
                                )
                            }
                        }
                    }
                    .padding(20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .foregroundColor(.neonText)
                }
            }
            .toolbarBackground(Color.cardBackground, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }
}

// MARK: - Vault Mode View (STAR Stories)

struct VaultModeView: View {
    @Query(sort: \StarStory.title) private var stories: [StarStory]
    @State private var selectedStory: StarStory?
    @State private var interviewMode = false
    
    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Interview Mode Toggle
            HStack {
                Text("INTERVIEW MODE")
                    .font(.operatorLabel(11))
                    .foregroundColor(.textSecondary)
                
                Spacer()
                
                Toggle("", isOn: $interviewMode)
                    .labelsHidden()
                    .tint(.primaryAccent)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            
            if stories.isEmpty {
                emptyState
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(stories) { story in
                            StoryCard(story: story, interviewMode: interviewMode)
                                .onTapGesture {
                                    selectedStory = story
                                }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)
                }
            }
        }
        .sheet(item: $selectedStory) { story in
            StoryEditorSheet(story: story)
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            
            Image(systemName: "doc.text")
                .font(.system(size: 60))
                .foregroundColor(.textSecondary)
            
            Text("Vault Empty")
                .font(.operatorHeader(20))
                .foregroundColor(.neonText)
            
            Text("Load GS Intel or add\nbehavioral STAR stories")
                .font(.subheadline)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
            
            Spacer()
        }
    }
}

// MARK: - Story Card

struct StoryCard: View {
    let story: StarStory
    let interviewMode: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(story.title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
                .lineLimit(2)
            
            if !interviewMode && !story.situation.isEmpty {
                Text(story.situation)
                    .font(.system(size: 12))
                    .foregroundColor(.textSecondary)
                    .lineLimit(3)
            }
            
            Spacer()
            
            // Tags
            if !story.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(story.tags, id: \.self) { tag in
                            Text(tag.uppercased())
                                .font(.system(size: 9, weight: .medium))
                                .foregroundColor(.neonText)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.neonText.opacity(0.2))
                                .cornerRadius(4)
                        }
                    }
                }
            }
        }
        .padding(16)
        .frame(height: interviewMode ? 100 : 160)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.cardBackground)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.border, lineWidth: 1)
        )
    }
}

// MARK: - Story Editor Sheet

struct StoryEditorSheet: View {
    @Bindable var story: StarStory
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Title
                        VStack(alignment: .leading, spacing: 8) {
                            Text("TITLE")
                                .font(.operatorLabel(11))
                                .foregroundColor(.textSecondary)
                            
                            TextField("Story Title", text: $story.title)
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(16)
                                .background(Color.cardBackground)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.border, lineWidth: 1)
                                )
                        }
                        
                        // STAR Fields
                        STARField(label: "SITUATION", text: $story.situation, placeholder: "Set the context...")
                        STARField(label: "TASK", text: $story.task, placeholder: "What was your responsibility?")
                        STARField(label: "ACTION", text: $story.action, placeholder: "What steps did you take?")
                        STARField(label: "RESULT", text: $story.result, placeholder: "What was the outcome?")
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Edit Story")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .foregroundColor(.primaryAccent)
                }
            }
            .toolbarBackground(Color.cardBackground, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }
}

// MARK: - STAR Field

struct STARField: View {
    let label: String
    @Binding var text: String
    let placeholder: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Circle()
                    .fill(labelColor)
                    .frame(width: 8, height: 8)
                
                Text(label)
                    .font(.operatorLabel(11))
                    .foregroundColor(labelColor)
            }
            
            TextEditor(text: $text)
                .font(.system(size: 15))
                .foregroundColor(.white)
                .scrollContentBackground(.hidden)
                .frame(minHeight: 80)
                .padding(12)
                .background(Color.cardBackground)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.border, lineWidth: 1)
                )
                .overlay(
                    Group {
                        if text.isEmpty {
                            Text(placeholder)
                                .font(.system(size: 15))
                                .foregroundColor(.textSecondary)
                                .padding(16)
                        }
                    },
                    alignment: .topLeading
                )
        }
    }
    
    private var labelColor: Color {
        switch label {
        case "SITUATION": return .neonText
        case "TASK": return .statusOA
        case "ACTION": return .statusInterview
        case "RESULT": return .primaryAccent
        default: return .textSecondary
        }
    }
}

#Preview {
    ArsenalView()
        .modelContainer(for: [
            DailyTask.self,
            JobApplication.self,
            Flashcard.self,
            DesignPattern.self,
            StarStory.self
        ], inMemory: true)
}
