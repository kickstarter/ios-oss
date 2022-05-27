import AVFoundation
import KsApi
import Library
import Prelude
import UIKit

internal final class ProjectPageViewControllerDataSource: ValueCellDataSource {
  internal enum Section: Int {
    case overviewCreatorHeader
    case overview
    case overviewSubpages
    case campaignHeader
    case campaign
    case faqsHeader
    case faqsEmpty
    case faqs
    case faqsAskAQuestion
    case risksHeader
    case risks
    case risksDisclaimer
    case environmentalCommitmentsHeader
    case environmentalCommitments
    case environmentalCommitmentsDisclaimer
  }

  private enum HeaderValue {
    case overview
    case campaign
    case environmentalCommitments
    case faqs
    case risks

    var description: String {
      switch self {
      case .overview:
        return Strings.Overview()
      case .campaign:
        return Strings.Campaign()
      case .environmentalCommitments:
        return Strings.Environmental_commitments()
      case .faqs:
        return Strings.Frequently_asked_questions()
      case .risks:
        return Strings.Risks_and_challenges()
      }
    }
  }

  private var preexistingImageViewElementsWithData = [(element: ImageViewElement, image: UIImage?)]()
  private var preexistingAudioVideoViewElementsWithPlayer =
    [(element: AudioVideoViewElement, player: AVPlayer?, image: UIImage?)]()

  func load(
    navigationSection: NavigationSection,
    project: Project,
    refTag: RefTag?,
    isExpandedStates: [Bool]? = nil
  ) {
    self.prepareImagesInCampaignSection()
    self.prepareAudioVideosInCampaignSection()
    // Clear all sections
    self.clearValues()

    switch navigationSection {
    case .overview:
      if currentUserIsCreator(of: project) {
        self.set(
          values: [project],
          cellClass: ProjectPamphletCreatorHeaderCell.self,
          inSection: Section.overviewCreatorHeader.rawValue
        )
      }

      self.set(
        values: [(project, refTag)],
        cellClass: ProjectPamphletMainCell.self,
        inSection: Section.overview.rawValue
      )

      let values: [ProjectPamphletSubpage] = [
        .comments(project.stats.commentsCount as Int?, .first),
        .updates(project.stats.updatesCount as Int?, .last)
      ]

      self.set(
        values: values,
        cellClass: ProjectPamphletSubpageCell.self,
        inSection: Section.overviewSubpages.rawValue
      )
    case .campaign:
      self.set(
        values: [HeaderValue.campaign.description],
        cellClass: ProjectHeaderCell.self,
        inSection: Section.campaignHeader.rawValue
      )

      let htmlViewElements = project.extendedProjectProperties?.story.htmlViewElements ?? []

      htmlViewElements.forEach { element in
        switch element {
        case let element as TextViewElement:
          self
            .appendRow(
              value: element,
              cellClass: TextViewElementCell.self,
              toSection: Section.campaign.rawValue
            )
        case let element as ImageViewElement:
          let preExistingElementImage = preexistingImageViewElementsWithData
            .filter { $0.element.src == element.src }
            .first?.image
          let dataExists = preExistingElementImage != nil
          let value = dataExists ? (element, preExistingElementImage) : (element, nil)

          self.appendRow(
            value: value,
            cellClass: ImageViewElementCell.self,
            toSection: Section.campaign.rawValue
          )
        case let element as AudioVideoViewElement:
          let preExistingAudioVideoElementWithPlayer = preexistingAudioVideoViewElementsWithPlayer
            .filter { $0.0.sourceURLString == element.sourceURLString }
            .first

          let elementWithPlayer = (
            element,
            preExistingAudioVideoElementWithPlayer?.player,
            preExistingAudioVideoElementWithPlayer?.image
          )

          self.appendRow(
            value: elementWithPlayer,
            cellClass: AudioVideoViewElementCell.self,
            toSection: Section.campaign.rawValue
          )
        case let element as ExternalSourceViewElement:
          self.appendRow(
            value: element,
            cellClass: ExternalSourceViewElementCell.self,
            toSection: Section.campaign.rawValue
          )
        default:
          break
        }
      }
    case .faq:
      self.set(
        values: [HeaderValue.faqs.description],
        cellClass: ProjectHeaderCell.self,
        inSection: Section.faqsHeader.rawValue
      )

      // Only render this cell for logged in users
      if AppEnvironment.current.currentUser != nil {
        self.set(
          values: [()],
          cellClass: ProjectFAQsAskAQuestionCell.self,
          inSection: Section.faqsAskAQuestion.rawValue
        )
      }

      let projectFAQs = project.extendedProjectProperties?.faqs ?? []

      guard !projectFAQs.isEmpty else {
        self.set(
          values: [()],
          cellClass: ProjectFAQsEmptyStateCell.self,
          inSection: Section.faqsEmpty.rawValue
        )

        return
      }

      guard let isExpandedStates = isExpandedStates else { return }

      let values = projectFAQs.enumerated().map { idx, faq in
        (faq, isExpandedStates[idx])
      }

      self.set(
        values: values,
        cellClass: ProjectFAQsCell.self,
        inSection: Section.faqs.rawValue
      )
    case .risks:
      // Risks are mandatory for creators
      let risks = project.extendedProjectProperties?.risks ?? ""

      self.set(
        values: [HeaderValue.risks.description],
        cellClass: ProjectHeaderCell.self,
        inSection: Section.risksHeader.rawValue
      )

      self.set(
        values: [risks],
        cellClass: ProjectRisksCell.self,
        inSection: Section.risks.rawValue
      )

      self.set(
        values: [()],
        cellClass: ProjectRisksDisclaimerCell.self,
        inSection: Section.risksDisclaimer.rawValue
      )
    case .environmentalCommitments:
      let environmentalCommitments = project.extendedProjectProperties?.environmentalCommitments ?? []

      self.set(
        values: [HeaderValue.environmentalCommitments.description],
        cellClass: ProjectHeaderCell.self,
        inSection: Section.environmentalCommitmentsHeader.rawValue
      )

      self.set(
        values: environmentalCommitments,
        cellClass: ProjectEnvironmentalCommitmentCell.self,
        inSection: Section.environmentalCommitments.rawValue
      )

      self.set(
        values: [()],
        cellClass: ProjectEnvironmentalCommitmentDisclaimerCell.self,
        inSection: Section.environmentalCommitmentsDisclaimer.rawValue
      )
    }
  }

