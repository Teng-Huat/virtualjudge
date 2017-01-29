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

  # unauthenticated scope
  scope "/", VirtualJudge do
    pipe_through [:browser] # Use the default browser stack
    get "/", PageController, :index
    resources "/sign_up", RegistrationController, only: [:new, :create]
    resources "/sign_in", SessionController, only: [:new, :create, :delete]
    get "/sign_up/:id/:invitation_token", RegistrationController, :edit
    put "/sign_up/:id/:invitation_token", RegistrationController, :update
  end

  # normal user authenticated scope
  scope "/", VirtualJudge do
    pipe_through [:browser, :authenticate_user] # Use the default browser stack
    resources "/problem", ProblemController, only: [:show]
    resources "/answer", AnswerController, only: [:index, :show]

    resources "/contest", ContestController, only: [:index, :show] do
      resources "/problems", ProblemController, only: [:show] do
        resources "/answer", AnswerController, only: [:create]
      end
    end

    put "/contest/:id", ContestController, :join

    resources "/practice", PracticeController, only: [:index] do
      resources "/problem", ProblemController, only: [:show] do
        resources "/answer", AnswerController, only: [:create]
      end
    end
  end

  # admin scope
  scope "/admin", VirtualJudge.Admin, as: :admin do
    pipe_through [:browser] # Use the default browser stack
    get "/invite", InvitationController, :new
    post "/invite", InvitationController, :create
    get "/users", UserController, :index
    get "/export", UserController, :export
    resources "/contest", ContestController
    get "/contest/export/:id", ContestController, :export
    resources "/practice", PracticeController
    resources "/problem", ProblemController
  end

  # Other scopes may use custom stacks.
  # scope "/api", VirtualJudge do
  #   pipe_through :api
  # end
end
