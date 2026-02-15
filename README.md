# Decision Lifecycle Event Store (PostgreSQL)

A PostgreSQL-based event-sourced decision lifecycle engine that enforces:

- Strict causal ordering
- Deterministic state transitions
- Append-only semantics
- Single active lifecycle constraint

All business invariants are enforced at the database layer using triggers and constraint triggers.

---

## Architecture Overview

The system models decisions as an append-only event stream.

Each decision follows a strict lifecycle:

INPUTS -> FEATURES -> MODEL -> POLICY -> OVERRIDE (Optional) -> FINALIZED

---

## Invariants Enforced

### 1. Causal Ordering
Each decision must increment `causal_index` sequentially.

### 2. Deterministic State Transitions
Only valid state transitions are permitted.

### 3. Append-Only Design
Updates and deletes are forbidden.

### 4. Single Active Decision
Only one non-finalized decision lifecycle may exist at a time.

---

## Project Structure

```
decision-lifecycle-event-store/
│
├── schema.sql
├── test_cases.sql
├── README.md
└── LICENSE
```

---

## Setup

Run:

```sql
\i schema.sql
```

Then execute test scenarios:

```sql
\i test_cases.sql
```

---

## Technologies

- PostgreSQL
- PL/pgSQL
- Constraint Triggers
- Event-Sourcing Pattern

---

## Design Patterns Used

- Event Sourcing
- State Machine Enforcement
- Database-Level Business Rules
- Append-Only Ledger Model

---

## Why This Matters

This project demonstrates how complex lifecycle constraints can be enforced at the database layer without relying on application logic.

It ensures data integrity by construction.

