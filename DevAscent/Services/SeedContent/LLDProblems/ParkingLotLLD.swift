//
//  ParkingLotLLD.swift
//  DevAscent
//
//  Parking Lot System LLD Problem
//

import Foundation

struct ParkingLotLLD {
    static func create() -> LLDProblem {
        return LLDProblem(
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
                
                class DisplayBoard {
                    -int floorNumber
                    -Map availableSpots
                    +onEvent(ParkingEvent) void
                    +display() void
                }
                
                ParkingLotSystem *-- ParkingFloor
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
                ParkingAllocationStrategy <|.. LowestFloorFirstStrategy
                ParkingAllocationStrategy <|.. NearestElevatorStrategy
                PricingStrategy <|.. HourlyPricingStrategy
            """,
            codeSnippet: """
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

            // ═══════════════════════════════════════════════════════════════
            // FILE: decorator/EVChargingDecorator.java
            // ═══════════════════════════════════════════════════════════════
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
                    
                    Ticket ticket = new Ticket(
                        UUID.randomUUID().toString(),
                        vehicle, spot, gate, LocalDateTime.now()
                    );
                    activeTickets.put(ticket.getTicketId(), ticket);
                    
                    notifyObservers(new ParkingEvent(EventType.ENTRY, spot));
                    return ticket;
                }
            }
            """,
            gsSpecificTwist: """
            **Goldman Sachs Twist: Subscription Model for Corporate Reserved Spots**

            Requirement: Corporate employees have reserved spots that cannot be taken by regular customers.

            **Solution: Proxy Pattern + ReservationStrategy**

            The **Proxy Pattern** intercepts spot access and checks reservation status before allocation.

            ```java
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
            ```

            **Key Design Decisions:**
            1. Proxy wraps real spot - no changes to core ParkingSpot
            2. Strategy filters reserved spots for regular customers
            3. Subscription service validates corporate vehicles
            4. Time-based reservations (9AM-6PM weekdays)
            """
        )
    }
}
