defmodule NewsBiteWeb.NewsBiteLive do
  alias NewsBite.BiteCache

  use NewsBiteWeb, :live_view
  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(modal_open: false)
      |> assign_bite_entries()

    {:ok, socket}
  end

  defp assign_bite_entries(socket) do
    assign(socket, bite_entries: BiteCache.list_bites() |> Enum.into(%{}))
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
    {:noreply, assign_bite_entries(socket)}
  end

  @impl true
  def handle_info("close_modal", socket) do
    {:noreply, assign(socket, modal_open: false)}
  end

  @impl true
  def handle_info({"bite_updated", bite_entry}, socket) do
    updated_bite_entries = Map.put(socket.assigns.bite_entries, bite_entry.bite.id, bite_entry)
    {:noreply, assign(socket, bite_entries: updated_bite_entries)}
  end

  @impl true
  def handle_info({"bite_deleted", id}, socket) do
    updated_bite_entries = Map.delete(socket.assigns.bite_entries, id)
    {:noreply, assign(socket, bite_entries: updated_bite_entries)}
  end
end
