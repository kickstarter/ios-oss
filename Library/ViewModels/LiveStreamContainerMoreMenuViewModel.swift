import LiveStream
import Prelude
import ReactiveSwift
import ReactiveExtensions
import Result

public protocol LiveStreamContainerMoreMenuViewModelType {
  var inputs: LiveStreamContainerMoreMenuViewModelInputs { get }
  var outputs: LiveStreamContainerMoreMenuViewModelOutputs { get }
}

public protocol LiveStreamContainerMoreMenuViewModelInputs {
  /// Call with the LiveStreamEvent
  func configureWith(liveStreamEvent: LiveStreamEvent, chatHidden: Bool)

  /// Call when the viewDidLoad
  func viewDidLoad()
}

public protocol LiveStreamContainerMoreMenuViewModelOutputs {
  var loadDataSource: Signal<[LiveStreamContainerMoreMenuItem], NoError> { get }
}

public final class LiveStreamContainerMoreMenuViewModel: LiveStreamContainerMoreMenuViewModelType,
LiveStreamContainerMoreMenuViewModelInputs, LiveStreamContainerMoreMenuViewModelOutputs {

  public init() {
    let configData = Signal.combineLatest(
      self.configData.signal.skipNil(),
      self.viewDidLoadProperty.signal
    )
    .map(first)

    self.loadDataSource = configData
      .map { liveStreamEvent, chatHidden -> [LiveStreamContainerMoreMenuItem] in
        return [
          .hideChat(hidden: chatHidden),
          .share(liveStreamEvent: liveStreamEvent),
          .cancel
        ]
    }
  }

  private let configData = MutableProperty<(LiveStreamEvent, Bool)?>(nil)
  public func configureWith(liveStreamEvent: LiveStreamEvent, chatHidden: Bool) {
    self.configData.value = (liveStreamEvent, chatHidden)
  }

  private let viewDidLoadProperty = MutableProperty()
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  public let loadDataSource: Signal<[LiveStreamContainerMoreMenuItem], NoError>

  public var inputs: LiveStreamContainerMoreMenuViewModelInputs { return self }
  public var outputs: LiveStreamContainerMoreMenuViewModelOutputs { return self }
}

public enum LiveStreamContainerMoreMenuItem {
  case hideChat(hidden: Bool)
  case share(liveStreamEvent: LiveStreamEvent)
  case cancel
}

extension LiveStreamContainerMoreMenuItem: Equatable {
  public static func == (lhs: LiveStreamContainerMoreMenuItem, rhs: LiveStreamContainerMoreMenuItem) -> Bool {
    switch (lhs, rhs) {
    case (.hideChat(let lhsHidden), .hideChat(let rhsHidden)):
      return lhsHidden == rhsHidden
    case (.share(let lhsLiveStreamEvent), .share(let rhsLiveStreamEvent)):
      return lhsLiveStreamEvent == rhsLiveStreamEvent
    case (.cancel, .cancel):
      return true
    default:
      return false
    }
  }
}
