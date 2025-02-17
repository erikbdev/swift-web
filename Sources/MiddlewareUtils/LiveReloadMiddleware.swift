#if DEBUG
  import Dependencies
  import Hummingbird
  import NIOFoundationCompat

  private let clock = ContinuousClock()

  struct ReloadBrowserMiddleware<Context: RequestContext>: RouterMiddleware {
    func handle(
      _ request: Input,
      context: Context,
      next: (Input, Context) async throws -> Output
    ) async throws -> Output {
      guard request.uri.path != "/live-reload" else {
        return Response(
          status: .ok,
          headers: [
            .contentType: "text/event-stream",
            .cacheControl: "no-cache",
            .connection: "keep-alive",
          ],
          body: .init { writer in
            for await _ in clock.timer(interval: .seconds(1)).cancelOnGracefulShutdown() {
              try await writer.write(ByteBuffer(string: "data: heartbeat\n\n"))
            }
            try await writer.finish(nil)
          }
        )
      }

      var handled = try await next(request, context)

      if let content = handled.headers[.contentType], content.contains("text/html") {
        let modifiedBuffer = handled.body.map { buffer in
          let bufferView = buffer.readableBytesView

          guard let range = bufferView.firstRange(of: __headEndTag) else {
            return buffer
          }

          let beforeSlice = buffer.getSlice(at: bufferView.startIndex, length: range.lowerBound)
          let afterSlice = buffer.getSlice(
            at: range.lowerBound,
            length: bufferView.count - range.lowerBound
          )

          var buffer = buffer
          buffer.clear()

          if let beforeSlice {
            buffer.writeImmutableBuffer(beforeSlice)
          }

          buffer.writeBytes(PackageResources.liveServerSnippet_html)

          if let afterSlice {
            buffer.writeImmutableBuffer(afterSlice)
          }

          return buffer
        }

        handled.body = modifiedBuffer
      }
      return handled
    }
  }

  private let __headEndTag: [UInt8] = [0x3C, 0x2F, 0x68, 0x65, 0x61, 0x64, 0x3E]
#endif
