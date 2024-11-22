import gleam/dict.{type Dict}
import gleam/erlang/process.{type Subject}
import gleam/io
import gleam/otp/actor

pub fn new() -> Result(Subject(Message), actor.StartError) {
  actor.start(init_state(), handle_message)
}

pub type Message {
  Text(receiver: String, message: String)
  Login(username: String, Subject(String))
  Logout(username: String)
  Shutdown
}

type State =
  Dict(String, Subject(String))

fn init_state() -> State {
  dict.new()
}

fn handle_message(message: Message, state: State) -> actor.Next(Message, State) {
  case message {
    Login(username, subject) -> {
      io.println(username <> " joined the chat")
      state
      |> dict.insert(username, subject)
      |> actor.continue
    }

    Logout(username) ->
      state
      |> dict.delete(username)
      |> actor.continue

    Text(receiver, message) -> {
      case dict.get(state, receiver) {
        Ok(subject) -> actor.send(subject, message)
        Error(_) -> io.print_error("Could not send message to " <> receiver)
      }
      actor.continue(state)
    }

    Shutdown -> actor.Stop(process.Normal)
  }
}
