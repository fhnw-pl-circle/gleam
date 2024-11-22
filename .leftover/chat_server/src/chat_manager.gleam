import chat_actor.{type ChatActor} as chat
import gleam/dict.{type Dict}
import gleam/erlang/process.{type Subject}
import gleam/io
import gleam/otp/actor
import gleam/result
import mist.{type WebsocketConnection}

pub type Message {
  Join(room: String, connection: WebsocketConnection)
  Leave(room: String, connection: WebsocketConnection)
}

pub fn new() -> Result(Subject(Message), actor.StartError) {
  actor.start(State(dict.new()), handle_message)
}

type State {
  State(rooms: Dict(String, ChatActor))
}

fn handle_message(message: Message, state: State) -> actor.Next(Message, State) {
  case message {
    Join(room, conn) -> {
      io.println("a user joins " <> room)
      let assert Ok(subject) =
        state.rooms
        |> dict.get(room)
        |> result.lazy_or(fn() { result.replace_error(chat.new(), Nil) })

      actor.send(subject, chat.Login(conn))
      actor.continue(state)
    }

    Leave(room, conn) -> {
      io.println("a user leaves " <> room)
      todo
    }
  }
}
