import Dependencies

struct Base62Generator: DependencyKey {
  let generate: @Sendable (Int) -> String

  func callAsFunction(_ lenght: Int) -> String {
    self.generate(lenght)
  }

  private static let randomCharacters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"

  static let liveValue = Base62Generator { lenght in
    (0..<lenght).reduce(into: "") { result, _ in
      randomCharacters.randomElement()
        .flatMap {
          result.append($0)
        }
    }
  }
}

extension DependencyValues {
  var base62Generator: Base62Generator {
    get { self[Base62Generator.self] }
    set { self[Base62Generator.self] = newValue }
  }
}