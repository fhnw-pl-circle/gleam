import gleam/erlang/process.{type Subject}
import gleam/io
import gleam/otp/actor

pub fn main() {
  let assert Ok(actor) = actor.start("zero", handle_message)

  process.send(actor, Message("one"))
  process.send(actor, Message("two"))
  process.send(actor, Message("three"))
  process.send(actor, Message("four"))

  let state = process.call(actor, Get, 100)
  io.println(state)

  //   process.send(actor, Shutdown)

  process.send(actor, Message("five"))
  let state = process.call(actor, Get, 100)
  io.println(state)
}

/// ACTOR
type Message {
  Message(String)
  Get(reply: Subject(String))
  Shutdown
}

fn handle_message(
  message: Message,
  state: String,
) -> actor.Next(Message, String) {
  case message {
    Message(m) -> {
      let new_state = state <> ", " <> m
      actor.continue(new_state)
    }
    Get(caller) -> {
      process.send(caller, state)
      actor.continue(state)
    }
    Shutdown -> actor.Stop(process.Normal)
  }
}
