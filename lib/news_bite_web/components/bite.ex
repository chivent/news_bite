defmodule NewsBiteWeb.Components.Bite do
  use NewsBiteWeb, :live_component

  @impl true
  def mount(socket) do
    {:ok, socket}
  end

  @impl true
  def render(%{bite: bite, summary: summary} = assigns) do
    ~H"""
    <div class='bg-gray-200'>
      <ul>
        <%= for {word, _count} <- summary do %>
          <li> <%= word %> </li>
        <% end %>
      </ul>
      <button phx-target={@myself} phx-click="delete_bite" phx-value-id={bite.id}> X </button>
    </div>
    """
  end

  @impl true
  def handle_event("delete_bite", %{"id" => id}, socket) do
    NewsBite.Bites.delete_bite(id)
    send(self(), {"bite_deleted", id})
    {:noreply, socket}
  end
end
