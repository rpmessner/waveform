defmodule WaveformWeb.PageController do
  use WaveformWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
