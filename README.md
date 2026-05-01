# VaultBank

A bank account agent built with [Jido](https://hexdocs.pm/jido) and [Phoenix LiveView](https://hexdocs.pm/phoenix_live_view).

## What is Jido?

[Jido](https://hexdido.dev) is an Elixir framework for building autonomous, signal-driven agents. Agents hold state, respond to signals, and execute actions — making them a natural fit for stateful business logic like a bank account.

## How it works

- **`BankAccountAgent`** (named *Vault*) — a `Jido.Agent` that holds the account state: balance, last updated timestamp, and transaction history
- **`DepositAction`** — a `Jido.Action` that adds to the balance and appends a transaction entry
- **`WithdrawAction`** — a `Jido.Action` that subtracts from the balance (with overdraft protection) and appends a transaction entry
- **`Dashboard`** — a Phoenix LiveView that dispatches signals to the agent on button click and re-renders with the updated state

Signals flow like this:
```
LiveView button click
  → Signal.new!("account.deposit", %{amount: 100})
  → AgentServer.call(pid, signal)
  → DepositAction.run/2
  → updated agent state
  → LiveView re-renders
```

## Getting started

```bash
mix setup
mix phx.server
```

Visit [localhost:4000](http://localhost:4000) in your browser.

## Stack

- [Elixir](https://elixir-lang.org)
- [Phoenix](https://phoenixframework.org) + [LiveView](https://hexdocs.pm/phoenix_live_view)
- [Jido 2.1](https://hexdocs.pm/jido)
- PostgreSQL
