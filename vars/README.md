# vars

> From the [write Gleam tutorial](https://gleam.run/writing-gleam/)

*A tiny CLi to read environment variables.*

## Development

```sh
gleam run   # Run the project
```

## Compile

```sh
# Compile the program to an escript (erlang)
gleam run -m gleescript

# Run the program
./vars get PATH
escript ./vars get PATH # On Windows
```