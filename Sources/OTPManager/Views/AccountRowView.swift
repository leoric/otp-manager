import SwiftUI
import AppKit

struct AccountRowView: View {
    let account: OTPAccount
    let isEditing: Bool
    let onDelete: () -> Void
    let onEdit: () -> Void

    @State private var timer: Timer?
    @State private var timeRemaining: Int = 30
    @State private var currentCode: String = ""
    @State private var isCopied: Bool = false

    var body: some View {
        HStack(spacing: 12) {
            if isEditing {
                Button(action: onDelete) {
                    Image(systemName: "minus.circle.fill")
                        .foregroundColor(.red)
                        .font(.system(size: 20))
                }
                .buttonStyle(.plain)
            }

            // Account information
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text(isCopied ? "Copied!" : currentCode)
                        .font(.system(size: 32, weight: .light, design: .monospaced))
                        .foregroundColor(isCopied ? .green : .white)
                        .animation(.easeInOut(duration: 0.2), value: isCopied)
                }

                HStack(spacing: 6) {
                    if !account.issuer.isEmpty {
                        Text(account.issuer)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.orange)
                    }

                    if !account.name.isEmpty {
                        Text("(\(account.name))")
                            .font(.system(size: 15, weight: .regular))
                            .foregroundColor(.white)
                    }
                }
                .lineLimit(1)
            }

            Spacer()

            if isEditing {
                // Reorder handle icon
                Image(systemName: "line.3.horizontal")
                    .foregroundColor(.gray)
                    .font(.system(size: 18))
            } else {
                CustomCircularProgressView(progress: Double(timeRemaining) / Double(max(1, account.period)))
            }
        }
        .padding(12)
        .background(Color(red: 0.11, green: 0.15, blue: 0.20))
        .cornerRadius(12)
        .contentShape(Rectangle())
        // Click action: copy code if not editing, open edit window if editing
        .onTapGesture {
            if isEditing {
                onEdit()
            } else {
                copyCodeToClipboard()
            }
        }
        .onAppear {
            updateCode()
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                updateCode()
            }
        }
        .onDisappear {
            timer?.invalidate()
        }
    }

    private func updateCode() {
        let now = Date()
        currentCode = OTPGenerator.generateOTP(for: account, date: now)
        let period = max(1, account.period)
        let elapsed = Int(now.timeIntervalSince1970) % period
        timeRemaining = period - elapsed
    }

    private func copyCodeToClipboard() {
        // Copy raw code without spaces (or with spaces based on preference, here raw stripped)
        let rawCode = currentCode.replacingOccurrences(of: " ", with: "")
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(rawCode, forType: .string)

        // Show "Copied!" notification feedback for 1 second
        withAnimation {
            isCopied = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation {
                isCopied = false
            }
        }
    }
}
