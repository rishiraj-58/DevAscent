//
//  QuickCommerceLLD.swift
//  DevAscent
//
//  Quick Commerce (Zepto/Blinkit) LLD Problem
//

import Foundation

struct QuickCommerceLLD {
    static func create() -> LLDProblem {
        return LLDProblem(
            title: "Quick Commerce (10-Min Delivery)",
            requirements: """
            **Core Domain Requirements:**
            • **Product Management:** Products with SKU, name, price
            • **User Management:** Users with location and cart
            • **Dark Store Management:** Multiple stores with inventory
            • **Inventory Management:** Stock tracking with replenishment strategies
            • **Cart Operations:** Add items, calculate totals
            • **Order Management:** Place orders, assign delivery partners
            • **Delivery Partner Assignment:** Based on proximity

            **Design Patterns (Mandatory):**
            • **Singleton Pattern:** DarkStoreManager, OrderManager
            • **Strategy Pattern:** ReplenishStrategy (Threshold, Weekly)
            • **Factory Pattern:** ProductFactory for product creation
            • **Abstract Class:** InventoryStore with DB implementation

            **Key Constraints:**
            • Dark stores serve nearby locations only
            • Inventory replenishment based on strategy
            • Order contains items, user, delivery partners
            """,
            solutionStrategy: """
            **Architecture:**

            **A. Entry Point:**
            • Zepto - Main application entry

            **B. Domain Models:**
            • Product - sku, name, price
            • User - name, location (x,y), Cart
            • Cart - items map, addItem, getTotal, getItems
            • DeliveryPartner - name
            • Order - orderId, user, items, partners, total

            **C. Inventory Layer:**
            • InventoryStore (Abstract) - addProduct, removeProduct, checkStock
            • DBInventoryStore - Database-backed implementation
            • InventoryManager - Facade over InventoryStore

            **D. Replenishment Strategy:**
            • ReplenishStrategy (Abstract) - replenish(manager, items)
            • ThresholdRepStrat - Replenish when below threshold
            • WeeklyRepStrat - Weekly scheduled replenishment

            **E. Dark Store Management:**
            • DarkStore - name, location, InventoryManager, ReplenishStrategy
            • DarkStoreManager (Singleton) - stores list, getNearbyStores

            **F. Order Management:**
            • OrderManager (Singleton) - placeOrder, orders list
            """,
            mermaidGraph: """
            classDiagram
                class Zepto
                class Product {
                    -int sku
                    -String name
                    -double price
                }
                class ProductFactory {
                    +createProduct(int sku)
                }
                class User {
                    -String name
                    -double x
                    -double y
                    -Cart cart
                }
                class DeliveryPartner {
                    -String name
                }
                class Cart {
                    +addItem(int sku, int qty)
                    +getTotal()
                    +getItems()
                }
                class InventoryStore {
                    +addProduct(Product, int qty)
                    +removeProduct(int sku, int qty)
                    +checkStock(int sku)
                    +listAllProducts()
                }
                class DBInventoryStore {
                    -Map stocks
                    -Map products
                    +addProduct(Product, int qty)
                    +removeProduct(int sku, int qty)
                    +checkStock(int sku)
                    +listAllProducts()
                }
                class InventoryManager {
                    -InventoryStore store
                    +addStock(int sku, int qty)
                    +removeStock(int sku, int qty)
                    +checkStock(int sku)
                    +getAvailableProducts()
                }
                class ReplenishStrategy {
                    +replenish(InventoryManager, Map items)
                }
                class ThresholdRepStrat {
                    -int threshold
                    +replenish(mgr, items)
                }
                class WeeklyRepStrat {
                    +replenish(mgr, items)
                }
                class DarkStore {
                    -String name
                    -double x
                    -double y
                    -InventoryManager mgr
                    -ReplenishStrategy rs
                    +getAllProducts()
                    +distanceTo(ux, uy)
                    +runReplenish(Map items)
                }
                class DarkStoreManager {
                    -List stores
                    +addStore(DarkStore)
                    +getNearbyStores(ux, uy, maxD)
                }
                class Order {
                    -int orderId
                    -User user
                    -List items
                    -List partners
                    -double total
                }
                class OrderManager {
                    +placeOrder(User, Cart, DarkStore)
                    -List orders
                }
                Zepto --> User
                Zepto --> DarkStoreManager
                Zepto --> OrderManager
                User --> Cart
                User --> DeliveryPartner
                ProductFactory --> Product
                Cart --> Product
                InventoryStore <|-- DBInventoryStore
                InventoryManager --> InventoryStore
                ReplenishStrategy <|-- ThresholdRepStrat
                ReplenishStrategy <|-- WeeklyRepStrat
                DarkStore --> InventoryManager
                DarkStore --> ReplenishStrategy
                DarkStoreManager --> DarkStore
                Order --> User
                Order --> DeliveryPartner
                OrderManager --> Order
                OrderManager --> DarkStore
            """,
            codeSnippet: """
            // ═══════════════════════════════════════════════════════════════
            // FILE: domain/Product.java & ProductFactory.java
            // ═══════════════════════════════════════════════════════════════
            @Data
            @AllArgsConstructor
            public class Product {
                private final int sku;
                private final String name;
                private final double price;
            }

            public class ProductFactory {
                private static final Map<Integer, Product> catalog = new ConcurrentHashMap<>();
                
                public static Product createProduct(int sku, String name, double price) {
                    return catalog.computeIfAbsent(sku, k -> new Product(sku, name, price));
                }
            }

            // ═══════════════════════════════════════════════════════════════
            // FILE: domain/Cart.java
            // ═══════════════════════════════════════════════════════════════
            public class Cart {
                private final Map<Integer, Integer> items = new ConcurrentHashMap<>();  // sku -> qty
                private final Map<Integer, Product> products = new ConcurrentHashMap<>();
                
                public void addItem(int sku, int qty, Product product) {
                    items.merge(sku, qty, Integer::sum);
                    products.put(sku, product);
                }
                
                public double getTotal() {
                    return items.entrySet().stream()
                        .mapToDouble(e -> products.get(e.getKey()).getPrice() * e.getValue())
                        .sum();
                }
                
                public Map<Integer, Integer> getItems() {
                    return Collections.unmodifiableMap(items);
                }
                
                public void clear() {
                    items.clear();
                    products.clear();
                }
            }

            // ═══════════════════════════════════════════════════════════════
            // FILE: inventory/InventoryStore.java (Abstract)
            // ═══════════════════════════════════════════════════════════════
            public abstract class InventoryStore {
                public abstract void addProduct(Product product, int qty);
                public abstract boolean removeProduct(int sku, int qty);
                public abstract int checkStock(int sku);
                public abstract List<Product> listAllProducts();
            }

            public class DBInventoryStore extends InventoryStore {
                private final Map<Integer, Integer> stocks = new ConcurrentHashMap<>();
                private final Map<Integer, Product> products = new ConcurrentHashMap<>();
                
                @Override
                public void addProduct(Product product, int qty) {
                    products.put(product.getSku(), product);
                    stocks.merge(product.getSku(), qty, Integer::sum);
                }
                
                @Override
                public boolean removeProduct(int sku, int qty) {
                    return stocks.computeIfPresent(sku, (k, current) -> 
                        current >= qty ? current - qty : null) != null;
                }
                
                @Override
                public int checkStock(int sku) {
                    return stocks.getOrDefault(sku, 0);
                }
                
                @Override
                public List<Product> listAllProducts() {
                    return new ArrayList<>(products.values());
                }
            }

            // ═══════════════════════════════════════════════════════════════
            // FILE: inventory/InventoryManager.java (Facade)
            // ═══════════════════════════════════════════════════════════════
            public class InventoryManager {
                private final InventoryStore store;
                
                public InventoryManager(InventoryStore store) {
                    this.store = store;
                }
                
                public void addStock(int sku, int qty) {
                    Product product = ProductFactory.getProduct(sku);
                    store.addProduct(product, qty);
                }
                
                public boolean removeStock(int sku, int qty) {
                    return store.removeProduct(sku, qty);
                }
                
                public int checkStock(int sku) {
                    return store.checkStock(sku);
                }
                
                public List<Product> getAvailableProducts() {
                    return store.listAllProducts().stream()
                        .filter(p -> store.checkStock(p.getSku()) > 0)
                        .collect(Collectors.toList());
                }
            }

            // ═══════════════════════════════════════════════════════════════
            // FILE: strategy/ReplenishStrategy.java
            // ═══════════════════════════════════════════════════════════════
            public abstract class ReplenishStrategy {
                public abstract void replenish(InventoryManager manager, Map<Integer, Integer> items);
            }

            public class ThresholdRepStrat extends ReplenishStrategy {
                private final int threshold;
                
                public ThresholdRepStrat(int threshold) {
                    this.threshold = threshold;
                }
                
                @Override
                public void replenish(InventoryManager manager, Map<Integer, Integer> items) {
                    items.forEach((sku, targetQty) -> {
                        int current = manager.checkStock(sku);
                        if (current < threshold) {
                            int needed = targetQty - current;
                            manager.addStock(sku, needed);
                            System.out.println("Replenished SKU " + sku + " by " + needed);
                        }
                    });
                }
            }

            public class WeeklyRepStrat extends ReplenishStrategy {
                @Override
                public void replenish(InventoryManager manager, Map<Integer, Integer> items) {
                    // Called by scheduler every week
                    items.forEach((sku, targetQty) -> {
                        int current = manager.checkStock(sku);
                        int needed = targetQty - current;
                        if (needed > 0) {
                            manager.addStock(sku, needed);
                        }
                    });
                }
            }

            // ═══════════════════════════════════════════════════════════════
            // FILE: store/DarkStore.java
            // ═══════════════════════════════════════════════════════════════
            @Data
            public class DarkStore {
                private final String name;
                private final double x, y;  // Location
                private final InventoryManager mgr;
                private final ReplenishStrategy rs;
                
                public List<Product> getAllProducts() {
                    return mgr.getAvailableProducts();
                }
                
                public double distanceTo(double ux, double uy) {
                    return Math.sqrt(Math.pow(x - ux, 2) + Math.pow(y - uy, 2));
                }
                
                public void runReplenish(Map<Integer, Integer> items) {
                    rs.replenish(mgr, items);
                }
            }

            // ═══════════════════════════════════════════════════════════════
            // FILE: store/DarkStoreManager.java (Singleton)
            // ═══════════════════════════════════════════════════════════════
            public class DarkStoreManager {
                private static volatile DarkStoreManager instance;
                private final List<DarkStore> stores = new CopyOnWriteArrayList<>();
                
                private DarkStoreManager() {}
                
                public static DarkStoreManager getInstance() {
                    if (instance == null) {
                        synchronized (DarkStoreManager.class) {
                            if (instance == null) {
                                instance = new DarkStoreManager();
                            }
                        }
                    }
                    return instance;
                }
                
                public void addStore(DarkStore store) {
                    stores.add(store);
                }
                
                public List<DarkStore> getNearbyStores(double ux, double uy, double maxDistance) {
                    return stores.stream()
                        .filter(store -> store.distanceTo(ux, uy) <= maxDistance)
                        .sorted(Comparator.comparingDouble(s -> s.distanceTo(ux, uy)))
                        .collect(Collectors.toList());
                }
            }

            // ═══════════════════════════════════════════════════════════════
            // FILE: order/OrderManager.java (Singleton)
            // ═══════════════════════════════════════════════════════════════
            public class OrderManager {
                private static volatile OrderManager instance;
                private final List<Order> orders = new CopyOnWriteArrayList<>();
                private int orderCounter = 0;
                
                private OrderManager() {}
                
                public static OrderManager getInstance() {
                    if (instance == null) {
                        synchronized (OrderManager.class) {
                            if (instance == null) {
                                instance = new OrderManager();
                            }
                        }
                    }
                    return instance;
                }
                
                public Order placeOrder(User user, Cart cart, DarkStore store) {
                    // Validate stock
                    for (Map.Entry<Integer, Integer> item : cart.getItems().entrySet()) {
                        if (store.getMgr().checkStock(item.getKey()) < item.getValue()) {
                            throw new IllegalStateException("Insufficient stock for SKU: " + item.getKey());
                        }
                    }
                    
                    // Deduct stock
                    cart.getItems().forEach((sku, qty) -> store.getMgr().removeStock(sku, qty));
                    
                    // Create order
                    Order order = new Order(
                        ++orderCounter,
                        user,
                        new ArrayList<>(cart.getItems().entrySet()),
                        List.of(new DeliveryPartner("Rider-" + orderCounter)),
                        cart.getTotal()
                    );
                    
                    orders.add(order);
                    cart.clear();
                    
                    return order;
                }
            }

            // ═══════════════════════════════════════════════════════════════
            // FILE: ZeptoDemo.java (Main)
            // ═══════════════════════════════════════════════════════════════
            public class ZeptoDemo {
                public static void main(String[] args) {
                    // Setup dark store
                    InventoryStore dbStore = new DBInventoryStore();
                    InventoryManager mgr = new InventoryManager(dbStore);
                    ReplenishStrategy strategy = new ThresholdRepStrat(10);
                    DarkStore store = new DarkStore("Koramangala Hub", 12.9, 77.6, mgr, strategy);
                    
                    DarkStoreManager.getInstance().addStore(store);
                    
                    // Add products
                    Product milk = ProductFactory.createProduct(101, "Milk 1L", 60.0);
                    Product bread = ProductFactory.createProduct(102, "Bread", 40.0);
                    mgr.addStock(101, 50);
                    mgr.addStock(102, 30);
                    
                    // User places order
                    User user = new User("John", 12.91, 77.61);
                    user.getCart().addItem(101, 2, milk);
                    user.getCart().addItem(102, 1, bread);
                    
                    // Find nearby store and place order
                    List<DarkStore> nearby = DarkStoreManager.getInstance()
                        .getNearbyStores(user.getX(), user.getY(), 5.0);
                    
                    OrderManager orderMgr = OrderManager.getInstance();
                    Order order = orderMgr.placeOrder(user, user.getCart(), nearby.get(0));
                    
                    System.out.println("Order placed! Total: ₹" + order.getTotal());
                }
            }
            """,
            gsSpecificTwist: """
            **Goldman Sachs Twist: Multi-Region with Consistent Hashing**

            **Requirement:** Scale to multiple cities with efficient store lookup.

            **Solution: Consistent Hashing + Geo-Partitioning**

            ```java
            public class GeoPartitionedStoreManager {
                private final ConsistentHash<DarkStore> storeRing;
                private final Map<String, List<DarkStore>> cityStores;
                
                public DarkStore findNearestStore(double lat, double lng, String city) {
                    // First filter by city
                    List<DarkStore> cityOptions = cityStores.get(city);
                    
                    // Use geohash for consistent hashing
                    String geoHash = GeoHash.encode(lat, lng, 6);
                    
                    // Find store responsible for this geohash region
                    DarkStore mapped = storeRing.get(geoHash);
                    
                    // Fallback to nearest if mapped store is overloaded
                    if (mapped.isOverloaded()) {
                        return cityOptions.stream()
                            .min(Comparator.comparingDouble(s -> s.distanceTo(lat, lng)))
                            .orElseThrow();
                    }
                    
                    return mapped;
                }
            }
            ```

            **Why InventoryStore is Abstract?**
            • Allows swapping DBInventoryStore with RedisInventoryStore
            • Testing with InMemoryInventoryStore
            • Open-Closed principle

            **Why ReplenishStrategy?**
            • ThresholdRepStrat for high-demand items
            • WeeklyRepStrat for stable items
            • Can add SeasonalRepStrat, AIRepStrat later
            """
        )
    }
}
