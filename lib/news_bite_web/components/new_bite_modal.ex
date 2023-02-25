defmodule NewsBiteWeb.Components.NewBiteModal do
  use NewsBiteWeb, :live_component
  alias NewsBite.{Bite, Bites}

  @impl true
  def mount(socket) do
    socket =
      socket
      |> assign(loading: false)
      |> assign(bite: %Bite{})

    {:ok, socket}
  end

  @impl true
  def handle_event("upsert_bite", %{"new_bite" => params}, socket) do
    attrs =
      Map.take(params, ["category", "country", "id"])
      |> Map.put("search_terms", [Map.get(params, "search_terms")])

    send(self(), {"update_bite", attrs})
    {:noreply, assign(socket, loading: true)}
  end
end
