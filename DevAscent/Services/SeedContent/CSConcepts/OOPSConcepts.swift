//
//  OOPSConcepts.swift
//  DevAscent
//
//  Object-Oriented Programming & SOLID CS Concepts
//

import Foundation

struct OOPSConcepts {
    static func all() -> [CSConcept] {
        return [
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
            )
        ]
    }
}
