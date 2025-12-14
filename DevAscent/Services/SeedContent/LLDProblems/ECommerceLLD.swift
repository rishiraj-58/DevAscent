//
//  ECommerceLLD.swift
//  DevAscent
//
//  E-Commerce Checkout LLD Problem
//

import Foundation

struct ECommerceLLD {
    static func create() -> LLDProblem {
        return LLDProblem(
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
                PaymentStrategy <|.. CreditCardPayment
                PaymentStrategy <|.. UPIPayment
                PaymentStrategy <|.. WalletPayment
                PaymentStrategy <|.. PayPalPayment
                DiscountDecorator <|-- PercentageDiscount
                DiscountDecorator <|-- FlatDiscount
                DiscountDecorator <|-- CouponDiscount
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
        )
    }
}
