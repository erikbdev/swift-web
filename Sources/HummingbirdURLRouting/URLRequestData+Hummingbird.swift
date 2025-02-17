import struct URLRouting.URLRequestData
import struct Hummingbird.Request
import struct HTTPTypes.HTTPFields
import struct Foundation.Data
import struct NIO.ByteBuffer
import Parsing

public extension URLRequestData {
  init(request: Hummingbird.Request) async {
    var body: ByteBuffer?
    do {
      for try await var buffer in request.body {
        body = body ?? ByteBuffer()
        body?.writeBuffer(&buffer)
      }
    } catch {
      body = nil
    }

    let authorization = request.headers.basicAuthorization

    self.init(
      method: request.method.rawValue,
      scheme: request.uri.scheme?.rawValue,
      user: authorization?.0,
      password: authorization?.1,
      host: request.uri.host,
      port: request.uri.port,
      path: request.uri.path,
      query: request.uri.queryParameters.reduce(into: [:]) { dict, item in
        dict[String(item.key), default: []].append(String(item.value))
      },
      fragment: request.uri.string.range(of: "#").flatMap { range in
        String(request.uri.string[request.uri.string.index(after: range.lowerBound)...])
      },
      headers: .init(
        request.headers.map { field in
          (
            field.name.canonicalName,
            field.value.components(separatedBy: ",")
          )
        },
        uniquingKeysWith: { $0 + $1 }
      ),
      body: body.flatMap { Data(buffer: $0) }
    )
  }
}

extension HTTPFields {
  public var basicAuthorization: (String, String)? {
    if case let .basic(username, password) = self.authorization {
      return (username, password)
    } else {
      return nil
    }
  }

  public var authorization: Authorization? {
    if let string = self[.authorization] {
      try? Authorization.parser.parse(string)
    } else {
      nil
    }
  }

  public enum Authorization: Sendable, Equatable {
    /// Token
    case bearer(String)

    /// base64-encoded credentials
    case basic(String, String)

    /// sha256-algorithm
    case digest(String)

    static var parser: some Parser<Substring, Self> {
      OneOf {
        Parse(.case(Self.bearer)) {
          OneOf { 
            "Bearer"
            "bearer"
          }
          " "
          Rest().map(.string)
        }

        Parse(.case(Self.basic)) {
          OneOf {
            "Basic"
            "basic"
          }
          " "

          Rest().map(Base64EncodedSubstringToSubstring()).pipe {
            Prefix { $0 != ":" }.map(.string)
            ":"
            Rest().map(.string)
          }
        }

        Parse(.case(Self.digest)) {
          OneOf {
            "Digest"
            "digest"
          }
          " "
          Rest().map(.string)
        }
      }
    }
  }
}

private struct Base64EncodedSubstringToSubstring: Conversion {
  @usableFromInline
  init() {}

  @inlinable
  func apply(_ input: Substring) -> Substring {
    Data(base64Encoded: String(input)).flatMap {
      String(decoding: $0, as: UTF8.self)[...]
    } ?? ""
  }

  @inlinable
  func unapply(_ output: Substring) -> Substring {
    output.data(using: .utf8)?
      .base64EncodedString()[...] ?? ""
  }
}