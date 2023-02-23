defmodule NewsBiteWeb.NewsBiteLive do
  alias NewsBite.BiteCache

  use NewsBiteWeb, :live_view
  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(modal_open: false)
      |> assign_bites()

    {:ok, socket}
  end

  defp assign_bites(socket) do
    assign(socket, bites: BiteCache.list_bites() |> Enum.into(%{}))
  end

  @impl true
  def handle_event("open_modal", _params, socket) do
    {:noreply, assign(socket, modal_open: true)}
  end

  @impl true
  def handle_event("close_modal", _params, socket) do
    send(self(), "close_modal")
    {:noreply, socket}
  end

  @impl true
  def handle_event("refresh_all", _params, socket) do
    # send(BiteCache, "refresh_news")
    {:noreply, assign_bites(socket)}
  end

  @impl true
  def handle_info("close_modal", socket) do
    {:noreply, assign(socket, modal_open: false)}
  end

  @impl true
  def handle_info({"bite_updated", bite}, socket) do
    updated_bites = Map.put(socket.assigns.bites, bite.id, bite)
    {:noreply, assign(socket, bites: updated_bites)}
  end

  @impl true
  def handle_info({"bite_deleted", id}, socket) do
    updated_bites = Map.delete(socket.assigns.bites, id)
    {:noreply, assign(socket, bites: updated_bites)}
  end
end
