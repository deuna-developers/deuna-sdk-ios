import Foundation

public enum WalletProvider: String {
    case applePay = "apple_pay"

    public var processorName: String { rawValue }

    static func fromProcessorName(_ name: String) -> WalletProvider? {
        return WalletProvider(rawValue: name)
    }
}
