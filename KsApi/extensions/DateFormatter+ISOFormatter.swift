import Foundation

extension DateFormatter {
  static var isoDateFormatter: DateFormatter {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-DD"
    return dateFormatter
  }
}
