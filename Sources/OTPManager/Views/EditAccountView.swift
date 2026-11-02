import SwiftUI

struct EditAccountView: View {
    @Environment(\.dismiss) var dismiss
    @State var account: OTPAccount
    var onSave: (OTPAccount) -> Void

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Button("Cancel") { dismiss() }
                    .foregroundColor(.orange)
                    .buttonStyle(.plain)
                Spacer()
                Text("Edit Account")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
                Button("Done") {
                    onSave(account)
                    dismiss()
                }
                .foregroundColor(.orange)
                .buttonStyle(.plain)
            }
            .padding()

            Form {
                Section(header: Text("DISPLAY").font(.caption).foregroundColor(.gray)) {
                    TextField("Name", text: $account.name)
                        .textFieldStyle(.plain)
                        .padding(8)
                        .background(Color(white: 0.15))
                        .cornerRadius(6)

                    TextField("Issuer", text: $account.issuer)
                        .textFieldStyle(.plain)
                        .padding(8)
                        .background(Color(white: 0.15))
                        .cornerRadius(6)
                }
            }
            .padding(.horizontal)
            Spacer()
        }
        .frame(width: 300, height: 260)
        .background(Color(red: 0.08, green: 0.10, blue: 0.13))
        .preferredColorScheme(.dark)
    }
}
