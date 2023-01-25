defmodule NewsBiteWeb.PageController do
  use NewsBiteWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
