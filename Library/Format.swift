//swiftlint:disable file_length
import Foundation
import KsApi
import Prelude

public enum Format {
  /**
   Formats an int into a string.

   - parameter x:   An integer.
   - parameter env: An (optional) environment.

   - returns: A formatted string.
   */
  public static func wholeNumber(x: Int, env: Environment = AppEnvironment.current) -> String {
    let formatter = NumberFormatterConfig.cachedFormatter(
      forConfig: .defaultWholeNumberConfig
        |> NumberFormatterConfig.lens.locale .~ env.locale
    )
    return formatter.stringFromNumber(x) ?? String(x)
  }

  /**
   Formats an int percentage into a string.

   - parameter percentage: An int where 100 corresponds to 100%.
   - parameter env:        An (optional) environment.

   - returns: A formatted string.
   */
  public static func percentage(percentage: Int, env: Environment = AppEnvironment.current) -> String {
    return Format.percentage(Double(percentage) / 100.0, env: env)
  }

  /**
   Formats a Double percentage into a string.

   - parameter percentage: A Double where .10 corresponds to 10%.
   - parameter env:        An (optional) environment.

   - returns: A formatted string.
   */
  public static func percentage(percentage: Double, env: Environment = AppEnvironment.current) -> String {
    let formatter = NumberFormatterConfig.cachedFormatter(
      forConfig: .defaultPercentageConfig
        |> NumberFormatterConfig.lens.locale .~ env.locale
    )

    return formatter.stringFromNumber(Float(percentage)) ?? (String(percentage) + "%")
  }

  /**
   Formats an int with currency symbol into a string.

   - parameter amount: The amount to format.
   - parameter country: The country that currency is in.
   - parameter omitCurrencyCode: Pass true if you want to force the currency code to be omitted when trying
                                 to disambiguate currencies.
   - parameter env: (optional) An environment to use for locality.

   - returns: A formatted string.
   */
  public static func currency(amount: Int,
                              country: Project.Country,
                              omitCurrencyCode: Bool = false,
                              env: Environment = AppEnvironment.current) -> String {

    let formatter = NumberFormatterConfig.cachedFormatter(
      forConfig: .defaultCurrencyConfig
        |> NumberFormatterConfig.lens.locale .~ env.locale
        |> NumberFormatterConfig.lens.currencySymbol .~ country.currencySymbol
    )

    let string = formatter.stringFromNumber(amount) ?? country.currencySymbol + String(amount)

    // Sometimes we need to append a country code in order to disambiguate a currency
    if !omitCurrencyCode && env.launchedCountries.currencyNeedsCode(country.currencySymbol) {
      // USD for US backers does not need to be disambiguated.
      if env.countryCode != "US" || country.countryCode != "US" {
        // NB: The space " " here is a non-breaking space
        return string + " " + country.currencyCode
      }
    }

    return string
  }

  /**
   Format a date into a string.

   - parameter secondsInUTC: Seconds represention of the date as measured from UTC.
   - parameter dateStyle: (optional) The style to format the date.
   - parameter timeStyle: (optional) The style to format the time.
   - parameter env: (optional) An environment to use for locality and time zones.

   - returns: A formatted string.
   */
  public static func date(secondsInUTC seconds: NSTimeInterval,
                                       dateStyle: NSDateFormatterStyle = .MediumStyle,
                                       timeStyle: NSDateFormatterStyle = .MediumStyle,
                                       env: Environment = AppEnvironment.current) -> String {

    let formatter = DateFormatterConfig.cachedFormatter(
      forConfig: .init(
        dateFormat: nil,
        dateStyle: dateStyle,
        locale: env.locale,
        timeStyle: timeStyle,
        timeZone: env.timeZone
      )
    )

    return formatter.stringFromDate(NSDate(timeIntervalSince1970: seconds))
  }

