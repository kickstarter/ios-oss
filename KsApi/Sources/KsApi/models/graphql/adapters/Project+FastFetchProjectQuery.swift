import GraphAPI
import ReactiveSwift

public struct ProjectPageExtraProperties {
  let extendedProjectProperties: ExtendedProjectProperties
  let video: Project.Video?
  let flagging: Bool

  public func addExtraProperties(toProject project: Project) -> Project {
    var updatedProject = project
    updatedProject.flagging = self.flagging
    updatedProject.extendedProjectProperties = self.extendedProjectProperties
    updatedProject.video = self.video

    return updatedProject
  }

  internal static func extraPropertiesProducer(
    from data: GraphAPI.FastFetchProjectPageExtendedPropertiesQuery.Data
  ) -> SignalProducer<ProjectPageExtraProperties, ErrorEnvelope> {
    let properties = ProjectPageExtraProperties.extraProperties(from: data)

    guard let properties else {
      return SignalProducer(error: ErrorEnvelope.couldNotParseJSON)
    }

    return SignalProducer(value: properties)
  }

  internal static func extraProperties(
    from data: GraphAPI.FastFetchProjectPageExtendedPropertiesQuery.Data
  ) -> ProjectPageExtraProperties? {
    guard let project = data.project else { return nil }

    let videoFragment = project.video?.fragments.projectVideoFragment
    let video = Project.Video.projectVideo(from: videoFragment)

    let extendedFragment = project.fragments.extendedProjectPropertiesFragment
    let extendedProperties = ExtendedProjectProperties.extendedProject(from: extendedFragment)

    let flagging = project.flagging.isSome

    return ProjectPageExtraProperties(
      extendedProjectProperties: extendedProperties,
      video: video,
      flagging: flagging
    )
  }
}

extension Project {
  static func projectProducer(
    from data: GraphAPI.FastFetchProjectPageBaseQuery.Data
  ) -> SignalProducer<Project, ErrorEnvelope> {
    guard let project = Project.project(from: data) else {
      return SignalProducer(error: ErrorEnvelope.couldNotParseJSON)
    }

    return SignalProducer(value: project)
  }

  internal static func project(
    from data: GraphAPI.FastFetchProjectPageBaseQuery.Data
  ) -> Project? {
    guard let project = data.project else { return nil }

    var backing: Backing?
    if let backingFragment = project.backing?.fragments.backingFragment {
      backing = Backing.backing(from: backingFragment)
    }

    let rewards: [Reward] = project.rewards?.nodes?.compactMap { node in
      guard let fragment = node?.fragments.rewardFragment else { return nil }
      return Reward.reward(from: fragment)
    } ?? []

    let noRewardFragment = project.fragments.noRewardRewardFragment
    let noReward = Reward.noRewardReward(from: noRewardFragment)

    return Project.project(
      from: project.fragments.projectFragment,
      flagging: nil,
      rewards: [noReward] + rewards,
      backing: backing,
      extendedProjectProperties: nil,
      video: nil
    )
  }
}
