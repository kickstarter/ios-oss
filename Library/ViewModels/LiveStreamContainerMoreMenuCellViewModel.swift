import LiveStream
import Prelude
import ReactiveSwift
import ReactiveExtensions
import Result

public protocol LiveStreamContainerMoreMenuCellViewModelType {
  var inputs: LiveStreamContainerMoreMenuCellViewModelInputs { get }
  var outputs: LiveStreamContainerMoreMenuCellViewModelOutputs { get }
}

public protocol LiveStreamContainerMoreMenuCellViewModelInputs {
  func configureWith(moreMenuItem: LiveStreamContainerMoreMenuItem)
}

public protocol LiveStreamContainerMoreMenuCellViewModelOutputs {
  var activityIndicatorViewHidden: Signal<Bool, NoError> { get }
  var iconImageName: Signal<String, NoError> { get }
  var rightActionButtonHidden: Signal<Bool, NoError> { get }
  var rightActionButtonImage: Signal<UIImage?, NoError> { get }
  var rightActionButtonTitle: Signal<String, NoError> { get }
  var subtitleLabelText: Signal<String, NoError> { get }
  var titleLabelText: Signal<String, NoError> { get }
  var titleLabelTextHidden: Signal<Bool, NoError> { get }
}

public final class LiveStreamContainerMoreMenuCellViewModel: LiveStreamContainerMoreMenuCellViewModelType,
LiveStreamContainerMoreMenuCellViewModelInputs, LiveStreamContainerMoreMenuCellViewModelOutputs {

  public init() {
    self.activityIndicatorViewHidden = .empty
    
    self.iconImageName = .empty

    self.rightActionButtonHidden = self.moreMenuItemProperty.signal.skipNil().map { menuItem in
      if case .subscribe = menuItem { return false }
      return true
    }

    self.rightActionButtonImage = .empty
    self.rightActionButtonTitle = .empty

    self.subtitleLabelText = self.moreMenuItemProperty.signal.skipNil().map { menuItem in
      switch menuItem {
      case .hideChat:
        return localizedString(key: "Hide_chat", defaultValue: "Hide chat")
      case .share:
        return localizedString(key: "Share_live_stream", defaultValue: "Share live stream")
      case .goToProject(let liveStreamEvent):
        return liveStreamEvent.project.name
      case .subscribe:
        return localizedString(key: "Sign_up_for_this_creators_live_streams",
                               defaultValue: "Sign up for this creator's live streams")
      case .cancel:
        return localizedString(key: "Cancel", defaultValue: "Cancel")
      }
    }

    self.titleLabelText = self.moreMenuItemProperty.signal.skipNil().map { menuItem in
      if case let .goToProject(liveStreamEvent) = menuItem { return liveStreamEvent.creator.name }
      return ""
    }

    self.titleLabelTextHidden = .empty
  }

  private let moreMenuItemProperty = MutableProperty<LiveStreamContainerMoreMenuItem?>(nil)
  public func configureWith(moreMenuItem: LiveStreamContainerMoreMenuItem) {
    self.moreMenuItemProperty.value = moreMenuItem
  }

  public let activityIndicatorViewHidden: Signal<Bool, NoError>
  public let iconImageName: Signal<String, NoError>
  public let rightActionButtonHidden: Signal<Bool, NoError>
  public let rightActionButtonImage: Signal<UIImage?, NoError>
  public let rightActionButtonTitle: Signal<String, NoError>
  public let subtitleLabelText: Signal<String, NoError>
  public let titleLabelText: Signal<String, NoError>
  public let titleLabelTextHidden: Signal<Bool, NoError>

  public var inputs: LiveStreamContainerMoreMenuCellViewModelInputs { return self }
  public var outputs: LiveStreamContainerMoreMenuCellViewModelOutputs { return self }
}

public enum LiveStreamContainerMoreMenuItem {
  case hideChat(hidden: Bool)
  case share(liveStreamEvent: LiveStreamEvent)
  case goToProject(liveStreamEvent: LiveStreamEvent)
  case subscribe(subscribed: Bool)
  case cancel
}
