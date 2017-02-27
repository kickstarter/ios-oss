import LiveStream
import Prelude
import ReactiveSwift
import ReactiveExtensions
import Result

public protocol LiveStreamContainerMoreMenuActionCellViewModelType {
  var inputs: LiveStreamContainerMoreMenuActionCellViewModelInputs { get }
  var outputs: LiveStreamContainerMoreMenuActionCellViewModelOutputs { get }
}

public protocol LiveStreamContainerMoreMenuActionCellViewModelInputs {
  func configureWith(moreMenuItem: LiveStreamContainerMoreMenuItem)
}

public protocol LiveStreamContainerMoreMenuActionCellViewModelOutputs {
  var creatorAvatarUrl: Signal<URL?, NoError> { get }
  var rightActionActivityIndicatorViewHidden: Signal<Bool, NoError> { get }
  var rightActionButtonHidden: Signal<Bool, NoError> { get }
  var rightActionButtonImageName: Signal<String, NoError> { get }
  var rightActionButtonTitle: Signal<String, NoError> { get }
  var titleLabelText: Signal<String, NoError> { get }
}

public final class LiveStreamContainerMoreMenuActionCellViewModel: LiveStreamContainerMoreMenuActionCellViewModelType,
LiveStreamContainerMoreMenuActionCellViewModelInputs, LiveStreamContainerMoreMenuActionCellViewModelOutputs {

  public init() {
    self.rightActionActivityIndicatorViewHidden = Signal.merge(
      self.moreMenuItemProperty.signal.skipNil().mapConst(true)
    )
    self.rightActionButtonImageName = .empty
    self.rightActionButtonTitle = .empty

    self.creatorAvatarUrl = self.moreMenuItemProperty.signal.skipNil().map { menuItem in
      if case let .subscribe(liveStreamEvent) = menuItem {
        return URL(string: liveStreamEvent.creator.avatar)
      }
      return nil
    }

    self.rightActionButtonHidden = self.moreMenuItemProperty.signal.skipNil().map { menuItem in
      if case .subscribe = menuItem { return false }
      return true
    }

    self.titleLabelText = self.moreMenuItemProperty.signal.skipNil().map { _ in
      return localizedString(key: "Sign_up_for_this_creators_live_streams",
                             defaultValue: "Sign up for this creator's live streams")
    }
  }

  private let moreMenuItemProperty = MutableProperty<LiveStreamContainerMoreMenuItem?>(nil)
  public func configureWith(moreMenuItem: LiveStreamContainerMoreMenuItem) {
    self.moreMenuItemProperty.value = moreMenuItem
  }

  public let creatorAvatarUrl: Signal<URL?, NoError>
  public let rightActionActivityIndicatorViewHidden: Signal<Bool, NoError>
  public let rightActionButtonHidden: Signal<Bool, NoError>
  public let rightActionButtonImageName: Signal<String, NoError>
  public let rightActionButtonTitle: Signal<String, NoError>
  public let titleLabelText: Signal<String, NoError>

  public var inputs: LiveStreamContainerMoreMenuActionCellViewModelInputs { return self }
  public var outputs: LiveStreamContainerMoreMenuActionCellViewModelOutputs { return self }
}

public enum LiveStreamContainerMoreMenuItem {
  case hideChat(hidden: Bool)
  case share(liveStreamEvent: LiveStreamEvent)
  case goToProject(liveStreamEvent: LiveStreamEvent)
  case subscribe(liveStreamEvent: LiveStreamEvent)
  case cancel
}
