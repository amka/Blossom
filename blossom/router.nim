import asynchttpserver, asyncdispatch
import re

type Route* = object
    path*: string
    handler*: proc(req: Request): Future[void]


type Router* = object
    ## Base Router object collects any routes that is handler by the app
    routes*: seq[Route]


proc notFoundHandler*(req: Request): Future[void]  =
    ## Default handler for Not found error
    req.respond(Http404, "Not Found")


proc addRoute*(
        self: var Router, 
        path: string, 
        handler: proc(req: Request): Future[void]
    ) =
    ## Add new route to ``Router`` and bind a function to it's URL
    let route = Route(path: path, handler: handler)
    self.routes.add(route)


proc matchRoute*(self: Router, path: string): proc(req: Request): Future[void] =
    ## Find Route for given ``path`` and return it's handler
    ## If no routes found return default 404 ``notFoundHandler``
    for route in self.routes.items:
        if route.path.match(re(path)): return route.handler

    return notFoundHandler
    