defmodule CashtrayWeb.Router do
  use CashtrayWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", CashtrayWeb do
    pipe_through :api
  end
end
