import SwiftUI
import UniformTypeIdentifiers

struct MainView: View {
    @EnvironmentObject var storageManager: StorageManager
    @State private var isEditing = false
    @State private var showAddMenu = false

    var body: some View {
        VStack(spacing: 0) {
            // Navigation bar
            HStack {
                Button(action: {
                    withAnimation { isEditing.toggle() }
                }) {
                    Text(isEditing ? "Done" : "Edit")
                        .foregroundColor(Color.orange)
                        .font(.system(size: 16, weight: .medium))
                }
                .buttonStyle(.plain)

                Spacer()

                // Settings button
                Button(action: {
                    WindowManager.shared.openWindow(
                        id: "settings",
                        title: "Settings",
                        size: NSSize(width: 320, height: 180),
                        content: SettingsView()
                    )
                }) {
                    Image(systemName: "gearshape")
                        .foregroundColor(.orange)
                        .font(.system(size: 16))
                }
                .buttonStyle(.plain)
                .padding(.trailing, 8)

                // Plus button
                Button(action: { showAddMenu.toggle() }) {
                    Image(systemName: "plus")
                        .foregroundColor(Color.orange)
                        .font(.system(size: 20))
                }
                .buttonStyle(.plain)
                .popover(isPresented: $showAddMenu, arrowEdge: .top) {
                    AddMenuPopoverView(
                        onManual: {
                            showAddMenu = false
                            WindowManager.shared.openWindow(
                                id: "addAccount",
                                title: "Add Account",
                                size: NSSize(width: 320, height: 420),
                                content: AddAccountView(onSave: { newAccount in
                                    storageManager.add(newAccount)
                                })
                            )
                        },
                        onQR: {
                            showAddMenu = false
                            importQRImage()
                        }
                    )
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)

            HStack {
                Text("Accounts")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)

            // Accounts list with reorder support
            List {
                ForEach(storageManager.accounts) { account in
                    AccountRowView(
                        account: account,
                        isEditing: isEditing,
                        onDelete: {
                            if let index = storageManager.accounts.firstIndex(of: account) {
                                storageManager.accounts.remove(at: index)
                            }
                        },
                        onEdit: {
                            WindowManager.shared.openWindow(
                                id: "editAccount_\(account.id)",
                                title: "Edit Account",
                                size: NSSize(width: 300, height: 260),
                                content: EditAccountView(account: account, onSave: { updatedAccount in
                                    storageManager.update(updatedAccount)
                                })
                            )
                        }
                    )
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
                    .listRowSeparator(.hidden)
                }
                .onMove { source, destination in
                    storageManager.accounts.move(fromOffsets: source, toOffset: destination)
                }
            }
            .listStyle(.plain)
            .padding(.horizontal, 12)
        }
        .frame(width: 340, height: 480)
        .background(Color(red: 0.07, green: 0.09, blue: 0.12))
    }

    private func importQRImage() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.image]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false

        if panel.runModal() == .OK, let url = panel.url {
            if let parsedAccount = parseQRCode(from: url) {
                storageManager.add(parsedAccount)
            }
        }
    }

    private func parseQRCode(from fileURL: URL) -> OTPAccount? {
        guard let ciImage = CIImage(contentsOf: fileURL) else { return nil }
        let context = CIContext()
        let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: context, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])
        let features = detector?.features(in: ciImage) as? [CIQRCodeFeature] ?? []

        for feature in features {
            if let stringValue = feature.messageString, let url = URL(string: stringValue), url.scheme == "otpauth" {
                return parseOTPAuthURL(url)
            }
        }
        return nil
    }

    private func parseOTPAuthURL(_ url: URL) -> OTPAccount? {
        guard url.host == "totp" || url.host == "hotp" else { return nil }
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let path = url.path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))

        var name = path
        var issuer = ""

        if path.contains(":") {
            let parts = path.components(separatedBy: ":")
            issuer = parts[0]
            name = parts[1]
        }

        var secret = ""
        var algorithm: HashAlgorithm = .sha1
        var digits = 6
        var period = 30

        for item in components?.queryItems ?? [] {
            switch item.name.lowercased() {
            case "secret": secret = item.value ?? ""
            case "issuer": issuer = item.value ?? issuer
            case "algorithm":
                if let val = item.value?.uppercased(), let alg = HashAlgorithm(rawValue: val) {
                    algorithm = alg
                }
            case "digits": digits = Int(item.value ?? "6") ?? 6
            case "period": period = Int(item.value ?? "30") ?? 30
            default: break
            }
        }

        return OTPAccount(
            name: name,
            issuer: issuer,
            secret: secret,
            algorithm: algorithm,
            isEightDigits: digits == 8,
            isTimeBased: url.host == "totp",
            period: period
        )
    }
}
