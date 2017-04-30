FROM armhf/alpine
MAINTAINER Pablo Carranza <pcarranza@gmail.com>

RUN apk --no-cache add \
	erlang \
        erlang-ssl \
	erlang-crypto \
	erlang-syntax-tools \
	git \
        elixir

ENV MIX_ENV prod

# RUN groupadd --gid 60000 operable
# RUN useradd -d /home/operable -u 60000 -g operable -s /bin/ash operable

RUN addgroup -g 60000 operable && \
    adduser -h /home/operable -D -u 60000 -G operable -s /bin/ash operable

# Create directories and upload cog source
WORKDIR /home/operable/cog

# Really, we only need the cog directory to be owned by operable,
# because (by default) that's where we write log files. None of the
# actual scripts or library files need to be owned by operable.
RUN chown -R operable /home/operable/cog

COPY mix.exs mix.lock /home/operable/cog/
COPY config/ /home/operable/cog/config/

RUN mix local.hex --force && mix local.rebar --force && mix deps.get --only=prod --no-archives-check

# Compile all the dependencies. The additional packages installed here
# are for Greenbar to build and run.
RUN apk --no-cache add \
        --virtual .build_deps \
        gcc \
        g++ && \
    apk --no-cache add \
        expat-dev \
        libstdc++ \
	openssl-dev

RUN apk --no-cache add \
	make \
	erlang-dev \
	erlang-parsetools

ENV DEBUG 1

RUN mix deps.compile && \
    apk del .build_deps

COPY emqttd_plugins/ /home/operable/cog/emqttd_plugins/
COPY priv/ /home/operable/cog/priv/
COPY web/ /home/operable/cog/web/
COPY lib/ /home/operable/cog/lib/

RUN mix compile --no-deps-check --no-archives-check

COPY scripts/ /home/operable/cog/scripts/

# This should be in place in the build environment already
# COPY cogctl-for-docker-build /usr/local/bin/cogctl

USER operable
RUN mix local.hex --force
