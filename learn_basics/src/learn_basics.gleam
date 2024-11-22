import gleam/float
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{type Option, None, Some}

pub fn main() {
  io.debug(add(1, 2))

  let add_one = fn(x) { add(1, x) }
  let add_two = add(2, _)

  io.debug(add_one(2))
  io.debug(add_two(2))

  let twice = fn(x: t, f: fn(t, t) -> t) -> t { f(x, x) }

  io.debug(twice(4, add))
  io.debug(twice("4", concat))

  work_with_lists()

  let thing_1 =
    thing_factory(
      "first thing",
      id: "T-0001-A",
      w: 103.0,
      l: 100.0,
      h: 21.5,
      weight: 525.8,
      weight_unit: "kg",
      size_unit: "cm",
      info: option.None,
    )

  io.debug(thing_1)
}

fn add(a: Int, b: Int) -> Int {
  a + b
}

fn concat(a: String, b: String) -> String {
  a <> b
}

fn work_with_lists() {
  let list = [0, 1, 2, 3, 4, 5]

  // let result = list.map(list.filter(list, int.is_even), int.multiply(2, _))
  let result =
    list.filter(list, int.is_even)
    |> list.map(int.multiply(2, _))
    |> list.reduce(int.add)

  case result {
    Error(_) -> io.debug("there is an error")
    Ok(r) -> io.debug("the result is " <> int.to_string(r))
    // Ok(r) -> int.to_string(r) |> fn(r) { "the result is " <> r } |> io.debug
  }
}

fn thing_factory(
  name: String,
  id id: String,
  w width: Float,
  l length: Float,
  h height: Float,
  size_unit size_unit: String,
  weight weight: Float,
  weight_unit weight_unit: String,
  info info: Option(String),
) -> String {
  "["
  <> id
  <> "]\t"
  <> name
  <> "\n"
  <> float.to_string(width)
  <> "x"
  <> float.to_string(height)
  <> "x"
  <> float.to_string(length)
  <> " "
  <> size_unit
  <> "\n"
  <> float.to_string(weight)
  <> " "
  <> weight_unit
  <> case info {
    Some(i) -> "\n" <> i
    None -> ""
  }
}