  override func configureCell(tableCell cell: UITableViewCell, withValue value: Any) {
    switch (cell, value) {
    case let (cell as ProjectEnvironmentalCommitmentCell, value as ProjectEnvironmentalCommitment):
      cell.configureWith(value: value)
    case let (cell as ProjectEnvironmentalCommitmentDisclaimerCell, _):
      cell.configureWith(value: ())
    case let (cell as ProjectHeaderCell, value as String):
      cell.configureWith(value: value)
    case let (cell as ProjectFAQsAskAQuestionCell, _):
      cell.configureWith(value: ())
    case let (cell as ProjectFAQsCell, value as (ProjectFAQ, Bool)):
      cell.configureWith(value: value)
    case let (cell as ProjectFAQsEmptyStateCell, _):
      cell.configureWith(value: ())
    case let (cell as ProjectPamphletCreatorHeaderCell, value as Project):
      cell.configureWith(value: value)
    case let (cell as ProjectPamphletMainCell, value as ProjectPamphletMainCellData):
      cell.configureWith(value: value)
    case let (cell as ProjectPamphletSubpageCell, value as ProjectPamphletSubpage):
      cell.configureWith(value: value)
    case let (cell as ProjectRisksCell, value as String):
      cell.configureWith(value: value)
    case let (cell as ProjectRisksDisclaimerCell, _):
      cell.configureWith(value: ())
    case let (cell as TextViewElementCell, value as TextViewElement):
      cell.configureWith(value: value)
    case let (cell as ImageViewElementCell, value as (ImageViewElement, UIImage?)):
      cell.configureWith(value: value)
    case let (cell as AudioVideoViewElementCell, value as (AudioVideoViewElement, AVPlayer?, UIImage?)):
      cell.configureWith(value: value)
    case let (cell as ExternalSourceViewElementCell, value as ExternalSourceViewElement):
      cell.configureWith(value: value)
    default:
      assertionFailure("Unrecognized combo: \(cell), \(value)")
    }
  }

