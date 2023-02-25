defmodule NewsBiteWeb.Components.Bite do
  use NewsBiteWeb, :live_component
  alias NewsBite.Bites

  @impl true
  def mount(socket) do
    socket =
      socket
      |> assign(selected_word_group: nil)
      |> assign(loading: false)

    {:ok, socket}
  end

  @impl true
  def render(%{bite: bite, selected_word_group: word_group} = assigns) do
    word_group = word_group || List.first(bite.article_groups)

    ~H"""
    <div class='bg-gray-200 relative'>

      <%= if @loading do %>
        <NewsBiteWeb.Components.Modal.progress fit = "true" notice="Refreshing Bite..."/>
      <% else %>
        <div></div>
      <% end %>

      <div class= "p-4 mb-4">
        <div class="flex justify-between pb-4 gap-4">
          <h2 class="text-xl font-bold"> <%= Bites.get_bite_title(bite) %> </h2>
          <div class="actions justify-self-end">
            <button class="hover:opacity-70" phx-target={@myself} phx-click="edit_bite" phx-value-id={bite.id}> E </button>
            <button class="hover:opacity-70" phx-target={@myself} phx-click="refresh_bite" phx-value-id={bite.id}> R </button>
            <button class="hover:opacity-70" phx-target={@myself} phx-click="delete_bite" phx-value-id={bite.id}> X </button>
          </div>
        </div>
        <div class="flex gap-2 flex-wrap">
          <%= for %{word: word, frequency: frequency, articles: articles} <- bite.article_groups do %>
          <div class = {"rounded-full px-3 py-1 hover:opacity-70 #{if word == word_group.word, do: 'bg-gray-500 text-white', else: 'bg-gray-300'}"}>
            <button phx-target={@myself} phx-click="select_word" phx-value-word={word}>
              <%= word %>
              <span class={"rounded-full px-2 #{if word == word_group.word, do: 'bg-gray-200 text-black', else: 'bg-gray-500 text-white'}"}> <%= frequency %> </span>
            </button>
          </div>
          <% end %>
        </div>

        <div class = "flex flex-col gap-2 pt-4">
          <%= for article <- word_group.articles do %>
            <a class = "bg-gray-300 p-2 hover:opacity-80" href={article.url} target="_blank">
              <h3 class="text-lg"> <%= article.title %> </h3>
              <p class="text-sm text-gray-500"> <%= article.description %> </p>
            </a>
          <% end %>
        </div>
      </div>
    </div>
    """
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

  @impl true
  def handle_event("delete_bite", %{"id" => id}, socket) do
    Bites.delete_bite(id)
    send(self(), {"bite_deleted", id})
    {:noreply, socket}
  end

  @impl true
  def handle_event("refresh_bite", %{"id" => id}, socket) do
    send(self(), {"refresh_bite", id})

    {:noreply, assign(socket, loading: true)}
  end

  @impl true
  def handle_event("edit_bite", %{"id" => id}, socket) do
    bite = Bites.get_bite_by_id(id)
    send(self(), {"show_bite_form", bite})
    {:noreply, socket}
  end
end
