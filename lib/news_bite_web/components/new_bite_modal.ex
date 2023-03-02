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
      |> assign(show_error: false)
      |> assign(bite: %Bite{})

    {:ok, socket}
  end

  @impl true
  def handle_event("upsert_bite", %{"new_bite" => params}, socket) do
    if form_valid?(params) do
      search_term = take_search_term(params)

      attrs =
        params
        |> Map.take(["category", "country", "id"])
        |> Map.put("search_term", search_term)

      send(self(), {"upsert_bite", attrs})
      {:noreply, assign(socket, loading: true, show_error: false)}
    else
      {:noreply, assign(socket, show_error: true)}
    end
  end

  defp take_search_term(params) do
    search_term =
      params
      |> Map.get("search_term")
      |> String.trim()

    if search_term != "", do: search_term, else: nil
  end

  defp form_valid?(params) do
    take_search_term(params) || Map.get(params, "country") != "" ||
      Map.get(params, "category") != ""
  end
end
