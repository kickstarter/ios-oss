import ReactiveSwift
import SwiftUI

private class ObservableSignalWrapper<T>: ObservableObject {
  private let (lifetime, token) = Lifetime.make()

  @Published var value: T

  init(initialValue value: T, withSignal signal: Signal<T, Never>) {
    self.value = value

    signal
      .take(during: self.lifetime)
      .observeValues { [weak self] newValue in
        self?.value = newValue
      }
  }
}

/// A property wrapper that is useful for bridging ReactiveSwift signals and SwiftUI views.
/// A SwiftUI view that uses an `ObservedSignal` will update when its `ObservedSignal` emits any value.
@propertyWrapper
public struct ObservedSignal<T>: DynamicProperty {
  @ObservedObject private var wrapper: ObservableSignalWrapper<T>

  public var wrappedValue: T {
    return self.wrapper.value
  }

  init(initialValue value: T, withSignal signal: Signal<T, Never>) {
    self.wrapper = ObservableSignalWrapper(initialValue: value, withSignal: signal)
  }
}
