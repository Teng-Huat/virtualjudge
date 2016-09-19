defimpl Canada.Can, for: VirtualJudge.User do
  alias VirtualJudge.User

  def can?(%User{type: "admin"}, action, User)
  when action in [:index, :new, :create, :export], do: true

  def can?(%User{}, _, _), do: false

  def can?(subject, action, resource) do
    raise """
    Unimplemented authorization check for User!  To fix see below...

    Please implement `can?` for User in #{__ENV__.file}.

    The function should match:

    subject:  #{inspect subject}

    action:   #{action}

    resource: #{inspect resource}
    """
  end
end

defimpl Canada.Can, for: Atom do
  def can?(nil, _action, _resource) do
    false
  end
end
