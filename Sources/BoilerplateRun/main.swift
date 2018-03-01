import Boilerplate
import Vapor
import Foundation

var config = Config.default()
var env = try Environment.detect()
var services = Services.default()

try Boilerplate.configure(&config, &env, &services)

let app = try Application(
    config: config,
    environment: env,
    services: services
)

try Boilerplate.boot(app)

Foundation.Thread.current.name = "main"
print(Foundation.Thread.current.name)
try app.run()
