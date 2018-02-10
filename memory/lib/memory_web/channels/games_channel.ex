defmodule MemoryWeb.GamesChannel do
  use MemoryWeb, :channel

  def join("games:" <> name, payload, socket) do
    game = Memory.GameBackup.load(name) || Memory.Game.new()
    game0 = Memory.Game.reload(game)
    socket = socket
    |> assign(:game, game)
    |> assign(:name, name)

    if authorized?(payload) do
      {:ok, %{"view" => Memory.Game.client_view(game)}, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_in("clickTile", %{"index" => i}, socket) do
    game0 = socket.assigns[:game]
    game1 = Memory.Game.click_tile(game0, i)
    Memory.GameBackup.save(socket.assigns[:name], game1)
    socket = assign(socket, :game, game1)
    {:reply, {:ok, %{"view" => Memory.Game.client_view(game1)}}, socket}
  end

  def handle_in("unDisable", %{"index" => i}, socket) do
    game0 = socket.assigns[:game]
    game1 = Memory.Game.undisable(game0, i)
    Memory.GameBackup.save(socket.assigns[:name], game1)
    socket = assign(socket, :game, game1)
    {:reply, {:ok, %{"view" => Memory.Game.client_view(game1)}}, socket}
  end

  def handle_in("restart", %{"index" => i}, socket) do
    game = Memory.Game.new()
    #Memory.GameBackup.save(socket.assigns[:name], game)
    socket = assign(socket, :game, game)
    {:reply, {:ok, %{"view" => Memory.Game.client_view(game)}}, socket}
  end


  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (games:lobby).
  def handle_in("shout", payload, socket) do
    broadcast socket, "shout", payload
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
