defmodule IagocavalcanteWeb.Router do
  use IagocavalcanteWeb, :router

  import IagocavalcanteWeb.UserAuth
  import IagocavalcanteWeb.Gettext

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {IagocavalcanteWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
    plug IagocavalcanteWeb.Plugs.Locale
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  # Other scopes may use custom stacks.
  # scope "/api", IagocavalcanteWeb do
  #   pipe_through :api
  # end

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

  scope "/", IagocavalcanteWeb do
    pipe_through [:browser]

    live_session :public_session,
      on_mount: [
        IagocavalcanteWeb.Nav,
        IagocavalcanteWeb.RestoreLocale
      ] do
      live "/", HomeLive, :home
      live gettext("/about"), AboutLive, :about
      live gettext("/articles"), ArticlesLive.Index, :index
      live gettext("/articles/:id"), ArticlesLive.Show, :show
      live gettext("/videos"), VideosLive.Index, :index
      live gettext("/videos/:id"), VideosLive.Show, :show
      live gettext("/projects"), ProjectsLive, :projects
      live gettext("/speaking"), SpeakingLive, :speaking
      live gettext("/uses"), UsesLive, :uses
      live gettext("/analytics"), AnalyticsLive, :analytics
      live "/subscribers/confirm/:token", SubscriberVerifyLive, :subscriber_verify
    end
  end

  ## Authentication routes

  scope "/admin", IagocavalcanteWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [
        {IagocavalcanteWeb.UserAuth, :redirect_if_user_is_authenticated},
        IagocavalcanteWeb.Nav
      ] do
      live gettext("/login"), UserLoginLive, :new
      live "/register", UserRegistrationLive, :new
      live "/reset_password", UserForgotPasswordLive, :new
      live "/reset_password/:token", UserResetPasswordLive, :edit
    end

    post "/login", UserSessionController, :create
  end

  scope "/admin", IagocavalcanteWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{IagocavalcanteWeb.UserAuth, :ensure_authenticated}, IagocavalcanteWeb.Nav] do
      # live "/users/register", UserRegistrationLive, :new
      live "/users/settings", UserSettingsLive, :edit
      live "/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email
      live "/posts", Admin.PostsLive.Index, :index
      live "/posts/new", Admin.PostsLive.New, :new
      live "/posts/:id/edit", Admin.PostsLive.Index, :edit
      live "/posts/:id", Admin.PostsLive.Show, :show
      live "/posts/:id/show/edit", Admin.PostsLive.Show, :edit
      live "/videos", Admin.VideosLive.Index, :index
    end
  end

  scope "/", IagocavalcanteWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete

    live_session :current_user,
      on_mount: [{IagocavalcanteWeb.UserAuth, :mount_current_user}] do
      live "/users/confirm/:token", UserConfirmationLive, :edit
      live "/users/confirm", UserConfirmationInstructionsLive, :new
    end
  end
end
