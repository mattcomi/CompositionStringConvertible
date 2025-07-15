# CompositionStringConvertible
A Swift protocol for composing the textual representation of a type in terms of its components.

The `CompositionStringConvertible` protocol inherits from `CustomStringConvertible` and provides a default implementation of `description` in a style similar to the textual representation supplied by the standard library.

```swift
protocol CompositionStringConvertible: CustomStringConvertible {
  func describe(to formatter: inout CompositionFormatter)
}
```

Types that conform to `CompositionStringConvertible` may customize the components that are included in their textual representation. 

Consider the following structure:

```swift
struct Person {
  let firstName: String
  let lastName: String
  let age: Int
  let pet: Animal?

  var fullName: String {
    [firstName, lastName].joined(separator: " ")
  }
}
```

`Person` doesn't implement `CustomStringConvertible` so a default textual representation is provided by the standard library:

```swift
let p = Person(firstName: "Matt", lastName: "Comi", age: 42, pet: nil)
print(p) // "Person(firstName: "Matt", lastName: "Comi", age: 42, pet: nil)"
```

Traditionally, the only way to customize this representation is by conforming to `CustomStringConvertible` and manually implementing `var description: String`. Alternatively, consider this conformance to `CompositionStringConvertible`:

```swift
extension Person: CompositionStringConvertible {
  func describe(to formatter: inout CompositionFormatter) {
    formatter.includesNilValues = false
    formatter.append(value: fullName)
    formatter.append(label: "age", value: age)
    formatter.append(label: "pet", value: pet)
  }
}
```

This implementation:

* Replaces the `firstName` and `lastName` properties with the `fullName` computed property.
* Omits the label of the `fullName` property.
* Indicates that `nil` values should not be included.

```swift
print(p) // "Person("Matt Comi", age: 42)"
```

## Formatting

Values appended to the `CompositionFormatter` are formatted using `String(describing:)`. This behavior may be overridden on platforms where `FormatStyle` is available:

```swift
public mutating func append<T, U: FormatStyle>(label: String? = nil, value: T?, formatStyle: U)
where T == U.FormatInput, U.FormatOutput == String
```

Consider this `Task` type:

```swift
struct Task {
  let name: String
  let progress: Float
}
```

A `Task` has the following default textual representation:

```swift 
let t = Task(name: "Tidy Garden", progress: 0.2)
print(t) // "Task(name: "Tidy Garden", progress: 0.2) 
```

By conforming to `CompositionStringConvertible` the progress of the task may be represented as a percentage: 

```swift
extension Task: CompositionStringConvertible {
  func describe(to formatter: inout CompositionFormatter) {
    formatter.append(value: name)
    formatter.append(label: "progress", value: progress, formatStyle: .percent)
  }
}

print(t) // "Task("Tidy Garden", progress: 20%)
```
