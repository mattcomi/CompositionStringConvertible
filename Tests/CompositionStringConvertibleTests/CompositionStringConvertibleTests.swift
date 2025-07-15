import Testing

import CompositionStringConvertible

@Test func usage() async throws {
  struct Animal {}

  struct Person: CompositionStringConvertible {
    let firstName: String
    let lastName: String
    let age: Int
    let pet: Animal?

    func describe(to formatter: inout CompositionFormatter) {
      formatter.includesNilValues = false
      formatter.append([firstName, lastName].joined(separator: " "))
      formatter.append(label: "age", age)
      formatter.append(label: "pet", pet)
    }
  }

  let mattComi = Person(firstName: "Matt", lastName: "Comi", age: 42, pet: nil)

  #expect(String(describing: mattComi) == #"Person("Matt Comi", age: 42)"#)
}

@Test func typeName() async throws {
  struct Apple: CompositionStringConvertible {
    enum TypeName {
      case standard
      case none
      case custom(String)
    }

    var typeName: TypeName = .standard

    func describe(to formatter: inout CompositionFormatter) {
      switch typeName {
      case .standard:
        break
      case .none:
        formatter.typeName = nil
      case .custom(let string):
        formatter.typeName = string
      }
    }
  }

  var fruit = Apple()

  #expect("\(fruit)" == "Apple()")

  fruit.typeName = .custom("Banana")

  #expect("\(fruit)" == "Banana()")

  fruit.typeName = .none

  #expect("\(fruit)" == "()")
}

@Test func includesNilValues() async throws {
  struct Point: CompositionStringConvertible {
    var x: Int?
    var y: Int?

    var includesNilValues = true

    func describe(to formatter: inout CompositionFormatter) {
      formatter.includesNilValues = includesNilValues
      formatter.append(label: "x", x)
      formatter.append(label: "y", y)
    }
  }

  var point = Point(x: 1, y: nil)

  #expect("\(point)" == "Point(x: 1, y: nil)")

  point.includesNilValues = false

  #expect("\(point)" == "Point(x: 1)")

  point.x = nil

  #expect("\(point)" == "Point()")
}

@Test func formatStyle() async throws {
  struct Task: CompositionStringConvertible {
    let name: String
    let progress: Float

    func describe(to formatter: inout CompositionFormatter) {
      formatter.append(name)
      formatter.append(label: "progress", progress, formatStyle: .percent)
    }
  }

  let tidyGarden = Task(name: "Tidy Garden", progress: 0.2)

  #expect("\(tidyGarden)" == #"Task("Tidy Garden", progress: 20%)"#)
}
