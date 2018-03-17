use Mix.Config

# In this file, we keep production configuration that
# you likely want to automate and keep it away from
# your version control system.

# You can generate a new secret by running:
#
#     mix phoenix.gen.secret
config :virtual_judge, VirtualJudge.Endpoint,
  secret_key_base: "RxnGxRsPrSbfgtKJ8ITUc57KllBCGe6cS33zZntkCwjNnuoZdUNIF1+O/gnitzgn"

# Configure your database
config :virtual_judge, VirtualJudge.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "virtual_judge_prod",
  hostname: "localhost",
  template: "template0",
  size: 20 # The amount of database connections in the pool

config :sendgrid,
  api_key: "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"

config :virtual_judge, VirtualJudge.Mailer,
  adapter: Bamboo.SendgridAdapter,
  api_key: "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"

config :virtual_judge, codechef_username: "steve0hh",
codechef_password: "6RWCr+7ia^HtyN"

config :virtual_judge, codeforce_username: "steve0hh",
codeforce_password: "TiLza]R,h82Zyw"

config :virtual_judge, poj_username: "steve0hh",
poj_password: "gRIrDsT4nw3HCumX"

config :virtual_judge, timus_judge_id: "220933LG"

config :virtual_judge, zoj_username: "steve0hh",
zoj_password: "rkVowkuY2rJtLqkYGNQGxmzE"

config :virtual_judge, hust_username: "steve0hh",
hust_password: "RZ#ztCCLg9(n3Y"

config :virtual_judge, lydsy_username: "steve0hh",
lydsy_password: "J2mp#cG{c4mcGMdEHziBC"

config :virtual_judge, fzu_username: "steve0hh",
fzu_password: "qB69*kkvVqaGQUq*nEGnP"

config :virtual_judge, ACMHDU_username: "siumin",
ACMHDU_password: "1234567890"

config :virtual_judge, UVA_username: "siuminang",
UVA_password: "1234567890"

config :virtual_judge, A2OJ_username: "siumin",
A2OJ_password: "1234567890"

config :virtual_judge, SPOJ_username: "siumin",
SPOJ_password: "1234567890"

config :virtual_judge, LightOJ_username: "sang022@e.ntu.edu.sg",
LightOJ_password: "1234567890"

config :virtual_judge, URI_username: "sang022@e.ntu.edu.sg",
URI_password: "1234567890"

config :virtual_judge, ACMSGU_username: "070538",
ACMSGU_password: "1234567890"
