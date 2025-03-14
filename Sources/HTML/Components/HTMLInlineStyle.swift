import ConcurrencyExtras
import Dependencies
import DependenciesMacros
import OrderedCollections

extension HTML {
  public func inlineStyle(
    _ property: String,
    _ value: String?,
    media mediaQuery: InlineStyle.MediaQuery? = nil,
    pre: InlineStyle.Selector = "",
    pseudo: InlineStyle.Pseudo? = nil,
    post: InlineStyle.Selector = ""
  ) -> HTMLInlineStyle<Self> {
    HTMLInlineStyle(
      content: self,
      styles: value.flatMap {
        [
          InlineStyle(
            property: property,
            value: $0,
            media: mediaQuery,
            preSelector: pre,
            pseudoSelector: pseudo,
            postSelector: post
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
    pre: InlineStyle.Selector = "",
    pseudo: InlineStyle.Pseudo? = nil,
    post: InlineStyle.Selector = ""
  ) -> Self {
    var copy = self
    if let value {
      copy.styles.append(
        InlineStyle(
          property: property,
          value: value,
          media: mediaQuery,
          preSelector: pre,
          pseudoSelector: pseudo,
          postSelector: post
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
  let preSelector: Selector
  let pseudoSelector: Pseudo?
  let postSelector: Selector

  public struct Selector: Sendable, Hashable, ExpressibleByStringLiteral {
    public let rawValue: String

    public init(
      leadingSpace: Bool = false,
      _ selector: String,
      trailingSpace: Bool = false
    ) {
      self.rawValue = "\(leadingSpace ? " " : "")\(selector)\(trailingSpace ? " " : "")"
    }

    public init(stringLiteral value: StringLiteralType) {
      self.init(value)
    }
  }

  public struct Pseudo: Sendable, Hashable {
    private var name: String
    private var isElement: Bool

    var rawValue: String { ":\(self.isElement ? ":" : "")\(self.name)" }

    public init(element: Bool, name: String = #function) {
      self.name = name
      self.isElement = element
    }

    public init(class: Bool, name: String = #function) {
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
  private struct HashedSelector: Hashable {
    let preSelector: InlineStyle.Selector
    let pseudoSelector: InlineStyle.Pseudo?
    let postSelector: InlineStyle.Selector

    init?(_ style: InlineStyle) {
      if style.preSelector.rawValue.isEmpty, 
        style.pseudoSelector?.rawValue.isEmpty ?? true, 
        style.postSelector.rawValue.isEmpty {
        return nil
      } else {
        self.preSelector = style.preSelector
        self.postSelector = style.postSelector
        self.pseudoSelector = style.pseudoSelector
      }
    }
  }

  public static var groupedStyles: StyleSheetGenerator {
    let usedStyles = LockIsolated<OrderedDictionary<String, OrderedSet<InlineStyle>>>([:])

    return Self(
      generate: { styles in
        usedStyles.withValue { usedStyles in
          guard let className = usedStyles.first(where: { $0.value == styles }) else {
            let className = "c\(usedStyles.count)"
            usedStyles[className] = styles
            return [className]
          }
          return [className.key]
        }
      },
      stylesheet: {
        usedStyles.withValue { usedStyles in
          var sheet = ""
          for (className, styles) in usedStyles {
            let mediaStyles = OrderedDictionary(grouping: styles) { $0.media }
              .sorted(by: { $0.key == nil ? $1.key != nil : false })
            for (media, styles) in mediaStyles {
              if let media {
                sheet.append("@media \(media.rawValue){")
              }
              defer {
                if media != nil {
                  sheet.append("}")
                }
              }

              let stylesWithSelectors = OrderedDictionary(grouping: styles, by: HashedSelector.init)
                .sorted(by: { $0.key == nil ? $1.key != nil : false })

              for (selector, styles) in stylesWithSelectors {
                sheet.append("\(selector?.preSelector.rawValue ?? "").\(className)\(selector?.pseudoSelector?.rawValue ?? "")\(selector?.postSelector.rawValue ?? ""){")
                defer { sheet.append("}") }
                sheet.append(contentsOf: styles.map { "\($0.property):\($0.value);"}.joined())
              }
            }
          }
          return sheet
        }
      }
    )
  }

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
              """
              \(style.preSelector.rawValue).\(className)\(style.pseudoSelector?.rawValue ?? "")\(style.postSelector.rawValue)"
              """
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
