import gleam/erlang/process.{type Subject}
import gleam/io
import gleam/otp/actor

pub fn new(name: String) -> Result(Subject(String), actor.StartError) {
  actor.start(name, handle_message)
}

fn handle_message(message: String, name: String) -> actor.Next(String, String) {
  io.println(name <> " >> " <> message)
  actor.continue(name)
}