  /**
   Format a date into a string.

   - parameter secondsInUTC: Seconds represention of the date as measured from UTC.
   - parameter dateFormat: A format string.

   - returns: A formatted string.
   */
  public static func date(secondsInUTC seconds: NSTimeInterval,
                                       dateFormat: String) -> String {

    let formatter = DateFormatterConfig.cachedFormatter(
      forConfig: .init(dateFormat: dateFormat,
        dateStyle: nil,
        locale: AppEnvironment.current.locale,
        timeStyle: nil,
        timeZone: AppEnvironment.current.timeZone
      )
    )

    return formatter.stringFromDate(NSDate(timeIntervalSince1970: seconds))
  }

  /**
   Format a duration into a string, i.e. "20 days", "14 hours", etc...

   - parameter seconds: Seconds represention of the date as measured from UTC.
   - parameter useToGo: If true, a localized "to go" will be appended to the unit so that it reads
                        "20 days to go", etc.
   - parameter abbreviate: Determines if an abbreviated version of the time unit string will be used.
   - parameter env: An (optional) environment.

   - returns: A pair of strings for the numeric time value and unit.
   */
  // swiftlint:disable valid_docs
  public static func duration(
    secondsInUTC seconds: NSTimeInterval,
                 abbreviate: Bool = false,
                 useToGo: Bool = false,
                 env: Environment = AppEnvironment.current) -> (time: String, unit: String) {

    let components = env.calendar.components([.Day, .Hour, .Minute, .Second],
                                             fromDate: NSDate(),
                                             toDate: NSDate(timeIntervalSince1970: seconds),
                                             options: [])

    let string: String
    if components.day > 1 {
      let format = abbreviate ? Strings.dates_time_days_abbreviated : Strings.dates_time_days
      string = format(time_count: components.day)
    } else if components.day == 1 || components.hour > 0 {
      let format = abbreviate ? Strings.dates_time_hours_abbreviated : Strings.dates_time_hours
      string = format(time_count: components.day * 24 + components.hour)
    } else if components.minute >= 0 && components.second >= 0 {
      let format = abbreviate ? Strings.dates_time_minutes_abbreviated : Strings.dates_time_minutes
      string = format(time_count: components.minute)
    } else if components.second < 0 {
      string = "0 " + Strings.discovery_baseball_card_deadline_units_secs()
    } else {
      string = ""
    }

    let split = string.componentsSeparatedByString(" ")
    guard split.count >= 1 else { return ("", "") }

    let result = (
      time: split.first ?? "",
      unit: split.suffixFrom(1).joinWithSeparator(" ")
    )

    if useToGo {
      return (
        time: result.time,
        unit: Strings.discovery_baseball_card_time_left_to_go(time_left: result.unit)
      )
    }
    return result
  }
  // swiftlint:enable valid_docs

  /**
   Format a date into a relative string.

   - parameter secondsInUTC: Seconds represention of the date as measured from UTC.
   - parameter abbreviate: (optional) Whether or not to use the abbreviated style.
   - parameter threshold: (optional) Threshold.
   - parameter env: An (optional) environment.

   - returns: A formatted string.
   */
  public static func relative(
    secondsInUTC seconds: NSTimeInterval,
                 abbreviate: Bool = false,
                 threshold thresholdInDays: Int = defaultThresholdInDays,
                 env: Environment = AppEnvironment.current) -> String {

    let components = env.calendar.components([.Day, .Hour, .Minute, .Second],
                                             fromDate: NSDate(timeIntervalSince1970: seconds),
                                             toDate: NSDate(),
                                             options: [])

    if abs(components.day) > thresholdInDays {
      return Format.date(secondsInUTC: seconds, dateStyle: .MediumStyle, timeStyle: .NoStyle)
    } else if components.day > 1 {
      let format = abbreviate ? Strings.dates_time_days_ago_abbreviated : Strings.dates_time_days_ago
      return format(time_count: components.day)
    } else if components.day == 1 {
      return Strings.dates_yesterday()
    } else if components.hour > 0 {
      let format = abbreviate ? Strings.dates_time_hours_ago_abbreviated : Strings.dates_time_hours_ago
      return format(time_count: components.hour)
    } else if components.minute > 0 {
      let format = abbreviate ? Strings.dates_time_minutes_ago_abbreviated : Strings.dates_time_minutes_ago
      return format(time_count: components.minute)
    } else if components.second > 0 {
      return Strings.dates_just_now()
    } else if components.day < 0 {
      let format = abbreviate ? Strings.dates_time_in_days_abbreviated : Strings.dates_time_in_days
      return format(time_count: -components.day)
    } else if components.hour < 0 {
      let format = abbreviate ? Strings.dates_time_in_hours_abbreviated : Strings.dates_time_in_hours
      return format(time_count: -components.hour)
    } else if components.minute < 0 {
      let format = abbreviate ? Strings.dates_time_in_minutes_abbreviated : Strings.dates_time_in_minutes
      return format(time_count: -components.minute)
    } else {
      return Strings.dates_right_now()
    }
  }
}

