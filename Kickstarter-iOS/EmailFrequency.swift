public enum EmailFrequency: Int {
  case daily
  case individualEmails

  public static let allCases: [EmailFrequency] = [.daily, .individualEmails]

  public var descriptionText: String {
    switch self {
    case .daily:
      return Strings.Daily_digest()
    case .individualEmails:
      return Strings.Individual_Emails()
    }
  }
}
