defmodule NewsBiteWeb.NewsBiteLive do
  alias NewsBite.{Bite, Bites, BiteCache}

  use NewsBiteWeb, :live_view
  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(modal_shown: nil)
      |> assign(flash_timer: nil)
      |> assign_bites()

    Phoenix.PubSub.subscribe(NewsBite.PubSub, "live_update")

    {:ok, socket}
  end

  defp assign_bites(socket) do
    assign(socket, bites: BiteCache.list_bites() |> Enum.into(%{}))
  end

  @impl true
  def handle_event("show_empty_bite_form", _params, socket) do
    send(self(), {"show_bite_form", %Bite{}})
    {:noreply, socket}
  end

  @impl true
  def handle_event("show_help_modal", _, socket) do
    {:noreply, assign(socket, modal_shown: :help)}
  end

  @impl true
  def handle_event("close_modal", _params, socket) do
    send(self(), "close_modal")
    {:noreply, socket}
  end

  @impl true
  def handle_event("refresh_all", _params, socket) do
    Process.send(:bite_cache, {:refresh_news, self()}, [])
    {:noreply, assign(socket, modal_shown: :refreshing_all)}
  end

  @impl true
  def handle_info({"show_flash", {type, message}}, socket) do
    socket.assigns.flash_timer && Process.cancel_timer(socket.assigns.flash_timer)
    timer_ref = Process.send_after(self(), "hide_flash", 4000)

    socket =
      socket
      |> put_flash(type, message)
      |> assign(flash_timer: timer_ref)

    {:noreply, socket}
  end

  @impl true
  def handle_info("hide_flash", socket) do
    socket =
      socket
      |> clear_flash()
      |> assign(flash_timer: nil)

    {:noreply, socket}
  end

  @impl true
  def handle_info("close_modal", socket) do
    {:noreply, assign(socket, modal_shown: nil)}
  end

  @impl true
  def handle_info({"show_bite_form", bite}, socket) do
    send_update(NewsBiteWeb.Components.NewBiteModal, id: "new_bite_modal", bite: bite)
    {:noreply, assign(socket, modal_shown: :new_bite_form)}
  end

  @impl true
  def handle_info("update_available", socket) do
    send(
      self(),
      {"show_flash",
       {:info, "Updated bites available! You may refresh the page to view the updates."}}
    )

    {:noreply, assign(socket, update_available: true)}
  end

  @impl true
  def handle_info("bites_refreshed", socket) do
    send(self(), "close_modal")
    send(self(), {"show_flash", {:success, "All Bites Refreshed!"}})

    socket =
      socket
      |> assign(bites: BiteCache.list_bites() |> Enum.into(%{}))

    {:noreply, socket}
  end

  @impl true
  def handle_info({"bite_deleted", id}, socket) do
    updated_bites = Map.delete(socket.assigns.bites, id)
    send(self(), {"show_flash", {:success, "Bite Deleted!"}})

    {:noreply, assign(socket, bites: updated_bites)}
  end

  @impl true
  def handle_info({"update_bite", attrs}, socket) do
    bite = Bites.upsert_bite(attrs)
    updated_bites = Map.put(socket.assigns.bites, bite.id, bite)

    send(self(), "close_modal")
    send(self(), {"show_flash", {:success, "Bite Updated!"}})

    {:noreply, assign(socket, bites: updated_bites)}
  end

  @impl true
  def handle_info({"refresh_bite", id}, socket) do
    bite = Bites.upsert_bite_article_groups(id)

    send_update(NewsBiteWeb.Components.Bite, id: id, loading: false, selected_word_group: nil)

    updated_bites = Map.put(socket.assigns.bites, id, bite)
    {:noreply, assign(socket, bites: updated_bites)}
  end
end
