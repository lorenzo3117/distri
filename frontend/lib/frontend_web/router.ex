defmodule FrontendWeb.Router do
  use FrontendWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_live_flash)
    plug(:put_root_layout, {FrontendWeb.LayoutView, :root})
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", FrontendWeb do
    pipe_through(:browser)

    live("/", IndexLive, :index)
    live("/coinflip_room/:id", CoinflipRoomLive, :coinflip_room)
    live("/logs", LogsLive, :logs)
  end

  scope "/auth", FrontendWeb do
    pipe_through(:browser)

    get("/", AuthController, :index)
    get("/login/:id", AuthController, :login)
    get("/logout", AuthController, :logout)
  end

  scope "/players", FrontendWeb do
    pipe_through(:browser)

    post("/", PlayersController, :player)
    delete("/:id", PlayersController, :remove)
  end

  # Other scopes may use custom stacks.
  # scope "/api", FrontendWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through(:browser)

      live_dashboard("/dashboard", metrics: FrontendWeb.Telemetry)
    end
  end

  # Enables the Swoosh mailbox preview in development.
  #
  # Note that preview only shows emails that were sent by the same
  # node running the Phoenix server.
  if Mix.env() == :dev do
    scope "/dev" do
      pipe_through(:browser)

      forward("/mailbox", Plug.Swoosh.MailboxPreview)
    end
  end
end
