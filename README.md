# CompositionStringConvertible
A Swift protocol for composing the textual representation of a type in terms of its components.

The `CompositionStringConvertible` protocol inherits from `CustomStringConvertible` and provides a default implementation of `description` in a style similar to textual representation supplied by the standard library.

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
    formatter.append(label: "fullName", value: fullName)
    formatter.append(label: "age", value: age)
    formatter.append(label: "pet", value: pet)
  }
}
```

This implementation replaces the `firstName` and `lastName` properties with the `fullName` computed property and indicates that `nil` values should not be included.

```swift
print(p) // "Person(fullName: "Matt Comi", age: 42)"
```
