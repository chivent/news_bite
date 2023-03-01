defmodule NewsBiteWeb.Components.Modal do
  alias NewsBiteWeb.Helpers.IconHelper

  use Phoenix.Component

  def overlay(assigns) do
    fit = Map.get(assigns, :fit) || false
    dismissable = Map.get(assigns, :dismissable) || false

    ~H"""
    <div class={if fit, do: "absolute w-full h-full z-10", else: "fixed w-screen h-screen z-10"}>
      <%= render_slot(@inner_block) %>
      <div phx-click={if dismissable, do: "close_modal", else: nil} class={if fit, do: "w-full h-full", else: "w-screen h-screen"}} style={"background-color: rgba(0, 0, 0, #{if fit, do: 0.25, else: 0.5});"}> </div>
    </div>
    """
  end

  def progress(assigns) do
    fit = Map.get(assigns, :fit) || false
    title = Map.get(assigns, :notice) || "Please Wait..."

    ~H"""
      <.overlay fit={fit}>
        <div class={"absolute #{if fit, do: 'w-full h-full', else: 'w-screen h-screen'}"}>
          <div role="status" class="flex justify-center items-center h-full">
            <div class="flex items-center bg-white rounded-md p-4">
              <svg aria-hidden="true" class="w-8 h-8 mr-2 text-gray-200 animate-spin fill-blue-600" viewBox="0 0 100 101" fill="none" xmlns="http://www.w3.org/2000/svg">
                  <path d="M100 50.5908C100 78.2051 77.6142 100.591 50 100.591C22.3858 100.591 0 78.2051 0 50.5908C0 22.9766 22.3858 0.59082 50 0.59082C77.6142 0.59082 100 22.9766 100 50.5908ZM9.08144 50.5908C9.08144 73.1895 27.4013 91.5094 50 91.5094C72.5987 91.5094 90.9186 73.1895 90.9186 50.5908C90.9186 27.9921 72.5987 9.67226 50 9.67226C27.4013 9.67226 9.08144 27.9921 9.08144 50.5908Z" fill="currentColor"/>
                  <path d="M93.9676 39.0409C96.393 38.4038 97.8624 35.9116 97.0079 33.5539C95.2932 28.8227 92.871 24.3692 89.8167 20.348C85.8452 15.1192 80.8826 10.7238 75.2124 7.41289C69.5422 4.10194 63.2754 1.94025 56.7698 1.05124C51.7666 0.367541 46.6976 0.446843 41.7345 1.27873C39.2613 1.69328 37.813 4.19778 38.4501 6.62326C39.0873 9.04874 41.5694 10.4717 44.0505 10.1071C47.8511 9.54855 51.7191 9.52689 55.5402 10.0491C60.8642 10.7766 65.9928 12.5457 70.6331 15.2552C75.2735 17.9648 79.3347 21.5619 82.5849 25.841C84.9175 28.9121 86.7997 32.2913 88.1811 35.8758C89.083 38.2158 91.5421 39.6781 93.9676 39.0409Z" fill="currentFill"/>
              </svg>
              <span><%= title %></span>
            </div>
          </div>
        </div>
      </.overlay>
    """
  end

  def help(assigns) do
    example_bite = %NewsBite.Bite{
      id: nil,
      category: :technology,
      search_term: "apple",
      article_groups: [
        %NewsBite.ArticleGroup{
          word: "word_1",
          frequency: 1,
          articles: [
            %NewsBite.Article{
              id: :mock,
              title: "Article Title",
              description: "This is a description with word_1",
              url: ""
            }
          ]
        }
      ]
    }

    ~H"""
      <.overlay dismissable={true}>
        <div class="absolute top-0 right-0 bottom-0 left-0 m-auto bg-white w-4/5 h-4/5 rounded-md overflow-y-hidden flex flex-col">
          <div class="flex justify-between items-center p-4">
            <p class="text-2xl font-bold"> Welcome to NewsBite! </p>
            <button class="py-2 px-4" type="button" phx-click="close_modal">
              <%= IconHelper.icon_tag(NewsBiteWeb.Endpoint, "cross", class: "h-6 w-6") %>
            </button>
          </div>

          <div class="space-y-4 overflow-y-scroll p-4 px-6">
            <div class="bg-slate-100 border border-solid border-blue-200 p-4 rounded">
              <p>This app helps you follow the latest news through Bites, groups that highlight the top 10 mentioned words in the 100 newest articles for a certain topic.</p>
            </div>
            <p class="pt-2 text-base">Every Bite can be created with specific search terms, category and country to search for news in.</p>
            <%= live_component NewsBiteWeb.Components.Bite, id: :mock, bite: example_bite %>
            <ul class="list-disc ml-6">
              <li> Word Badge - A top 10 frequently mentioned words and the number of times it has been repeated. Selecting a word lists the articles containing it. </li>
              <li> <p class="flex items-end"> <%= IconHelper.icon_tag(NewsBiteWeb.Endpoint, "refresh", class: "h-5 w-5") %> - Click to retrieve the latest news for this bite. </p> </li>
              <li> <p class="flex items-end"> <%= IconHelper.icon_tag(NewsBiteWeb.Endpoint, "edit", class: "h-5 w-5") %> - Click to update the search terms of the bite. </p> </li>
              <li> <p class="flex items-end"> <%= IconHelper.icon_tag(NewsBiteWeb.Endpoint, "delete", class: "h-5 w-5") %> - Click to remove the bite. </p></li>
              <li> Article - An article related to the currently selected word. Click to visit the article </li>
            </ul>

            <p> You may create multiple Bites to follow various topics. All Bites are refreshed every 4 hours, but a manual refresh of all Bites can be triggered by clicking on __.</p>
            <div class="pt-2">
              <p class="italic text-gray-400"> As this project is under development, only 100 Bite refreshes can triggered each day. <br> Happy news following! </p>
            </div>
          </div>
        </div>
      </.overlay>
    """
  end
end
