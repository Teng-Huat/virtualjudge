# VirtualJudge

To start your Phoenix app:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.create && mix ecto.migrate`
  * Install Node.js dependencies with `npm install`
  * Start Phoenix endpoint with `mix phoenix.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](http://www.phoenixframework.org/docs/deployment).

## Configuring for development

If you are using [tmux](https://tmux.github.io/) with [tmuxinator](https://github.com/tmuxinator/tmuxinator), run:

```
cp `pwd`/virtualjudge.yml ~/.tmuxinator/virtualjudge.yml
```

Then edit it to your own likings and binding to your OS

## Some useful cli commands

```
redis-cli flushdb # resets the redisdb
```

## Learn more

  * Official website: http://www.phoenixframework.org/
  * Guides: http://phoenixframework.org/docs/overview
  * Docs: https://hexdocs.pm/phoenix
  * Mailing list: http://groups.google.com/group/phoenix-talk
  * Source: https://github.com/phoenixframework/phoenix
