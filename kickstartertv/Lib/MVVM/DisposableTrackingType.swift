import ReactiveCocoa

public protocol DisposableTrackingType: class {
  var disposables: [Disposable] { get set }
}

extension DisposableTrackingType {
  /// Adds a disposable to the internal collection of disposables being tracked.
  public final func addDisposable(disposable: Disposable) {
    disposables.append(disposable)
  }

  /// Optionally adds a disposable to the internal collection of disposables being tracked.
  public final func addDisposable(disposable: Disposable?) {
    guard let disposable = disposable else { return }
    addDisposable(disposable)
  }

  /// Adds a collection of disposables to the internal collection being tracked.
  public final func addDisposables(disposables: [Disposable]) {
    self.disposables += disposables
  }

  /// Adds a collection of optional disposables to the internal collection being tracked.
  public final func addDisposables(disposables: [Disposable?]) {
    for d in disposables {
      addDisposable(d)
    }
  }

  /// Dispose of and clear the internal collection of disposables
  public final func clearDisposables() {
    for d in disposables {
      d.dispose()
    }
    disposables = []
  }
}
