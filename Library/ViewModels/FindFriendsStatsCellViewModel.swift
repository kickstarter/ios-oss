import KsApi
import ReactiveCocoa
import ReactiveExtensions
import Result
import Prelude

public protocol FindFriendsStatsCellViewModelInputs {
  /// Call to set with stats and the source from whence it comes
  func configureWith(stats stats: FriendStatsEnvelope, source: FriendsSource)

  /// Call when follow all button is tapped
  func followAllButtonTapped()
}

public protocol FindFriendsStatsCellViewModelOutputs {
  /// Emits total friends' backed projects text
  var backedProjectsCountText: Signal<String, NoError> { get }

  /// Emits text for Follow All button
  var followAllText: Signal<String, NoError> { get }

  /// Emits friends count text
  var friendsCountText: Signal<String, NoError> { get }

  /// Emits whether Follow All button should show
  var hideFollowAllButton: Signal<Bool, NoError> { get }

  /// Emits when should show Follow All confirmation alert with friends count
  var notifyDelegateShowFollowAllFriendsAlert: Signal<Int, NoError> { get }
}

public protocol FindFriendsStatsCellViewModelType {
  var inputs: FindFriendsStatsCellViewModelInputs { get }
  var outputs: FindFriendsStatsCellViewModelOutputs { get }
}

public final class FindFriendsStatsCellViewModel: FindFriendsStatsCellViewModelType,
  FindFriendsStatsCellViewModelInputs, FindFriendsStatsCellViewModelOutputs {
  public init() {
    let friendProjectsCount: Signal<Int, NoError> = self.configureWithStatsProperty.signal
      .map { $0?.stats.friendProjectsCount ?? 0 }

    let remoteFriendCount: Signal<Int, NoError> = self.configureWithStatsProperty.signal
      .map { $0?.stats.remoteFriendsCount ?? 0 }

    self.backedProjectsCountText = friendProjectsCount.map { Format.wholeNumber($0) }

    self.followAllText = remoteFriendCount
      .map(Strings.social_following_stats_button_follow_all_friends(remote_friends_count:))

    self.friendsCountText = remoteFriendCount.map { Format.wholeNumber($0) }

    self.hideFollowAllButton = remoteFriendCount.map { $0 <= 2 }

    self.notifyDelegateShowFollowAllFriendsAlert = remoteFriendCount
      .map { $0 }
      .takeWhen(self.followAllButtonTappedProperty.signal)
  }

  public var inputs: FindFriendsStatsCellViewModelInputs { return self }
  public var outputs: FindFriendsStatsCellViewModelOutputs { return self }

  private let configureWithStatsProperty = MutableProperty<FriendStatsEnvelope?>(nil)
  private let configureWithSourceProperty = MutableProperty<FriendsSource>(FriendsSource.findFriends)
  public func configureWith(stats stats: FriendStatsEnvelope, source: FriendsSource) {
    configureWithStatsProperty.value = stats
    configureWithSourceProperty.value = source
  }

  private let confirmFollowAllFriendsProperty = MutableProperty()
  func confirmFollowAllFriends() {
    confirmFollowAllFriendsProperty.value = ()
  }

  private let declineFollowAllFriendsProperty = MutableProperty()
  func declineFollowAllFriends() {
    declineFollowAllFriendsProperty.value = ()
  }

  private let followAllButtonTappedProperty = MutableProperty()
  public func followAllButtonTapped() {
    followAllButtonTappedProperty.value = ()
  }

  public let backedProjectsCountText: Signal<String, NoError>
  public let followAllText: Signal<String, NoError>
  public let friendsCountText: Signal<String, NoError>
  public let hideFollowAllButton: Signal<Bool, NoError>
  public let notifyDelegateShowFollowAllFriendsAlert: Signal<Int, NoError>
}
