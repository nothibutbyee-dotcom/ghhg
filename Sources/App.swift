
import SwiftUI
import UIKit

@main
struct FakeNewTermApp: App {
    var body: some Scene {
        WindowGroup {
            TerminalView()
        }
    }
}

// MARK: - Main Application

struct TerminalView: View {

    @State private var selectedTab = 0

    @State private var command = ""
    @State private var cwd = "/var/root"

    @State private var output: [String] = [
        "NewTerm 3.0.0",
        "Welcome to your terminal.",
        "Type 'help' to see available commands.",
        ""
    ]

    @State private var history: [String] = []

    @State private var files: [String: String] = [
        "/var/root/.zshrc": "# ZSH configuration",
        "/var/root/README.txt": "Welcome to iPhone."
    ]

    @State private var directories: Set<String> = [
        "/",
        "/var",
        "/var/root",
        "/var/mobile",
        "/var/mobile/Library",
        "/Applications",
        "/System",
        "/usr",
        "/usr/bin",
        "/etc",
        "/tmp"
    ]

    // Appearance settings

    @State private var fontSize: Double = 14
    @State private var fontChoice = "Monospaced"
    @State private var textColorName = "Green"
    @State private var backgroundName = "Black"

    // MARK: Colors

    private var terminalColor: Color {
        switch textColorName {
        case "Green": return .green
        case "White": return .white
        case "Cyan": return .cyan
        case "Red": return .red
        case "Purple": return .purple
        case "Orange": return .orange
        case "Blue": return .blue
        default: return .green
        }
    }

    private var terminalBackground: Color {
        switch backgroundName {
        case "Black": return Color.black
        case "Dark Gray": return Color(white: 0.12)
        case "Navy": return Color(red: 0.02, green: 0.04, blue: 0.15)
        case "Purple": return Color(red: 0.12, green: 0.04, blue: 0.17)
        case "White": return Color.white
        default: return Color.black
        }
    }

    private var terminalTextColor: Color {
        backgroundName == "White" ? .black : .white
    }

    private var fontDesign: Font.Design {
        switch fontChoice {
        case "Rounded": return .rounded
        case "Serif": return .serif
        case "System": return .default
        default: return .monospaced
        }
    }

    private var shortPath: String {
        cwd == "/var/root" ? "~" : cwd
    }

    // MARK: Main Tab Navigation

    var body: some View {
        TabView(selection: $selectedTab) {

            terminalScreen
                .tabItem {
                    Image(systemName: "terminal")
                    Text("Terminal")
                }
                .tag(0)

            settingsScreen
                .tabItem {
                    Image(systemName: "slider.horizontal.3")
                    Text("Settings")
                }
                .tag(1)
        }
        .tint(terminalColor)
        .preferredColorScheme(.dark)
    }

    // MARK: Terminal Screen

