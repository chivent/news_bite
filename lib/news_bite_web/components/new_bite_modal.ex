defmodule NewsBiteWeb.Components.NewBiteModal do
  use NewsBiteWeb, :live_component
  alias NewsBite.Bites

  @impl true
  def mount(socket) do
    {:ok, socket}
  end

  @impl true
  def handle_event("create_bite", %{"new_bite" => params}, socket) do
    params =
      Map.take(params, ["category"])
      |> Map.put("search_terms", [Map.get(params, "search_terms")])

    bite_entry = Bites.create_bite(params)
    send(self(), {"bite_updated", bite_entry})
    send(self(), "close_modal")
    {:noreply, socket}
  end
end
