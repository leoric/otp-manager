import SwiftUI

struct SettingsView: View {
    @ObservedObject private var hotKeyManager = HotKeyManager.shared

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Settings")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                Button("Done") {
                    WindowManager.shared.closeWindow(id: "settings")
                }
                .foregroundColor(.orange)
                .buttonStyle(.plain)
            }

            VStack(alignment: .leading, spacing: 10) {
                Text("Global Hotkey to Show/Hide:")
                    .font(.subheadline)
                    .foregroundColor(.gray)

                HStack {
                    Text(hotKeyManager.isRecording ? "Press keys..." : hotKeyManager.displayString)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color(white: 0.2))
                        .cornerRadius(6)
                        .foregroundColor(hotKeyManager.isRecording ? .orange : .white)

                    Button(hotKeyManager.isRecording ? "Cancel" : "Record Shortcut") {
                        if hotKeyManager.isRecording {
                            hotKeyManager.stopRecording()
                        } else {
                            hotKeyManager.startRecording()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.orange)
                }
            }
            Spacer()
        }
        .padding()
        .frame(width: 320, height: 180)
        .background(Color(red: 0.08, green: 0.10, blue: 0.13))
    }
}
