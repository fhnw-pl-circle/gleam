import gleam/erlang/process.{type Subject}
import gleam/io
import gleam/list
import gleam/otp/actor
import gleam/set.{type Set}
import mist

pub fn new() -> Result(ChatActor, actor.StartError) {
  actor.start(init_state(), handle_message)
}

pub type ChatActor =
  Subject(Message)

pub type Message {
  Text(message: String)
  Login(user: mist.WebsocketConnection)
  Logout(user: mist.WebsocketConnection)
  Shutdown
}

type State =
  Set(mist.WebsocketConnection)

fn init_state() -> State {
  set.new()
}

fn handle_message(message: Message, state: State) -> actor.Next(Message, State) {
  case message {
    Login(user) -> {
      io.println("user joined the chat")
      state
      |> set.insert(user)
      |> actor.continue
    }

    Logout(user) ->
      state
      |> set.delete(user)
      |> actor.continue

    Text(message) -> {
      state
      |> set.map(fn(conn) { mist.send_text_frame(conn, message) })

      actor.continue(state)
    }

    Shutdown -> actor.Stop(process.Normal)
  }
}
