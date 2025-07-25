import HTML

func == <T: AsyncHTML>(lhs: T, rhs: String) async throws -> Bool {
  try await lhs.render() == rhs
}

func == <T: HTML>(lhs: T, rhs: String) -> Bool {
  lhs.render() == rhs
}