
public enum PaymentWidgetEvent: String {
    case onBinDetected =  "onBinDetected"
    case onInstallmentSelected =  "onInstallmentSelected"
    case refetchOrder =  "refetchOrder"
    case purchase =  "purchase"
    case purchaseError =  "purchaseError"
    case paymentMethods3dsInitiated = "paymentMethods3dsInitiated"
    case linkClose = "linkClose"
}
