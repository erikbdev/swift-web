import Dependencies
import MacroTesting
import Testing
import VueMacros
import Vue

@Suite("Expression tests")
struct ExpressionTests {
  private struct Nested: Encodable {
    let count = 0
  }

  @Test func createKeyValueExpression() async throws {
    let test1 = Expression("hello")
    let test2 = Expression(0)
    let test3 = Expression([Int]())

    #expect((test1 * test3).rawValue == "\"hello\" * []")
    #expect((test2 * 0).rawValue == "0 * 0")

    let test4: Expression = "hello"
    let test5: Expression = 0
    let test6: Expression = []
    let test7: Expression = nil

    #expect(test4.rawValue == "\"hello\"" )
    #expect(test5.rawValue == "0")
    #expect(test6.rawValue == "[]")
    #expect(test7.rawValue == "null")

    let object1 = Expression(
      ("count", 0),
      ("msg", String?.none),
      ("nested", Nested())
    )

    #expect(
     object1.rawValue == 
      """
      {"count":0,"msg":null,"nested":{"count":0}}
      """
    )

    let var1 = Expression(rawValue: "count")

    #expect(var1.rawValue == "count")
    #expect(var1.length.rawValue == "count.length")
    #expect(var1.toString().rawValue == "count.toString()")
    #expect(var1.append("hello", 0, [Int]()).rawValue == #"count.append("hello", 0, [])"#)
    #expect(var1.append(test1, test2, test3).rawValue == #"count.append("hello", 0, [])"#)
  }
}