    private var terminalScreen: some View {
        VStack(spacing: 0) {

            // Header

            HStack {
                HStack(spacing: 7) {
                    Circle().fill(.red)
                        .frame(width: 11, height: 11)

                    Circle().fill(.yellow)
                        .frame(width: 11, height: 11)

                    Circle().fill(.green)
                        .frame(width: 11, height: 11)
                }

                Spacer()

                Text("NewTerm 3")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(terminalTextColor)

                Spacer()

                Image(systemName: "terminal")
                    .foregroundColor(terminalColor)
            }
            .padding()
            .background(terminalBackground)

            Rectangle()
                .fill(terminalColor.opacity(0.35))
                .frame(height: 1)

            // Output

            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 5) {

                        ForEach(
                            Array(output.enumerated()),
                            id: \.offset
                        ) { index, line in

                            Text(line.isEmpty ? " " : line)
                                .font(.system(
                                    size: fontSize,
                                    weight: .medium,
                                    design: fontDesign
                                ))
                                .foregroundColor(
                                    line.hasPrefix("root@iPhone:")
                                    ? terminalColor
                                    : terminalTextColor
                                )
                                .frame(
                                    maxWidth: .infinity,
                                    alignment: .leading
                                )
                                .textSelection(.enabled)
                                .id(index)
                        }

                        Color.clear
                            .frame(height: 1)
                            .id("BOTTOM")
                    }
                    .padding(12)
                }
                .background(terminalBackground)
                .onChange(of: output.count) { _ in
                    withAnimation {
                        proxy.scrollTo("BOTTOM", anchor: .bottom)
                    }
                }
            }

            // Input

            Rectangle()
                .fill(terminalColor.opacity(0.35))
                .frame(height: 1)

            HStack(spacing: 5) {

                Text("root@iPhone")
                    .foregroundColor(terminalColor)

                Text(":")
                    .foregroundColor(terminalTextColor)

                Text(shortPath)
                    .foregroundColor(.cyan)
                    .lineLimit(1)

                Text("#")
                    .foregroundColor(terminalColor)

                TextField("", text: $command)
                    .font(.system(
                        size: fontSize,
                        design: fontDesign
                    ))
                    .foregroundColor(terminalTextColor)
                    .tint(terminalColor)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .submitLabel(.send)
                    .onSubmit {
                        runCommand()
                    }
            }
            .padding(12)
            .background(terminalBackground)
        }
        .background(terminalBackground)
    }

    // MARK: Settings Screen

    private var settingsScreen: some View {
        NavigationView {
            Form {

                // Font settings

                Section(header: Text("FONT SETTINGS")) {

                    VStack(alignment: .leading, spacing: 12) {

                        HStack {
                            Text("Font size")

                            Spacer()

                            Text("\(Int(fontSize)) pt")
                                .foregroundColor(.secondary)
                        }

                        Slider(
                            value: $fontSize,
                            in: 9...26,
                            step: 1
                        )
                        .tint(terminalColor)
                    }
                    .padding(.vertical, 5)

                    Picker("Font style", selection: $fontChoice) {
                        Text("Monospaced").tag("Monospaced")
                        Text("Rounded").tag("Rounded")
                        Text("Serif").tag("Serif")
                        Text("System").tag("System")
                    }
                }

                // Color settings

                Section(header: Text("TERMINAL COLORS")) {

                    Picker("Text color", selection: $textColorName) {
                        Text("Green").tag("Green")
                        Text("White").tag("White")
                        Text("Cyan").tag("Cyan")
                        Text("Red").tag("Red")
                        Text("Purple").tag("Purple")
                        Text("Orange").tag("Orange")
                        Text("Blue").tag("Blue")
                    }

                    Picker("Background", selection: $backgroundName) {
                        Text("Black").tag("Black")
                        Text("Dark Gray").tag("Dark Gray")
                        Text("Navy").tag("Navy")
                        Text("Purple").tag("Purple")
                        Text("White").tag("White")
                    }
                }

                // Live preview

                Section(header: Text("LIVE PREVIEW")) {

                    VStack(alignment: .leading, spacing: 9) {

                        Text("root@iPhone:~# whoami")

                        Text("root")

                        Text("root@iPhone:~# fastfetch")

                        Text("Device: iPhone")
                        Text("Shell: zsh")
                        Text("User: root")
                        Text("Terminal: NewTerm 3")
                    }
                    .font(.system(
                        size: fontSize,
                        weight: .medium,
                        design: fontDesign
                    ))
                    .foregroundColor(terminalColor)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(14)
                    .background(terminalBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                // Reset

                Section(header: Text("OTHER")) {

                    Button(role: .destructive) {
                        fontSize = 14
                        fontChoice = "Monospaced"
                        textColorName = "Green"
                        backgroundName = "Black"
                    } label: {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                            Text("Reset Appearance")
                        }
                    }

                    HStack {
                        Text("Application")
                        Spacer()
                        Text("NewTerm 3")
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("Version")
                        Spacer()
                        Text("3.0.0")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }

    // MARK: Terminal Helpers

    private func printLine(_ text: String) {
        output.append(
            contentsOf: text.components(separatedBy: "\n")
        )
    }

    private func resolvePath(_ path: String) -> String {

        let base = path.hasPrefix("/")
            ? path
            : cwd + "/" + path

        var components: [String] = []

        for component in base.split(separator: "/") {

            switch component {
            case ".":
                continue

            case "..":
                if !components.isEmpty {
                    components.removeLast()
                }

            default:
                components.append(String(component))
            }
        }

        return "/" + components.joined(separator: "/")
    }

    private func parentPath(_ path: String) -> String {
        URL(fileURLWithPath: path)
            .deletingLastPathComponent()
            .path
    }

    // MARK: Command Engine

    private func runCommand() {

        let raw = command.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !raw.isEmpty else { return }

        output.append(
            "root@iPhone:\(shortPath) # \(raw)"
        )

        history.append(raw)

        let parts = raw.split(separator: " ").map(String.init)

        guard let cmd = parts.first else {
            command = ""
            return
        }

        let args = Array(parts.dropFirst())

        switch cmd {

        case "help":

            printLine("""
            NewTerm 3 Commands
            ----------------------------

            SYSTEM
            whoami       Current username
            id           User information
            uname        System information
            hostname     Device hostname
            fastfetch    System summary
            neofetch     System summary
            date         Current date
            uptime       System uptime

            FILESYSTEM
            pwd          Current directory
            ls           List files
            cd           Change directory
            cat          Read file
            echo         Print text
            touch        Create virtual file
            mkdir        Create directory
            rm           Remove virtual file

            UTILITIES
            clear        Clear terminal
            history      Command history
            ps           Process list
            df           Disk information
            free         Memory information
            which        Find command
            apt          Package manager
            dpkg         Package information
            sudo         Privilege simulation

            ----------------------------
            """)

        case "whoami":
            printLine("root")

        case "id":
            printLine(
                "uid=0(root) gid=0(wheel) groups=0(wheel),80(admin)"
            )

        case "hostname":
            printLine("iPhone")

        case "uname":
            printLine(
                "Darwin iPhone \(UIDevice.current.systemVersion) arm64"
            )

        case "pwd":
            printLine(cwd)

        case "date":
            printLine(
                Date().formatted(
                    date: .complete,
                    time: .standard
                )
            )

        case "uptime":
            printLine("up 3 days, 4 hours, 22 minutes")

        case "clear":
            output.removeAll()

        case "fastfetch", "neofetch":
            showFastfetch()

        case "ls":

            let target = args.first ?? cwd
            let path = resolvePath(target)

            if directories.contains(path) {

                let folders = directories
                    .filter {
                        parentPath($0) == path && $0 != path
                    }
                    .map {
                        URL(fileURLWithPath: $0).lastPathComponent + "/"
                    }

                let fileList = files.keys
                    .filter {
                        parentPath($0) == path
                    }
                    .map {
                        URL(fileURLWithPath: $0).lastPathComponent
                    }

                printLine(
                    (folders + fileList).sorted().joined(separator: "  ")
                )

            } else {
                printLine("ls: \(target): No such directory")
            }

        case "cd":

            let target = args.first ?? "/var/root"
            let path = resolvePath(target)

            if directories.contains(path) {
                cwd = path
            } else {
                printLine("cd: no such directory: \(target)")
            }

        case "cat":

            guard let name = args.first else {
                printLine("Usage: cat filename")
                break
            }

            let path = resolvePath(name)

            if let contents = files[path] {
                printLine(contents)
            } else {
                printLine("cat: \(name): No such file")
            }

        case "echo":
            printLine(args.joined(separator: " "))

        case "touch":

            guard let name = args.first else {
                printLine("Usage: touch filename")
                break
            }

            let path = resolvePath(name)

            if directories.contains(parentPath(path)) {
                files[path] = files[path] ?? ""
            } else {
                printLine("touch: directory does not exist")
            }

        case "mkdir":

            guard let name = args.first else {
                printLine("Usage: mkdir directory")
                break
            }

            let path = resolvePath(name)

            if directories.contains(parentPath(path)) {
                directories.insert(path)
            } else {
                printLine("mkdir: parent directory does not exist")
            }

        case "rm":

            guard let name = args.first else {
                printLine("Usage: rm filename")
                break
            }

            let path = resolvePath(name)

            if files.removeValue(forKey: path) != nil {
                printLine("")
            } else {
                printLine("rm: cannot remove '\(name)': No such file")
            }

        case "history":

            for (index, item) in history.enumerated() {
                printLine("\(index + 1)  \(item)")
            }

        case "ps":

            printLine("""
              PID TTY           TIME CMD
                1 ??         0:00.01 launchd
              102 ??         0:00.04 SpringBoard
              204 ttys000    0:00.02 zsh
              205 ttys000    0:00.01 NewTerm
            """)

        case "df":

            printLine("""
            Filesystem       Size    Used   Avail
            /dev/disk1       128G     42G     86G
            /dev/disk2        32G      8G     24G
            """)

        case "free":

            printLine("""
            Memory information:
            Total:  6.0 GB
            Used:   2.8 GB
            Free:   3.2 GB
            """)

        case "which":

            if let name = args.first {
                printLine("/usr/bin/\(name)")
            } else {
                printLine("Usage: which command")
            }

        case "apt":

            if args.first == "update" {

                printLine("""
                Hit:1 http://repo.example stable InRelease
                Reading package lists... Done
                All packages are up to date.
                """)

            } else if args.first == "list" {

                printLine("Installed packages: 12")

            } else {

                printLine("Usage: apt update | apt list")
            }

        case "dpkg":

            printLine("""
            Desired=Unknown/Install/Remove/Purge
            Package database: 12 simulated packages
            """)

        case "sudo":

            printLine("You are already root.")

        case "exit":

            printLine("logout")

        default:

            printLine("zsh: command not found: \(cmd)")
        }

        command = ""
    }

    // MARK: Fastfetch

    private func showFastfetch() {

        printLine("""
         _   _                 _
        | \\ | | _____      __ | |___
        |  \\| |/ _ \\ \\ /\\ / / | / __|
        | |\\  |  __/\\ V  V /  | \\__ \\
        |_| \\_|\\___| \\_/\\_/   |_|___/

        root@iPhone
        -------------------------
        Device:       \(UIDevice.current.model)
        OS:           iOS \(UIDevice.current.systemVersion)
        Shell:        zsh
        User:         root
        UID:          0
        Hostname:     iPhone
        Terminal:     NewTerm 3
        Packages:     12
        Filesystem:   APFS
        Architecture: arm64
        -------------------------
        """)
    }
}
