import XCTest
import Carbon
@testable import OTPManager

// MARK: - Mock HotKey Registrar
final class MockHotKeyRegistrar: HotKeyRegistering {
    var isRegistered = false
    var isUnregistered = false
    var registeredKeyCode: UInt32?
    var registeredModifiers: UInt32?

    func register(keyCode: UInt32, modifiers: UInt32, handler: @escaping () -> Void) -> EventHotKeyRef? {
        isRegistered = true
        registeredKeyCode = keyCode
        registeredModifiers = modifiers
        // Return a non-nil dummy pointer for testing
        return OpaquePointer(bitPattern: 0xDEADBEEF)
    }

    func unregister(_ hotKeyRef: EventHotKeyRef) {
        isUnregistered = true
    }
}

// MARK: - HotKeyManagerTests Suite
final class HotKeyManagerTests: XCTestCase {
    private var mockUserDefaults: UserDefaults!
    private var mockRegistrar: MockHotKeyRegistrar!
    private var sut: HotKeyManager!

    override func setUp() {
        super.setUp()
        mockUserDefaults = UserDefaults(suiteName: "HotKeyManagerTestsSuite")
        mockUserDefaults.removePersistentDomain(forName: "HotKeyManagerTestsSuite")
        mockRegistrar = MockHotKeyRegistrar()
        sut = HotKeyManager(userDefaults: mockUserDefaults, registrar: mockRegistrar)
    }

    override func tearDown() {
        mockUserDefaults.removePersistentDomain(forName: "HotKeyManagerTestsSuite")
        mockUserDefaults = nil
        mockRegistrar = nil
        sut = nil
        super.tearDown()
    }

    // MARK: - Tests

    func testInitialDefaultValues() {
        XCTAssertEqual(sut.keyCode, 49)
        XCTAssertEqual(sut.keyModifiers, UInt32(cmdKey | optionKey))
        XCTAssertFalse(sut.isRecording)
    }

    func testSaveKeyComboPersistsData() {
        let testKeyCode: UInt32 = 0 // Key 'A'
        let testModifiers: UInt32 = UInt32(cmdKey | shiftKey)

        sut.saveKeyCombo(code: testKeyCode, mods: testModifiers)

        XCTAssertEqual(sut.keyCode, testKeyCode)
        XCTAssertEqual(sut.keyModifiers, testModifiers)
        XCTAssertEqual(mockUserDefaults.object(forKey: "HotKeyCodes") as? UInt32, testKeyCode)
        XCTAssertEqual(mockUserDefaults.object(forKey: "HotKeyModifiers") as? UInt32, testModifiers)
    }

    func testLoadKeyComboRestoresPersistedData() {
        let testKeyCode: UInt32 = 1 // Key 'S'
        let testModifiers: UInt32 = UInt32(controlKey | optionKey)

        mockUserDefaults.set(testKeyCode, forKey: "HotKeyCodes")
        mockUserDefaults.set(testModifiers, forKey: "HotKeyModifiers")

        let newManager = HotKeyManager(userDefaults: mockUserDefaults, registrar: mockRegistrar)

        XCTAssertEqual(newManager.keyCode, testKeyCode)
        XCTAssertEqual(newManager.keyModifiers, testModifiers)
    }

    func testRegisterCallsRegistrar() {
        sut.register()

        XCTAssertTrue(mockRegistrar.isRegistered)
        XCTAssertEqual(mockRegistrar.registeredKeyCode, 49)
        XCTAssertNotNil(sut.hotKeyRef)
    }

    func testRegisterUnregistersPreviousHotKey() {
        sut.register()
        XCTAssertTrue(mockRegistrar.isRegistered)

        sut.register()
        XCTAssertTrue(mockRegistrar.isUnregistered)
    }

    func testDisplayStringFormatting() {
        sut.keyModifiers = UInt32(cmdKey | optionKey)
        sut.keyCode = 49 // Space
        XCTAssertEqual(sut.displayString, "⌘ ⌥ Space")

        sut.keyModifiers = UInt32(controlKey | shiftKey)
        sut.keyCode = 36 // Return
        XCTAssertEqual(sut.displayString, "⌃ ⇧ ↵")
    }

    func testCharacterForKeyCodeMapping() {
        XCTAssertEqual(sut.characterForKeyCode(49), "Space")
        XCTAssertEqual(sut.characterForKeyCode(36), "↵")
        XCTAssertEqual(sut.characterForKeyCode(48), "⇥")
        XCTAssertEqual(sut.characterForKeyCode(51), "⌫")
        XCTAssertEqual(sut.characterForKeyCode(53), "Esc")
        XCTAssertEqual(sut.characterForKeyCode(123), "←")
        XCTAssertEqual(sut.characterForKeyCode(124), "→")
        XCTAssertEqual(sut.characterForKeyCode(125), "↓")
        XCTAssertEqual(sut.characterForKeyCode(126), "↑")
        XCTAssertEqual(sut.characterForKeyCode(999), "Key 999")
    }
}
