defmodule NewsBiteWeb.Helpers.IconHelper do
  @moduledoc """
  Provides icons for templates
  """
  use Phoenix.HTML
  alias NewsBiteWeb.Router.Helpers, as: Routes

  def icon_tag(conn, name, opts \\ []) do
    opts = Keyword.update(opts, :class, "icon", &("icon " <> &1))

    content_tag(:svg, opts) do
      tag(:use, href: Routes.static_path(conn, "/images/icons.svg#" <> name))
    end
  end
end
