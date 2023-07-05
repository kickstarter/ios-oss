import Library
import SwiftUI

struct DashboardDeprecationView: View {
  private let contentPadding = 12.0
  private let imageSizeMultiplier = 1.5
  private var deprecationDateText: String {
    self.formatted(dateString: "2023-08-14")
  }

  var body: some View {
    HStack {
      if let iconImage = image(named: "fix-icon", inBundle: Bundle.framework) {
        Image(uiImage: iconImage)
          .frame(width: contentPadding * imageSizeMultiplier)
          .scaledToFit()
          .foregroundColor(Color(UIColor.ksr_white))
          .padding(.horizontal, contentPadding)
      }

      Text(Strings.Creator_dashboard_removal_warning(expiration_date: deprecationDateText))
        .font(Font(UIFont.ksr_subhead(size: 15)))
        .foregroundColor(Color(UIColor.ksr_white))
        .lineLimit(nil)
        .padding([.vertical, .trailing], contentPadding)
    }
    .frame(maxWidth: .infinity, alignment: .center)
    .background(Color(UIColor.ksr_alert))
  }

  private func formatted(dateString: String) -> String {
    let date = self.toDate(dateString: dateString)
    return Format.date(
      secondsInUTC: date.timeIntervalSince1970,
      template: "MMMM d, yyyy",
      timeZone: UTCTimeZone
    )
  }

  private func toDate(dateString: String) -> Date {
    // Always use UTC timezone here this date should be timezone agnostic
    guard let date = Format.date(
      from: dateString,
      dateFormat: "yyyy-MM-dd",
      timeZone: UTCTimeZone
    ) else {
      fatalError("Unable to parse date format")
    }

    return date
  }
}
