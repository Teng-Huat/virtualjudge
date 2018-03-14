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

  pipeline :user do
    plug :authenticate_user
    plug VirtualJudge.Authorize, scope: :user
  end

  pipeline :admin do
    plug :authenticate_user
    plug VirtualJudge.Authorize, scope: :admin
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  # unauthenticated scope
  scope "/", VirtualJudge do
    pipe_through [:browser] # Use the default browser stack
    get "/", PageController, :index
    get "/help", PageController, :help
    resources "/sign_up", RegistrationController, only: [:new, :create]
    resources "/sign_in", SessionController, only: [:new, :create, :delete]
    get "/sign_up/:id/:invitation_token", RegistrationController, :edit
    put "/sign_up/:id/:invitation_token", RegistrationController, :update
    # reset password routes
    get "/reset_password", ResetPasswordController, :new
    post "/reset_password", ResetPasswordController, :create
    get "/reset_password/:id/:reset_password_token", ResetPasswordController, :edit
    put "/reset_password/:id", ResetPasswordController, :reset
  end

  # normal user authenticated scope
  scope "/", VirtualJudge do
    pipe_through [:browser, :user]
    resources "/problem", ProblemController, only: [:show]
    resources "/answer", AnswerController, only: [:index, :show]

    resources "/contest", ContestController, only: [:index, :show] do
      resources "/problems", ProblemController, only: [:show] do
        resources "/answer", AnswerController, only: [:create]
      end
    end

    post "/contest/:id", ContestController, :join

    resources "/practice", PracticeController, only: [:index] do
      resources "/problem", ProblemController, only: [:show] do
        resources "/answer", AnswerController, only: [:create]
      end
    end
  end

  # admin scope
  scope "/admin", VirtualJudge.Admin, as: :admin do
    pipe_through [:browser, :admin]
    get "/invite", InvitationController, :new
    post "/invite", InvitationController, :create
    put "/invite/:id", InvitationController, :resend_invitation

    resources "/user", UserController, except: [:show]
    post "/user/:id", UserController, :delete
    resources "/team", TeamController, only: [:index, :create, :delete]
    post "/team/:id", TeamController, :delete
    get "/export", UserController, :export
    get "/problem/export", ProblemController, :export
    resources "/contest", ContestController
    post "/contest/:id", ContestController, :delete
    get "/contest/export/:id", ContestController, :export
    resources "/practice", PracticeController
    post "/practice/:id", PracticeController, :delete
    resources "/problem", ProblemController
    post "/problem", ProblemController, :filter
    post "/problem/:id", ProblemController, :delete
    resources "/answer", AnswerController, only: [:show]
  end

  # Other scopes may use custom stacks.
  # scope "/api", VirtualJudge do
  #   pipe_through :api
  # end
end
