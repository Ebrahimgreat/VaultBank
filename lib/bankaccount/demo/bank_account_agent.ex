defmodule Bankaccount.Demo.BankAccountAgent do
  use Jido.Agent,
  name: "vault",
  description: "Vault — a bank account agent for deposits and withdrawals",
  schema: [
    amount: [type: :integer, default: 0],
    last_updated_at: [type: :any, default: nil],
    transactions: [type: :any, default: nil]
  ]
  alias Bankaccount.Demo.{
    DepositAction,
    WithrawAction

  }
  @impl true
  def signal_routes(_ctx) do
    [
      {"account.deposit", DepositAction},
      {"account.withdraw", WithrawAction}
    ]
  end

end
