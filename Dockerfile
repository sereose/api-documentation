FROM elixir:1.10.0

RUN mix local.hex --force \
 && mix archive.install --force hex phx_new 1.4.10 \
 && apt-get update \
 && curl -sL https://deb.nodesource.com/setup_10.x | bash \
 && apt-get install -y apt-utils \
 && apt-get install -y nodejs \
 && apt-get install -y build-essential \
 && apt-get install -y inotify-tools \
 && mix local.rebar --force 

# set build ENV
ENV MIX_ENV=prod

# install mix dependencies
COPY mix.exs mix.lock ./
COPY config config
RUN mix deps.get
RUN mix deps.compile

# build assets
COPY package.json package.json ./
COPY brunch-config.js brunch-config.js ./

RUN npm install 
RUN npm run prod 
RUN mix phx.digest 


# build project
COPY lib lib
RUN mix compile

ENV APP_HOME /app
RUN mkdir -p $APP_HOME
WORKDIR $APP_HOME
   
EXPOSE 4000

CMD ["mix", "phx.server"]