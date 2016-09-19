defmodule VirtualJudge.Router do
  use VirtualJudge.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug VirtualJudge.Auth, repo: VirtualJudge.Repo
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", VirtualJudge do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    resources "/problem", ProblemController, only: [:index, :show] do
      resources "/answer", AnswerController, only: [:create]
    end
    resources "/sign_up", RegistrationController, only: [:new, :create]
    resources "/sign_in", SessionController, only: [:new, :create, :delete]

    get "/sign_up/:id/:invitation_token", RegistrationController, :edit
    put "/sign_up/:id/:invitation_token", RegistrationController, :update

    scope "/admin", Admin, as: :admin do
      get "/invite", InvitationController, :new
      post "/invite", InvitationController, :create
      get "/users", UserController, :index
      get "/export", UserController, :export
    end

  end

  # Other scopes may use custom stacks.
  # scope "/api", VirtualJudge do
  #   pipe_through :api
  # end
end