  // MARK: Helpers

  private func prepareImagesInCampaignSection() {
    if self.numberOfSections(in: UITableView()) > Section.campaign.rawValue {
      self.items(in: Section.campaign.rawValue).forEach { valueAndResuseId in
        guard let imageViewData = valueAndResuseId.value as? (element: ImageViewElement, image: UIImage?),
          imageViewData.image != nil else {
          return
        }

        preexistingImageViewElementsWithData.append(imageViewData)

        var seenURLStrings = Set<String>()
        var uniqueElements = [(element: ImageViewElement, image: UIImage?)]()
        for (imageElement, image) in preexistingImageViewElementsWithData {
          if !seenURLStrings.contains(imageElement.src) {
            uniqueElements.append((imageElement, image))
            seenURLStrings.insert(imageElement.src)
          }
        }

        preexistingImageViewElementsWithData = uniqueElements
      }
    }
  }

  private func prepareAudioVideosInCampaignSection() {
    if self.numberOfSections(in: UITableView()) > Section.campaign.rawValue {
      self.items(in: Section.campaign.rawValue).forEach { valueAndResuseId in
        guard let audioVideoViewElementWithPlayer = valueAndResuseId
          .value as? (AudioVideoViewElement, AVPlayer?, UIImage?)
        else {
          return
        }

        preexistingAudioVideoViewElementsWithPlayer.append(audioVideoViewElementWithPlayer)

        var seenURLStrings = Set<String>()
        var uniqueElements = [(element: AudioVideoViewElement, player: AVPlayer?, image: UIImage?)]()
        for (audioVideoElement, player, image) in preexistingAudioVideoViewElementsWithPlayer {
          if !seenURLStrings.contains(audioVideoElement.sourceURLString) {
            uniqueElements.append((audioVideoElement, player, image))
            seenURLStrings.insert(audioVideoElement.sourceURLString)
          }
        }

        preexistingAudioVideoViewElementsWithPlayer = uniqueElements
      }
    }
  }

  internal func updateImageViewElementWith(_ imageViewElement: ImageViewElement,
                                           image: UIImage,
                                           indexPath: IndexPath) {
    self.set(
      value: (imageViewElement, image),
      cellClass: ImageViewElementCell.self,
      inSection: indexPath.section,
      row: indexPath.row
    )
  }

  internal func updateAudioVideoViewElementWith(_ audioVideoViewElement: AudioVideoViewElement,
                                                player: AVPlayer,
                                                thumbnailImage: UIImage?,
                                                indexPath: IndexPath) {
    self.set(
      value: (audioVideoViewElement, player, thumbnailImage),
      cellClass: AudioVideoViewElementCell.self,
      inSection: indexPath.section,
      row: indexPath.row
    )
  }

  internal func imageViewElementWith(urls: [URL],
                                     indexPath: IndexPath) -> (url: URL,
                                                               element: ImageViewElement,
                                                               image: UIImage?,
                                                               indexPath: IndexPath)? {
    let allURLStrings = urls.map { $0.absoluteString }

    guard let indexPathSection = Section(rawValue: indexPath.section)?.rawValue,
      let imageViewElementItem = self.items(in: indexPathSection)[indexPath.row]
      .value as? (element: ImageViewElement, image: UIImage?)
    else {
      return nil
    }

    for index in 0..<allURLStrings.count {
      if allURLStrings[index] == imageViewElementItem.element.src {
        return (urls[index], imageViewElementItem.element, imageViewElementItem.image, indexPath)
      }
    }

    return nil
  }

