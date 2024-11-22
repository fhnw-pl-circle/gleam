import gleam/bytes_tree
import gleam/erlang/process
import gleam/http/request.{type Request}
import gleam/http/response.{type Response}
import gleam/io
import gleam/option.{None}
import gleam/otp/actor
import gleam/string
import mist.{type Connection, type ResponseData}

pub fn main() {
  let assert Ok(_) =
    mist.new(server)
    |> mist.port(3000)
    |> mist.start_http

  process.sleep_forever()
}

fn server(req: Request(Connection)) -> Response(ResponseData) {
  case request.path_segments(req) {
    [] -> text_response(200, "Welcome to the Gleam echo websocket server!")
    ["ws"] -> websocket_server(req)
    other ->
      text_response(404, "route " <> string.concat(other) <> " not found")
  }
}

fn websocket_server(req: Request(Connection)) -> Response(ResponseData) {
  mist.websocket(
    request: req,
    on_init: fn(_) {
      io.println("👋 hello")
      #(Nil, None)
    },
    on_close: fn(_) { io.println("👋 goodbye") },
    handler: fn(_, connection, raw_message) {
      case raw_message {
        mist.Text(message) -> {
          io.println("👉 " <> message)
          let _ = connection |> mist.send_text_frame(">> " <> message)
          actor.continue(Nil)
        }
        _ -> actor.continue(Nil)
      }
    },
  )
}

fn text_response(status: Int, text: String) -> Response(ResponseData) {
  response.new(status)
  |> response.set_body(mist.Bytes(bytes_tree.from_string(text)))
}
