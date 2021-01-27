import KsApi
import Prelude
import ReactiveExtensions
import ReactiveSwift

public protocol FindFriendsHeaderCellViewModelInputs {
  /// Call when close button is tapped to dismiss this view
  func closeButtonTapped()

  /// Call to set source from whence this view was loaded
  func configureWith(source: FriendsSource)

  /// Call when Find Friends button is tapped
  func findFriendsButtonTapped()
}

public protocol FindFriendsHeaderCellViewModelOutputs {
  /// Emits when should notify delegate to go to Find Friends screen
  var notifyDelegateGoToFriends: Signal<(), Never> { get }

  /// Emits when should notify delegate to dismiss this view
  var notifyDelegateToDismissHeader: Signal<(), Never> { get }
}

public protocol FindFriendsHeaderCellViewModelType {
  var inputs: FindFriendsHeaderCellViewModelInputs { get }
  var outputs: FindFriendsHeaderCellViewModelOutputs { get }
}

public final class FindFriendsHeaderCellViewModel: FindFriendsHeaderCellViewModelType,
  FindFriendsHeaderCellViewModelInputs, FindFriendsHeaderCellViewModelOutputs {
  public init() {
    self.notifyDelegateGoToFriends = self.findFriendsButtonTappedProperty.signal
    self.notifyDelegateToDismissHeader = self.closeButtonTappedProperty.signal
  }

  public var inputs: FindFriendsHeaderCellViewModelInputs { return self }
  public var outputs: FindFriendsHeaderCellViewModelOutputs { return self }

  fileprivate let closeButtonTappedProperty = MutableProperty(())
  public func closeButtonTapped() {
    self.closeButtonTappedProperty.value = ()
  }

  fileprivate let configureWithProperty = MutableProperty<FriendsSource>(FriendsSource.activity)
  public func configureWith(source: FriendsSource) {
    self.configureWithProperty.value = source
  }

  fileprivate let findFriendsButtonTappedProperty = MutableProperty(())
  public func findFriendsButtonTapped() {
    self.findFriendsButtonTappedProperty.value = ()
  }

  public let notifyDelegateGoToFriends: Signal<(), Never>
  public let notifyDelegateToDismissHeader: Signal<(), Never>
}
