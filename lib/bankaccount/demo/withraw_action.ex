defmodule Bankaccount.Demo.WithrawAction do
  alias Jido.Signal
  alias Jido.Agent.Directive
  use Jido.Action,
  name: "withraw_action",
  description: "Withrawing amount",
  schema: [
    amount: [type: :integer, default: 10, doc: "Withrawing amount"]
  ]
  @impl true
  def run(%{amount: amount}, context) do
    current_amount = Map.get(context.state, :amount, 0)
    transactions = Map.get(context.state, :transactions) || []

    if amount > current_amount do
      {:error, "Insufficient funds: balance is #{current_amount}"}
    else
      new_amount = current_amount - amount
      now = DateTime.utc_now()

      transaction = %{type: :withdrawal, amount: amount, balance: new_amount, at: now}

      emit_signal = Signal.new!(
        "withdrawal.completed",
        %{delta: amount, previous: current_amount, current: new_amount},
        source: "/demo/withdraw-action"
      )

      {:ok, %{amount: new_amount, last_updated_at: now, transactions: transactions ++ [transaction]}, Directive.emit(emit_signal)}
    end
  end

end
