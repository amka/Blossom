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
import sugar
import strutils

import ./router

        
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
    router*: Router
    httpServer*: AsyncHttpServer

proc handleRequest(self: Blossom, req: Request): Future[void] =
    # FIXME: procedure should be gcsafe
    let handler = self.router.matchRoute(req.url.path)
    return handler(req)

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


proc main() =
    let port = paramStr(1).parseInt().Port
    let settings = newSettings(port=port)
    var blossom = initApp(settings)
    blossom.router.addRoute("/", 
        proc(req: Request): Future[void] = 
            req.respond(Http200, "Blossom is gorgeous!")
    )

    blossom.router.addRoute("/sugar", (req: Request) =>
        req.respond(Http200, "Sugar is sweet!")
    )

    blossom.serve()


when isMainModule:
    main()