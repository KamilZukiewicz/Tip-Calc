// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum L10n {
  internal enum Alert {
    internal enum Button {
      internal enum Close {
        /// Close
        internal static let title = L10n.tr("Localizable", "alert.button.close.title", fallback: "Close")
      }
    }
  }
  internal enum Form {
    internal enum Number {
      internal enum Of {
        internal enum People {
          /// Number of people: %d
          internal static func title(_ p1: Int) -> String {
            return L10n.tr("Localizable", "form.number.of.people.title", p1, fallback: "Number of people: %d")
          }
        }
      }
    }
  }
  internal enum Picker {
    internal enum Choose {
      internal enum Currency {
        /// Choose currency:
        internal static let title = L10n.tr("Localizable", "picker.choose.currency.title", fallback: "Choose currency:")
      }
    }
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg..., fallback value: String) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: value, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
