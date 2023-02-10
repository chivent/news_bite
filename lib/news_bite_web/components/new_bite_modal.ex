defmodule NewsBiteWeb.Components.NewBiteModal do
  use NewsBiteWeb, :live_component
  alias NewsBite.Bites

  @impl true
  def mount(socket) do
    {:ok, socket}
  end

  @impl true
  def handle_event("create_bite", _, socket) do
    # TODO: Create bite with params here...
    bite_entry = Bites.create_bite(%{})
    send(self(), {"bite_added", bite_entry})
    send(self(), "close_modal")
    {:noreply, socket}
  end
end