  internal func indexPathIsCommentsSubpage(_ indexPath: IndexPath) -> Bool {
    return (self[indexPath] as? ProjectPamphletSubpage)?.isComments == true
  }

  internal func indexPathIsUpdatesSubpage(_ indexPath: IndexPath) -> Bool {
    return (self[indexPath] as? ProjectPamphletSubpage)?.isUpdates == true
  }

  internal func isExpandedValuesForFAQsSection() -> [Bool]? {
    guard let values = self[section: Section.faqs.rawValue] as? [(ProjectFAQ, Bool)] else { return nil }
    return values.map { _, isExpanded in isExpanded }
  }

  internal func isIndexPathAnImageViewElement(tableView: UITableView,
                                              indexPath: IndexPath,
                                              section: ProjectPageViewControllerDataSource.Section) -> Bool {
    guard indexPath.section == section.rawValue else { return false }

    if self.numberOfSections(in: tableView) > section.rawValue,
      self.numberOfItems(in: section.rawValue) > indexPath.row,
      let _ = self.items(in: section.rawValue)[indexPath.row].value as? (ImageViewElement, UIImage?) {
      return true
    }

    return false
  }

  internal func imageViewElementURL(tableView: UITableView,
                                    indexPath: IndexPath) -> URL? {
    let section = ProjectPageViewControllerDataSource.Section.campaign

    guard indexPath.section == section.rawValue else { return nil }

    if self.numberOfSections(in: tableView) > section.rawValue,
      self.numberOfItems(in: section.rawValue) > indexPath.row,
      let (imageViewElement, _) = self.items(in: section.rawValue)[indexPath.row]
      .value as? (ImageViewElement, UIImage?),
      let urlString = imageViewElement.href,
      let url = URL(string: urlString) {
      return url
    }

    return nil
  }

  internal func audioVideoViewElementWithNoPlayer(
    tableView: UITableView,
    indexPath: IndexPath,
    section: ProjectPageViewControllerDataSource.Section
  ) -> (AudioVideoViewElement, IndexPath)? {
    guard indexPath.section == section.rawValue else { return nil }

    if self.numberOfSections(in: tableView) > section.rawValue,
      self.numberOfItems(in: section.rawValue) > indexPath.row,
      let (element, player, _) = self.items(in: section.rawValue)[indexPath.row]
      .value as? (AudioVideoViewElement, AVPlayer?, UIImage?),
      player == nil {
      return (element, indexPath)
    }

    return nil
  }

  internal func updateAudioVideoViewElementSeektime(with seekTime: CMTime,
                                                    tableView: UITableView,
                                                    indexPath: IndexPath) {
    if self.numberOfSections(in: tableView) > indexPath.section,
      self.numberOfItems(in: indexPath.section) > indexPath.row,
      let audioVideoViewElementWithPlayerAndImage = self.items(in: indexPath.section)[indexPath.row]
      .value as? (AudioVideoViewElement, AVPlayer, UIImage?) {
      let updatedAudioVideoElement = audioVideoViewElementWithPlayerAndImage.0
        |> AudioVideoViewElement.lens.seekPosition .~ seekTime

      self.set(
        value: (
          updatedAudioVideoElement,
          audioVideoViewElementWithPlayerAndImage.1,
          audioVideoViewElementWithPlayerAndImage.2
        ),
        cellClass: AudioVideoViewElementCell.self,
        inSection: indexPath.section,
        row: indexPath.row
      )
    }
  }

  internal func preloadCampaignImageViewElement(_ element: ImageViewElement, image: UIImage) {
    self.appendRow(
      value: (element, image),
      cellClass: ImageViewElementCell.self,
      toSection: Section.campaign.rawValue
    )
  }

  internal func preloadCampaignAudioVideoViewElement(
    _ element: AudioVideoViewElement,
    player: AVPlayer,
    image: UIImage?
  ) {
    self.appendRow(
      value: (element, player, image),
      cellClass: AudioVideoViewElementCell.self,
      toSection: Section.campaign.rawValue
    )
  }
}
