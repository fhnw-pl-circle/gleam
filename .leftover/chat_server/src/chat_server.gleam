import chat_manager
import gleam/bytes_tree
import gleam/erlang/process
import gleam/http/request.{type Request}
import gleam/http/response.{type Response}
import gleam/io
import gleam/option.{None, Some}
import gleam/otp/actor
import mist.{type Connection, type ResponseData}

pub fn main() {
  // let selector = process.new_selector()
  // let state = Nil

  let assert Ok(_) =
    mist.new(server)
    |> mist.port(3000)
    |> mist.start_http

  process.sleep_forever()
}

fn server(req: Request(Connection)) -> Response(ResponseData) {
  case request.path_segments(req) {
    [] -> text_response(200, "a chat server...")
    ["chat"] -> websocket_server(req)
    _ -> text_response(404, "not found")
  }
}

fn websocket_server(req: Request(Connection)) -> Response(ResponseData) {
  let assert Ok(manager) = chat_manager.new()

  mist.websocket(
    request: req,
    on_init: fn(_) {
      io.println("new connection")
      #(Nil, None)
    },
    on_close: fn(_) { io.println("goodbye") },
    handler: fn(_, conn, message) {
      case message {
        mist.Text("join " <> room) -> {
          actor.send(manager, chat_manager.Join(room, conn))
          actor.continue(Nil)
        }

        mist.Text(msg) -> {
          io.println(">> " <> msg)
          let assert Ok(_) = mist.send_text_frame(conn, msg)
          actor.continue(Nil)
        }

        mist.Closed | mist.Shutdown -> {
          io.println("shutting down")
          actor.Stop(process.Normal)
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
