//
//  CarRentalLLD.swift
//  DevAscent
//
//  Car Rental System LLD Problem
//

import Foundation

struct CarRentalLLD {
    static func create() -> LLDProblem {
        return LLDProblem(
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
        )
    }
}
