//
//  QuickCommerceLLD.swift
//  DevAscent
//
//  Quick Commerce LLD (Zepto/Blinkit Style)
//

import Foundation

struct QuickCommerceLLD {
    static func create() -> LLDProblem {
        return LLDProblem(
            title: "Quick Commerce (10-Min Delivery)",
            requirements: """
            **Core Domain Requirements:**
            • **Dark Stores:** Micro-warehouses mapping users by geolocation
            • **Inventory Management:** Prevent overselling with concurrent purchases
            • **Order Lifecycle:** Placed → Accepted → Packed → Out For Delivery → Delivered
            • **Delivery Assignment:** Assign to nearest available rider
            • **Cart Management:** Add items, update quantities, checkout

            **Critical Concurrency Challenge:**
            100 users try to buy the last "Milk Packet" at the exact same millisecond.
            Solution: Optimistic Locking (versioning) or Pessimistic Locking (synchronized/ReentrantLock)

            **Design Patterns (Mandatory):**
            • **Singleton:** InventoryManager for global store states
            • **Strategy Pattern:** DeliveryAssignmentStrategy, PricingStrategy
            • **Observer Pattern:** NotificationService observes Order state changes
            • **State Pattern:** Order status transitions with invalid transition prevention
            • **Factory Pattern:** Payment objects, Notification types
            """,
            solutionStrategy: """
            **Architecture:**
            1. **Dark Store Service:** Geolocation-based user-to-store mapping
            2. **Inventory Service:** Thread-safe stock management with locking
            3. **Order Service:** State machine for order lifecycle
            4. **Delivery Service:** Rider assignment with strategy pattern
            5. **Notification Service:** Observer for real-time updates

            **Concurrency Solution (Optimistic Locking):**
            ```java
            @Version
            private Long version;
            
            public boolean reserveStock(String productId, int qty) {
                // CAS operation with version check
                // Retry on OptimisticLockException
            }
            ```

            **Key Design Decisions:**
            • Saga pattern for distributed transactions (inventory + payment)
            • Circuit breaker for rider service failures
            • Event sourcing for order audit trail
            """,
            mermaidGraph: """
            classDiagram
                class ZeptoApp {
                    <<Singleton>>
                    -InventoryManager inventoryManager
                    -OrderService orderService
                    -DeliveryService deliveryService
                    +placeOrder(userId, cart) Order
                    +trackOrder(orderId) OrderStatus
                }

                class User {
                    -String userId
                    -String name
                    -Location location
                    -Cart cart
                    +addToCart(product, qty) void
                    +checkout() Order
                }

                class DarkStore {
                    -String storeId
                    -String name
                    -Location location
                    -double serviceRadius
                    -Inventory inventory
                    +isServicable(location) boolean
                    +getDistance(location) double
                }

                class Inventory {
                    -Map productStock
                    -Long version
                    +reserveStock(productId, qty) boolean
                    +releaseStock(productId, qty) void
                    +getAvailable(productId) int
                }

                class Order {
                    -String orderId
                    -User user
                    -DarkStore darkStore
                    -List orderItems
                    -OrderState state
                    -DeliveryPartner rider
                    -DateTime createdAt
                    +transition(newState) void
                    +cancel() void
                }

                class OrderState {
                    <<interface>>
                    +pack(order) void
                    +dispatch(order) void
                    +deliver(order) void
                    +cancel(order) void
                }

                class PlacedState {
                    +accept(order) void
                }

                class PackedState {
                    +dispatch(order) void
                }

                class OutForDeliveryState {
                    +deliver(order) void
                }

                class DeliveredState
                class CancelledState

                class DeliveryPartner {
                    -String riderId
                    -String name
                    -Location currentLocation
                    -RiderStatus status
                    +accept(order) void
                    +updateLocation(location) void
                }

                class DeliveryStrategy {
                    <<interface>>
                    +assignRider(order, riders) DeliveryPartner
                }

                class NearestRiderStrategy {
                    +assignRider(order, riders) DeliveryPartner
                }

                class BatchAssignmentStrategy {
                    +assignRider(order, riders) DeliveryPartner
                }

                class PricingStrategy {
                    <<interface>>
                    +calculatePrice(cart, darkStore) Money
                }

                class StandardPricing {
                    +calculatePrice(cart, darkStore) Money
                }

                class SurgePricing {
                    -double surgeMultiplier
                    +calculatePrice(cart, darkStore) Money
                }

                class NotificationService {
                    <<Observer>>
                    -List subscribers
                    +notify(order, event) void
                    +subscribe(subscriber) void
                }

                class PaymentFactory {
                    +createPayment(type) Payment
                }

                class Payment {
                    <<interface>>
                    +process(amount) boolean
                    +refund() boolean
                }

                ZeptoApp --> DarkStore
                ZeptoApp --> OrderState
                User --> Order : places
                Order --> DarkStore : belongs to
                Order --> OrderState : has
                Order --> DeliveryPartner : assigned to
                DarkStore --> Inventory : contains
                OrderState <|.. PlacedState
                OrderState <|.. PackedState
                OrderState <|.. OutForDeliveryState
                OrderState <|.. DeliveredState
                OrderState <|.. CancelledState
                DeliveryStrategy <|.. NearestRiderStrategy
                DeliveryStrategy <|.. BatchAssignmentStrategy
                PricingStrategy <|.. StandardPricing
                PricingStrategy <|.. SurgePricing
                Payment <|.. UPIPayment
                Payment <|.. CardPayment
                NotificationService --> Order : observes
            """,
            codeSnippet: """
            // ═══════════════════════════════════════════════════════════════
            // FILE: domain/Inventory.java (Concurrency-Safe)
            // ═══════════════════════════════════════════════════════════════
            @Entity
            @Data
            public class Inventory {
                @Id
                private String productId;
                private String darkStoreId;
                private int quantity;
                
                @Version  // Optimistic Locking
                private Long version;
                
                /**
                 * Thread-safe stock reservation with Optimistic Locking.
                 * When 100 users try to buy last item, only ONE succeeds.
                 * Others get OptimisticLockException and retry/fail gracefully.
                 */
                public synchronized boolean reserveStock(int qty) {
                    if (this.quantity >= qty) {
                        this.quantity -= qty;
                        return true;
                    }
                    return false;
                }
                
                public void releaseStock(int qty) {
                    this.quantity += qty;
                }
            }

            // ═══════════════════════════════════════════════════════════════
            // FILE: service/InventoryService.java (With Pessimistic Lock)
            // ═══════════════════════════════════════════════════════════════
            @Service
            @RequiredArgsConstructor
            public class InventoryService {
                private final InventoryRepository repository;
                private final ReentrantLock lock = new ReentrantLock();
                
                @Transactional
                public boolean reserveWithPessimisticLock(String productId, String storeId, int qty) {
                    lock.lock();
                    try {
                        // SELECT ... FOR UPDATE (DB-level lock)
                        Inventory inv = repository.findByProductIdAndStoreIdForUpdate(productId, storeId);
                        if (inv != null && inv.getQuantity() >= qty) {
                            inv.setQuantity(inv.getQuantity() - qty);
                            repository.save(inv);
                            return true;
                        }
                        return false;
                    } finally {
                        lock.unlock();
                    }
                }
                
                @Transactional
                @Retryable(value = OptimisticLockException.class, maxAttempts = 3)
                public boolean reserveWithOptimisticLock(String productId, String storeId, int qty) {
                    Inventory inv = repository.findByProductIdAndStoreId(productId, storeId);
                    if (inv != null && inv.reserveStock(qty)) {
                        repository.save(inv);  // Version check happens here
                        return true;
                    }
                    return false;
                }
            }

            // ═══════════════════════════════════════════════════════════════
            // FILE: state/OrderState.java (State Pattern)
            // ═══════════════════════════════════════════════════════════════
            public interface OrderState {
                default void accept(Order order) {
                    throw new IllegalStateException("Cannot accept in current state");
                }
                default void pack(Order order) {
                    throw new IllegalStateException("Cannot pack in current state");
                }
                default void dispatch(Order order) {
                    throw new IllegalStateException("Cannot dispatch in current state");
                }
                default void deliver(Order order) {
                    throw new IllegalStateException("Cannot deliver in current state");
                }
                default void cancel(Order order) {
                    throw new IllegalStateException("Cannot cancel in current state");
                }
            }

            public class PlacedState implements OrderState {
                @Override
                public void accept(Order order) {
                    order.setState(new AcceptedState());
                    order.notifyObservers("Order accepted by dark store");
                }
                
                @Override
                public void cancel(Order order) {
                    order.getInventoryService().releaseStock(order.getItems());
                    order.setState(new CancelledState());
                    order.notifyObservers("Order cancelled, stock released");
                }
            }

            public class AcceptedState implements OrderState {
                @Override
                public void pack(Order order) {
                    order.setState(new PackedState());
                    order.notifyObservers("Order packed, ready for pickup");
                }
            }

            public class PackedState implements OrderState {
                @Override
                public void dispatch(Order order) {
                    order.setState(new OutForDeliveryState());
                    order.notifyObservers("Rider " + order.getRider().getName() + " is on the way");
                }
            }

            public class OutForDeliveryState implements OrderState {
                @Override
                public void deliver(Order order) {
                    order.setState(new DeliveredState());
                    order.setDeliveredAt(Instant.now());
                    order.notifyObservers("Order delivered! Enjoy your items");
                }
            }

            // ═══════════════════════════════════════════════════════════════
            // FILE: strategy/DeliveryStrategy.java (Strategy Pattern)
            // ═══════════════════════════════════════════════════════════════
            public interface DeliveryStrategy {
                Optional<DeliveryPartner> assignRider(Order order, List<DeliveryPartner> availableRiders);
            }

            @Component("nearestRider")
            public class NearestRiderStrategy implements DeliveryStrategy {
                @Override
                public Optional<DeliveryPartner> assignRider(Order order, List<DeliveryPartner> riders) {
                    Location storeLocation = order.getDarkStore().getLocation();
                    
                    return riders.stream()
                        .filter(r -> r.getStatus() == RiderStatus.AVAILABLE)
                        .min(Comparator.comparingDouble(
                            r -> calculateDistance(storeLocation, r.getCurrentLocation())
                        ));
                }
                
                private double calculateDistance(Location a, Location b) {
                    // Haversine formula for geographic distance
                    double lat1 = Math.toRadians(a.getLatitude());
                    double lat2 = Math.toRadians(b.getLatitude());
                    double dLat = lat2 - lat1;
                    double dLon = Math.toRadians(b.getLongitude() - a.getLongitude());
                    
                    double h = Math.sin(dLat/2) * Math.sin(dLat/2) +
                               Math.cos(lat1) * Math.cos(lat2) *
                               Math.sin(dLon/2) * Math.sin(dLon/2);
                    
                    return 6371 * 2 * Math.atan2(Math.sqrt(h), Math.sqrt(1-h)); // km
                }
            }

            // ═══════════════════════════════════════════════════════════════
            // FILE: observer/NotificationService.java (Observer Pattern)
            // ═══════════════════════════════════════════════════════════════
            @Service
            public class NotificationService implements OrderObserver {
                private final PushNotificationClient pushClient;
                private final SMSClient smsClient;
                
                @Override
                public void onOrderStateChange(Order order, String message) {
                    // Notify customer
                    pushClient.send(order.getUser().getDeviceToken(), message);
                    
                    // Notify rider if assigned
                    if (order.getRider() != null) {
                        pushClient.send(order.getRider().getDeviceToken(), 
                            "Order #" + order.getOrderId() + ": " + message);
                    }
                }
            }

            // ═══════════════════════════════════════════════════════════════
            // FILE: ZeptoApp.java (Singleton Facade)
            // ═══════════════════════════════════════════════════════════════
            @Service
            public class ZeptoApp {
                private static ZeptoApp instance;
                
                private final DarkStoreService darkStoreService;
                private final InventoryService inventoryService;
                private final OrderService orderService;
                private final DeliveryService deliveryService;
                private final PaymentFactory paymentFactory;
                
                // Singleton pattern
                public static synchronized ZeptoApp getInstance() {
                    if (instance == null) {
                        instance = new ZeptoApp();
                    }
                    return instance;
                }
                
                @Transactional
                public Order placeOrder(String userId, Cart cart, PaymentType paymentType) {
                    // 1. Find nearest dark store
                    User user = userService.findById(userId);
                    DarkStore store = darkStoreService.findNearest(user.getLocation());
                    
                    // 2. Reserve inventory (with concurrency handling)
                    for (CartItem item : cart.getItems()) {
                        boolean reserved = inventoryService.reserveWithOptimisticLock(
                            item.getProductId(), store.getStoreId(), item.getQuantity()
                        );
                        if (!reserved) {
                            throw new OutOfStockException(item.getProductId());
                        }
                    }
                    
                    // 3. Process payment
                    Payment payment = paymentFactory.createPayment(paymentType);
                    Money total = pricingStrategy.calculatePrice(cart, store);
                    
                    if (!payment.process(total)) {
                        // ROLLBACK: Release reserved stock
                        for (CartItem item : cart.getItems()) {
                            inventoryService.releaseStock(item.getProductId(), 
                                store.getStoreId(), item.getQuantity());
                        }
                        throw new PaymentFailedException();
                    }
                    
                    // 4. Create order
                    Order order = orderService.create(user, store, cart, payment);
                    
                    // 5. Assign rider
                    deliveryService.assignRider(order);
                    
                    return order;
                }
            }
            """,
            gsSpecificTwist: """
            **GS Twist: Multi-Region Dark Store Network**
            
            Goldman Sachs twist: Design for 500+ dark stores across 50 cities with:
            
            1. **Consistent Hashing** for store assignment to handle store additions/removals
            2. **Distributed Locking** using Redis/Zookeeper for cross-store inventory sync
            3. **Event-Driven Architecture** with Kafka for:
               - InventoryReservedEvent
               - OrderStateChangedEvent
               - RiderAssignedEvent
            4. **Saga Pattern** for distributed transactions (Inventory → Payment → Order)
            5. **Circuit Breaker** for rider service with fallback to manual assignment queue
            
            **Edge Case Discussion Points:**
            - Stock Rollback on payment failure (Compensating Transaction)
            - Rider unavailable (Retry with exponential backoff + fallback queue)
            - Dark store goes offline mid-order (Failover to nearby store)
            - Flash sale handling (Rate limiting + queue-based ordering)
            """
        )
    }
}
