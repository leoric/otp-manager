import SwiftUI

struct AddAccountView: View {
    var onSave: (OTPAccount) -> Void

    @State private var name: String = ""
    @State private var issuer: String = ""
    @State private var secret: String = ""
    @State private var algorithm: HashAlgorithm = .sha1
    @State private var isEightDigits: Bool = false
    @State private var isTimeBased: Bool = true
    @State private var period: String = "30"

    private var isSecretValid: Bool {
        let tempAccount = OTPAccount(secret: secret)
        return tempAccount.isValidSecret
    }

    var body: some View {
        VStack(spacing: 0) {
            // Window header
            HStack {
                Button("Cancel") {
                    WindowManager.shared.closeWindow(id: "addAccount")
                }
                .foregroundColor(.orange)
                .buttonStyle(.plain)
                .font(.system(size: 15))

                Spacer()

                Text("Add Account")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)

                Spacer()

                Button("Done") {
                    let account = OTPAccount(
                        name: name,
                        issuer: issuer,
                        secret: secret,
                        algorithm: algorithm,
                        isEightDigits: isEightDigits,
                        isTimeBased: isTimeBased,
                        period: Int(period) ?? 30
                    )
                    onSave(account)
                    WindowManager.shared.closeWindow(id: "addAccount")
                }
                .foregroundColor(isSecretValid ? .orange : .gray)
                .disabled(!isSecretValid)
                .buttonStyle(.plain)
                .font(.system(size: 15, weight: .bold))
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 12)

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // DISPLAY section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("DISPLAY")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.gray)
                            .padding(.leading, 4)

                        VStack(spacing: 8) {
                            TextField("Name", text: $name)
                                .textFieldStyle(.plain)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.white)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                                .background(Color(white: 0.16))
                                .cornerRadius(8)

                            TextField("Issuer", text: $issuer)
                                .textFieldStyle(.plain)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.white)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                                .background(Color(white: 0.16))
                                .cornerRadius(8)
                        }
                    }

                    // DETAILS section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("DETAILS")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.gray)
                            .padding(.leading, 4)

                        VStack(spacing: 12) {
                            // Secret key with auto-UPPERCASE and Base32 validation
                            VStack(alignment: .leading, spacing: 4) {
                                TextField("Secret key", text: $secret)
                                    .textFieldStyle(.plain)
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.white)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 12)
                                    .background(Color(white: 0.16))
                                    .cornerRadius(8)
                                    .onChange(of: secret) { newValue in
                                        // Auto convert lowercase to UPPERCASE and remove spaces on typing
                                        let sanitized = OTPAccount.sanitizeSecret(newValue)
                                        if sanitized != newValue {
                                            secret = sanitized
                                        }
                                    }
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(secret.isEmpty || isSecretValid ? Color.clear : Color.red, lineWidth: 1)
                                    )

                                if !secret.isEmpty && !isSecretValid {
                                    Text("Invalid Base32 secret (allowed: A-Z, 2-7)")
                                        .font(.system(size: 10))
                                        .foregroundColor(.red)
                                        .padding(.leading, 4)
                                }
                            }

                            // Algorithm
                            HStack {
                                Text("Algorithm")
                                    .foregroundColor(.white)
                                Spacer()
                                Picker("", selection: $algorithm) {
                                    ForEach(HashAlgorithm.allCases) { alg in
                                        Text(alg.rawValue).tag(alg)
                                    }
                                }
                                .pickerStyle(.menu)
                                .labelsHidden()
                            }

                            Divider().background(Color.white.opacity(0.1))

                            // Eight digits toggle
                            Toggle(isOn: $isEightDigits) {
                                Text("Eight digits")
                                    .foregroundColor(.white)
                            }
                            .toggleStyle(SwitchToggleStyle(tint: .blue))

                            Divider().background(Color.white.opacity(0.1))

                            // Time based toggle
                            Toggle(isOn: $isTimeBased) {
                                Text("Time based")
                                    .foregroundColor(.white)
                            }
                            .toggleStyle(SwitchToggleStyle(tint: .blue))

                            Divider().background(Color.white.opacity(0.1))

                            // Period
                            HStack {
                                Text("Period")
                                    .foregroundColor(.white)
                                Spacer()
                                TextField("30", text: $period)
                                    .textFieldStyle(.plain)
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.white)
                                    .frame(width: 80, height: 28)
                                    .background(Color(white: 0.16))
                                    .cornerRadius(6)
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
        }
        .frame(width: 340, height: 440)
        .background(Color(red: 0.08, green: 0.10, blue: 0.13))
    }
}
