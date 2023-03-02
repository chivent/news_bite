defmodule NewsBiteWeb.Components.NewBiteModal do
  @moduledoc """
  LiveComponent handling a form for upserting Bites
  """
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
    attrs =
      params
      |> Map.take(["category", "country", "id"])
      |> take_search_term(params)

    send(self(), {"update_bite", attrs})
    {:noreply, assign(socket, loading: true)}
  end

  defp take_search_term(attrs, params) do
    search_term =
      params
      |> Map.get("search_term")
      |> String.trim()

    if search_term != "" do
      Map.put(attrs, "search_term", search_term)
    else
      attrs
    end
  end
end