private let defaultThresholdInDays = 30 // days

private struct DateFormatterConfig {
  private let dateFormat: String?
  private let dateStyle: NSDateFormatterStyle?
  private let locale: NSLocale
  private let timeStyle: NSDateFormatterStyle?
  private let timeZone: NSTimeZone

  private func formatter() -> NSDateFormatter {
    let formatter = NSDateFormatter()
    if let dateFormat = self.dateFormat {
      formatter.dateFormat = dateFormat
    }
    formatter.timeZone = self.timeZone
    formatter.locale = self.locale
    if let dateStyle = self.dateStyle {
      formatter.dateStyle = dateStyle
    }
    if let timeStyle = self.timeStyle {
      formatter.timeStyle = timeStyle
    }
    return formatter
  }

  private static var formatters: [DateFormatterConfig:NSDateFormatter] = [:]

  private static func cachedFormatter(forConfig config: DateFormatterConfig) -> NSDateFormatter {
    let formatter = self.formatters[config] ?? config.formatter()
    self.formatters[config] = formatter
    return formatter
  }
}

extension DateFormatterConfig: Hashable {
  private var hashValue: Int {
    return
      (self.dateFormat?.hashValue ?? 0)
        ^ (self.dateStyle?.hashValue ?? 0)
        ^ self.locale.hashValue
        ^ (self.timeStyle?.hashValue ?? 0)
        ^ self.timeZone.hashValue
  }
}

private func == (lhs: DateFormatterConfig, rhs: DateFormatterConfig) -> Bool {
  return
    lhs.dateFormat == rhs.dateFormat
      && lhs.dateStyle == rhs.dateStyle
      && lhs.locale == rhs.locale
      && lhs.timeStyle == rhs.timeStyle
      && lhs.timeZone == rhs.timeZone
}

private struct NumberFormatterConfig {
  private let numberStyle: NSNumberFormatterStyle
  private let roundingMode: NSNumberFormatterRoundingMode
  private let maximumFractionDigits: Int
  private let generatesDecimalNumbers: Bool
  private let locale: NSLocale
  private let currencySymbol: String

  private func formatter() -> NSNumberFormatter {
    let formatter = NSNumberFormatter()
    formatter.numberStyle = self.numberStyle
    formatter.roundingMode = self.roundingMode
    formatter.maximumFractionDigits = self.maximumFractionDigits
    formatter.generatesDecimalNumbers = self.generatesDecimalNumbers
    formatter.locale = self.locale
    formatter.currencySymbol = self.currencySymbol
    return formatter
  }

  private static var formatters: [NumberFormatterConfig:NSNumberFormatter] = [:]

  private static let defaultWholeNumberConfig = NumberFormatterConfig(numberStyle: .DecimalStyle,
                                                                      roundingMode: .RoundDown,
                                                                      maximumFractionDigits: 0,
                                                                      generatesDecimalNumbers: false,
                                                                      locale: .currentLocale(),
                                                                      currencySymbol: "$")

  private static let defaultPercentageConfig = NumberFormatterConfig(numberStyle: .PercentStyle,
                                                                     roundingMode: .RoundDown,
                                                                     maximumFractionDigits: 0,
                                                                     generatesDecimalNumbers: false,
                                                                     locale: .currentLocale(),
                                                                     currencySymbol: "$")

