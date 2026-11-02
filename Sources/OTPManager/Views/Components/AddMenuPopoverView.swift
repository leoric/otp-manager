import SwiftUI

struct AddMenuPopoverView: View {
    var onManual: () -> Void
    var onQR: () -> Void
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            Text("Add Account")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
                .padding(.vertical, 12)
            
            Divider().background(Color.gray.opacity(0.3))
            
            Button(action: onManual) {
                Text("Enter Manually")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
            }
            .buttonStyle(.plain)
            
            Divider().background(Color.gray.opacity(0.3))
            
            Button(action: onQR) {
                Text("Import QR Image")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
            }
            .buttonStyle(.plain)
            
            Divider().background(Color.gray.opacity(0.3))
            
            Button(action: { dismiss() }) {
                Text("Cancel")
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
            }
            .buttonStyle(.plain)
        }
        .frame(width: 200)
        .background(Color(red: 0.15, green: 0.18, blue: 0.22))
    }
}