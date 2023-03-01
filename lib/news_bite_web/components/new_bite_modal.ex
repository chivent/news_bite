defmodule NewsBiteWeb.Components.NewBiteModal do
  use NewsBiteWeb, :live_component
  alias NewsBite.Bite

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
    search_term =
      params
      |> Map.get("search_term")
      |> String.trim()

    attrs = Map.take(params, ["category", "country", "id"])

    attrs =
      if search_term != "" do
        Map.put(attrs, "search_term", search_term)
      else
        attrs
      end

    send(self(), {"update_bite", attrs})
    {:noreply, assign(socket, loading: true)}
  end
end
