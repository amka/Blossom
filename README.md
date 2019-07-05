# Blossom

![Blossom](./doc/blossom-icons8.png) Blossom is a minimalistic web framework built in [nim](https://nim-lang.org/) languge largely inspired by [Bottle](http://bottlepy.org/docs/dev/), [Redstone](http://redstonedart.org/) and [Jester](https://github.com/dom96/jester).

## Example

```nim
import blossom

proc main() =
    let port = paramStr(1).parseInt().Port
    let settings = newSettings(port=port)
    var blossom = initApp(settings)
    blossom.serve()

when isMainModule:
    main()
```

## Roadmap

[ ] Static routing
[ ] Dynamic routing
[ ] Templating
[ ] Logging

## Icon

Icon generously provided by [Icons8](https://icons8.com/).