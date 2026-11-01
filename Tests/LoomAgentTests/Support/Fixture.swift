import Foundation

enum Fixture {
    /// A folder of its own for one test, removed with the process's temporary files.
    static func folder() throws -> URL {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("loom-\(UUID().uuidString.prefix(8))", isDirectory: true)
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }

    /// A cooking community's types, mapped: what the package is held to reading well.
    static let cooking = [
        "post: Dish title=name body=notes author=cook.name avatar=cook.photo community=club.name score=likes comments=replyCount created=sharedAt url=link thumbnail=photo saved=isSaved",
        "comment: Note body=text author=cook.name avatar=cook.photo score=likes parent=replyTo created=writtenAt",
        "user: Cook name=handle display=name avatar=photo bio=about joined=since posts=dishCount",
        "community: Club id=slug name=slug title=name icon=badge about=rules subscribers=members",
    ]

    /// The text of the file `name` among `paths`.
    static func text(_ paths: [String], _ name: String) throws -> String {
        guard let path = paths.first(where: { $0.hasSuffix("/" + name) }) else {
            throw CocoaError(.fileNoSuchFile, userInfo: [NSFilePathErrorKey: name])
        }
        return try String(contentsOfFile: path, encoding: .utf8)
    }
}
