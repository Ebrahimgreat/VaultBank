defmodule Bankaccount.Demo.DepositAction do
  use Jido.Action,
  name: "deposit_action",
  description: "Deposit an amount into the account",
  schema: [
    amount: [type: :integer, doc: "Amount to deposit"]
  ]
  alias Jido.Agent.Directive
  alias Jido.Signal
  @impl true
  def run(%{amount: amount}, context) do
    current_amount = Map.get(context.state, :amount, 0)
    transactions = Map.get(context.state, :transactions) || []
    new_amount = current_amount + amount
    now = DateTime.utc_now()

    transaction = %{type: :deposit, amount: amount, balance: new_amount, at: now}

    emit_signal = Signal.new!(
      "deposit.completed",
      %{previous: current_amount, current: new_amount}
    )

    {:ok, %{amount: new_amount, last_updated_at: now, transactions: transactions ++ [transaction]}, Directive.emit(emit_signal)}
  end

end
