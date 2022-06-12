# Distributed Applications

This is our attempt for the june entry for Distributed Applications in UCLL.

Created by Lorenzo Catalano (r0790963) & Szymon Nidecki (r0790938)

## About

We have created a very simple casino application where you can add players, create a room where a 30s timer goes off to flip a coin. Players can log in as any player that exists in the application and bet with the balance they have.

### OTP

The application uses a backend created with an **OTP** design. This design consists of two main parts. First we have the players which consist of:

- A Player supervisor (simple one for one strategy)
- A Player server (Facade for Player Agent [Worker])
- A supervisor of all Player supervisor (rest for one strategy)

Second we have the coinflip rooms:

- A Coinflip supervisor (simple one for one strategy)
- A Coinflip server (Facede for Coinflip Agent [Worker])
- A supervisor for all Coinflip supervisors (rest for one strategy)

### PubSub & LiveView

The application uses PubSub and LiveView to update the website asynchronously, most of the pages you see in the app are a live view that has a publish/subscribe relationship and frequently gets updated with broadcasts.

### RabbitMQ

The application uses RabbitMQ to send messages from the OTP backend to the frontend to broadcast changes in the live views. For example if a player is added then a new GenServer is created which in turn sends a message back to the frontend, this message than gets broadcasted to the correct live view to see an updated list of players on the front page.

## Requirements

- Works best on a linux operating system
- Docker compose
- esl-erlang
- elixir v1.12+
- phoenix v1.6+
- inotify-tools (optional)

## RabbitMQ

```bash
sudo docker-compose up
```

Go to [localhost:15672](http://localhost:15672) and log in with:

```
guest
guest
```

## Frontend

Go to the 'frontend' directory and execute following commands:

```elixir
mix deps.get
iex -S mix phx.server #mix phx.server
```

Go to [localhost:4000](http://localhost:4000)

## Backend (optional)

**Note:** You are only required to start the frontend as it is connected to the backend and starts that part on its own.

Go to the 'backend' directory and execute following commands:

```elixir
mix deps.get
iex -S mix
```