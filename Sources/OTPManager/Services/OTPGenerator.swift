import Foundation
import CryptoKit

struct OTPGenerator {
    static func generateOTP(for account: OTPAccount, date: Date = Date()) -> String {
        guard !account.sanitizedSecret.isEmpty,
              let secretData = base32Decode(account.sanitizedSecret) else {
            return account.isEightDigits ? "00000000" : "000000"
        }

        let counter = UInt64(date.timeIntervalSince1970) / UInt64(max(1, account.period))
        var counterBytes = counter.bigEndian
        let counterData = Data(bytes: &counterBytes, count: MemoryLayout<UInt64>.size)

        let hmacData: Data
        switch account.algorithm {
        case .sha1:
            let key = SymmetricKey(data: secretData)
            hmacData = Data(HMAC<Insecure.SHA1>.authenticationCode(for: counterData, using: key))
        case .sha256:
            let key = SymmetricKey(data: secretData)
            hmacData = Data(HMAC<SHA256>.authenticationCode(for: counterData, using: key))
        case .sha512:
            let key = SymmetricKey(data: secretData)
            hmacData = Data(HMAC<SHA512>.authenticationCode(for: counterData, using: key))
        }

        guard let lastByte = hmacData.last else {
            return account.isEightDigits ? "00000000" : "000000"
        }

        let offset = Int(lastByte & 0x0f)
        guard offset + 4 <= hmacData.count else {
            return account.isEightDigits ? "00000000" : "000000"
        }

        // Byte-by-byte reading to prevent misaligned pointer crash on ARM64
        let b0 = UInt32(hmacData[offset] & 0x7f) << 24
        let b1 = UInt32(hmacData[offset + 1]) << 16
        let b2 = UInt32(hmacData[offset + 2]) << 8
        let b3 = UInt32(hmacData[offset + 3])

        let truncated = b0 | b1 | b2 | b3

        let digits = account.isEightDigits ? 8 : 6
        let modulo = UInt32(pow(10.0, Double(digits)))
        let code = truncated % modulo

        let codeString = String(format: "%0\(digits)d", code)

        if digits == 6 {
            let index = codeString.index(codeString.startIndex, offsetBy: 3)
            return "\(codeString[..<index]) \(codeString[index...])"
        } else if digits == 8 {
            let index = codeString.index(codeString.startIndex, offsetBy: 4)
            return "\(codeString[..<index]) \(codeString[index...])"
        }

        return codeString
    }

    private static func base32Decode(_ string: String) -> Data? {
        let base32HexTable = "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567"
        var buffer = 0
        var bitsLeft = 0
        var result = Data()

        for char in string.uppercased() {
            guard let index = base32HexTable.firstIndex(of: char) else { continue }
            let val = base32HexTable.distance(from: base32HexTable.startIndex, to: index)
            buffer = (buffer << 5) | val
            bitsLeft += 5
            if bitsLeft >= 8 {
                bitsLeft -= 8
                result.append(UInt8((buffer >> bitsLeft) & 0xff))
            }
        }
        return result.isEmpty ? nil : result
    }
}
