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
  internal enum CardView {
    internal enum AmountShowView {
      internal enum Text1 {
        /// Tip amount:
        internal static let title = L10n.tr("Localizable", "cardView.amountShowView.text1.title", fallback: "Tip amount:")
      }
      internal enum Text2 {
        /// Total amount:
        internal static let title = L10n.tr("Localizable", "cardView.amountShowView.text2.title", fallback: "Total amount:")
      }
      internal enum Text3 {
        /// Per person:
        internal static let title = L10n.tr("Localizable", "cardView.amountShowView.text3.title", fallback: "Per person:")
      }
    }
    internal enum BillValueView {
      internal enum Textfield {
        /// Total amount: %@
        internal static func title(_ p1: Any) -> String {
          return L10n.tr("Localizable", "cardView.billValueView.textfield.title", String(describing: p1), fallback: "Total amount: %@")
        }
      }
    }
    internal enum ButtonView {
      internal enum Button {
        internal enum AddToHistory {
          /// Add to history
          internal static let title = L10n.tr("Localizable", "cardView.buttonView.button.addToHistory.title", fallback: "Add to history")
        }
        internal enum Load {
          /// Load
          internal static let title = L10n.tr("Localizable", "cardView.buttonView.button.load.title", fallback: "Load")
        }
        internal enum Save {
          /// Save
          internal static let title = L10n.tr("Localizable", "cardView.buttonView.button.save.title", fallback: "Save")
        }
      }
      internal enum ConfirmationDialog {
        /// Are you sure you want to import the file?
        internal static let title = L10n.tr("Localizable", "cardView.buttonView.confirmationDialog.title", fallback: "Are you sure you want to import the file?")
      }
      internal enum PresetButton {
        internal enum Cancel {
          /// Cancel
          internal static let title = L10n.tr("Localizable", "cardView.buttonView.presetButton.cancel.title", fallback: "Cancel")
        }
        internal enum Family {
          /// Family
          internal static let title = L10n.tr("Localizable", "cardView.buttonView.presetButton.family.title", fallback: "Family")
        }
        internal enum Friends {
          /// Friends
          internal static let title = L10n.tr("Localizable", "cardView.buttonView.presetButton.friends.title", fallback: "Friends")
        }
        internal enum Work {
          /// Work
          internal static let title = L10n.tr("Localizable", "cardView.buttonView.presetButton.work.title", fallback: "Work")
        }
      }
    }
    internal enum HistoryView {
      internal enum ScrollView {
        internal enum Button {
          internal enum Delete {
            /// Delete
            internal static let title = L10n.tr("Localizable", "cardView.historyView.scrollView.button.delete.title", fallback: "Delete")
          }
        }
        internal enum TextCourrency {
          /// Courrency %@
          internal static func title(_ p1: Any) -> String {
            return L10n.tr("Localizable", "cardView.historyView.scrollView.textCourrency.title", String(describing: p1), fallback: "Courrency %@")
          }
        }
        internal enum TextData {
          /// Date %@
          internal static func title(_ p1: Any) -> String {
            return L10n.tr("Localizable", "cardView.historyView.scrollView.textData.title", String(describing: p1), fallback: "Date %@")
          }
        }
        internal enum TextPerPerson {
          /// Per person %@
          internal static func title(_ p1: Any) -> String {
            return L10n.tr("Localizable", "cardView.historyView.scrollView.textPerPerson.title", String(describing: p1), fallback: "Per person %@")
          }
        }
        internal enum TextTip {
          /// Tip %@
          internal static func title(_ p1: Any) -> String {
            return L10n.tr("Localizable", "cardView.historyView.scrollView.textTip.title", String(describing: p1), fallback: "Tip %@")
          }
        }
      }
      internal enum Text {
        /// History
        internal static let title = L10n.tr("Localizable", "cardView.historyView.text.title", fallback: "History")
      }
    }
  }
  internal enum Form {
    internal enum Calculate {
      internal enum Currency {
        /// Convert to currency
        internal static let title = L10n.tr("Localizable", "form.calculate.currency.title", fallback: "Convert to currency")
      }
    }
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
      internal enum CurrencyCnverted {
        /// Convert to currency
        internal static let title = L10n.tr("Localizable", "picker.choose.currencyCnverted.title", fallback: "Convert to currency")
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
