import ConcurrencyExtras
import Dependencies
import DependenciesMacros
import OrderedCollections

extension HTML {
  public func inlineStyle(
    _ property: String,
    _ value: String?,
    media mediaQuery: InlineStyle.MediaQuery? = nil,
    pre: String? = nil,
    pseudo: InlineStyle.Pseudo? = nil,
    post: String? = nil
  ) -> HTMLInlineStyle<Self> {
    HTMLInlineStyle(
      content: self,
      styles: value.flatMap {
        [
          InlineStyle(
            property: property,
            value: $0,
            media: mediaQuery,
            pre: pre,
            pseudo: pseudo,
            post: post
          )
        ]
      } ?? []
    )
  }
}

public struct HTMLInlineStyle<Content: HTML>: HTML {
  let content: Content
  var styles: OrderedSet<InlineStyle>

  public func inlineStyle(
    _ property: String,
    _ value: String?,
    media mediaQuery: InlineStyle.MediaQuery? = nil,
    pre: String? = nil,
    pseudo: InlineStyle.Pseudo? = nil,
    post: String? = nil
  ) -> Self {
    var copy = self
    if let value {
      copy.styles.append(
        InlineStyle(
          property: property,
          value: value,
          media: mediaQuery,
          pre: pre,
          pseudo: pseudo,
          post: post
        )
      )
    }
    return copy
  }

  @_spi(Render)
  public static func _render<Output: HTMLByteStream>(
    _ html: consuming Self,
    into output: inout Output
  ) {
    withDependencies {
      guard let ssg = $0.ssg else {
        for style in html.styles {
          $0.allAttributes["style", default: ""]
            .append("\(style.property): \(style.value);")
        }
        return
      }

      let classes = ssg.generate(html.styles)

      guard !classes.isEmpty else { return }

      $0.allAttributes["class", default: ""]
        .append(($0.allAttributes.keys.contains("class") ? " " : "") + classes.joined(separator: " "))
    } operation: {
      Content._render(
        html.content,
        into: &output
      )
    }
  }

  public var body: Never { fatalError() }
}

extension HTMLInlineStyle: Sendable where Content: Sendable {}

public struct InlineStyle: Sendable, Hashable {
  let property: String
  let value: String
  let media: MediaQuery?
  let pre: String?
  let pseudo: Pseudo?
  let post: String?

  public struct Pseudo: Sendable, Hashable {
    private var name: String
    private var isElement: Bool

    var rawValue: String { ":\(self.isElement ? ":" : "")\(self.name)" }

    private init(element: Bool, name: String = #function) {
      self.name = name
      self.isElement = element
    }

    private init(class: Bool, name: String = #function) {
      self.name = name
      self.isElement = !`class`
    }

    public static let active = Self(class: true)
    public static let after = Self(element: true)
    public static let before = Self(element: true)
    public static let checked = Self(element: true)
    public static let disabled = Self(element: true)
    public static let empty = Self(class: true)
    public static let firstChild = Self(class: true, name: "first-child")
  }

  public struct MediaQuery: Sendable, Hashable, RawRepresentable, ExpressibleByStringLiteral, ExpressibleByStringInterpolation {
    private var values: [String] = []

    public var rawValue: String { self.values.joined(separator: " ") }

    public init(rawValue: String) {
      self.values = [rawValue]
    }

    public init(stringLiteral value: String) {
      self.init(rawValue: value)
    }

    private init(_ values: [String]) {
      self.values = values
    }

    public func and(_ query: Self) -> Self {
      var copy = self
      copy.values.append("and")
      copy.values.append(contentsOf: query.values)
      return copy
    }

    public func or(_ query: Self) -> Self {
      var copy = self
      copy.values.append(",")
      copy.values.append(contentsOf: query.values)
      return copy
    }

    public func not(_ query: Self) -> Self {
      var copy = self
      copy.values.append("not")
      copy.values.append(contentsOf: query.values)
      return copy
    }

    public static func only(_ query: Self) -> Self {
      Self(["only"] + query.values)
    }

    public static var all: Self { #function }
    public static var print: Self { #function }
    public static var screen: Self { #function }

    public static func minWidth(_ value: Int) -> Self {
      "(min-width: \(value)px)"
    }

    public static func maxWidth(_ value: Int) -> Self {
      "(max-width: \(value)px)"
    }
  }
}

@DependencyClient
public struct StyleSheetGenerator: Sendable {
  public let generate: @Sendable (_ styles: OrderedSet<InlineStyle>) -> [String]
  public let stylesheet: @Sendable () -> String
}

extension StyleSheetGenerator {
  // TBD: add support for stylesheet generation based on list of styles
  // public static var grouped: StyleSheetGenerator {
  //   // let usedStyles = LockIsolated<OrderedSet<InlineStyle>>([])
  //   let rulesets = LockIsolated<OrderedDictionary<InlineStyle.MediaQuery?, OrderedDictionary<String, String>>>([:])

  //   return Self(
  //     generate: { styles in [] },
  //     stylesheet: {
  //       rulesets.withValue { rulesets in
  //         var sheet = ""
  //         for (mediaQuery, styles) in rulesets.sorted(by: { $0.key == nil ? $1.key != nil : false }) {
  //           if let mediaQuery {
  //             sheet.append("@media \(mediaQuery.rawValue){")
  //           }
  //           defer {
  //             if mediaQuery != nil {
  //               sheet.append("}")
  //             }
  //           }
  //           for (className, style) in styles {
  //             sheet.append("\(className){\(style)}")
  //           }
  //         }
  //         return sheet
  //       }
  //      }
  //   )
  // }

  public static var `class`: StyleSheetGenerator {
    let usedStyles = LockIsolated<OrderedSet<InlineStyle>>([])
    let rulesets = LockIsolated<OrderedDictionary<InlineStyle.MediaQuery?, OrderedDictionary<String, String>>>([:])

    return Self(
      generate: { styles in
        usedStyles.withValue { usedStyles in
          var classes = [String]()

          for style in styles {
            let index = usedStyles.firstIndex(of: style) ?? usedStyles.append(style).index
            #if DEBUG
              let className = "\(style.property)-\(index)"
            #else
              let className = "c\(index)"
            #endif

            let selector =
              "\(style.pre.flatMap { $0 + " " } ?? "").\(className)\(style.pseudo?.rawValue ?? "")\(style.post.flatMap { " " + $0 } ?? "")"

            rulesets.withValue { rulesets in
              if rulesets[style.media, default: [:]][selector] == nil {
                rulesets[style.media, default: [:]][selector] = "\(style.property):\(style.value);"
              }
            }

            classes.append(className)
          }

          return classes
        }
      },
      stylesheet: {
        rulesets.withValue { rulesets in
          var sheet = ""
          for (mediaQuery, styles) in rulesets.sorted(by: { $0.key == nil ? $1.key != nil : false }) {
            if let mediaQuery {
              sheet.append("@media \(mediaQuery.rawValue){")
            }
            defer {
              if mediaQuery != nil {
                sheet.append("}")
              }
            }
            for (className, style) in styles {
              sheet.append("\(className){\(style)}")
            }
          }
          return sheet
        }
      }
    )
  }
}

extension StyleSheetGenerator: DependencyKey {
  public static var liveValue: StyleSheetGenerator? { nil }
  public static var testValue: StyleSheetGenerator? { nil }
}

extension DependencyValues {
  public var ssg: StyleSheetGenerator? {
    get { self[StyleSheetGenerator.self] }
    set { self[StyleSheetGenerator.self] = newValue }
  }
}
