//
//  StockExchangeLLD.swift
//  DevAscent
//
//  Stock Exchange / Order Matching LLD Problem
//

import Foundation

struct StockExchangeLLD {
    static func create() -> LLDProblem {
        return LLDProblem(
            title: "Stock Exchange / Order Matching",
            requirements: """
            • Support BUY and SELL orders
            • Price-Time priority matching
            • Order types: Market, Limit, Stop-Loss
            • Real-time trade execution
            • Order book management
            """,
            solutionStrategy: """
            **Patterns Used:**
            - **Single Writer Principle** (LMAX Disruptor)
            - **Observer Pattern**: Price ticker updates
            - **Strategy Pattern**: Different order matching algorithms
            
            **Data Structures:**
            - PriorityQueue for order book (Price/Time priority)
            - TreeMap for price levels
            """,
            mermaidGraph: """
            classDiagram
                class MatchingEngine {
                    -OrderBook orderBook
                    -List strategies
                    -TradeExecutor executor
                    +processOrder(Order) List
                    -match(Order, OrderBook) List
                    +registerStrategy(MatchingStrategy)
                }
                
                class OrderBook {
                    -String symbol
                    -TreeMap buyOrders
                    -TreeMap sellOrders
                    -ReentrantLock lock
                    +addOrder(Order) void
                    +cancelOrder(orderId) boolean
                    +modifyOrder(orderId, newQty) boolean
                    +getBestBid() Double
                    +getBestAsk() Double
                    +getSpread() double
                }
                
                class Order {
                    -String orderId
                    -String symbol
                    -OrderType type
                    -OrderSide side
                    -double price
                    -int quantity
                    -int filledQty
                    -OrderStatus status
                    -long timestamp
                    +isFilled() boolean
                    +getRemainingQty() int
                }
                
                class OrderType {
                    
                    MARKET
                    LIMIT
                    STOP_LOSS
                    STOP_LIMIT
                    IOC
                    FOK
                }
                
                class MatchingStrategy {
                    
                    +canMatch(Order, Order) boolean
                    +getExecutionPrice(Order, Order) double
                }
                class PriceTimePriority
                class ProRataMatching
                
                class Trade {
                    -String tradeId
                    -Order buyOrder
                    -Order sellOrder
                    -double executionPrice
                    -int quantity
                    -long executedAt
                }
                
                class TradeExecutor {
                    +execute(Order, Order, price, qty) Trade
                    +settle(Trade) void
                }
                
                class CircuitBreaker {
                    -double upperLimit
                    -double lowerLimit
                    -boolean isTripped
                    +checkPrice(price) boolean
                    +trip() void
                    +reset() void
                }
                
                MatchingEngine *-- OrderBook
                MatchingEngine *-- TradeExecutor
                MatchingEngine o-- CircuitBreaker
                MatchingEngine ..> MatchingStrategy
                OrderBook *-- Order
                Order --> OrderType
                MatchingStrategy <|.. PriceTimePriority
                MatchingStrategy <|.. ProRataMatching
                TradeExecutor --> Trade
                Trade --> Order
            """,
            codeSnippet: """
            public class OrderBook {
                // Best prices at the front
                private final TreeMap<Double, Queue<Order>> buyOrders = 
                    new TreeMap<>(Collections.reverseOrder());  // Highest first
                private final TreeMap<Double, Queue<Order>> sellOrders = 
                    new TreeMap<>();  // Lowest first
                
                public void addOrder(Order order) {
                    TreeMap<Double, Queue<Order>> book = 
                        order.getSide() == Side.BUY ? buyOrders : sellOrders;
                    
                    book.computeIfAbsent(order.getPrice(), 
                        k -> new LinkedList<>()).offer(order);
                }
                
                public Double getBestBid() {
                    return buyOrders.isEmpty() ? null : buyOrders.firstKey();
                }
                
                public Double getBestAsk() {
                    return sellOrders.isEmpty() ? null : sellOrders.firstKey();
                }
            }

            public class MatchingEngine {
                private final OrderBook orderBook = new OrderBook();
                
                public List<Trade> processOrder(Order incoming) {
                    List<Trade> trades = new ArrayList<>();
                    
                    if (incoming.getSide() == Side.BUY) {
                        // Match against sell orders
                        while (incoming.getQuantity() > 0 && canMatch(incoming)) {
                            Trade trade = executeMatch(incoming, getBestSellOrder());
                            trades.add(trade);
                        }
                    }
                    
                    // Add remaining to book
                    if (incoming.getQuantity() > 0) {
                        orderBook.addOrder(incoming);
                    }
                    
                    return trades;
                }
            }
            """,
            gsSpecificTwist: "Implement circuit breakers for 10% price swings and handle order priority during system restarts"
        )
    }
}
