defmodule TestAppWeb.Router do
  use TestAppWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end
  
  scope "/api", TestAppWeb.Api do
    pipe_through :api

    get "/info", ImageController, :info
    get "/thumbnail", ImageController, :thumbnail
  end

  scope "/", TestAppWeb do
    pipe_through :browser

    get "/", PageController, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", TestAppWeb do
  #   pipe_through :api
  # end
end
