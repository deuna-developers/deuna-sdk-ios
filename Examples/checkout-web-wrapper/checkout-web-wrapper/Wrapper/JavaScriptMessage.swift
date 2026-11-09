enum CallbackName: String {
    case onSuccess
    case onError
    case onEventDispatch
}

enum WidgetType: String {
    case paymentWidget
    case elementsWidget
}

struct JavaScriptMessage {
    let callbackName: CallbackName
    let payload: [String: Any]
    let widgetType: WidgetType
}
