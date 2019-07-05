## Copyright (C) 2019 Andrey Maksimov
## MIT License
## 
## Blossom - minimalistic web framework.
## Largely inspired by Bottle (python) and Redstone (dart) and Jester (nim).
##

import asynchttpserver, asyncdispatch
import logging
import os
import parseopt
import strutils


type
    Route = object
        rule*: string
        handler*: proc(req: Request)

type
    Settings = object
        appName*: string
        port*: Port
        bindAddr*: string
        reusePort*: bool

proc newSettings(port=Port(8080), appName="", bindAddr="", reusePort=false): Settings =
    result = Settings(
        appName: appName,
        port: port,
        bindAddr: bindAddr,
        reusePort: reusePort
    )

type Blossom* = object
    ## This type contains a description of a Blossom web framework
    settings*: Settings
    routes*: seq[Route]
    httpServer*: AsyncHttpServer


proc handleRequest(Blossom: Blossom, req: Request): Future[void] =
    req.respond(Http200, "OK")

proc initApp*(settings: Settings = newSettings()): Blossom =
    ## Initialize Blossom app by overriding default settings
    result = Blossom(settings: settings)

proc serve*(self: var Blossom) =
    ## Start an AsyncHttpServer and runs it till it stopped

    # Ensure we have at least one logger enabled, defaulting to console.
    if logging.getHandlers().len == 0:
        addHandler(logging.newConsoleLogger())
        setLogFilter(when defined(release): lvlInfo else: lvlDebug)

    self.httpServer  = newAsyncHttpServer(reusePort=true)

    # copy the app object?
    var blossom = self

    # Run server
    let serveFuture = self.httpServer.serve(
        self.settings.port,
        proc (req: asynchttpserver.Request): Future[void] {.gcsafe, closure.} =
            result = handleRequest(blossom, req),
        self.settings.bindAddr
    )

    asyncCheck(serveFuture)
    
    # Start the loop
    runForever()

# proc add_route(self: Blossom, route: Route) =
#     self.routes.add(route)


proc main() =
    let port = paramStr(1).parseInt().Port
    let settings = newSettings(port=port)
    var blossom = initApp(settings)
    blossom.serve()


when isMainModule:
    main()