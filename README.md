# Blossom

![Blossom](./doc/blossom-icons8.png)

Blossom is a minimalistic web framework built in [nim](https://nim-lang.org/) languge largely inspired by [Bottle](http://bottlepy.org/docs/dev/), [Redstone](http://redstonedart.org/) and [Jester](https://github.com/dom96/jester).

## Example

```nim
import sugar
import blossom

proc main() =
    # Initialize application
    let settings = newSettings()
    var blossom = initApp(settings)

    # Add a couple of routes
    blossom.router.addRoute("/", 
        proc(req: Request): Future[void] = 
            req.respond(Http200, "Blossom is gorgeous!")
    )

    # And route with sugar macro
    blossom.router.addRoute("/sugar", (req: Request) =>
        req.respond(Http200, "Sugar is sweet!")
    )

    # Start server
    blossom.serve()

when isMainModule:
    main()
```

## Roadmap

- [x] Static routing
- [ ] Dynamic routing
- [ ] Templating
- [ ] Logging

## Icon

Icon generously provided by [Icons8](https://icons8.com/).
