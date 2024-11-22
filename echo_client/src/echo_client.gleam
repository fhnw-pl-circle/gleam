import gleam/list
import gleam/option.{type Option}
import gleam/string
import lustre
import lustre/attribute
import lustre/effect
import lustre/element
import lustre/element/html
import lustre/event
import lustre_websocket as ws

//                                       +--------+
//                                       |        |
//                                       | update |
//                                       |        |
//                                       +--------+
//                                         ^    |
//                                         |    |
//                                     Msg |    | Model
//                                         |    |
//                                         |    v
//+------+                         +------------------------+
//|      |          Model          |                        |
//| init |------------------------>|     Lustre Runtime     |
//|      |                         |                        |
//+------+                         +------------------------+
//                                         ^    |
//                                         |    |
//                                     Msg |    | Model
//                                         |    |
//                                         |    v
//                                       +--------+
//                                       |        |
//                                       |  view  |
//                                       |        |
//                                       +--------+
// from https://hexdocs.pm/lustre/guide/02-state-management.html

pub fn main() {
  let app = lustre.application(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)

  Nil
}

// === MODEL ===

type Model {
  Model(
    text: String,
    messages: List(String),
    connection: Connection,
    socket: Option(ws.WebSocket),
  )
}

type Connection {
  Connected
  Connecting
  Disconnected
}

fn init(_) -> #(Model, effect.Effect(Msg)) {
  #(
    Model(
      text: "type a message...",
      connection: Disconnected,
      messages: list.new(),
      socket: option.None,
    ),
    effect.none(),
  )
}

// === UPDATE ===

type Msg {
  SetText(text: String)
  Connect
  Send
  WsWrapper(ws.WebSocketEvent)
}

fn update(model: Model, msg: Msg) -> #(Model, effect.Effect(Msg)) {
  case msg, model.socket {
    SetText(text), _ -> #(Model(..model, text: text), effect.none())
    Connect, _ -> #(
      Model(..model, connection: Connecting),
      ws.init("http://localhost:3000/ws", WsWrapper),
      // this is an effect
    )
    Send, option.Some(socket) -> #(
      Model(..model, text: ""),
      ws.send(socket, model.text),
    )

    WsWrapper(ws.OnTextMessage(text)), _ -> #(
      Model(..model, messages: list.append(model.messages, [text])),
      effect.none(),
    )
    WsWrapper(ws.OnOpen(socket)), _ -> #(
      Model(..model, connection: Connected, socket: option.Some(socket)),
      effect.none(),
    )
    _, _ -> panic as "💥"
  }
}

// === VIEW ===

fn view(model: Model) -> element.Element(Msg) {
  html.div([], [
    html.input([
      attribute.type_("text"),
      attribute.value(model.text),
      event.on_input(SetText),
    ]),
    button(model),
    messages(model),
  ])
}

fn button(model: Model) -> element.Element(Msg) {
  case model.connection {
    Disconnected ->
      html.button([event.on_click(Connect)], [element.text("connect")])
    Connecting ->
      html.button([attribute.disabled(True)], [element.text("connecting...")])
    Connected -> html.button([event.on_click(Send)], [element.text("send")])
  }
}

fn messages(model: Model) -> element.Element(Msg) {
  let list =
    model.messages
    |> list.map(fn(text) { html.ul([], [element.text(text)]) })
  html.ul([], list)
}
