import Foundation
import Hummingbird
import NIOFoundationCompat
@preconcurrency import URLRouting

public struct URLRoutingMiddleware<
  R: Parser & Sendable,
  Context: RequestContext
>: Sendable, RouterMiddleware where R.Input == URLRequestData {
  private let router: R
  private let respond: @Sendable (Self.Input, Context, R.Output) async throws -> ResponseGenerator

  public init(
    _ router: R,
    use closure: @Sendable @escaping (Self.Input, Context, R.Output) async throws -> ResponseGenerator
  ) {
    self.router = router
    self.respond = closure
  }

  public func handle(
    _ request: Self.Input,
    context: Context,
    next: (Self.Input, Context) async throws -> Self.Output
  ) async throws -> Self.Output {
    let route: R.Output
    do {
      route = try await self.router.parse(URLRequestData(request: request))
    } catch let routingError {
      do {
        return try await next(request, context)
      } catch {
        context.logger.info("\(routingError)")
        #if DEBUG
          throw HTTPError(.notFound, message: "Routing \(routingError)")
        #else
          throw error
        #endif
      }
    }
    return try await self.respond(request, context, route).response(from: request, context: context)
  }
}
