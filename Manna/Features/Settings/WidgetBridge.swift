import WidgetKit

/// Bridge para recarregar o widget após mudanças no app.
enum WidgetBridge {
    static func reload() {
        WidgetCenter.shared.reloadAllTimelines()
    }
}