  private static let defaultCurrencyConfig = NumberFormatterConfig(numberStyle: .CurrencyStyle,
                                                                   roundingMode: .RoundDown,
                                                                   maximumFractionDigits: 0,
                                                                   generatesDecimalNumbers: false,
                                                                   locale: .currentLocale(),
                                                                   currencySymbol: "$")

  private static func cachedFormatter(forConfig config: NumberFormatterConfig) -> NSNumberFormatter {
    let formatter = self.formatters[config] ?? config.formatter()
    self.formatters[config] = formatter
    return formatter
  }
}

extension NumberFormatterConfig: Hashable {
  private var hashValue: Int {
    return
      self.numberStyle.hashValue
        ^ self.roundingMode.hashValue
        ^ self.maximumFractionDigits.hashValue
        ^ self.generatesDecimalNumbers.hashValue
        ^ self.locale.hashValue
        ^ self.currencySymbol.hashValue
  }
}

private func == (lhs: NumberFormatterConfig, rhs: NumberFormatterConfig) -> Bool {
  return
    lhs.numberStyle == rhs.numberStyle
      && lhs.roundingMode == rhs.roundingMode
      && lhs.maximumFractionDigits == rhs.maximumFractionDigits
      && lhs.generatesDecimalNumbers == rhs.generatesDecimalNumbers
      && lhs.locale == rhs.locale
      && lhs.currencySymbol == rhs.currencySymbol
}

// swiftlint:disable type_name
extension NumberFormatterConfig {
  private enum lens {
    private static let numberStyle = Lens<NumberFormatterConfig, NSNumberFormatterStyle>(
      view: { $0.numberStyle },
      set: { .init(numberStyle: $0, roundingMode: $1.roundingMode,
        maximumFractionDigits: $1.maximumFractionDigits, generatesDecimalNumbers: $1.generatesDecimalNumbers,
        locale: $1.locale, currencySymbol: $1.currencySymbol) }
    )

    private static let roundingMode = Lens<NumberFormatterConfig, NSNumberFormatterRoundingMode>(
      view: { $0.roundingMode },
      set: { .init(numberStyle: $1.numberStyle, roundingMode: $0,
        maximumFractionDigits: $1.maximumFractionDigits, generatesDecimalNumbers: $1.generatesDecimalNumbers,
        locale: $1.locale, currencySymbol: $1.currencySymbol) }
    )

    private static let maximumFractionDigits = Lens<NumberFormatterConfig, Int>(
      view: { $0.maximumFractionDigits },
      set: { .init(numberStyle: $1.numberStyle, roundingMode: $1.roundingMode, maximumFractionDigits: $0,
        generatesDecimalNumbers: $1.generatesDecimalNumbers, locale: $1.locale,
        currencySymbol: $1.currencySymbol) }
    )

    private static let generatesDecimalNumbers = Lens<NumberFormatterConfig, Bool>(
      view: { $0.generatesDecimalNumbers },
      set: { .init(numberStyle: $1.numberStyle, roundingMode: $1.roundingMode,
        maximumFractionDigits: $1.maximumFractionDigits, generatesDecimalNumbers: $0, locale: $1.locale,
        currencySymbol: $1.currencySymbol) }
    )

    private static let locale = Lens<NumberFormatterConfig, NSLocale>(
      view: { $0.locale },
      set: { .init(numberStyle: $1.numberStyle, roundingMode: $1.roundingMode,
        maximumFractionDigits: $1.maximumFractionDigits, generatesDecimalNumbers: $1.generatesDecimalNumbers,
        locale: $0, currencySymbol: $1.currencySymbol) }
    )

    private static let currencySymbol = Lens<NumberFormatterConfig, String>(
      view: { $0.currencySymbol },
      set: { .init(numberStyle: $1.numberStyle, roundingMode: $1.roundingMode,
        maximumFractionDigits: $1.maximumFractionDigits, generatesDecimalNumbers: $1.generatesDecimalNumbers,
        locale: $1.locale, currencySymbol: $0) }
    )
  }
}
// swiftlint:enable type_name
