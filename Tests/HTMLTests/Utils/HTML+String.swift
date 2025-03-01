import HTML

func == <T: HTML>(lhs: T, rhs: String) -> Bool {
  lhs.render() == rhs
}