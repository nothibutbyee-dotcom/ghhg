import SwiftUI

@main
struct FakeStoreApp: App {
    var body: some Scene {
        WindowGroup { RootView() }
    }
}

struct Package: Identifiable {
    let id = UUID()
    let name: String
    let author: String
    let icon: String
    let info: String
}

let packages = [
    Package(name: "Rainbow Dock", author: "demo dev", icon: "paintpalette.fill", info: "Pretends to color your dock."),
    Package(name: "Banana Mode", author: "demo dev", icon: "moon.stars.fill", info: "Pretends to turn everything banana."),
    Package(name: "Turbo Battery", author: "demo dev", icon: "bolt.fill", info: "Does absolutely nothing, very fast.")
]

final class Store: ObservableObject {
    @Published var installed: Set<UUID> = []
}

struct RootView: View {
    @StateObject private var store = Store()

    var body: some View {
        TabView {
            PackageList(title: "Packages", onlyInstalled: false)
                .tabItem { Label("Packages", systemImage: "shippingbox") }
            PackageList(title: "Installed", onlyInstalled: true)
                .tabItem { Label("Installed", systemImage: "checkmark.circle") }
        }
        .environmentObject(store)
    }
}

struct PackageList: View {
    @EnvironmentObject var store: Store
    let title: String
    let onlyInstalled: Bool
    @State private var search = ""

    var shown: [Package] {
        packages.filter {
            (!onlyInstalled || store.installed.contains($0.id)) &&
            (search.isEmpty || $0.name.localizedCaseInsensitiveContains(search))
        }
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(shown) { pkg in
                        NavigationLink {
                            Detail(pkg: pkg)
                        } label: {
                            Label(pkg.name, systemImage: pkg.icon)
                        }
                    }
                } footer: {
                    Text("Demo app. Nothing is really installed.")
                }
            }
            .navigationTitle(title)
            .searchable(text: $search)
        }
    }
}

struct Detail: View {
    @EnvironmentObject var store: Store
    let pkg: Package
    @State private var progress = 0.0
    @State private var busy = false

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: pkg.icon).font(.system(size: 70))
            Text(pkg.name).font(.title.bold())
            Text("by \(pkg.author)").foregroundStyle(.secondary)
            Text(pkg.info)
            if busy {
                ProgressView(value: progress)
                Text("Pretend installing...")
            } else if store.installed.contains(pkg.id) {
                Button("Remove", role: .destructive) { store.installed.remove(pkg.id) }
                    .buttonStyle(.bordered)
            } else {
                Button("Fake Install") { Task { await install() } }
                    .buttonStyle(.borderedProminent)
            }
            Text("Demo app. Nothing is really installed.")
                .font(.footnote).foregroundStyle(.secondary)
        }
        .padding()
    }

    @MainActor
    func install() async {
        busy = true
        for step in 1...20 {
            try? await Task.sleep(nanoseconds: 100_000_000)
            progress = Double(step) / 20
        }
        store.installed.insert(pkg.id)
        busy = false
        progress = 0
    }
}
