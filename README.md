# Distri

Pls help

## RabbitMQ

```bash
sudo docker-compose up
```

Go to [localhost:15672](http://localhost:15672) and log in with:
```
guest
guest
```


## Backend

```elixir
mix deps.get
iex -S mix
```

## Frontend

```elixir
mix deps.get
iex -S mix phx.server #mix phx.server
```

Go to [localhost:4000](http://localhost:4000)