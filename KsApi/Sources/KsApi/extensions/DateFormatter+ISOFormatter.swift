import Foundation

extension DateFormatter {
  static var isoDateFormatter: DateFormatter {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    dateFormatter.timeZone = TimeZone.init(secondsFromGMT: 0)
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    return dateFormatter
  }
}
