import Foundation

class StorageManager: ObservableObject {
    @Published var accounts: [OTPAccount] = [] {
        didSet {
            save()
        }
    }
    
    private let key = "SavedOTPAccounts"
    
    init() {
        load()
    }
    
    func load() {
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode([OTPAccount].self, from: data) {
            self.accounts = decoded
        }
    }
    
    func save() {
        if let encoded = try? JSONEncoder().encode(accounts) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }
    
    func add(_ account: OTPAccount) {
        accounts.append(account)
    }
    
    func delete(at offsets: IndexSet) {
        accounts.remove(atOffsets: offsets)
    }
    
    func update(_ account: OTPAccount) {
        if let index = accounts.firstIndex(where: { $0.id == account.id }) {
            accounts[index] = account
        }
    }
}