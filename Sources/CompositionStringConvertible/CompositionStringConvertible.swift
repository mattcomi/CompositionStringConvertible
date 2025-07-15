import Foundation

/// A type that describes its components to a `CompositionFormatter` to produce a textual representation.
///
/// The `CompositionStringConvertible` protocol inherits from `CustomStringConvertible` and provides a default
/// implementation of `description` in a style similar to the textual representation supplied by the standard library.
/// Types that conform to `CompositionStringConvertible` may customize the components that are included in their textual
/// representation.
///
/// Consider the following structure:
///
/// ```swift
/// struct Person {
///   let firstName: String
///   let lastName: String
///   let age: Int
///   let pet: Animal?
///
///   var fullName: String {
///     [firstName, lastName].joined(separator: " ")
///   }
/// }
/// ```
///
/// `Person` doesn't implement `CustomStringConvertible` so a default textual representation is provided by the standard
///  library:
///
/// ```swift
/// let p = Person(firstName: "Matt", lastName: "Comi", age: 42, pet: nil)
/// print(p) // "Person(firstName: "Matt", lastName: "Comi", age: 42, pet: nil)"
/// ```
///
/// Traditionally, the only way to customize this representation is by conforming to `CustomStringConvertible` and
/// manually implementing `var description: String`. Alternatively, consider this conformance to
/// `CompositionStringConvertible`:
///
/// ```swift
/// extension Person: CompositionStringConvertible {
///   func describe(to formatter: inout CompositionFormatter) {
///     formatter.includesNilValues = false
///     formatter.append(value: fullName)
///     formatter.append(label: "age", value: age)
///     formatter.append(label: "pet", value: pet)
///   }
/// }
/// ```
///
/// This implementation:
///
/// * Replaces the `firstName` and `lastName` properties with the `fullName` computed property.
/// * Omits the label of the `fullName` property.
/// * Indicates that `nil` values should not be included.
///
/// ```swift
/// print(p) // "Person("Matt Comi", age: 42)"
/// ```
public protocol CompositionStringConvertible: CustomStringConvertible {
  /// Describes this instance by adding its components to the provided formatter.
  func describe(to formatter: inout CompositionFormatter)
}

extension CompositionStringConvertible {
  public var description: String {
    var formatter = CompositionFormatter(typeName: .init(describing: Self.self), includesNilValues: true)

    describe(to: &formatter)

    return formatter.string
  }
}

/// A formatter that produces a textual representation of a type based on its name and components.
public struct CompositionFormatter {
  private struct Component: CustomStringConvertible {
    let label: String?
    let value: String?
    let isString: Bool

    var description: String {
      let styledValue =
        if let value {
          isString ? #""\#(value)""# : value
        } else {
          "nil"
        }

      return [label, styledValue].compactMap { $0 }.joined(separator: ": ")
    }
  }

  /// The name of the type being composed.
  ///
  /// The `ComponentStringConvertible` sets this to `String(describing: Self.self)`.
  public var typeName: String?

  /// Indicates whether `nil` values should be included in the resulting string.
  public var includesNilValues: Bool

  private var components: [Component] = []

  init(typeName: String?, includesNilValues: Bool) {
    self.typeName = typeName
    self.includesNilValues = includesNilValues
  }

  /// Appends a component to the `ComponentFormatter`.
  public mutating func append<T>(label: String? = nil, _ value: T?) {
    let isString = value is any StringProtocol

    components.append(.init(label: label, value: value.map { String(describing: $0) }, isString: isString))
  }

  /// Returns the textual representation of the type.
  public var string: String {
    let componentsDescription =
      components
      .compactMap { element in
        if element.value == nil && !includesNilValues { return nil }

        return String(describing: element)
      }
      .joined(separator: ", ")

    return "\(typeName ?? "")(\(componentsDescription))"
  }
}

#if canImport(Foundation)
  import Foundation

  @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
  extension CompositionFormatter {
    /// Appends the component to the `ComponentFormatter` formatted with the given `FormatStyle`.
    public mutating func append<T, U: FormatStyle>(label: String? = nil, _ value: T?, formatStyle: U)
    where T == U.FormatInput, U.FormatOutput == String {
      let isString = value is any StringProtocol

      components.append(.init(label: label, value: value.map { formatStyle.format($0) }, isString: isString))
    }
  }
#endif
