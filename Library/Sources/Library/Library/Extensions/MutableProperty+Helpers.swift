import ReactiveSwift

extension MutableProperty {
  /// Emits its current value when `takeInitialValueWhen` is sent, and whenever the value changes, too.
  /// Useful for turning a `MutableProperty` with a default value into a `signal`.
  func signal(takeInitialValueWhen initialSignal: Signal<Void, Never>) -> Signal<Value, Never> {
    return Signal.merge(
      self.producer.takeWhen(initialSignal),
      self.signal
    )
  }
}
