//
//  SplitwiseLLD.swift
//  DevAscent
//
//  Splitwise / Expense Sharing LLD Problem
//

import Foundation

struct SplitwiseLLD {
    static func create() -> LLDProblem {
        return LLDProblem(
            title: "Splitwise / Expense Sharing",
            requirements: """
            **Core Domain Requirements:**
            • **User Management:** Create users with balances tracking
            • **Group Management:** Create groups, add/remove members
            • **Expense Tracking:** Add expenses with different split strategies
            • **Balance Calculation:** Track who owes whom
            • **Payment Settlement:** Settle debts between users
            • **Debt Simplification:** Minimize number of transactions

            **Design Patterns (Mandatory):**
            • **Singleton Pattern:** Splitwise as main service
            • **Strategy Pattern:** SplitStrategy (Equal, Exact, Percentage)
            • **Factory Pattern:** SplitFactory for strategy creation
            • **Observer Pattern:** Notify users on expense/payment events

            **Split Types:**
            • **EQUAL:** Split equally among all participants
            • **EXACT:** Exact amounts specified per user
            • **PERCENTAGE:** Percentage-based split
            """,
            solutionStrategy: """
            **Architecture:**

            **A. Singleton Service:**
            • Splitwise - Central service with users, groups, expenses maps
            • Methods: settleIndividualPayment, addIndividualExpense

            **B. Domain Models:**
            • User - userId, name, email, balances map
            • Group - groupId, name, members, expenses, balances
            • Expense - id, desc, amount, paidUserId, splits, groupId
            • Split - userId, amount (individual share)

            **C. Strategy Pattern (Split Calculation):**
            • SplitStrategy (Abstract) - calcSplit(total, userIds, values)
            • EqualSplit - Divides equally
            • ExactSplit - Uses exact amounts provided
            • PercentageSplit - Calculates from percentages

            **D. Factory Pattern:**
            • SplitFactory - getSplitStrat(SplitType)

            **E. Observer Pattern:**
            • Observer (Abstract) - update(message)
            • Notifies group members on expense/payment events

            **F. Debt Simplification:**
            • DebtSimplifier - Minimizes transactions using net balance
            """,
            mermaidGraph: """
            classDiagram
                class Splitwise {
                    -Map users
                    -Map groups
                    -Map expenses
                    +settleIndividualPayment()
                    +addIndividualExpense()
                }
                class Group {
                    -String groupId
                    -String name
                    -List members
                    -Map expenses
                    -Map balances
                    +addMember(User)
                    +removeMember(User)
                    +notifyObs()
                    +updateGroupBal(from, to, amt)
                    +addExpense()
                    +settlePayment(from, to, amt)
                    +simplifyDebt()
                }
                class Expense {
                    -String id
                    -String desc
                    -double amt
                    -String paidUserId
                    -List splits
                    -String groupId
                }
                class User {
                    -String userId
                    -String name
                    -String email
                    -Map balances
                    +updateAmtExp()
                    +updateBal(userId, amt)
                }
                class Observer {
                    +update(msg)
                }
                class DebtSimplifier {
                    +simplifyDebt(Map balances)
                }
                class SplitFactory {
                    +getSplitStrat(SplitType)
                }
                class SplitType {
                    EQUAL
                    EXACT
                    PERCENTAGE
                }
                class Split {
                    -String userId
                    -double amount
                }
                class SplitStrategy {
                    +calcSplit(double, List, List)
                }
                class ExactSplit {
                    +calcSplit()
                }
                class EqualSplit {
                    +calcSplit()
                }
                class PercentageSplit {
                    +calcSplit()
                }
                Splitwise --> User
                Splitwise --> Group
                Splitwise --> Expense
                Group --> User
                Group --> Expense
                Group --> Observer
                Group --> DebtSimplifier
                Expense --> Split
                Split --> User
                SplitFactory --> SplitStrategy
                SplitFactory --> SplitType
                SplitStrategy --> Split
                SplitStrategy <|-- ExactSplit
                SplitStrategy <|-- EqualSplit
                SplitStrategy <|-- PercentageSplit
                User --> Observer
            """,
            codeSnippet: """
            // ═══════════════════════════════════════════════════════════════
            // FILE: domain/Split.java & SplitType.java
            // ═══════════════════════════════════════════════════════════════
            public enum SplitType {
                EQUAL, EXACT, PERCENTAGE
            }

            @Data
            @AllArgsConstructor
            public class Split {
                private final String userId;
                private final double amount;
            }

            // ═══════════════════════════════════════════════════════════════
            // FILE: strategy/SplitStrategy.java
            // ═══════════════════════════════════════════════════════════════
            public abstract class SplitStrategy {
                public abstract List<Split> calcSplit(double totalAmount, 
                                                       List<String> userIds, 
                                                       List<Double> values);
            }

            public class EqualSplit extends SplitStrategy {
                @Override
                public List<Split> calcSplit(double totalAmount, 
                                             List<String> userIds, 
                                             List<Double> values) {
                    double perPerson = totalAmount / userIds.size();
                    return userIds.stream()
                        .map(id -> new Split(id, perPerson))
                        .collect(Collectors.toList());
                }
            }

            public class ExactSplit extends SplitStrategy {
                @Override
                public List<Split> calcSplit(double totalAmount, 
                                             List<String> userIds, 
                                             List<Double> values) {
                    // Validate sum equals total
                    double sum = values.stream().mapToDouble(v -> v).sum();
                    if (Math.abs(sum - totalAmount) > 0.01) {
                        throw new IllegalArgumentException(
                            "Exact amounts must sum to total: " + totalAmount);
                    }
                    
                    List<Split> splits = new ArrayList<>();
                    for (int i = 0; i < userIds.size(); i++) {
                        splits.add(new Split(userIds.get(i), values.get(i)));
                    }
                    return splits;
                }
            }

            public class PercentageSplit extends SplitStrategy {
                @Override
                public List<Split> calcSplit(double totalAmount, 
                                             List<String> userIds, 
                                             List<Double> values) {
                    // Validate percentages sum to 100
                    double sum = values.stream().mapToDouble(v -> v).sum();
                    if (Math.abs(sum - 100.0) > 0.01) {
                        throw new IllegalArgumentException("Percentages must sum to 100");
                    }
                    
                    List<Split> splits = new ArrayList<>();
                    for (int i = 0; i < userIds.size(); i++) {
                        double amount = totalAmount * values.get(i) / 100.0;
                        splits.add(new Split(userIds.get(i), amount));
                    }
                    return splits;
                }
            }

            // ═══════════════════════════════════════════════════════════════
            // FILE: factory/SplitFactory.java
            // ═══════════════════════════════════════════════════════════════
            public class SplitFactory {
                public static SplitStrategy getSplitStrat(SplitType type) {
                    return switch (type) {
                        case EQUAL -> new EqualSplit();
                        case EXACT -> new ExactSplit();
                        case PERCENTAGE -> new PercentageSplit();
                    };
                }
            }

            // ═══════════════════════════════════════════════════════════════
            // FILE: domain/User.java
            // ═══════════════════════════════════════════════════════════════
            @Data
            public class User implements Observer {
                private final String userId;
                private final String name;
                private final String email;
                private final Map<String, Double> balances = new ConcurrentHashMap<>();
                
                public void updateBal(String otherUserId, double amount) {
                    balances.merge(otherUserId, amount, Double::sum);
                }
                
                public double getBalanceWith(String otherUserId) {
                    return balances.getOrDefault(otherUserId, 0.0);
                }
                
                @Override
                public void update(String message) {
                    System.out.println("📩 " + name + " received: " + message);
                }
            }

            // ═══════════════════════════════════════════════════════════════
            // FILE: domain/Group.java
            // ═══════════════════════════════════════════════════════════════
            public class Group {
                private final String groupId;
                private final String name;
                private final List<User> members = new CopyOnWriteArrayList<>();
                private final Map<String, Expense> expenses = new ConcurrentHashMap<>();
                private final Map<String, Map<String, Double>> balances = new ConcurrentHashMap<>();
                private final List<Observer> observers = new ArrayList<>();
                
                public void addMember(User user) {
                    members.add(user);
                    observers.add(user);  // User is also an observer
                    balances.put(user.getUserId(), new ConcurrentHashMap<>());
                }
                
                public void removeMember(User user) {
                    if (hasOutstandingBalance(user)) {
                        throw new IllegalStateException("User has outstanding balance");
                    }
                    members.remove(user);
                    observers.remove(user);
                }
                
                public void addExpense(Expense expense) {
                    expenses.put(expense.getId(), expense);
                    
                    String paidBy = expense.getPaidUserId();
                    for (Split split : expense.getSplits()) {
                        if (!split.getUserId().equals(paidBy)) {
                            updateGroupBal(split.getUserId(), paidBy, split.getAmount());
                        }
                    }
                    
                    notifyObs("New expense: " + expense.getDesc() + " - $" + expense.getAmt());
                }
                
                public void updateGroupBal(String from, String to, double amount) {
                    // 'from' owes 'to' this amount
                    balances.get(from).merge(to, amount, Double::sum);
                    balances.get(to).merge(from, -amount, Double::sum);
                }
                
                public void settlePayment(String fromUserId, String toUserId, double amount) {
                    updateGroupBal(fromUserId, toUserId, -amount);  // Reduce debt
                    notifyObs(fromUserId + " paid $" + amount + " to " + toUserId);
                }
                
                public void simplifyDebt() {
                    DebtSimplifier.simplifyDebt(balances);
                }
                
                private void notifyObs(String message) {
                    observers.forEach(obs -> obs.update("[" + name + "] " + message));
                }
            }

            // ═══════════════════════════════════════════════════════════════
            // FILE: service/DebtSimplifier.java (Graph Algorithm)
            // ═══════════════════════════════════════════════════════════════
            public class DebtSimplifier {
                public static List<Transaction> simplifyDebt(Map<String, Map<String, Double>> balances) {
                    // Calculate net balance per user
                    Map<String, Double> netBalance = new HashMap<>();
                    
                    for (String user : balances.keySet()) {
                        double net = balances.get(user).values().stream()
                            .mapToDouble(d -> d).sum();
                        netBalance.put(user, net);
                    }
                    
                    // Separate into creditors (positive) and debtors (negative)
                    PriorityQueue<Pair<String, Double>> creditors = new PriorityQueue<>(
                        (a, b) -> Double.compare(b.getValue(), a.getValue()));
                    PriorityQueue<Pair<String, Double>> debtors = new PriorityQueue<>(
                        (a, b) -> Double.compare(a.getValue(), b.getValue()));
                    
                    for (Map.Entry<String, Double> e : netBalance.entrySet()) {
                        if (e.getValue() > 0.01) {
                            creditors.add(new Pair<>(e.getKey(), e.getValue()));
                        } else if (e.getValue() < -0.01) {
                            debtors.add(new Pair<>(e.getKey(), e.getValue()));
                        }
                    }
                    
                    // Match debtors with creditors
                    List<Transaction> transactions = new ArrayList<>();
                    while (!creditors.isEmpty() && !debtors.isEmpty()) {
                        Pair<String, Double> creditor = creditors.poll();
                        Pair<String, Double> debtor = debtors.poll();
                        
                        double amount = Math.min(creditor.getValue(), -debtor.getValue());
                        transactions.add(new Transaction(debtor.getKey(), creditor.getKey(), amount));
                        
                        if (creditor.getValue() > amount + 0.01) {
                            creditors.add(new Pair<>(creditor.getKey(), creditor.getValue() - amount));
                        }
                        if (-debtor.getValue() > amount + 0.01) {
                            debtors.add(new Pair<>(debtor.getKey(), debtor.getValue() + amount));
                        }
                    }
                    
                    return transactions;
                }
            }

            // ═══════════════════════════════════════════════════════════════
            // FILE: Splitwise.java (Singleton)
            // ═══════════════════════════════════════════════════════════════
            public class Splitwise {
                private static volatile Splitwise instance;
                private static final Object lock = new Object();
                
                private final Map<String, User> users = new ConcurrentHashMap<>();
                private final Map<String, Group> groups = new ConcurrentHashMap<>();
                private final Map<String, Expense> expenses = new ConcurrentHashMap<>();
                
                private Splitwise() {}
                
                public static Splitwise getInstance() {
                    if (instance == null) {
                        synchronized (lock) {
                            if (instance == null) {
                                instance = new Splitwise();
                            }
                        }
                    }
                    return instance;
                }
                
                public User createUser(String name, String email) {
                    User user = new User(UUID.randomUUID().toString(), name, email);
                    users.put(user.getUserId(), user);
                    return user;
                }
                
                public Group createGroup(String name) {
                    Group group = new Group(UUID.randomUUID().toString(), name);
                    groups.put(group.getGroupId(), group);
                    return group;
                }
                
                public void addIndividualExpense(String paidByUserId, String owedByUserId, 
                                                  double amount, String description) {
                    User paidBy = users.get(paidByUserId);
                    User owedBy = users.get(owedByUserId);
                    
                    paidBy.updateBal(owedByUserId, amount);
                    owedBy.updateBal(paidByUserId, -amount);
                    
                    owedBy.update("You owe " + paidBy.getName() + " $" + amount + " for " + description);
                }
                
                public void settleIndividualPayment(String fromUserId, String toUserId, double amount) {
                    User from = users.get(fromUserId);
                    User to = users.get(toUserId);
                    
                    from.updateBal(toUserId, -amount);
                    to.updateBal(fromUserId, amount);
                    
                    to.update(from.getName() + " paid you $" + amount);
                }
            }

            // ═══════════════════════════════════════════════════════════════
            // FILE: SplitwiseDemo.java (Main)
            // ═══════════════════════════════════════════════════════════════
            public class SplitwiseDemo {
                public static void main(String[] args) {
                    Splitwise app = Splitwise.getInstance();
                    
                    // Create users
                    User alice = app.createUser("Alice", "alice@email.com");
                    User bob = app.createUser("Bob", "bob@email.com");
                    User charlie = app.createUser("Charlie", "charlie@email.com");
                    
                    // Create group
                    Group trip = app.createGroup("Goa Trip");
                    trip.addMember(alice);
                    trip.addMember(bob);
                    trip.addMember(charlie);
                    
                    // Add expense with equal split
                    SplitStrategy strategy = SplitFactory.getSplitStrat(SplitType.EQUAL);
                    List<Split> splits = strategy.calcSplit(300.0, 
                        List.of(alice.getUserId(), bob.getUserId(), charlie.getUserId()),
                        null);
                    
                    Expense dinner = new Expense("Dinner", 300.0, alice.getUserId(), splits, trip.getGroupId());
                    trip.addExpense(dinner);
                    // Output: Bob received: [Goa Trip] New expense: Dinner - $300.0
                    
                    // Settle up
                    trip.settlePayment(bob.getUserId(), alice.getUserId(), 100.0);
                    
                    // Simplify remaining debts
                    trip.simplifyDebt();
                }
            }
            """,
            gsSpecificTwist: """
            **Goldman Sachs Twist: Currency Conversion + Recurring Expenses**

            **Requirement:** Support multiple currencies and recurring expenses.

            **Solution: Decorator + Scheduler**

            ```java
            public class CurrencyConverter {
                private static final Map<String, Double> RATES = Map.of(
                    "USD", 1.0, "EUR", 0.85, "INR", 83.0, "GBP", 0.79
                );
                
                public static double convert(double amount, String from, String to) {
                    double usdAmount = amount / RATES.get(from);
                    return usdAmount * RATES.get(to);
                }
            }

            public class RecurringExpense {
                private final Expense template;
                private final Duration interval;  // WEEKLY, MONTHLY
                private final LocalDate startDate;
                private final LocalDate endDate;
                
                @Scheduled(cron = "0 0 0 * * ?")  // Run daily
                public void processRecurring() {
                    if (shouldCreateToday()) {
                        Expense newExpense = template.clone();
                        newExpense.setId(UUID.randomUUID().toString());
                        group.addExpense(newExpense);
                    }
                }
            }
            ```

            **Why Factory for SplitStrategy?**
            • Encapsulates strategy creation logic
            • Easy to add new split types (WeightedSplit, CustomFormula)
            • Client doesn't know concrete classes

            **Why DebtSimplifier uses Graph Algorithm?**
            • Minimizes N-way settlements to at most N-1 transactions
            • Uses net balance calculation (creditors vs debtors)
            • Greedy matching algorithm for optimal solution
            """
        )
    }
}
