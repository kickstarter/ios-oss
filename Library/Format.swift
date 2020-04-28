import Foundation
import KsApi
import Prelude

public let UTCTimeZone = TimeZone(secondsFromGMT: 0)!

public enum Format {
  /**
   Formats an int into a string.

   - parameter x:   An integer.
   - parameter env: An (optional) environment.

   - returns: A formatted string.
   */
  public static func wholeNumber(_ x: Int, env: Environment = AppEnvironment.current) -> String {
    let formatter = NumberFormatterConfig.cachedFormatter(
      forConfig: .defaultWholeNumberConfig
        |> NumberFormatterConfig.lens.locale .~ env.locale
    )
    return formatter.string(for: x) ?? String(x)
  }

  /**
   Formats an int percentage into a string.

   - parameter percentage: An int where 100 corresponds to 100%.
   - parameter env:        An (optional) environment.

   - returns: A formatted string.
   */
  public static func percentage(_ percentage: Int, env: Environment = AppEnvironment.current) -> String {
    return Format.percentage(Double(percentage) / 100.0, env: env)
  }

  /**
   Formats a Double percentage into a string.

   - parameter percentage: A Double where .10 corresponds to 10%.
   - parameter env:        An (optional) environment.

   - returns: A formatted string.
   */
  public static func percentage(_ percentage: Double, env: Environment = AppEnvironment.current) -> String {
    let formatter = NumberFormatterConfig.cachedFormatter(
      forConfig: .defaultPercentageConfig
        |> NumberFormatterConfig.lens.locale .~ env.locale
    )

    return formatter.string(for: percentage) ?? (String(percentage) + "%")
  }

  /**
    Formats a Double currency amount into a string.

   - parameter amount: A Double associated with a currency amount

   - returns: A formatted string with 2 fraction digits
   */

