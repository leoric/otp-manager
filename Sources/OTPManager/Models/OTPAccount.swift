import Foundation

enum HashAlgorithm: String, Codable, CaseIterable, Identifiable {
    case sha1 = "SHA1"
    case sha256 = "SHA256"
    case sha512 = "SHA512"

    var id: String { rawValue }
}

struct OTPAccount: Identifiable, Codable, Equatable {
    var id: UUID
    var name: String
    var issuer: String
    var secret: String
    var algorithm: HashAlgorithm
    var isEightDigits: Bool
    var isTimeBased: Bool
    var period: Int

    init(
        id: UUID = UUID(),
        name: String = "",
        issuer: String = "",
        secret: String = "",
        algorithm: HashAlgorithm = .sha1,
        isEightDigits: Bool = false,
        isTimeBased: Bool = true,
        period: Int = 30
    ) {
        self.id = id
        self.name = name
        self.issuer = issuer
        self.secret = OTPAccount.sanitizeSecret(secret)
        self.algorithm = algorithm
        self.isEightDigits = isEightDigits
        self.isTimeBased = isTimeBased
        self.period = period
    }

    // Removes spaces and converts characters to UPPERCASE
    static func sanitizeSecret(_ rawSecret: String) -> String {
        return rawSecret.replacingOccurrences(of: " ", with: "").uppercased()
    }

    var sanitizedSecret: String {
        OTPAccount.sanitizeSecret(secret)
    }

    // Validates that the secret key is a valid non-empty Base32 string (A-Z, 2-7)
    var isValidSecret: Bool {
        let cleanSecret = sanitizedSecret
        guard !cleanSecret.isEmpty else { return false }
        let base32AllowedSet = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567")
        return cleanSecret.unicodeScalars.allSatisfy { base32AllowedSet.contains($0) }
    }
}
