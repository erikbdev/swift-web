import Dependencies
import MacroTesting
import Testing
import VueMacros
import Vue

private struct Nested: Encodable {
  let count = 0
}

@Suite("Expression tests")
struct ExpressionTests {
  @Test func createKeyValueExpression() async throws {
    let test1 = Expression("hello")
    let test2 = Expression(0)
    let test3 = Expression([Int]())
    let test4 = Expression(nil)

    #expect(test1.initialValue == "hello")
    #expect(test2.initialValue == 0)
    #expect(test3.initialValue == [])
    #expect(test4.initialValue == nil)

    #expect(test1.rawValue == "\"hello\"")
    #expect(test2.rawValue == "0")
    #expect(test3.rawValue == "[]")
    #expect(test4.rawValue == "null")

    let test5: Expression = "hello"
    let test6: Expression = 0
    let test7: Expression = []
    let test8: Expression = nil

    #expect(test5.initialValue == "hello")
    #expect(test6.initialValue == 0)
    // #expect(test7.initialValue == [])
    #expect(test8.initialValue == nil)

    #expect(test5.rawValue == "\"hello\"" )
    #expect(test6.rawValue == "0")
    #expect(test7.rawValue == "[]")
    #expect(test8.rawValue == "null")

    let expr1 = test1 * test3
    let expr2 = test2 * 0
    #expect(expr1.rawValue == "\"hello\" * []")
    #expect(expr2.rawValue == "0 * 0")

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
    #expect(var1.append(0, var1, "test").rawValue == #"count.append(0, count, "test")"#)
  }
}