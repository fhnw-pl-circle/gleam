import gleeunit
import gleeunit/should
import vars/internal.{format_variable}

pub fn main() {
  gleeunit.main()
}

pub fn format_variable_test() {
  format_variable("name", "value")
  |> should.equal("name=value")
}
