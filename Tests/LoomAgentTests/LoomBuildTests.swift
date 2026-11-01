import Foundation
import XCTest
@testable import LoomAgent

/// The kit compiled and run as apps would: written into a package of five apps (a Lemmy-like one in Swift 6, a
/// Mastodon-like one in Swift 5, the least call in both, and a kit made by two calls), built with `swift build` for
/// the Mac and with `xcodebuild` for the iPhone simulator, then every screen made from each app's own values and
/// drawn offscreen.
/// Gated (`LOOM_BUILD=1`): the builds take a few minutes.
final class LoomBuildTests: XCTestCase {
    private struct App {
        let name: String
        let mode: String
        let models: String
        let samples: String
        let check: String
        let input: LoomAgent.Input
    }

    func testTheKitBuildsForMacAndIPhoneInBothLanguageModesAndEveryScreenDraws() throws {
        try XCTSkipUnless(ProcessInfo.processInfo.environment["LOOM_BUILD"] == "1", "set LOOM_BUILD=1 to build the output")
        let package = try Fixture.folder()
        let least = LoomAgent.Input(mappings: SocialApps.lemmyLines, style: .reader, colors: .assets, features: [],
                                    screens: [.feed, .post, .thread, .profile], prefix: "Kit")
        let apps = [
            App(name: "Lemmy", mode: ".v6", models: SocialApps.lemmyModels, samples: SocialApps.lemmySamples,
                check: SocialApps.lemmyCheck, input: .init(mappings: SocialApps.lemmyLines)),
            App(name: "Mastodon", mode: ".v5", models: SocialApps.mastodonModels, samples: SocialApps.mastodonSamples,
                check: SocialApps.mastodonCheck, input: .init(mappings: SocialApps.mastodonLines, style: .social)),
            App(name: "Least", mode: ".v6", models: SocialApps.lemmyModels, samples: SocialApps.lemmySamples,
                check: SocialApps.leastCheck, input: least),
            App(name: "LeastFive", mode: ".v5", models: SocialApps.lemmyModels, samples: SocialApps.lemmySamples,
                check: SocialApps.leastCheck, input: least),
        ]
        var written = 0
        for app in apps {
            var input = app.input
            input.into = "Sources/\(app.name)/Social"
            input.directory = package.path
            written += try LoomAgent.write(input, note: { _ in }, yield: { _ in }).paths.count
            let sources = package.appendingPathComponent("Sources/\(app.name)")
            try app.models.write(to: sources.appendingPathComponent("Models.swift"), atomically: true, encoding: .utf8)
            try app.samples.write(to: sources.appendingPathComponent("Samples.swift"), atomically: true, encoding: .utf8)
            try app.check.replacingOccurrences(of: "__APP__", with: app.name)
                .write(to: sources.appendingPathComponent("\(app.name)Check.swift"), atomically: true, encoding: .utf8)
        }
        // A kit made by two calls into one folder: the second adds screens and features to the first.
        for call in [LoomAgent.Input(mappings: SocialApps.lemmyLines, features: [.vote, .reply], screens: [.thread, .compose]),
                     LoomAgent.Input(features: [.save], screens: [.search])] {
            var input = call
            input.into = "Sources/Later/Social"
            input.directory = package.path
            written += try LoomAgent.write(input, note: { _ in }, yield: { _ in }).paths.count
        }
        try SocialApps.lemmyModels.write(to: package.appendingPathComponent("Sources/Later/Models.swift"), atomically: true, encoding: .utf8)
        XCTAssertGreaterThan(written, 150)

        let targets = apps.map { #".target(name: "\#($0.name)", swiftSettings: [.swiftLanguageMode(\#($0.mode))])"# }
            + [#".target(name: "Later", swiftSettings: [.swiftLanguageMode(.v6)])"#]
        try """
        // swift-tools-version:6.0
        import PackageDescription
        let package = Package(
            name: "SocialApps",
            platforms: [.iOS(.v17), .macOS(.v14)],
            products: [.library(name: "SocialApps", targets: [\((apps.map(\.name) + ["Later"]).map { "\"\($0)\"" }.joined(separator: ", "))])],
            targets: [
                \(targets.joined(separator: ",\n        ")),
                .executableTarget(name: "Check", dependencies: [\(apps.map { "\"\($0.name)\"" }.joined(separator: ", "))],
                                  swiftSettings: [.swiftLanguageMode(.v6)]),
            ]
        )
        """.write(to: package.appendingPathComponent("Package.swift"), atomically: true, encoding: .utf8)
        let check = package.appendingPathComponent("Sources/Check")
        try FileManager.default.createDirectory(at: check, withIntermediateDirectories: true)
        try """
        import Foundation
        import Lemmy
        import Mastodon
        import Least
        import LeastFive

        let results = MainActor.assumeIsolated {
            [LemmyCheck.run(into: nil), MastodonCheck.run(into: nil), LeastCheck.run(), LeastFiveCheck.run()]
        }
        let failed = results.flatMap(\\.failed)
        print("drew \\(results.flatMap(\\.drawn).count) screens")
        if !failed.isEmpty {
            print("did not draw: \\(failed)")
            exit(1)
        }
        """.write(to: check.appendingPathComponent("main.swift"), atomically: true, encoding: .utf8)

        // The Mac: every target, Swift 6 and Swift 5, with no warning in what the kit wrote.
        let mac = try run(["swift", "build", "--package-path", package.path])
        XCTAssertEqual(mac.status, 0, mac.log)
        let warnings = mac.log.split(separator: "\n").filter { $0.contains("/Social/") && $0.contains("warning:") }
        XCTAssertTrue(warnings.isEmpty, warnings.joined(separator: "\n"))

        // Every screen made from each app's own values and drawn: nothing traps.
        let drawn = try run(["swift", "run", "--package-path", package.path, "Check"])
        XCTAssertEqual(drawn.status, 0, drawn.log)
        XCTAssertNotNil(drawn.log.range(of: #"drew \d{2,} screens"#, options: .regularExpression), drawn.log)

        // The iPhone simulator.
        let phone = try run(["xcodebuild", "-scheme", "SocialApps", "-destination", "generic/platform=iOS Simulator",
                             "-derivedDataPath", package.appendingPathComponent("dd").path,
                             "-skipPackagePluginValidation", "-skipMacroValidation", "build"], in: package)
        XCTAssertTrue(phone.log.contains("** BUILD SUCCEEDED **"), String(phone.log.suffix(4_000)))
    }

    private func run(_ arguments: [String], in folder: URL? = nil) throws -> (status: Int32, log: String) {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        process.arguments = arguments
        if let folder { process.currentDirectoryURL = folder }
        let out = Pipe()
        process.standardOutput = out
        process.standardError = out
        try process.run()
        let data = out.fileHandleForReading.readDataToEndOfFile()
        process.waitUntilExit()
        return (process.terminationStatus, String(decoding: data, as: UTF8.self))
    }
}
