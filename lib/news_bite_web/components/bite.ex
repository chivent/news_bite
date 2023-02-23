defmodule NewsBiteWeb.Components.Bite do
  use NewsBiteWeb, :live_component

  @impl true
  def mount(socket) do
    socket = assign(socket, selected_word_group: %{articles: []})
    {:ok, socket}
  end

  @impl true
  def render(%{bite: bite, selected_word_group: word_group} = assigns) do
    ~H"""
    <div class='bg-gray-200 p-4'>
      <div class="flex gap-2 flex-wrap">
        <%= for %{word: word, frequency: frequency, articles: articles} <- bite.article_groups do %>
        <div class = "bg-gray-300 rounded-full px-2">
          <button phx-target={@myself} phx-click="select_word" phx-value-word={word}> <%= word %> </button>
        </div>
        <% end %>
      </div>
      <div class = "flex flex-col gap-2 pt-4">
        <%= for article <- word_group.articles do %>
          <div class = "bg-gray-300 p-2"> <%= article.title %> </div>
        <% end %>
      </div>
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

  @impl true
  def handle_event("select_word", %{"word" => word}, socket) do
    word_group =
      Enum.find(socket.assigns.bite.article_groups, fn article_group ->
        article_group.word == word
      end)

    socket = assign(socket, selected_word_group: word_group)
    {:noreply, socket}
  end
end
