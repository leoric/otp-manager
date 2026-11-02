import Cocoa
import Carbon

// MARK: - HotKey Protocol Abstraction
public protocol HotKeyRegistering {
    func register(keyCode: UInt32, modifiers: UInt32, handler: @escaping () -> Void) -> EventHotKeyRef?
    func unregister(_ hotKeyRef: EventHotKeyRef)
}

// MARK: - Carbon Implementation
public final class CarbonHotKeyRegistrar: HotKeyRegistering {
    public init() {}

    public func register(keyCode: UInt32, modifiers: UInt32, handler: @escaping () -> Void) -> EventHotKeyRef? {
        var hotKeyRef: EventHotKeyRef?
        var gMyHotKeyID = EventHotKeyID()
        gMyHotKeyID.signature = OSType(0x4F54504D) // 'OTPM'
        gMyHotKeyID.id = 1

        var eventType = EventTypeSpec()
        eventType.eventClass = OSType(kEventClassKeyboard)
        eventType.eventKind = OSType(kEventHotKeyPressed)

        InstallEventHandler(GetApplicationEventTarget(), { (_, _, _) -> OSStatus in
            HotKeyManager.shared.onTrigger?()
            return noErr
        }, 1, &eventType, nil, nil)

        let status = RegisterEventHotKey(keyCode, modifiers, gMyHotKeyID, GetApplicationEventTarget(), 0, &hotKeyRef)
        return status == noErr ? hotKeyRef : nil
    }

    public func unregister(_ hotKeyRef: EventHotKeyRef) {
        UnregisterEventHotKey(hotKeyRef)
    }
}

// MARK: - HotKeyManager
public final class HotKeyManager: ObservableObject {
    public static let shared = HotKeyManager()

    @Published public var keyCode: UInt32 = 49 // Default: Space
    @Published public var keyModifiers: UInt32 = UInt32(cmdKey | optionKey)
    @Published public var isRecording = false

    public var hotKeyRef: EventHotKeyRef?
    public var onTrigger: (() -> Void)?

    private let userDefaults: UserDefaults
    private let registrar: HotKeyRegistering
    private var eventMonitor: Any?

    public init(userDefaults: UserDefaults = .standard, registrar: HotKeyRegistering = CarbonHotKeyRegistrar()) {
        self.userDefaults = userDefaults
        self.registrar = registrar
        loadKeyCombo()
    }

    public func register() {
        if let ref = hotKeyRef {
            registrar.unregister(ref)
            hotKeyRef = nil
        }

        hotKeyRef = registrar.register(keyCode: keyCode, modifiers: keyModifiers) { [weak self] in
            self?.onTrigger?()
        }
    }

    public func startRecording() {
        isRecording = true
        eventMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            guard let self = self, self.isRecording else { return event }

            var carbonMods: UInt32 = 0
            let flags = event.modifierFlags
            if flags.contains(.command) { carbonMods |= UInt32(cmdKey) }
            if flags.contains(.option) { carbonMods |= UInt32(optionKey) }
            if flags.contains(.control) { carbonMods |= UInt32(controlKey) }
            if flags.contains(.shift) { carbonMods |= UInt32(shiftKey) }

            self.saveKeyCombo(code: UInt32(event.keyCode), mods: carbonMods)
            self.stopRecording()
            return nil
        }
    }

    public func stopRecording() {
        isRecording = false
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
            eventMonitor = nil
        }
    }

    public func saveKeyCombo(code: UInt32, mods: UInt32) {
        self.keyCode = code
        self.keyModifiers = mods
        userDefaults.set(code, forKey: "HotKeyCodes")
        userDefaults.set(mods, forKey: "HotKeyModifiers")
        register()
    }

    public func loadKeyCombo() {
        if let code = userDefaults.object(forKey: "HotKeyCodes") as? UInt32,
           let mods = userDefaults.object(forKey: "HotKeyModifiers") as? UInt32 {
            self.keyCode = code
            self.keyModifiers = mods
        }
    }

    public var displayString: String {
        var str = ""
        if (keyModifiers & UInt32(cmdKey)) != 0 { str += "⌘ " }
        if (keyModifiers & UInt32(optionKey)) != 0 { str += "⌥ " }
        if (keyModifiers & UInt32(controlKey)) != 0 { str += "⌃ " }
        if (keyModifiers & UInt32(shiftKey)) != 0 { str += "⇧ " }

        str += characterForKeyCode(keyCode)
        return str
    }

    public func characterForKeyCode(_ code: UInt32) -> String {
        switch code {
        case 49: return "Space"
        case 36: return "↵"
        case 48: return "⇥"
        case 51: return "⌫"
        case 53: return "Esc"
        case 123: return "←"
        case 124: return "→"
        case 125: return "↓"
        case 126: return "↑"
        default:
            return "Key \(code)"
        }
    }
}
