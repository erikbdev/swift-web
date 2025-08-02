import Dependencies
import DependenciesMacros
import OrderedCollections

public struct HTMLContext: Sendable {
  public let configuration: Configuration
  public var attributes = OrderedDictionary<String, String>()

  public var styles: StyleSheetGenerator?
  public var stylesheet: String { styles?.stylesheet() ?? "" }

  @usableFromInline
  var depth = 0

  @usableFromInline
  var currentIndentation: String { String(repeating: configuration.indentation, count: depth) }

  public init(_ configuration: Configuration) {
    self.configuration = configuration
  }

  public struct Configuration: Sendable {
    let indentation: String
    let newLine: String

    public init(indentation: String, newLine: String) {
      self.indentation = indentation
      self.newLine = newLine
    }

    public static let minified = Self(indentation: "", newLine: "")
    public static let pretty = Self(indentation: "  ", newLine: "\n")
  }

  public struct StyleSheetGenerator: Sendable {
    let generate: @Sendable (_ styles: OrderedSet<InlineStyle>) -> [String]
    let stylesheet: @Sendable () -> String
  }
}

extension HTMLContext: TestDependencyKey {
  public static var liveValue: HTMLContext { HTMLContext(.minified) }
  public static var testValue: HTMLContext { HTMLContext(.pretty) }
}

extension DependencyValues {
  public var htmlContext: HTMLContext {
    get { self[HTMLContext.self] }
    set { self[HTMLContext.self] = newValue }
  }
}

extension HTMLContext.StyleSheetGenerator {
  private struct HashedSelector: Hashable {
    let preSelector: InlineStyle.Selector
    let pseudoSelector: InlineStyle.Pseudo?
    let postSelector: InlineStyle.Selector

    init?(_ style: InlineStyle) {
      if style.preSelector.rawValue.isEmpty,
        style.pseudoSelector?.rawValue.isEmpty ?? true,
        style.postSelector.rawValue.isEmpty
      {
        return nil
      } else {
        self.preSelector = style.preSelector
        self.postSelector = style.postSelector
        self.pseudoSelector = style.pseudoSelector
      }
    }
  }

  public static var groupedStyles: Self {
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
                sheet.append(
                  "\(selector?.preSelector.rawValue ?? "").\(className)\(selector?.pseudoSelector?.rawValue ?? "")\(selector?.postSelector.rawValue ?? ""){"
                )
                defer { sheet.append("}") }
                sheet.append(contentsOf: styles.map { "\($0.property):\($0.value);" }.joined())
              }
            }
          }
          return sheet
        }
      }
    )
  }

  public static var `class`: Self {
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
              \(style.preSelector.rawValue).\(className)\(style.pseudoSelector?.rawValue ?? "")\(style.postSelector.rawValue)
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
