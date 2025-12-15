//
//  AirTrafficLLD.swift
//  DevAscent
//
//  Air Traffic Control LLD Problem
//

import Foundation

struct AirTrafficLLD {
    static func create() -> LLDProblem {
        return LLDProblem(
            title: "Air Traffic Control System",
            requirements: """
            **Core Domain Requirements:**
            • **Flight Management:** Track flights with priority levels
            • **Runway Management:** Allocate/release runways with state tracking
            • **Queue Management:** Priority-based landing/takeoff queues
            • **Weather Handling:** Delay operations based on weather
            • **Collision Avoidance:** Ensure safe runway allocation
            • **Notifications:** Alert observers on flight events

            **Design Patterns (Mandatory):**
            • **Singleton Pattern:** ATCTower as central controller
            • **Command Pattern:** FlightCommand (Land, Takeoff, Hold, Divert)
            • **State Pattern:** RunwayState (Available, Occupied, Maintenance)
            • **Strategy Pattern:** SchedulingStrategy for queue processing
            • **Observer Pattern:** Notify airlines/ground crew on events
            • **Factory Pattern:** FlightFactory for flight creation

            **Priority Levels:**
            • EMERGENCY (0) - Medical, fuel critical
            • INTERNATIONAL (1) - Long-haul flights
            • DOMESTIC (2) - Short-haul flights
            """,
            solutionStrategy: """
            **Architecture:**

            **A. Central Controller (Singleton):**
            • ATCTower - Singleton managing all operations
            • Holds RunwayManager, FlightQueue, WeatherService

            **B. Command Pattern (Flight Operations):**
            • FlightCommand (Interface) - execute(), undo()
            • LandCommand, TakeoffCommand, HoldCommand, DivertCommand
            • CommandHistory for undo operations

            **C. State Pattern (Runway Lifecycle):**
            • RunwayState (Interface) - allocate(), release(), maintain()
            • AvailableState, OccupiedState, MaintenanceState
            • State transitions validated by state objects

            **D. Strategy Pattern (Scheduling):**
            • SchedulingStrategy - selectNext(queue)
            • PriorityStrategy - Strictly by priority
            • FuelAwareStrategy - Consider fuel levels
            • WeatherAwareStrategy - Adjust for conditions

            **E. Observer Pattern (Notifications):**
            • ATCObserver - onFlightEvent(event)
            • AirlineNotifier, GroundCrewNotifier, RadarDisplay

            **F. Domain Models:**
            • Flight - flightNumber, priority, status, aircraft
            • Runway - id, state, currentFlight
            • Aircraft - type, fuelLevel, capacity
            """,
            mermaidGraph: """
            classDiagram
                class ATCDemo {
                    +main(args)
                }
                class ATCTower {
                    -static ATCTower instance
                    -RunwayManager runwayMgr
                    -FlightQueue flightQueue
                    -WeatherService weather
                    -List observers
                    +getInstance()
                    +requestLanding(Flight)
                    +requestTakeoff(Flight)
                    +executeCommand(FlightCommand)
                    +addObserver(ATCObserver)
                    +notify(FlightEvent)
                }
                class FlightQueue {
                    -PriorityQueue landingQueue
                    -PriorityQueue takeoffQueue
                    -SchedulingStrategy strategy
                    +enqueue(Flight, QueueType)
                    +dequeue(QueueType)
                    +setStrategy(SchedulingStrategy)
                }
                class RunwayManager {
                    -List runways
                    +findAvailable()
                    +allocate(Runway, Flight)
                    +release(Runway)
                    +getStatus()
                }
                class Runway {
                    -String id
                    -RunwayState state
                    -Flight currentFlight
                    +allocate(Flight)
                    +release()
                    +maintain()
                    +setState(RunwayState)
                }
                class RunwayState {
                    +allocate(Runway, Flight)
                    +release(Runway)
                    +maintain(Runway)
                }
                class AvailableState {
                    +allocate(Runway, Flight)
                    +release(Runway)
                    +maintain(Runway)
                }
                class OccupiedState {
                    +allocate(Runway, Flight)
                    +release(Runway)
                    +maintain(Runway)
                }
                class MaintenanceState {
                    +allocate(Runway, Flight)
                    +release(Runway)
                    +maintain(Runway)
                }
                class Flight {
                    -String flightNumber
                    -FlightPriority priority
                    -FlightStatus status
                    -Aircraft aircraft
                    +getPriority()
                    +getStatus()
                }
                class FlightFactory {
                    +createFlight(String, FlightPriority, Aircraft)
                }
                class Aircraft {
                    -String type
                    -int fuelLevel
                    -int capacity
                }
                class FlightPriority {
                    EMERGENCY
                    INTERNATIONAL
                    DOMESTIC
                }
                class FlightStatus {
                    APPROACHING
                    HOLDING
                    LANDING
                    LANDED
                    TAXIING
                    DEPARTED
                }
                class FlightCommand {
                    +execute()
                    +undo()
                }
                class LandCommand {
                    -Flight flight
                    -Runway runway
                    +execute()
                    +undo()
                }
                class TakeoffCommand {
                    -Flight flight
                    -Runway runway
                    +execute()
                    +undo()
                }
                class HoldCommand {
                    -Flight flight
                    +execute()
                    +undo()
                }
                class DivertCommand {
                    -Flight flight
                    -String alternateAirport
                    +execute()
                    +undo()
                }
                class CommandHistory {
                    -Stack commands
                    +push(FlightCommand)
                    +undo()
                }
                class SchedulingStrategy {
                    +selectNext(PriorityQueue)
                }
                class PriorityStrategy {
                    +selectNext(PriorityQueue)
                }
                class FuelAwareStrategy {
                    +selectNext(PriorityQueue)
                }
                class WeatherAwareStrategy {
                    -WeatherService weather
                    +selectNext(PriorityQueue)
                }
                class ATCObserver {
                    +onFlightEvent(FlightEvent)
                }
                class AirlineNotifier {
                    +onFlightEvent(FlightEvent)
                }
                class GroundCrewNotifier {
                    +onFlightEvent(FlightEvent)
                }
                class RadarDisplay {
                    +onFlightEvent(FlightEvent)
                }
                class WeatherService {
                    +getCurrentConditions()
                    +isSafeForOperations()
                }
                class FlightEvent {
                    -Flight flight
                    -EventType type
                    -Instant timestamp
                }
                ATCDemo --> ATCTower
                ATCTower --> RunwayManager
                ATCTower --> FlightQueue
                ATCTower --> WeatherService
                ATCTower --> ATCObserver
                ATCTower --> FlightCommand
                ATCTower --> CommandHistory
                RunwayManager --> Runway
                Runway --> RunwayState
                Runway --> Flight
                RunwayState <|-- AvailableState
                RunwayState <|-- OccupiedState
                RunwayState <|-- MaintenanceState
                FlightQueue --> SchedulingStrategy
                FlightQueue --> Flight
                SchedulingStrategy <|-- PriorityStrategy
                SchedulingStrategy <|-- FuelAwareStrategy
                SchedulingStrategy <|-- WeatherAwareStrategy
                WeatherAwareStrategy --> WeatherService
                FlightFactory --> Flight
                Flight --> Aircraft
                Flight --> FlightPriority
                Flight --> FlightStatus
                FlightCommand <|-- LandCommand
                FlightCommand <|-- TakeoffCommand
                FlightCommand <|-- HoldCommand
                FlightCommand <|-- DivertCommand
                LandCommand --> Flight
                LandCommand --> Runway
                TakeoffCommand --> Flight
                TakeoffCommand --> Runway
                HoldCommand --> Flight
                DivertCommand --> Flight
                CommandHistory --> FlightCommand
                ATCObserver <|.. AirlineNotifier
                ATCObserver <|.. GroundCrewNotifier
                ATCObserver <|.. RadarDisplay
                FlightEvent --> Flight
            """,
            codeSnippet: """
            // ═══════════════════════════════════════════════════════════════
            // FILE: state/RunwayState.java (State Pattern)
            // ═══════════════════════════════════════════════════════════════
            public interface RunwayState {
                void allocate(Runway runway, Flight flight);
                void release(Runway runway);
                void maintain(Runway runway);
            }

            public class AvailableState implements RunwayState {
                @Override
                public void allocate(Runway runway, Flight flight) {
                    runway.setCurrentFlight(flight);
                    runway.setState(new OccupiedState());
                    System.out.println("Runway " + runway.getId() + " allocated to " + flight.getFlightNumber());
                }
                
                @Override
                public void release(Runway runway) {
                    throw new IllegalStateException("Runway already available");
                }
                
                @Override
                public void maintain(Runway runway) {
                    runway.setState(new MaintenanceState());
                    System.out.println("Runway " + runway.getId() + " under maintenance");
                }
            }

            public class OccupiedState implements RunwayState {
                @Override
                public void allocate(Runway runway, Flight flight) {
                    throw new IllegalStateException("Runway occupied by " + runway.getCurrentFlight());
                }
                
                @Override
                public void release(Runway runway) {
                    Flight completed = runway.getCurrentFlight();
                    runway.setCurrentFlight(null);
                    runway.setState(new AvailableState());
                    System.out.println("Runway " + runway.getId() + " released from " + completed.getFlightNumber());
                }
                
                @Override
                public void maintain(Runway runway) {
                    throw new IllegalStateException("Cannot maintain occupied runway");
                }
            }

            // ═══════════════════════════════════════════════════════════════
            // FILE: command/FlightCommand.java (Command Pattern)
            // ═══════════════════════════════════════════════════════════════
            public interface FlightCommand {
                void execute();
                void undo();
            }

            public class LandCommand implements FlightCommand {
                private final Flight flight;
                private final Runway runway;
                
                public LandCommand(Flight flight, Runway runway) {
                    this.flight = flight;
                    this.runway = runway;
                }
                
                @Override
                public void execute() {
                    runway.allocate(flight);
                    flight.setStatus(FlightStatus.LANDING);
                    System.out.println("✈️ " + flight.getFlightNumber() + " landing on Runway " + runway.getId());
                }
                
                @Override
                public void undo() {
                    runway.release();
                    flight.setStatus(FlightStatus.HOLDING);
                    System.out.println("⏪ " + flight.getFlightNumber() + " landing aborted");
                }
            }

            public class HoldCommand implements FlightCommand {
                private final Flight flight;
                private final FlightStatus previousStatus;
                
                public HoldCommand(Flight flight) {
                    this.flight = flight;
                    this.previousStatus = flight.getStatus();
                }
                
                @Override
                public void execute() {
                    flight.setStatus(FlightStatus.HOLDING);
                    System.out.println("⏸️ " + flight.getFlightNumber() + " holding pattern");
                }
                
                @Override
                public void undo() {
                    flight.setStatus(previousStatus);
                }
            }

            // ═══════════════════════════════════════════════════════════════
            // FILE: strategy/SchedulingStrategy.java (Strategy Pattern)
            // ═══════════════════════════════════════════════════════════════
            public interface SchedulingStrategy {
                Flight selectNext(PriorityQueue<Flight> queue);
            }

            public class PriorityStrategy implements SchedulingStrategy {
                @Override
                public Flight selectNext(PriorityQueue<Flight> queue) {
                    return queue.poll();  // Already sorted by priority
                }
            }

            public class FuelAwareStrategy implements SchedulingStrategy {
                @Override
                public Flight selectNext(PriorityQueue<Flight> queue) {
                    // Check for critically low fuel flights first
                    Optional<Flight> critical = queue.stream()
                        .filter(f -> f.getAircraft().getFuelLevel() < 15)
                        .findFirst();
                    
                    if (critical.isPresent()) {
                        queue.remove(critical.get());
                        return critical.get();
                    }
                    return queue.poll();
                }
            }

            public class WeatherAwareStrategy implements SchedulingStrategy {
                private final WeatherService weather;
                
                public WeatherAwareStrategy(WeatherService weather) {
                    this.weather = weather;
                }
                
                @Override
                public Flight selectNext(PriorityQueue<Flight> queue) {
                    if (!weather.isSafeForOperations()) {
                        return null;  // Hold all flights
                    }
                    // In poor visibility, prioritize larger aircraft
                    if (weather.getVisibility() < 500) {
                        return queue.stream()
                            .filter(f -> f.getAircraft().hasILS())
                            .findFirst()
                            .orElse(queue.poll());
                    }
                    return queue.poll();
                }
            }

            // ═══════════════════════════════════════════════════════════════
            // FILE: observer/ATCObserver.java (Observer Pattern)
            // ═══════════════════════════════════════════════════════════════
            public interface ATCObserver {
                void onFlightEvent(FlightEvent event);
            }

            public class AirlineNotifier implements ATCObserver {
                @Override
                public void onFlightEvent(FlightEvent event) {
                    System.out.println("📢 Airline notified: " + event.getFlight().getFlightNumber() + 
                        " - " + event.getType());
                }
            }

            public class GroundCrewNotifier implements ATCObserver {
                @Override
                public void onFlightEvent(FlightEvent event) {
                    if (event.getType() == EventType.LANDING) {
                        System.out.println("🛠️ Ground crew preparing for " + event.getFlight().getFlightNumber());
                    }
                }
            }

            public class RadarDisplay implements ATCObserver {
                @Override
                public void onFlightEvent(FlightEvent event) {
                    System.out.println("📡 Radar updated: " + event.getFlight().getFlightNumber() + 
                        " status=" + event.getFlight().getStatus());
                }
            }

            // ═══════════════════════════════════════════════════════════════
            // FILE: ATCTower.java (Singleton Facade)
            // ═══════════════════════════════════════════════════════════════
            public class ATCTower {
                private static volatile ATCTower instance;
                private final RunwayManager runwayMgr;
                private final FlightQueue flightQueue;
                private final WeatherService weather;
                private final List<ATCObserver> observers = new CopyOnWriteArrayList<>();
                private final CommandHistory history = new CommandHistory();
                
                private ATCTower() {
                    this.runwayMgr = new RunwayManager();
                    this.weather = new WeatherService();
                    this.flightQueue = new FlightQueue(new PriorityStrategy());
                }
                
                public static ATCTower getInstance() {
                    if (instance == null) {
                        synchronized (ATCTower.class) {
                            if (instance == null) {
                                instance = new ATCTower();
                            }
                        }
                    }
                    return instance;
                }
                
                public void requestLanding(Flight flight) {
                    flightQueue.enqueue(flight, QueueType.LANDING);
                    processLandingQueue();
                }
                
                private void processLandingQueue() {
                    Flight next = flightQueue.dequeue(QueueType.LANDING);
                    if (next == null) return;
                    
                    Runway runway = runwayMgr.findAvailable();
                    if (runway != null) {
                        FlightCommand cmd = new LandCommand(next, runway);
                        executeCommand(cmd);
                        notify(new FlightEvent(next, EventType.LANDING));
                    } else {
                        FlightCommand holdCmd = new HoldCommand(next);
                        executeCommand(holdCmd);
                        flightQueue.enqueue(next, QueueType.LANDING);  // Re-queue
                    }
                }
                
                public void executeCommand(FlightCommand cmd) {
                    cmd.execute();
                    history.push(cmd);
                }
                
                public void undoLastCommand() {
                    history.undo();
                }
                
                public void addObserver(ATCObserver observer) {
                    observers.add(observer);
                }
                
                private void notify(FlightEvent event) {
                    observers.forEach(obs -> obs.onFlightEvent(event));
                }
            }

            // ═══════════════════════════════════════════════════════════════
            // FILE: ATCDemo.java (Main)
            // ═══════════════════════════════════════════════════════════════
            public class ATCDemo {
                public static void main(String[] args) {
                    ATCTower tower = ATCTower.getInstance();
                    
                    // Add observers
                    tower.addObserver(new AirlineNotifier());
                    tower.addObserver(new GroundCrewNotifier());
                    tower.addObserver(new RadarDisplay());
                    
                    // Create flights
                    Aircraft a380 = new Aircraft("A380", 45, 550);
                    Flight emergency = FlightFactory.createFlight("MED911", FlightPriority.EMERGENCY, a380);
                    Flight international = FlightFactory.createFlight("BA287", FlightPriority.INTERNATIONAL, a380);
                    
                    // Request landings
                    tower.requestLanding(international);
                    tower.requestLanding(emergency);  // Will be prioritized!
                    
                    // Undo if needed
                    tower.undoLastCommand();
                }
            }
            """,
            gsSpecificTwist: """
            **Goldman Sachs Twist: Concurrent Emergency Handling**

            **Requirement:** Handle multiple simultaneous emergencies on limited runways.

            **Solution: Preemption + Circuit Breaker**

            ```java
            public class EmergencyPreemptionService {
                private final ATCTower tower;
                
                public void handleEmergency(Flight emergency) {
                    // 1. Find lowest priority occupied runway
                    Runway preemptible = tower.getRunwayMgr().getOccupiedRunways()
                        .stream()
                        .filter(r -> r.getCurrentFlight().getPriority().getValue() > 0)
                        .min(Comparator.comparing(r -> r.getCurrentFlight().getPriority()))
                        .orElse(null);
                    
                    if (preemptible != null) {
                        // 2. Preempt: Abort current landing, send to holding
                        Flight bumped = preemptible.getCurrentFlight();
                        tower.executeCommand(new HoldCommand(bumped));
                        tower.executeCommand(new LandCommand(emergency, preemptible));
                        
                        // 3. Re-queue bumped flight with higher priority boost
                        bumped.boostPriority();
                        tower.getFlightQueue().enqueue(bumped, QueueType.LANDING);
                    }
                }
            }

            // Circuit breaker for weather conditions
            public class WeatherCircuitBreaker {
                private enum State { CLOSED, OPEN, HALF_OPEN }
                private State state = State.CLOSED;
                private int failureCount = 0;
                
                public boolean canOperate() {
                    if (state == State.OPEN) {
                        return false;  // All operations suspended
                    }
                    return weather.isSafeForOperations();
                }
            }
            ```

            **Why Command Pattern?**
            • Undo capability for aborted landings
            • Command history for audit trail
            • Batch processing of commands

            **Why State Pattern for Runways?**
            • Invalid state transitions prevented at compile time
            • Each state knows its valid transitions
            • Easy to add new states (Emergency, Closed)
            """
        )
    }
}
