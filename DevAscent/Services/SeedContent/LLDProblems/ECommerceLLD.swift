//
//  ECommerceLLD.swift
//  DevAscent
//
//  E-Commerce / Online Shopping System LLD Problem
//

import Foundation

struct ECommerceLLD {
    static func create() -> LLDProblem {
        return LLDProblem(
            title: "E-Commerce / Online Shopping System",
            requirements: """
            **Core Domain Requirements:**
            • **Customer Management:** Register customers with account, addresses
            • **Product Catalog:** Products with categories, search functionality
            • **Shopping Cart:** Add/remove products, calculate totals
            • **Order Management:** Place orders, track order states
            • **Payment Processing:** Multiple payment strategies (Card, UPI)
            • **Inventory Management:** Stock tracking, reservation
            • **Notifications:** Observer pattern for order status updates

            **Design Patterns (Mandatory):**
            • **Singleton Pattern:** OnlineShoppingSystem as main entry point
            • **State Pattern:** Order states (Placed → Shipped → Delivered/Cancelled)
            • **Strategy Pattern:** Payment processing (CreditCard, UPI)
            • **Decorator Pattern:** Product decorations (GiftWrap, etc.)
            • **Observer Pattern:** Order status notifications

            **Thread-Safety Requirements:**
            • ConcurrentHashMap for all repositories
            • Synchronized inventory operations
            • Atomic order state transitions
            """,
            solutionStrategy: """
            **Architecture:**

            **A. Facade Layer:**
            • OnlineShoppingSystem (Singleton) - Central API gateway
            • Delegates to OrderService, PaymentService, InventoryService, SearchService

            **B. Service Layer:**
            • OrderService - Order creation, state management
            • PaymentService - Strategy-based payment processing
            • InventoryService - Stock management with locking
            • SearchService - Product catalog search

            **C. Domain Models:**
            • Customer → Account, Address (composition)
            • Order → OrderLineItem, OrderState (state machine)
            • Product → ProductCategory (enum)
            • ShoppingCart → CartItem (aggregation)

            **D. State Machine (Order Lifecycle):**
            • PlacedState → ShippedState → DeliveredState
            • Any state → CancelledState (with restrictions)

            **E. Decorator Pattern (Product Add-ons):**
            • ProductDecorator wraps Product
            • GiftWrapDecorator adds gift wrapping cost
            """,
            mermaidGraph: """
            classDiagram
                class OnlineShoppingDemo {
                    +main(args)
                }
                class OnlineShoppingSystem {
                    -instance OnlineShoppingSystem
                    -customers Map
                    -orders Map
                    -products Map
                    -paymentService PaymentService
                    -inventoryService InventoryService
                    -orderService OrderService
                    -searchService SearchService
                    +getInstance()
                    +registerCustomer(String, String, Address)
                    +placeOrder(String, PaymentStrategy)
                    +addProduct(Product, int)
                    +addToCart(String, String, int)
                    +searchProducts(String)
                    +getCustomerCart(String)
                }
                class OrderService {
                    -inventoryService InventoryService
                    +makeOrder(Customer, ShoppingCart)
                }
                class PaymentService {
                    +processPayment(PaymentStrategy, double)
                }
                class InventoryService {
                    -stock Map
                    +addStock(Product, int)
                    +reduceStock(Product, int)
                    +hasStock(List)
                }
                class SearchService {
                    -productCatalog Collection
                    +searchByCategory(ProductCategory)
                    +searchByName(String)
                }
                class Order {
                    -id String
                    -customer Customer
                    -status OrderStatus
                    -shippingAddress Address
                    -totalAmount double
                    -orderDate LocalDateTime
                    -items List
                    -currentState OrderState
                    +shipOrder()
                    +deliverOrder()
                    +cancelOrder()
                }
                class OrderLineItem {
                    -productId String
                    -quantity int
                    -productName String
                    -priceAtOrder double
                }
                class OrderStatus {
                    PLACED
                    SHIPPED
                    PENDING_PAYMENT
                    DELIVERED
                    CANCELLED
                    RETURNED
                }
                class OrderState {
                    +ship(Order)
                    +deliver(Order)
                    +cancel(Order)
                }
                class PlacedState {
                    +ship(Order)
                    +deliver(Order)
                    +cancel(Order)
                }
                class ShippedState {
                    +ship(Order)
                    +deliver(Order)
                    +cancel(Order)
                }
                class DeliveredState {
                    +ship(Order)
                    +deliver(Order)
                    +cancel(Order)
                }
                class CancelledState {
                    +ship(Order)
                    +deliver(Order)
                    +cancel(Order)
                }
                class Customer {
                    -id String
                    -name String
                    -email String
                    -account Account
                    -shippingAddress Address
                    +updateEmail()
                    +setShippingAddress(Address)
                }
                class Account {
                    -username String
                    -password String
                    -cart ShoppingCart
                }
                class Address {
                    -street String
                    -city String
                    -state String
                    -zipCode String
                }
                class ShoppingCart {
                    -items Map
                    +addProduct(Product, int)
                    +removeProduct(String)
                    +getItems()
                    +calculateTotal()
                }
                class CartItem {
                    -quantity int
                    -product Product
                    +incrementQuantity(int)
                    +getPrice()
                }
                class Product {
                    -id String
                    -name String
                    -price double
                    -description String
                    -category ProductCategory
                }
                class ProductCategory {
                    CLOTHING
                    HOME_GOODS
                    GROCERY
                    ELECTRONICS
                    BEAUTY
                    OTHER
                }
                class ProductDecorator {
                    #decoratedProduct Product
                }
                class GiftWrapDecorator {
                    -GIFT_WRAP_COST double
                    +getDescription()
                    +getPrice()
                }
                class BaseProduct {
                    +getName()
                    +getPrice()
                    +getCategory()
                    +getId()
                    +getDescription()
                }
                class PaymentStrategy {
                    +processPayment(double)
                }
                class CreditCardPaymentStrategy {
                    -cardNumber String
                    +processPayment(double)
                }
                class UPIPaymentStrategy {
                    -upiId String
                    +processPayment(double)
                }
                class Subject {
                    -observers List
                    +addObserver(OrderObserver)
                    +removeObserver(OrderObserver)
                    +notifyObservers(Order)
                }
                class OrderObserver {
                    +update(Order)
                }
                OnlineShoppingDemo --> OnlineShoppingSystem
                OnlineShoppingSystem --> OrderService
                OnlineShoppingSystem --> PaymentService
                OnlineShoppingSystem --> InventoryService
                OnlineShoppingSystem --> SearchService
                OnlineShoppingSystem --> Customer
                OnlineShoppingSystem --> Order
                OnlineShoppingSystem --> Product
                OrderService --> InventoryService
                PaymentService ..> PaymentStrategy
                PaymentStrategy <|.. CreditCardPaymentStrategy
                PaymentStrategy <|.. UPIPaymentStrategy
                Order --> Customer
                Order --> OrderLineItem
                Order --> OrderState
                Order --> OrderStatus
                OrderState <|-- PlacedState
                OrderState <|-- ShippedState
                OrderState <|-- DeliveredState
                OrderState <|-- CancelledState
                Customer --> Account
                Customer --> Address
                Account --> ShoppingCart
                ShoppingCart --> CartItem
                CartItem --> Product
                Product --> ProductCategory
                ProductDecorator --> Product
                ProductDecorator <|-- GiftWrapDecorator
                BaseProduct --|> Product
                Subject --> OrderObserver
                Order --|> Subject
            """,
            codeSnippet: """
            // ═══════════════════════════════════════════════════════════════
            // FILE: domain/OrderState.java (State Pattern)
            // ═══════════════════════════════════════════════════════════════
            public interface OrderState {
                void ship(Order order);
                void deliver(Order order);
                void cancel(Order order);
            }

            public class PlacedState implements OrderState {
                @Override
                public void ship(Order order) {
                    System.out.println("Order " + order.getId() + " shipped!");
                    order.setStatus(OrderStatus.SHIPPED);
                    order.setState(new ShippedState());
                }
                
                @Override
                public void deliver(Order order) {
                    throw new IllegalStateException("Cannot deliver - order not shipped yet");
                }
                
                @Override
                public void cancel(Order order) {
                    System.out.println("Order " + order.getId() + " cancelled");
                    order.setStatus(OrderStatus.CANCELLED);
                    order.setState(new CancelledState());
                }
            }

            public class ShippedState implements OrderState {
                @Override
                public void ship(Order order) {
                    throw new IllegalStateException("Already shipped");
                }
                
                @Override
                public void deliver(Order order) {
                    System.out.println("Order " + order.getId() + " delivered!");
                    order.setStatus(OrderStatus.DELIVERED);
                    order.setState(new DeliveredState());
                }
                
                @Override
                public void cancel(Order order) {
                    throw new IllegalStateException("Cannot cancel shipped order");
                }
            }

            public class DeliveredState implements OrderState {
                @Override
                public void ship(Order order) {
                    throw new IllegalStateException("Already delivered");
                }
                
                @Override
                public void deliver(Order order) {
                    throw new IllegalStateException("Already delivered");
                }
                
                @Override
                public void cancel(Order order) {
                    throw new IllegalStateException("Cannot cancel delivered order");
                }
            }

            // ═══════════════════════════════════════════════════════════════
            // FILE: strategy/PaymentStrategy.java
            // ═══════════════════════════════════════════════════════════════
            public interface PaymentStrategy {
                boolean processPayment(double amount);
            }

            public class CreditCardPaymentStrategy implements PaymentStrategy {
                private final String cardNumber;
                
                public CreditCardPaymentStrategy(String cardNumber) {
                    this.cardNumber = cardNumber;
                }
                
                @Override
                public boolean processPayment(double amount) {
                    // Integrate with payment gateway
                    System.out.println("Processing $" + amount + " via Credit Card: ****" + 
                        cardNumber.substring(cardNumber.length() - 4));
                    return true;  // Assume success
                }
            }

            public class UPIPaymentStrategy implements PaymentStrategy {
                private final String upiId;
                
                public UPIPaymentStrategy(String upiId) {
                    this.upiId = upiId;
                }
                
                @Override
                public boolean processPayment(double amount) {
                    System.out.println("Processing ₹" + amount + " via UPI: " + upiId);
                    return true;
                }
            }

            // ═══════════════════════════════════════════════════════════════
            // FILE: decorator/ProductDecorator.java
            // ═══════════════════════════════════════════════════════════════
            public abstract class ProductDecorator extends Product {
                protected Product decoratedProduct;
                
                public ProductDecorator(Product product) {
                    super(product.getId(), product.getName(), 
                          product.getPrice(), product.getCategory());
                    this.decoratedProduct = product;
                }
            }

            public class GiftWrapDecorator extends ProductDecorator {
                private static final double GIFT_WRAP_COST = 5.99;
                
                public GiftWrapDecorator(Product product) {
                    super(product);
                }
                
                @Override
                public double getPrice() {
                    return decoratedProduct.getPrice() + GIFT_WRAP_COST;
                }
                
                @Override
                public String getDescription() {
                    return decoratedProduct.getDescription() + " [Gift Wrapped]";
                }
            }

            // ═══════════════════════════════════════════════════════════════
            // FILE: domain/ShoppingCart.java
            // ═══════════════════════════════════════════════════════════════
            public class ShoppingCart {
                private final Map<String, CartItem> items = new ConcurrentHashMap<>();
                
                public void addProduct(Product product, int quantity) {
                    items.compute(product.getId(), (id, existing) -> {
                        if (existing == null) {
                            return new CartItem(product, quantity);
                        } else {
                            existing.incrementQuantity(quantity);
                            return existing;
                        }
                    });
                }
                
                public void removeProduct(String productId) {
                    items.remove(productId);
                }
                
                public Map<String, CartItem> getItems() {
                    return Collections.unmodifiableMap(items);
                }
                
                public double calculateTotal() {
                    return items.values().stream()
                        .mapToDouble(CartItem::getPrice)
                        .sum();
                }
                
                public void clear() {
                    items.clear();
                }
            }

            // ═══════════════════════════════════════════════════════════════
            // FILE: service/InventoryService.java (Thread-Safe)
            // ═══════════════════════════════════════════════════════════════
            public class InventoryService {
                private final Map<String, Integer> stock = new ConcurrentHashMap<>();
                private final ReentrantLock lock = new ReentrantLock();
                
                public void addStock(Product product, int quantity) {
                    stock.merge(product.getId(), quantity, Integer::sum);
                }
                
                public boolean reduceStock(Product product, int quantity) {
                    lock.lock();
                    try {
                        int current = stock.getOrDefault(product.getId(), 0);
                        if (current >= quantity) {
                            stock.put(product.getId(), current - quantity);
                            return true;
                        }
                        return false;
                    } finally {
                        lock.unlock();
                    }
                }
                
                public boolean hasStock(List<CartItem> items) {
                    return items.stream().allMatch(item -> 
                        stock.getOrDefault(item.getProduct().getId(), 0) >= item.getQuantity()
                    );
                }
            }

            // ═══════════════════════════════════════════════════════════════
            // FILE: OnlineShoppingSystem.java (Singleton Facade)
            // ═══════════════════════════════════════════════════════════════
            public class OnlineShoppingSystem {
                private static volatile OnlineShoppingSystem instance;
                private static final Object lock = new Object();
                
                private final Map<String, Customer> customers = new ConcurrentHashMap<>();
                private final Map<String, Order> orders = new ConcurrentHashMap<>();
                private final Map<String, Product> products = new ConcurrentHashMap<>();
                
                private final PaymentService paymentService;
                private final InventoryService inventoryService;
                private final OrderService orderService;
                private final SearchService searchService;
                
                private OnlineShoppingSystem() {
                    this.paymentService = new PaymentService();
                    this.inventoryService = new InventoryService();
                    this.orderService = new OrderService(inventoryService);
                    this.searchService = new SearchService(products.values());
                }
                
                public static OnlineShoppingSystem getInstance() {
                    if (instance == null) {
                        synchronized (lock) {
                            if (instance == null) {
                                instance = new OnlineShoppingSystem();
                            }
                        }
                    }
                    return instance;
                }
                
                public Customer registerCustomer(String name, String email, Address address) {
                    Customer customer = new Customer(name, email, address);
                    customers.put(customer.getId(), customer);
                    return customer;
                }
                
                public Order placeOrder(String customerId, PaymentStrategy paymentStrategy) {
                    Customer customer = customers.get(customerId);
                    if (customer == null) throw new IllegalArgumentException("Customer not found");
                    
                    ShoppingCart cart = customer.getAccount().getCart();
                    if (cart.getItems().isEmpty()) {
                        throw new IllegalStateException("Cart is empty");
                    }
                    
                    // Check inventory
                    if (!inventoryService.hasStock(new ArrayList<>(cart.getItems().values()))) {
                        throw new IllegalStateException("Insufficient stock");
                    }
                    
                    // Process payment
                    double total = cart.calculateTotal();
                    if (!paymentService.processPayment(paymentStrategy, total)) {
                        throw new RuntimeException("Payment failed");
                    }
                    
                    // Create order
                    Order order = orderService.makeOrder(customer, cart);
                    orders.put(order.getId(), order);
                    
                    // Clear cart
                    cart.clear();
                    
                    return order;
                }
                
                public void addToCart(String customerId, String productId, int quantity) {
                    Customer customer = customers.get(customerId);
                    Product product = products.get(productId);
                    customer.getAccount().getCart().addProduct(product, quantity);
                }
            }

            // ═══════════════════════════════════════════════════════════════
            // FILE: OnlineShoppingDemo.java (Main)
            // ═══════════════════════════════════════════════════════════════
            public class OnlineShoppingDemo {
                public static void main(String[] args) {
                    OnlineShoppingSystem system = OnlineShoppingSystem.getInstance();
                    
                    // Add products to catalog
                    Product laptop = new Product("1", "MacBook Pro", 1999.99, ProductCategory.ELECTRONICS);
                    system.addProduct(laptop, 10);  // 10 in stock
                    
                    // Register customer
                    Address addr = new Address("123 Main St", "NYC", "NY", "10001");
                    Customer customer = system.registerCustomer("John Doe", "john@email.com", addr);
                    
                    // Add to cart (with gift wrap decorator)
                    Product wrappedLaptop = new GiftWrapDecorator(laptop);
                    system.addToCart(customer.getId(), laptop.getId(), 1);
                    
                    // Place order with credit card
                    PaymentStrategy payment = new CreditCardPaymentStrategy("4111111111111111");
                    Order order = system.placeOrder(customer.getId(), payment);
                    // Output: Processing $2005.98 via Credit Card: ****1111
                    
                    // Ship and deliver
                    order.shipOrder();   // Output: Order xxx shipped!
                    order.deliverOrder(); // Output: Order xxx delivered!
                }
            }
            """,
            gsSpecificTwist: """
            **Goldman Sachs Twist: Saga Pattern for Distributed Checkout**

            **Problem:** In a microservices architecture, checkout involves:
            1. InventoryService (reserve stock)
            2. PaymentService (process payment)
            3. OrderService (create order)

            If step 2 fails, we need to rollback step 1!

            **Solution: Saga Pattern with Compensating Transactions**

            ```java
            public class CheckoutSaga {
                private final InventoryService inventoryService;
                private final PaymentService paymentService;
                private final OrderService orderService;
                
                public Order execute(Customer customer, ShoppingCart cart, 
                                     PaymentStrategy payment) throws SagaException {
                    String reservationId = null;
                    String paymentId = null;
                    
                    try {
                        // Step 1: Reserve Inventory
                        reservationId = inventoryService.reserveStock(cart.getItems());
                        
                        // Step 2: Process Payment
                        paymentId = paymentService.processPayment(payment, cart.calculateTotal());
                        
                        // Step 3: Create Order
                        return orderService.createOrder(customer, cart, paymentId);
                        
                    } catch (PaymentException e) {
                        // COMPENSATE: Release inventory if payment fails
                        if (reservationId != null) {
                            inventoryService.releaseReservation(reservationId);
                        }
                        throw new SagaException("Checkout failed at payment", e);
                        
                    } catch (OrderException e) {
                        // COMPENSATE: Refund payment and release inventory
                        if (paymentId != null) {
                            paymentService.refund(paymentId);
                        }
                        if (reservationId != null) {
                            inventoryService.releaseReservation(reservationId);
                        }
                        throw new SagaException("Checkout failed at order creation", e);
                    }
                }
            }
            ```

            **Why State Pattern for Orders?**
            • Prevents invalid transitions (can't deliver before shipping)
            • Each state encapsulates its own behavior
            • Easy to add new states (Processing, Refunded)

            **Why Decorator for Products?**
            • Add-ons like GiftWrap, InsuranceWrap without modifying Product
            • Stack decorators: `new Insurance(new GiftWrap(product))`
            """
        )
    }
}
