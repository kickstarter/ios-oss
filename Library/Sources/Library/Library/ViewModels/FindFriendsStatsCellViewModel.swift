import KsApi
import Prelude
import ReactiveExtensions
import ReactiveSwift

public protocol FindFriendsStatsCellViewModelInputs {
  /// Call to set with stats and the source from whence it comes
  func configureWith(stats: FriendStatsEnvelope, source: FriendsSource)

  /// Call when follow all button is tapped
  func followAllButtonTapped()
}

public protocol FindFriendsStatsCellViewModelOutputs {
  /// Emits total friends' backed projects text
  var backedProjectsCountText: Signal<String, Never> { get }

  /// Emits text for Follow All button
  var followAllText: Signal<String, Never> { get }

  /// Emits friends count text
  var friendsCountText: Signal<String, Never> { get }

  /// Emits whether Follow All button should show
  var hideFollowAllButton: Signal<Bool, Never> { get }

  /// Emits when should show Follow All confirmation alert with friends count
  var notifyDelegateShowFollowAllFriendsAlert: Signal<Int, Never> { get }
}

public protocol FindFriendsStatsCellViewModelType {
  var inputs: FindFriendsStatsCellViewModelInputs { get }
  var outputs: FindFriendsStatsCellViewModelOutputs { get }
}

public final class FindFriendsStatsCellViewModel: FindFriendsStatsCellViewModelType,
  FindFriendsStatsCellViewModelInputs, FindFriendsStatsCellViewModelOutputs {
  public init() {
    let friendProjectsCount: Signal<Int, Never> = self.configureWithStatsProperty.signal
      .map { $0?.stats.friendProjectsCount ?? 0 }

    let remoteFriendCount: Signal<Int, Never> = self.configureWithStatsProperty.signal
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

  fileprivate let configureWithStatsProperty = MutableProperty<FriendStatsEnvelope?>(nil)
  fileprivate let configureWithSourceProperty = MutableProperty<FriendsSource>(FriendsSource.findFriends)
  public func configureWith(stats: FriendStatsEnvelope, source: FriendsSource) {
    self.configureWithStatsProperty.value = stats
    self.configureWithSourceProperty.value = source
  }

  fileprivate let confirmFollowAllFriendsProperty = MutableProperty(())
  func confirmFollowAllFriends() {
    self.confirmFollowAllFriendsProperty.value = ()
  }

  fileprivate let declineFollowAllFriendsProperty = MutableProperty(())
  func declineFollowAllFriends() {
    self.declineFollowAllFriendsProperty.value = ()
  }

  fileprivate let followAllButtonTappedProperty = MutableProperty(())
  public func followAllButtonTapped() {
    self.followAllButtonTappedProperty.value = ()
  }

  public let backedProjectsCountText: Signal<String, Never>
  public let followAllText: Signal<String, Never>
  public let friendsCountText: Signal<String, Never>
  public let hideFollowAllButton: Signal<Bool, Never>
  public let notifyDelegateShowFollowAllFriendsAlert: Signal<Int, Never>
}
