import argv
import envoy
import gleam/io
import gleam/result
import vars/internal.{format_variable}

pub fn main() {
  case argv.load().arguments {
    ["get", name] -> get(name)
    _ -> help()
  }
}

fn help() {
  io.println("Usage: vars get <name>")
}

fn get(name: String) {
  let value = envoy.get(name) |> result.unwrap("UNDEFINED")
  io.println(format_variable(name, value))
}
//
// another way to write the same function
//
// fn get(name: String) {
//   envoy.get(name)
//   |> result.unwrap("UNDEFINED")
//   |> format_variable(name, _)
//   |> io.println
// }
