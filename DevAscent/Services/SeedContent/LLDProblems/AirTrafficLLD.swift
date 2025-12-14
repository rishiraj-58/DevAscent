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
        )
    }
}