  public static func decimalCurrency(for amount: Double) -> String {
    let formatter = NumberFormatterConfig.cachedFormatter(
      forConfig: .defaultDecimalCurrencyConfig
    )

    return formatter.string(for: amount) ?? String(format: "%.2f", amount)
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
  public static func currency(
    _ amount: Int,
    country: Project.Country,
    omitCurrencyCode: Bool = true,
    env: Environment = AppEnvironment.current
  ) -> String {
    return Format.formattedCurrency(
      amount,
      country: country,
      omitCurrencyCode: omitCurrencyCode,
      env: env
    )
  }

  public static func currency(
    _ amount: Double,
    country: Project.Country,
    omitCurrencyCode: Bool = true,
    roundingMode: NumberFormatter.RoundingMode = .down,
    maximumFractionDigits: Int = 0,
    minimumFractionDigits: Int = 0,
    env: Environment = AppEnvironment.current
  ) -> String {
    return Format.formattedCurrency(
      amount,
      country: country,
      omitCurrencyCode: omitCurrencyCode,
      roundingMode: roundingMode,
      maximumFractionDigits: maximumFractionDigits,
      minimumFractionDigits: minimumFractionDigits,
      env: env
    )
  }

  public static func formattedCurrency(
    _ amount: Any,
    country: Project.Country,
    omitCurrencyCode: Bool = true,
    roundingMode: NumberFormatter.RoundingMode = .down,
    maximumFractionDigits: Int = 0,
    minimumFractionDigits: Int = 0,
    env: Environment = AppEnvironment.current
  ) -> String {
    let symbol = currencySymbol(
      forCountry: country,
      omitCurrencyCode: omitCurrencyCode,
      env: env
    )

    let formatter = NumberFormatterConfig.cachedFormatter(
      forConfig: .defaultCurrencyConfig
        |> NumberFormatterConfig.lens.roundingMode .~ roundingMode
        |> NumberFormatterConfig.lens.maximumFractionDigits .~ maximumFractionDigits
        |> NumberFormatterConfig.lens.minimumFractionDigits .~ minimumFractionDigits
        |> NumberFormatterConfig.lens.locale .~ env.locale
        |> NumberFormatterConfig.lens.currencySymbol .~ symbol
    )

    return formatter.string(for: amount)?
      .trimmed()
      .replacingOccurrences(of: String.nbsp + String.nbsp, with: String.nbsp)
      ?? (symbol + "\(amount)")
  }

  public static func attributedCurrency(
    _ amount: Double,
    country: Project.Country,
    omitCurrencyCode: Bool = true,
    defaultAttributes: String.Attributes = [:],
    superscriptAttributes: String.Attributes = [:],
    env: Environment = AppEnvironment.current
  ) -> NSAttributedString? {
    let symbol = currencySymbol(forCountry: country, omitCurrencyCode: omitCurrencyCode, env: env)
    let config = NumberFormatterConfig.defaultCurrencyConfig
      |> NumberFormatterConfig.lens.locale .~ env.locale
      |> NumberFormatterConfig.lens.currencySymbol .~ symbol
      |> NumberFormatterConfig.lens.minimumFractionDigits .~ 2
      |> NumberFormatterConfig.lens.maximumFractionDigits .~ 2

    guard let formatter = NumberFormatterConfig.cachedFormatter(forConfig: config)
      as? AttributedNumberFormatter else { return nil }

    _ = formatter
      |> \.defaultAttributes .~ defaultAttributes
      |> \.currencySymbolAttributes .~ superscriptAttributes
      |> \.decimalSeparatorAttributes .~ superscriptAttributes
      |> \.fractionDigitsAttributes .~ superscriptAttributes

    return formatter.attributedString(for: amount)
  }

  public static func attributedPlusSign(_ attributes: String.Attributes = [:]) -> NSAttributedString {
    return NSAttributedString(string: Strings.plus_shipping_cost(shipping_cost: ""), attributes: attributes)
  }

  /**
   Create a date from a string with the given format

    - parameter dateString: The date string to convert to a Date
    - parameter dateFormat: The format the date string is in ex. "yyyy-MM-DD".
    - parameter timeZone: (optional) The timeZone the Date should be in.
    - parameter env: (optional) An environment to use for locality and time zones.

    - returns: A Date object with the specified time zone and locality.
   */
  public static func date(
    from dateString: String,
    dateFormat: String,
    timeZone: TimeZone? = nil,
    env: Environment = AppEnvironment.current
  ) -> Date? {
    let formatter = DateFormatterConfig.cachedFormatter(
      forConfig: .init(
        dateFormat: dateFormat,
        dateStyle: nil,
        locale: env.locale,
        template: nil,
        timeStyle: nil,
        timeZone: timeZone ?? env.calendar.timeZone
      )
    )

    return formatter.date(from: dateString)
  }

  /**
   Format a date into a string.

   - parameter secondsInUTC: Seconds represention of the date as measured from UTC.
   - parameter dateStyle: (optional) The style to format the date.
   - parameter timeStyle: (optional) The style to format the time.
   - parameter env: (optional) An environment to use for locality and time zones.

   - returns: A formatted string.
   */
  public static func date(
    secondsInUTC seconds: TimeInterval,
    dateStyle: DateFormatter.Style = .medium,
    timeStyle: DateFormatter.Style = .medium,
    timeZone: TimeZone? = nil,
    env: Environment = AppEnvironment.current
  ) -> String {
    let formatter = DateFormatterConfig.cachedFormatter(
      forConfig: .init(
        dateFormat: nil,
        dateStyle: dateStyle,
        locale: env.locale,
        template: nil,
        timeStyle: timeStyle,
        timeZone: timeZone ?? env.calendar.timeZone
      )
    )

    return formatter.string(from: env.dateType.init(timeIntervalSince1970: seconds).date)
  }

  /**
   Format a date into a string.

   - parameter secondsInUTC: Seconds represention of the date as measured from UTC.
   - parameter template: A localized template string.

   - returns: A formatted string.
   */
  public static func date(
    secondsInUTC seconds: TimeInterval,
    template: String,
    timeZone: TimeZone? = nil
  ) -> String {
    let formatter = DateFormatterConfig.cachedFormatter(
      forConfig: .init(
        dateFormat: nil,
        dateStyle: nil,
        locale: AppEnvironment.current.locale,
        template: template,
        timeStyle: nil,
        timeZone: timeZone ?? AppEnvironment.current.calendar.timeZone
      )
    )

    return formatter.string(from: AppEnvironment.current.dateType.init(timeIntervalSince1970: seconds).date)
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
  public static func duration(
    secondsInUTC seconds: TimeInterval,
    abbreviate: Bool = false,
    useToGo: Bool = false,
    env: Environment = AppEnvironment.current
  ) -> (time: String, unit: String) {
    let components = env.calendar.dateComponents(
      [.day, .hour, .minute, .second],
      from: env.dateType.init().date,
      to: env.dateType.init(timeIntervalSince1970: seconds).date
    )

    let (day, hour, minute, second) = (
      components.day ?? 0,
      components.hour ?? 0,
      components.minute ?? 0,
      components.second ?? 0
    )

    let string: String
    if day > 1 {
      string = abbreviate
        ? Strings.dates_time_days_abbreviated(time_count: day)
        : Strings.dates_time_days(time_count: day)
    } else if day == 1 || hour > 0 {
      let count = day * 24 + hour
      string = abbreviate
        ? Strings.dates_time_hours_abbreviated(time_count: count)
        : Strings.dates_time_hours(time_count: count)
    } else if minute > 0, second >= 0 {
      string = abbreviate
        ? Strings.dates_time_minutes_abbreviated(time_count: minute)
        : Strings.dates_time_minutes(time_count: minute)
    } else if second <= 0 {
      string = "0 " + Strings.discovery_baseball_card_deadline_units_secs()
    } else {
      string = ""
    }

    let split = string
      .replacingOccurrences(of: "(\\d+) *", with: "$1 ", options: .regularExpression)
      .components(separatedBy: " ")

    guard split.count >= 1 else { return ("", "") }

    let result = (
      time: split.first ?? "",
      unit: split.suffix(from: 1).joined(separator: " ")
    )

    if useToGo {
      return (
        time: result.time,
        unit: Strings.discovery_baseball_card_time_left_to_go(time_left: result.unit)
      )
    }
    return result
  }

  /**
   Format a date into a relative string.

   - parameter secondsInUTC: Seconds represention of the date as measured from UTC.
   - parameter abbreviate: (optional) Whether or not to use the abbreviated style.
   - parameter threshold: (optional) Threshold.
   - parameter env: An (optional) environment.

   - returns: A formatted string.
   */
  public static func relative(
    secondsInUTC seconds: TimeInterval,
    abbreviate: Bool = false,
    threshold thresholdInDays: Int = defaultThresholdInDays,
    timeZone: TimeZone? = nil,
    env: Environment = AppEnvironment.current
  ) -> String {
    let components = env.calendar.dateComponents(
      [.day, .hour, .minute, .second],
      from: env.dateType.init(timeIntervalSince1970: seconds).date,
      to: env.dateType.init().date
    )

    let (day, hour, minute, second) = (
      components.day ?? 0,
      components.hour ?? 0,
      components.minute ?? 0,
      components.second ?? 0
    )

    if abs(day) > thresholdInDays {
      return Format.date(
        secondsInUTC: seconds, dateStyle: .medium, timeStyle: .none, timeZone: timeZone ??
          env.calendar.timeZone, env: env
      )
    } else if day > 1 {
      return abbreviate
        ? Strings.dates_time_days_ago_abbreviated(time_count: day)
        : Strings.dates_time_days_ago(time_count: day)
    } else if day == 1 {
      return Strings.dates_yesterday()
    } else if hour > 0 {
      return abbreviate
        ? Strings.dates_time_hours_ago_abbreviated(time_count: hour)
        : Strings.dates_time_hours_ago(time_count: hour)
    } else if minute > 0 {
      return abbreviate
        ? Strings.dates_time_minutes_ago_abbreviated(time_count: minute)
        : Strings.dates_time_minutes_ago(time_count: minute)
    } else if second > 0 {
      return Strings.dates_just_now()
    } else if day < 0 {
      return abbreviate
        ? Strings.dates_time_in_days_abbreviated(time_count: -day)
        : Strings.dates_time_in_days(time_count: -day)
    } else if hour < 0 {
      return abbreviate
        ? Strings.dates_time_in_hours_abbreviated(time_count: -hour)
        : Strings.dates_time_in_hours(time_count: -hour)
    } else if minute < 0 {
      return abbreviate
        ? Strings.dates_time_in_minutes_abbreviated(time_count: -minute)
        : Strings.dates_time_in_minutes(time_count: -minute)
    } else {
      return Strings.dates_right_now()
    }
  }
}

public let defaultThresholdInDays = 30 // days

internal struct DateFormatterConfig {
  let dateFormat: String?
  fileprivate let dateStyle: DateFormatter.Style?
  fileprivate let locale: Locale
  fileprivate let template: String?
  fileprivate let timeStyle: DateFormatter.Style?
  fileprivate let timeZone: TimeZone

  fileprivate func formatter() -> DateFormatter {
    let formatter = DateFormatter()
    formatter.locale = self.locale
    formatter.timeZone = self.timeZone
    if let template = self.template {
      formatter.setLocalizedDateFormatFromTemplate(template)
    }
    if let dateFormat = self.dateFormat {
      formatter.dateFormat = dateFormat
    }
    if let dateStyle = self.dateStyle {
      formatter.dateStyle = dateStyle
    }
    if let timeStyle = self.timeStyle {
      formatter.timeStyle = timeStyle
    }
    return formatter
  }

  fileprivate static var formatters: [DateFormatterConfig: DateFormatter] = [:]

  fileprivate static func cachedFormatter(forConfig config: DateFormatterConfig) -> DateFormatter {
    let formatter = self.formatters[config] ?? config.formatter()
    self.formatters[config] = formatter
    return formatter
  }
}

extension DateFormatterConfig: Hashable {
  func hash(into hasher: inout Hasher) {
    hasher.combine(self.template)
    hasher.combine(self.dateStyle)
    hasher.combine(self.locale)
    hasher.combine(self.timeStyle)
    hasher.combine(self.timeZone)
  }
}

func == (lhs: DateFormatterConfig, rhs: DateFormatterConfig) -> Bool {
  return
    lhs.template == rhs.template
      && lhs.dateStyle == rhs.dateStyle
      && lhs.locale == rhs.locale
      && lhs.timeStyle == rhs.timeStyle
      && lhs.timeZone == rhs.timeZone
}

private struct NumberFormatterConfig {
  fileprivate let numberStyle: NumberFormatter.Style
  fileprivate let roundingMode: NumberFormatter.RoundingMode
  fileprivate let maximumFractionDigits: Int
  fileprivate let minimumFractionDigits: Int
  fileprivate let generatesDecimalNumbers: Bool
  fileprivate let locale: Locale
  fileprivate let currencySymbol: String

  fileprivate func formatter() -> NumberFormatter {
    let formatter = AttributedNumberFormatter()
    formatter.numberStyle = self.numberStyle
    formatter.roundingMode = self.roundingMode
    formatter.maximumFractionDigits = self.maximumFractionDigits
    formatter.minimumFractionDigits = self.minimumFractionDigits
    formatter.generatesDecimalNumbers = self.generatesDecimalNumbers
    formatter.locale = self.locale
    formatter.currencySymbol = self.currencySymbol
    return formatter
  }

  fileprivate static var formatters: [NumberFormatterConfig: NumberFormatter] = [:]

  fileprivate static let defaultWholeNumberConfig = NumberFormatterConfig(
    numberStyle: .decimal,
    roundingMode: .down,
    maximumFractionDigits: 0,
    minimumFractionDigits: 0,
    generatesDecimalNumbers: false,
    locale: .current,
    currencySymbol: "$"
  )

  fileprivate static let defaultPercentageConfig = NumberFormatterConfig(
    numberStyle: .percent,
    roundingMode: .down,
    maximumFractionDigits: 0,
    minimumFractionDigits: 0,
    generatesDecimalNumbers: false,
    locale: .current,
    currencySymbol: "$"
  )

  fileprivate static let defaultCurrencyConfig = NumberFormatterConfig(
    numberStyle: .currency,
    roundingMode: .down,
    maximumFractionDigits: 0,
    minimumFractionDigits: 0,
    generatesDecimalNumbers: false,
    locale: .current,
    currencySymbol: "$"
  )

  fileprivate static let defaultDecimalCurrencyConfig = NumberFormatterConfig(
    numberStyle: .decimal,
    roundingMode: .down,
    maximumFractionDigits: 2,
    minimumFractionDigits: 2,
    generatesDecimalNumbers: false,
    // Decimal currency amounts are always formatted using En locale for compatibility with the API
    locale: Locale(identifier: "en"),
    currencySymbol: "$"
  )

  fileprivate static func cachedFormatter(forConfig config: NumberFormatterConfig) -> NumberFormatter {
    let formatter = self.formatters[config] ?? config.formatter()
    self.formatters[config] = formatter
    return formatter
  }
}

extension NumberFormatterConfig: Hashable {
  fileprivate func hash(into hasher: inout Hasher) {
    hasher.combine(self.numberStyle)
    hasher.combine(self.roundingMode)
    hasher.combine(self.maximumFractionDigits)
    hasher.combine(self.generatesDecimalNumbers)
    hasher.combine(self.locale)
    hasher.combine(self.currencySymbol)
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

extension NumberFormatterConfig {
  fileprivate enum lens {
    fileprivate static let numberStyle = Lens<NumberFormatterConfig, NumberFormatter.Style>(
      view: { $0.numberStyle },
      set: { .init(
        numberStyle: $0, roundingMode: $1.roundingMode,
        maximumFractionDigits: $1.maximumFractionDigits,
        minimumFractionDigits: $1.minimumFractionDigits,
        generatesDecimalNumbers: $1.generatesDecimalNumbers,
        locale: $1.locale, currencySymbol: $1.currencySymbol
      ) }
    )

    fileprivate static let roundingMode = Lens<NumberFormatterConfig, NumberFormatter.RoundingMode>(
      view: { $0.roundingMode },
      set: { .init(
        numberStyle: $1.numberStyle, roundingMode: $0,
        maximumFractionDigits: $1.maximumFractionDigits,
        minimumFractionDigits: $1.minimumFractionDigits,
        generatesDecimalNumbers: $1.generatesDecimalNumbers,
        locale: $1.locale, currencySymbol: $1.currencySymbol
      ) }
    )

    fileprivate static let maximumFractionDigits = Lens<NumberFormatterConfig, Int>(
      view: { $0.maximumFractionDigits },
      set: { .init(
        numberStyle: $1.numberStyle, roundingMode: $1.roundingMode, maximumFractionDigits: $0,
        minimumFractionDigits: $1.minimumFractionDigits,
        generatesDecimalNumbers: $1.generatesDecimalNumbers, locale: $1.locale,
        currencySymbol: $1.currencySymbol
      ) }
    )

    fileprivate static let minimumFractionDigits = Lens<NumberFormatterConfig, Int>(
      view: { $0.minimumFractionDigits },
      set: { .init(
        numberStyle: $1.numberStyle, roundingMode: $1.roundingMode,
        maximumFractionDigits: $1.maximumFractionDigits,
        minimumFractionDigits: $0,
        generatesDecimalNumbers: $1.generatesDecimalNumbers, locale: $1.locale,
        currencySymbol: $1.currencySymbol
      ) }
    )

    fileprivate static let generatesDecimalNumbers = Lens<NumberFormatterConfig, Bool>(
      view: { $0.generatesDecimalNumbers },
      set: { .init(
        numberStyle: $1.numberStyle, roundingMode: $1.roundingMode,
        maximumFractionDigits: $1.maximumFractionDigits,
        minimumFractionDigits: $1.minimumFractionDigits,
        generatesDecimalNumbers: $0, locale: $1.locale,
        currencySymbol: $1.currencySymbol
      ) }
    )

    fileprivate static let locale = Lens<NumberFormatterConfig, Locale>(
      view: { $0.locale },
      set: { .init(
        numberStyle: $1.numberStyle, roundingMode: $1.roundingMode,
        maximumFractionDigits: $1.maximumFractionDigits,
        minimumFractionDigits: $1.minimumFractionDigits,
        generatesDecimalNumbers: $1.generatesDecimalNumbers,
        locale: $0, currencySymbol: $1.currencySymbol
      ) }
    )

    fileprivate static let currencySymbol = Lens<NumberFormatterConfig, String>(
      view: { $0.currencySymbol },
      set: { .init(
        numberStyle: $1.numberStyle, roundingMode: $1.roundingMode,
        maximumFractionDigits: $1.maximumFractionDigits,
        minimumFractionDigits: $1.minimumFractionDigits,
        generatesDecimalNumbers: $1.generatesDecimalNumbers,
        locale: $1.locale, currencySymbol: $0
      ) }
    )
  }
}
