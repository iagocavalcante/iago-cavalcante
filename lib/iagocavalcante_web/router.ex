defmodule IagocavalcanteWeb.Router do
  use IagocavalcanteWeb, :router

  import IagocavalcanteWeb.UserAuth
  use Gettext, backend: IagocavalcanteWeb.Gettext

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {IagocavalcanteWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
    plug IagocavalcanteWeb.Plugs.Locale
    plug IagocavalcanteWeb.Plugs.MetaTags
  end

  pipeline :admin_layout do
    plug :put_layout, {IagocavalcanteWeb.Layouts, :admin}
  end

  pipeline :app_layout do
    plug :put_layout, {IagocavalcanteWeb.Layouts, :app}
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug :fetch_session
    plug :fetch_flash
    plug :put_secure_browser_headers
    plug :fetch_current_user
    plug IagocavalcanteWeb.Plugs.CORS
  end

  pipeline :api_auth do
    plug IagocavalcanteWeb.Plugs.ApiAuth
  end

  pipeline :require_authenticated_admin do
    plug :require_authenticated_user
    plug IagocavalcanteWeb.Plugs.RequireAdmin
  end

  # API routes
  scope "/api", IagocavalcanteWeb.API, as: :api do
    pipe_through :api

    # Public API routes (no auth required)
    get "/health", HealthController, :check
  end

  scope "/api", IagocavalcanteWeb.API, as: :api do
    pipe_through [:api, :api_auth]

    # Bookmark management
    resources "/bookmarks", BookmarkController, except: [:new, :edit] do
      patch "/archive", BookmarkController, :archive
      patch "/favorite", BookmarkController, :toggle_favorite
      patch "/read", BookmarkController, :mark_as_read
    end

    get "/bookmarks-stats", BookmarkController, :stats
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:iagocavalcante, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: IagocavalcanteWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  pipeline :comment_rate_limit do
    plug IagocavalcanteWeb.Plugs.RateLimiter
  end

  scope "/", IagocavalcanteWeb do
    pipe_through [:browser, :app_layout]

    live_session :public_session,
      layout: {IagocavalcanteWeb.Layouts, :app},
      on_mount: [
        IagocavalcanteWeb.Nav,
        IagocavalcanteWeb.RestoreLocale
      ] do
      live "/", HomeLive, :home

      # English routes
      live "/about", AboutLive, :about
      live "/articles", ArticlesLive.Index, :index
      live "/articles/:id", ArticlesLive.Show, :show
      live "/videos", VideosLive.Index, :index
      live "/videos/:id", VideosLive.Show, :show
      live "/projects", ProjectsLive, :projects
      live "/speaking", SpeakingLive, :speaking
      live "/uses", UsesLive, :uses
      live "/analytics", AnalyticsLive, :analytics
      live "/bookmarks", BookmarksLive, :bookmarks

      # Portuguese routes (same LiveViews)
      live "/sobre", AboutLive, :about
      live "/artigos", ArticlesLive.Index, :index
      live "/artigos/:id", ArticlesLive.Show, :show
      live "/projetos", ProjectsLive, :projects
      live "/palestras", SpeakingLive, :speaking
      live "/setup", UsesLive, :uses
      live "/favoritos", BookmarksLive, :bookmarks

      live "/privacy", PrivacyLive, :privacy
      live "/subscribers/confirm/:token", SubscriberVerifyLive, :subscriber_verify
    end
  end

  ## Authentication routes

  scope "/admin", IagocavalcanteWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated, :app_layout]

    live_session :redirect_if_user_is_authenticated,
      layout: {IagocavalcanteWeb.Layouts, :app},
      on_mount: [
        {IagocavalcanteWeb.UserAuth, :redirect_if_user_is_authenticated},
        IagocavalcanteWeb.AdminNav
      ] do
      live gettext("/login"), UserLoginLive, :new
      # Registration disabled - only specific admin email allowed
      # live "/register", UserRegistrationLive, :new
      live "/reset_password", UserForgotPasswordLive, :new
      live "/reset_password/:token", UserResetPasswordLive, :edit
    end

    post "/login", UserSessionController, :create
  end

  scope "/admin", IagocavalcanteWeb do
    pipe_through [:browser, :require_authenticated_admin, :admin_layout]

    live_session :require_authenticated_admin,
      layout: {IagocavalcanteWeb.Layouts, :admin},
      on_mount: [
        {IagocavalcanteWeb.UserAuth, :ensure_authenticated_admin},
        IagocavalcanteWeb.AdminNav
      ] do
      # live "/users/register", UserRegistrationLive, :new
      live "/users/settings", UserSettingsLive, :edit
      live "/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email
      live "/posts", Admin.PostsLive.Index, :index
      live "/posts/new", Admin.PostsLive.New, :new
      live "/posts/:id/edit", Admin.PostsLive.Index, :edit
      live "/posts/:id", Admin.PostsLive.Show, :show
      live "/posts/:id/show/edit", Admin.PostsLive.Show, :edit
      live "/videos", Admin.VideosLive.Index, :index
      live "/comments", Admin.CommentsLive, :index
    end
  end

  scope "/", IagocavalcanteWeb do
    pipe_through [:browser, :app_layout]

    delete "/users/log_out", UserSessionController, :delete

    live_session :current_user,
      on_mount: [{IagocavalcanteWeb.UserAuth, :mount_current_user}] do
      live "/users/confirm/:token", UserConfirmationLive, :edit
      live "/users/confirm", UserConfirmationInstructionsLive, :new
    end
  end
end
