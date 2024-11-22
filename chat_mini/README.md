# chat_mini

The chat actor is implemented in its own [module](./src/chat_server.gleam) and only the `new` function (and the `Message` type) is public. This seams to be a common pattern. Now we could further simplify the usage of this actor by providing public functions to send messages to the actor (over just exposing the `Nessage` type). 

## Development

```sh
gleam run   # Run the project
```
