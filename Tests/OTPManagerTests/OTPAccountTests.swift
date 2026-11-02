import XCTest
@testable import OTPManager

final class OTPAccountTests: XCTestCase {

    func testValidBase32Secrets() {
        let validSecrets = [
            "JBSWY3DPEHPK3PXP",
            "jbswy3dpehpk3pxp", // case-insensitive
            "JBSW Y3DP EHPK 3PXP", // spaces ignored
            "234567ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        ]

        for secret in validSecrets {
            let account = OTPAccount(secret: secret)
            XCTAssertTrue(account.isValidSecret, "Expected secret '\(secret)' to be valid")
        }
    }

    func testInvalidBase32Secrets() {
        let invalidSecrets = [
            "", // empty
            "   ", // spaces only
            "sdfsdfsd", // contains 's', 'f', 'd' (invalid Base32)
            "JBSWY890", // contains '8', '9', '0'
            "JBSWY3DP!", // contains special characters
        ]

        for secret in invalidSecrets {
            let account = OTPAccount(secret: secret)
            XCTAssertFalse(account.isValidSecret, "Expected secret '\(secret)' to be invalid")
        }
    }

    func testSecretSanitizationAndUppercase() {
        let input = "  jbsw y3dp ehpk 3pxp  "
        let expected = "JBSWY3DPEHPK3PXP"

        let sanitized = OTPAccount.sanitizeSecret(input)
        XCTAssertEqual(sanitized, expected)

        let account = OTPAccount(secret: input)
        XCTAssertEqual(account.secret, expected)
        XCTAssertTrue(account.isValidSecret)
    }
}
