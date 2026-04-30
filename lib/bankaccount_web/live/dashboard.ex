defmodule BankaccountWeb.Dashboard do
  alias Jido.Signal
  alias Bankaccount.Demo.BankAccountAgent
  alias Jido.AgentServer
  use BankaccountWeb, :live_view

  #--Event Handlers--
  @impl true
  def handle_event("deposit", _params, socket) do
    {:noreply, send_signal(socket, "account.deposit", %{amount: 100})}
  end

  @impl true
  def handle_event("withdraw", _params, socket) do
    {:noreply, send_signal(socket, "account.withdraw", %{amount: 100})}
  end

  defp send_signal(socket, signal_type, data) do
    pid = socket.assigns.server_pid
    signal = Signal.new!(signal_type, data, source: "/demo/bank-account-live")

    case AgentServer.call(pid, signal) do
      {:ok, new_agent} ->
        assign(socket, :agent, new_agent)

      {:error, reason} ->
        assign(socket, :error, inspect(reason))
    end
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, pid} = AgentServer.start_link(
      jido: Bankaccount.Jido,
      agent: BankAccountAgent,
      id: "bankaccount-demo-#{System.unique_integer([:positive])}"
    )

    {:ok, server_state} = AgentServer.state(pid)
    agent = server_state.agent

    {:ok,
     socket
     |> assign(:server_pid, pid)
     |> assign(:agent, agent)
     |> assign(:error, nil)}
  end

  @impl true
  def terminate(_reason, socket) do
    if pid = socket.assigns[:server_pid] do
      if Process.alive?(pid), do: GenServer.stop(pid, :normal)
    end
    :ok
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="rounded-lg border border-border bg-card p-6 space-y-6">
      <%!-- Header --%>
      <div class="flex items-center justify-between">
        <div class="flex items-center gap-2">
          <div class="h-2 w-2 rounded-full bg-emerald-400 animate-pulse" />
          <div class="text-sm font-semibold text-foreground">Vault</div>
        </div>
        <div class="text-[10px] text-muted-foreground font-mono bg-muted px-2 py-0.5 rounded border border-border">
          id: {@agent.id |> String.slice(0..7)}…
        </div>
      </div>

      <%!-- Balance --%>
      <div class="flex flex-col items-center py-6">
        <div class="text-6xl font-bold tabular-nums">${@agent.state.amount}</div>
        <div class="text-xs text-muted-foreground mt-1">current balance</div>
      </div>

      <%!-- Error --%>
      <div :if={@error} class="text-sm text-red-400 text-center">{@error}</div>

      <%!-- Controls --%>
      <div class="flex items-center justify-center gap-4">
        <button
          phx-click="withdraw"
          class="px-4 py-2 rounded-md border border-border text-foreground hover:border-red-400/40 transition-colors text-sm font-semibold"
        >
          Withdraw $100
        </button>
        <button
          phx-click="deposit"
          class="px-4 py-2 rounded-md border border-border text-foreground hover:border-emerald-400/40 transition-colors text-sm font-semibold"
        >
          Deposit $100
        </button>
      </div>
    </div>
    """
  end
end
