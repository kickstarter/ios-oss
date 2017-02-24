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
  var creatorAvatarHidden: Signal<Bool, NoError> { get }
  var creatorAvatarUrl: Signal<URL?, NoError> { get }
  var iconImage: Signal<UIImage?, NoError> { get }
  var iconImageHidden: Signal<Bool, NoError> { get }
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
    self.rightActionButtonImage = .empty
    self.rightActionButtonTitle = .empty
    
    self.iconImage = self.moreMenuItemProperty.signal.skipNil().map { menuItem in
      switch menuItem {
      case .hideChat:
        return UIImage(named: "speech-icon")
      case .share:
        return UIImage(named: "share-icon")
      case .goToProject:
        return UIImage(named: "info-icon")
      default:
        return nil
      }
    }

    self.iconImageHidden = self.iconImage.map { $0 == nil }

    self.creatorAvatarUrl = self.moreMenuItemProperty.signal.skipNil().map { menuItem in
      if case let .subscribe(liveStreamEvent) = menuItem {
        return URL(string: liveStreamEvent.creator.avatar)
      }
      return nil
    }

    self.creatorAvatarHidden = self.creatorAvatarUrl.map { $0 == nil }

    self.rightActionButtonHidden = self.moreMenuItemProperty.signal.skipNil().map { menuItem in
      if case .subscribe = menuItem { return false }
      return true
    }

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

    self.titleLabelTextHidden = self.moreMenuItemProperty.signal.skipNil().map { menuItem in
      if case .goToProject = menuItem { return false }
      return true
    }
  }

  private let moreMenuItemProperty = MutableProperty<LiveStreamContainerMoreMenuItem?>(nil)
  public func configureWith(moreMenuItem: LiveStreamContainerMoreMenuItem) {
    self.moreMenuItemProperty.value = moreMenuItem
  }

  public let activityIndicatorViewHidden: Signal<Bool, NoError>
  public let creatorAvatarHidden: Signal<Bool, NoError>
  public let creatorAvatarUrl: Signal<URL?, NoError>
  public let iconImage: Signal<UIImage?, NoError>
  public let iconImageHidden: Signal<Bool, NoError>
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
  case subscribe(liveStreamEvent: LiveStreamEvent)
  case cancel
}
