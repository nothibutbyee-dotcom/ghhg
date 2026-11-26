
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

struct TerminalView: View {
    @State private var command = ""
    @State private var cwd = "/var/root"
    @State private var output: [String] = [
        "NewTerm 3",
        "Last login: today",
        "Type 'help' for available commands.",
        ""
    ]

    @State private var history: [String] = []

    @State private var files: [String: String] = [
        "/var/root/.zshrc": "# NewTerm shell configuration",
        "/var/root/README.txt": "Welcome to your iPhone."
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

    private let green = Color(red: 0.35, green: 1, blue: 0.55)
    private let background = Color(red: 0.025, green: 0.035, blue: 0.04)

    var body: some View {
        VStack(spacing: 0) {

            // Terminal header
            HStack {
                Circle()
                    .fill(.red)
                    .frame(width: 11, height: 11)

                Circle()
                    .fill(.yellow)
                    .frame(width: 11, height: 11)

                Circle()
                    .fill(.green)
                    .frame(width: 11, height: 11)

                Spacer()

                Text("NewTerm 3")
                    .foregroundColor(.white)
                    .font(.system(size: 14, weight: .bold))

                Spacer()

                Image(systemName: "terminal")
                    .foregroundColor(green)
            }
            .padding()
            .background(Color.black)

            Divider()
                .overlay(green.opacity(0.3))

            // Terminal output
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 5) {
                        ForEach(Array(output.enumerated()), id: \.offset) { index, line in
                            Text(line.isEmpty ? " " : line)
                                .font(.system(size: 13, design: .monospaced))
                                .foregroundColor(line.hasPrefix("root@") ? green : .white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .textSelection(.enabled)
                                .id(index)
                        }

                        Color.clear
                            .frame(height: 1)
                            .id("BOTTOM")
                    }
                    .padding(12)
                }
                .onChange(of: output.count) { _ in
                    withAnimation {
                        proxy.scrollTo("BOTTOM", anchor: .bottom)
                    }
                }
            }

            Divider()
                .overlay(green.opacity(0.3))

            // Input prompt
            HStack(spacing: 7) {
                Text("root@iPhone")
                    .foregroundColor(green)

                Text(":")
                    .foregroundColor(.white)

                Text(shortPath)
                    .foregroundColor(.cyan)

                Text("#")
                    .foregroundColor(green)

                TextField("", text: $command, onCommit: runCommand)
                    .font(.system(size: 14, design: .monospaced))
                    .foregroundColor(.white)
                    .tint(green)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .submitLabel(.send)
            }
            .padding(13)
            .background(Color.black)
        }
        .background(background)
        .preferredColorScheme(.dark)
    }

    private var shortPath: String {
        cwd == "/var/root" ? "~" : cwd
    }

    private func printLine(_ text: String) {
        output.append(contentsOf: text.components(separatedBy: "\n"))
    }

    private func runCommand() {
        let raw = command.trimmingCharacters(in: .whitespaces)
        guard !raw.isEmpty else { return }

        output.append("root@iPhone:\(shortPath) # \(raw)")
        history.append(raw)

        let parts = raw.split(separator: " ").map(String.init)
        let cmd = parts.first ?? ""
        let args = Array(parts.dropFirst())

        switch cmd {

        case "help":
            printLine("""
            Available commands:

            SYSTEM
              whoami       Current user
              id           User information
              uname        System information
              hostname     Device hostname
              fastfetch    System summary
              uptime       System uptime
              date         Current date

            FILESYSTEM
              pwd          Current directory
              ls           List files
              cd           Change directory
              cat          Read a file
              echo         Print text
              touch        Create a file
              mkdir        Create directory
              rm           Remove virtual file
              clear        Clear terminal

            UTILITIES
              history      Command history
              ps           Process list
              df           Disk information
              free         Memory information
              which        Find command
              apt          Package manager
              dpkg         Package information
              neofetch     System summary

            """.trimmingCharacters(in: .newlines))

        case "whoami":
            printLine("root")

        case "id":
            printLine("uid=0(root) gid=0(wheel) groups=0(wheel),80(admin)")

        case "hostname":
            printLine("iPhone")

        case "uname":
            printLine("Darwin iPhone \(UIDevice.current.systemVersion) Darwin Kernel Version")

        case "pwd":
            printLine(cwd)

        case "date":
            printLine(Date().formatted(date: .complete, time: .standard))

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
                let children = directories.filter {
                    parentPath($0) == path && $0 != path
                }.map {
                    URL(fileURLWithPath: $0).lastPathComponent + "/"
                }

                let fileChildren = files.keys.filter {
                    parentPath($0) == path
                }.map {
                    URL(fileURLWithPath: $0).lastPathComponent
                }

                printLine((children + fileChildren).sorted().joined(separator: "  "))
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
            printLine(files[path] ?? "cat: \(name): No such file")

        case "echo":
            printLine(args.joined(separator: " "))

        case "touch":
            guard let name = args.first else {
                printLine("Usage: touch filename")
                break
            }

            let path = resolvePath(name)
            files[path] = files[path] ?? ""
            printLine("")

        case "mkdir":
            guard let name = args.first else {
                printLine("Usage: mkdir directory")
                break
            }

            directories.insert(resolvePath(name))
            printLine("")

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
            printLine("Desired=Unknown/Install/Remove/Purge")
            printLine("Package database: 12 simulated packages")

        case "sudo":
            printLine("You are already root.")

        case "exit":
            printLine("logout")

        case "":
            break

        default:
            printLine("zsh: command not found: \(cmd)")
        }

        command = ""
    }

    private func resolvePath(_ path: String) -> String {
        let base: String

        if path.hasPrefix("/") {
            base = path
        } else {
            base = cwd + "/" + path
        }

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
        let url = URL(fileURLWithPath: path)
        let parent = url.deletingLastPathComponent().path
        return parent.isEmpty ? "/" : parent
    }

    private func showFastfetch() {
        printLine("""
         _   _                 _
        | \\ | | _____      __ | |___
        |  \\| |/ _ \\ \\ /\\ / / | / __|
        | |\\  |  __/\\ V  V /  | \\__ \\
        |_| \\_|\\___| \\_/\\_/   |_|___/

        root@iPhone
        -------------------------
        Device:     \(UIDevice.current.model)
        OS:         iOS \(UIDevice.current.systemVersion)
        Shell:      zsh
        User:       root
        UID:        0
        Hostname:   iPhone
        Terminal:   NewTerm 3
        Packages:   12
        Filesystem: APFS
        Architecture: arm64
        -------------------------
        """)
    }
}
