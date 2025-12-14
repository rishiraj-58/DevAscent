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
            **Core Requirements:**
            • User Management with balance sheets (who owes whom)
            • Groups: Users belong to multiple groups, group or individual expenses
            • Expense Types: EQUAL, EXACT, PERCENTAGE, SHARES splits
            • Balance Sheet: Detailed balances + Simplify Debt (minimize transactions)
            • Notifications: Observer pattern for expense alerts

            **Design Patterns (Mandatory):**
            • **Singleton:** SplitwiseService (ExpenseManager)
            • **Strategy:** SplitStrategy (Equal, Exact, Percentage, Share)
            • **Factory:** SplitFactory to create correct strategy
            • **Observer:** Group notifies Users of new expenses
            • **Command:** AddExpenseCommand, SettleDebtCommand for undo/redo

            **Critical Algorithm:**
            • Debt Simplification using Greedy Algorithm (minimize cash flow)
            """,
            solutionStrategy: """
            **Architecture:**

            **A. Domain Model:**
            • User: id, name, email, balances (Map<userId, amount>)
            • Group: members, expenses, activities
            • Expense: paidBy, amount, splits, splitStrategy
            • Split: user, amount, isPaid

            **B. Strategy Pattern (Split Types):**
            • EqualSplitStrategy: amount / users.size()
            • ExactSplitStrategy: validate sum == total
            • PercentageSplitStrategy: validate sum == 100%
            • ShareSplitStrategy: proportional by shares

            **C. Observer Pattern:**
            • Group implements Subject (Observable)
            • User implements Observer
            • Notify on: expense added, settlement, member joined

            **D. Debt Simplification (Greedy):**
            1. Calculate net balance for each user
            2. Separate into Debtors (net < 0) and Creditors (net > 0)
            3. Match max debtor with max creditor recursively
            4. Creates minimum number of transactions
            """,
            mermaidGraph: """
            classDiagram
                class SplitwiseService {
                    -static SplitwiseService instance
                    -Map users
                    -Map groups
                    -CommandHistory commandHistory
                    -NotificationService notifications
                    +getInstance() SplitwiseService
                    +createUser(name, email) User
                    +createGroup(name, creator) Group
                    +addExpense(group, expense) void
                    +settleUp(from, to, amount) Transaction
                    +undo() void
                    +redo() void
                }
                
                class User {
                    -String userId
                    -String name
                    -String email
                    -Map balances
                    -List groups
                    +updateBalance(userId, amount) void
                    +getNetBalance() double
                    +getBalanceWith(User) double
                    +onNotify(Event) void
                }
                
                class Group {
                    -String groupId
                    -String name
                    -User createdBy
                    -List members
                    -List expenses
                    -List observers
                    -ReentrantLock lock
                    +addMember(User) void
                    +addExpense(Expense) void
                    +getBalances() Map
                    +getSimplifiedDebts() List
                    +attach(Observer) void
                    +notifyAll(Event) void
                }
                
                class Expense {
                    -String expenseId
                    -String description
                    -User paidBy
                    -double amount
                    -LocalDateTime createdAt
                    -SplitStrategy strategy
                    -List splits
                    +getSplitForUser(User) Split
                }
                
                class Split {
                    -User user
                    -double amount
                    -boolean isPaid
                    +markPaid() void
                }
                
                class SplitStrategy {
                    +calculateSplits(amount, users) List
                    +validate(amount, splits) boolean
                }
                
                class EqualSplitStrategy {
                    +calculateSplits(amount, users) List
                }
                
                class ExactSplitStrategy {
                    -Map exactAmounts
                    +validate(amount, splits) boolean
                }
                
                class PercentageSplitStrategy {
                    -Map percentages
                    +validate(amount, splits) boolean
                }
                
                class ShareSplitStrategy {
                    -Map shares
                    +calculateSplits(amount, users) List
                }
                
                class SplitFactory {
                    +create(SplitType, params) SplitStrategy
                }
                
                class DebtSimplifier {
                    +simplify(Map balances) List
                    -matchDebtorToCreditor(debtors, creditors) Transaction
                }
                
                class Command {
                    +execute() void
                    +undo() void
                }
                
                class AddExpenseCommand {
                    -Group group
                    -Expense expense
                    +execute() void
                    +undo() void
                }
                
                class SettleDebtCommand {
                    -User from
                    -User to
                    -double amount
                }
                
                class ExpenseObserver {
                    +onExpenseAdded(Expense) void
                    +onSettlement(Transaction) void
                }
                
                class Transaction {
                    -String id
                    -User from
                    -User to
                    -double amount
                    -TransactionStatus status
                }
                
                SplitwiseService *-- User
                SplitwiseService *-- Group
                SplitwiseService o-- Command
                Group *-- Expense
                Group *-- User : members
                Group o-- ExpenseObserver
                Expense *-- Split
                Expense o-- SplitStrategy
                SplitStrategy <|-- EqualSplitStrategy
                SplitStrategy <|-- ExactSplitStrategy
                SplitStrategy <|-- PercentageSplitStrategy
                SplitStrategy <|-- ShareSplitStrategy
                SplitFactory ..> SplitStrategy
                Command <|-- AddExpenseCommand
                Command <|-- SettleDebtCommand
                User ..|> ExpenseObserver
                DebtSimplifier ..> Transaction
            """,
            codeSnippet: """
            // ═══════════════════════════════════════════════════════════════
            // FILE: strategy/SplitStrategy.java
            // ═══════════════════════════════════════════════════════════════
            public interface SplitStrategy {
                List<Split> calculateSplits(double amount, List<User> users);
                boolean validate(double amount, List<Split> splits);
            }

            public class EqualSplitStrategy implements SplitStrategy {
                @Override
                public List<Split> calculateSplits(double amount, List<User> users) {
                    int n = users.size();
                    double baseAmount = Math.floor(amount * 100 / n) / 100;
                    double remainder = amount - (baseAmount * n);
                    
                    List<Split> splits = new ArrayList<>();
                    for (int i = 0; i < n; i++) {
                        // Handle rounding: give extra cent to first users
                        double splitAmount = baseAmount;
                        if (i < Math.round(remainder * 100)) {
                            splitAmount += 0.01;
                        }
                        splits.add(new Split(users.get(i), splitAmount));
                    }
                    return splits;
                }
                
                @Override
                public boolean validate(double amount, List<Split> splits) {
                    return true; // Always valid for equal split
                }
            }

            public class ExactSplitStrategy implements SplitStrategy {
                private final Map<String, Double> exactAmounts;
                
                @Override
                public List<Split> calculateSplits(double amount, List<User> users) {
                    return users.stream()
                        .map(u -> new Split(u, exactAmounts.getOrDefault(u.getId(), 0.0)))
                        .collect(Collectors.toList());
                }
                
                @Override
                public boolean validate(double amount, List<Split> splits) {
                    double sum = splits.stream().mapToDouble(Split::getAmount).sum();
                    return Math.abs(sum - amount) < 0.01; // Tolerance for rounding
                }
            }

            // ═══════════════════════════════════════════════════════════════
            // FILE: factory/SplitFactory.java
            // ═══════════════════════════════════════════════════════════════
            public class SplitFactory {
                public static SplitStrategy create(SplitType type, Map<String, Double> params) {
                    return switch (type) {
                        case EQUAL -> new EqualSplitStrategy();
                        case EXACT -> new ExactSplitStrategy(params);
                        case PERCENTAGE -> new PercentageSplitStrategy(params);
                        case SHARE -> new ShareSplitStrategy(params);
                    };
                }
            }

            // ═══════════════════════════════════════════════════════════════
            // FILE: service/DebtSimplifier.java (Greedy Algorithm)
            // ═══════════════════════════════════════════════════════════════
            public class DebtSimplifier {
                
                /**
                 * Greedy algorithm to minimize number of transactions.
                 * Time: O(n log n), Space: O(n)
                 */
                public List<Transaction> simplify(Map<User, Double> balances) {
                    // Separate into creditors (owed money) and debtors (owe money)
                    PriorityQueue<UserBalance> creditors = new PriorityQueue<>(
                        (a, b) -> Double.compare(b.amount, a.amount)); // Max heap
                    PriorityQueue<UserBalance> debtors = new PriorityQueue<>(
                        Comparator.comparingDouble(a -> a.amount)); // Min heap
                    
                    balances.forEach((user, balance) -> {
                        if (balance > 0.01) {
                            creditors.offer(new UserBalance(user, balance));
                        } else if (balance < -0.01) {
                            debtors.offer(new UserBalance(user, balance));
                        }
                    });
                    
                    List<Transaction> transactions = new ArrayList<>();
                    
                    while (!creditors.isEmpty() && !debtors.isEmpty()) {
                        UserBalance creditor = creditors.poll();
                        UserBalance debtor = debtors.poll();
                        
                        // Amount to settle
                        double settleAmount = Math.min(creditor.amount, -debtor.amount);
                        
                        transactions.add(Transaction.builder()
                            .from(debtor.user)
                            .to(creditor.user)
                            .amount(settleAmount)
                            .build());
                        
                        // Re-add if not fully settled
                        double creditorRemaining = creditor.amount - settleAmount;
                        double debtorRemaining = debtor.amount + settleAmount;
                        
                        if (creditorRemaining > 0.01) {
                            creditors.offer(new UserBalance(creditor.user, creditorRemaining));
                        }
                        if (debtorRemaining < -0.01) {
                            debtors.offer(new UserBalance(debtor.user, debtorRemaining));
                        }
                    }
                    
                    return transactions;
                }
            }

            // ═══════════════════════════════════════════════════════════════
            // FILE: command/AddExpenseCommand.java (Command Pattern)
            // ═══════════════════════════════════════════════════════════════
            public interface Command {
                void execute();
                void undo();
            }

            @AllArgsConstructor
            public class AddExpenseCommand implements Command {
                private final Group group;
                private final Expense expense;
                
                @Override
                public void execute() {
                    group.addExpense(expense);
                    
                    // Update balances
                    User paidBy = expense.getPaidBy();
                    for (Split split : expense.getSplits()) {
                        if (!split.getUser().equals(paidBy)) {
                            split.getUser().updateBalance(paidBy.getId(), -split.getAmount());
                            paidBy.updateBalance(split.getUser().getId(), split.getAmount());
                        }
                    }
                    
                    // Notify observers
                    group.notifyObservers(new ExpenseAddedEvent(expense));
                }
                
                @Override
                public void undo() {
                    group.removeExpense(expense);
                    
                    // Reverse balances
                    User paidBy = expense.getPaidBy();
                    for (Split split : expense.getSplits()) {
                        if (!split.getUser().equals(paidBy)) {
                            split.getUser().updateBalance(paidBy.getId(), split.getAmount());
                            paidBy.updateBalance(split.getUser().getId(), -split.getAmount());
                        }
                    }
                }
            }

            // ═══════════════════════════════════════════════════════════════
            // FILE: service/SplitwiseService.java (Singleton)
            // ═══════════════════════════════════════════════════════════════
            public class SplitwiseService {
                private static volatile SplitwiseService instance;
                
                private final ConcurrentHashMap<String, User> users = new ConcurrentHashMap<>();
                private final ConcurrentHashMap<String, Group> groups = new ConcurrentHashMap<>();
                private final Deque<Command> undoStack = new ConcurrentLinkedDeque<>();
                private final Deque<Command> redoStack = new ConcurrentLinkedDeque<>();
                private final DebtSimplifier debtSimplifier = new DebtSimplifier();
                
                private SplitwiseService() {}
                
                public static SplitwiseService getInstance() {
                    if (instance == null) {
                        synchronized (SplitwiseService.class) {
                            if (instance == null) {
                                instance = new SplitwiseService();
                            }
                        }
                    }
                    return instance;
                }
                
                public void addExpense(String groupId, User paidBy, double amount,
                                      SplitType type, Map<String, Double> splitParams) {
                    Group group = groups.get(groupId);
                    SplitStrategy strategy = SplitFactory.create(type, splitParams);
                    
                    Expense expense = Expense.builder()
                        .expenseId(UUID.randomUUID().toString())
                        .paidBy(paidBy)
                        .amount(amount)
                        .strategy(strategy)
                        .splits(strategy.calculateSplits(amount, group.getMembers()))
                        .createdAt(LocalDateTime.now())
                        .build();
                    
                    // Validate
                    if (!strategy.validate(amount, expense.getSplits())) {
                        throw new InvalidSplitException("Split amounts don't add up");
                    }
                    
                    Command cmd = new AddExpenseCommand(group, expense);
                    cmd.execute();
                    undoStack.push(cmd);
                    redoStack.clear();
                }
                
                public void undo() {
                    if (!undoStack.isEmpty()) {
                        Command cmd = undoStack.pop();
                        cmd.undo();
                        redoStack.push(cmd);
                    }
                }
                
                public List<Transaction> getSimplifiedDebts(String groupId) {
                    Map<User, Double> balances = groups.get(groupId).calculateNetBalances();
                    return debtSimplifier.simplify(balances);
                }
            }
            """,
            gsSpecificTwist: """
            **Multi-Currency Support (GS Twist)**

            **Problem:** Expenses in different currencies with real-time forex.

            **Solution:**

            ```java
            public class CurrencyAwareExpense extends Expense {
                private final Currency currency;
                private final double originalAmount;
                private final ForexService forexService;
                
                @Override
                public double getAmountInBaseCurrency() {
                    return forexService.convert(originalAmount, currency, Currency.USD);
                }
            }

            // At settlement time, lock the exchange rate
            public class Settlement {
                private final double lockedRate;
                private final Currency sourceCurrency;
                private final Currency targetCurrency;
                
                public Settlement(User from, User to, double amount, Currency curr) {
                    this.lockedRate = forexService.getRate(curr, to.getPreferredCurrency());
                }
            }
            ```

            **Edge Cases Handled:**

            1. **Rounding Errors ($100 / 3):**
               - Use `Math.floor(amount * 100 / n) / 100` for base
               - Distribute remainder cents to first N users
               - Example: $100/3 = $33.33, $33.33, $33.34

            2. **Concurrency (simultaneous expenses):**
               - `ReentrantLock` per Group for expense operations
               - `ConcurrentHashMap` for users and groups
               - Atomic balance updates with `updateBalance()`
            """
        )
    }
}
