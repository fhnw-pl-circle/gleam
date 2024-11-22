import chat_client
import chat_server.{Login, Shutdown, Text}
import gleam/erlang
import gleam/io
import gleam/otp/actor

pub fn main() {
  io.println("starting Chat Mini... ⭐")

  io.println("starting actors...")
  let assert Ok(chat) = chat_server.new()
  let assert Ok(client_a) = chat_client.new("A")
  let assert Ok(client_b) = chat_client.new("B")

  io.println("connecting clients to chat...")
  actor.send(chat, Login("A", client_a))
  actor.send(chat, Login("B", client_b))

  io.println("sending some messages...")
  actor.send(chat, Text("B", "Hi B"))
  actor.send(chat, Text("A", "Hi A"))

  let _ = erlang.get_line("\npress ENTER to stop\n\n")

  io.println("shutting down...")
  actor.send(chat, Shutdown)
}
