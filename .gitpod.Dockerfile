FROM gitpod/workspace-postgres
                    
USER root

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update \
    && apt-get install erlang -y \
    && apt-get install elixir -y

RUN mix local.hex --force \
  && mix local.rebar --force

ENV POSTGRES_USERNAME=gitpod
ENV POSTGRES_PASSWORD=
