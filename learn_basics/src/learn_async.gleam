import gleam/erlang/process
import gleam/int
import gleam/io
import gleam/list
import gleam/otp/task

pub fn main() {
  async_await()
  concurrent()
}

fn async_await() {
  list.range(0, 100)
  |> list.map(spawn_task)
  |> list.each(task.await_forever)
}

fn spawn_task(i: Int) {
  task.async(fn() {
    // case i % 4 {
    //   0 -> process.sleep(2000)
    //   _ -> Nil
    // }
    let n = int.to_string(i)
    io.println("hello from " <> n)
  })
}

fn concurrent() {
  let x = task.async(fn() { computation(1) })
  let y = task.async(fn() { computation(2) })

  let x = task.await_forever(x)
  let y = task.await_forever(y)

  x + y |> int.to_string |> io.println
}

fn computation(n: int) {
  process.sleep(2000)
  io.debug(n)
}
