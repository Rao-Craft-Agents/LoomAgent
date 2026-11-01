//  WHAT: Loom's social-app UI as a Granite agent package. A call names the app's types with one mapping line a
//        role (`post: Dish title=name author=cook.name score=likes`) and the screens and parts it wants; the run
//        writes plain SwiftUI views into the folder the call names (feeds, post cards and pages, threaded
//        comments, profiles, communities, compose, reply, search, filters, share as image), the protocols they
//        read, the conformances that make the app's types those protocols, and answers where.
//  IN:   Input: the folder, the mapping lines, the look and where its colours come from, the features and screens,
//        a prefix for view names, the modules a mapped type lives in.
//  OUT:  LoomResult: the files written, the views, the conformances, the schema, and what the app still has to do.
//  PIN:  NO MODEL. Every file is made from the call, the same way every time; a line that is not understood is
//        refused with its reason, and nothing is written until every problem is fixed and every file parses.
//  PIN:  THE VIEWS NEVER ROUTE. They take values and closures (`SocialActions`) and hold no global state, so the app's
//        services, navigation and modals stay the app's; a control whose closure is nil is not drawn.

import Foundation
import GraniteAgents

public struct LoomAgent: GraniteAgentPackage {
    public struct Input: Codable, Sendable {
        /// The folder the views go in, relative to the project; `Shared/Views/Social` when left out.
        public var into: String?
        /// One line a role: `post: Dish title=name body=notes author=cook.name avatar=cook.photo score=likes`.
        public var mappings: [String]?
        /// The look the views start in; `loom` when left out.
        public var style: LoomStyle?
        /// Where the colours come from; `code` when left out.
        public var colors: LoomColors?
        /// The parts to write; every one when left out.
        public var features: [LoomFeature]?
        /// The screens to write; every one when left out.
        public var screens: [LoomScreen]?
        /// A prefix for the view types, when the app already has names that clash: `Kit` writes `KitPostCardView`.
        public var prefix: String?
        /// Modules the conformances import: where a mapped type lives.
        public var imports: [String]?
        /// The host's folder.
        public var directory: String?

        public init(into: String? = nil, mappings: [String]? = nil, style: LoomStyle? = nil, colors: LoomColors? = nil,
                    features: [LoomFeature]? = nil, screens: [LoomScreen]? = nil, prefix: String? = nil,
                    imports: [String]? = nil, directory: String? = nil) {
            self.into = into; self.mappings = mappings; self.style = style; self.colors = colors; self.features = features
            self.screens = screens; self.prefix = prefix; self.imports = imports; self.directory = directory
        }
    }

    public typealias Event = LoomFrame
    public typealias Output = LoomResult
    public typealias Compute = Void

    public static let word = "loom"
    public static let summary = "writes a social app's UI as plain SwiftUI in Loom's look (feeds, post cards and pages, threaded comments, profiles, communities, compose, reply, search), made to show the app's own types from one mapping line a type."
    public static let fields = [
        "into": "the folder for the views, relative to the project; Shared/Views/Social when left out",
        "mappings": "one line a role (post, comment, user, community, instance): `post: Dish title=name author=cook.name avatar=cook.photo score=likes comments=replyCount created=sharedAt`; a bare path is read off the value, anything else is Swift that may name `value`",
        "style": "loom (Loom's look, the default), social (a timeline) or reader (compact rows with thumbnails and scores); all three are written, this is the one the views start in",
        "colors": "code (colours in code for light and dark, the default) or assets (read colors/background, colors/foreground and the other roles from the asset catalog)",
        "features": "the parts to write, every one when left out: vote, save, share, reply, report, block, nsfwShield, markdown, linkPreview, media, swipeActions, editing",
        "screens": "the screens to write, every one when left out: feed, post, thread, compose, reply, profile, community, search, instances, filter, share",
        "prefix": "a prefix for the view types when the app already has views of these names: `Kit` writes KitPostCardView",
        "imports": "modules the conformances import, such as the package a mapped type is declared in",
    ]
    public static let guide = """
        Tag loom for a social app's screens: a feed of posts, a post's page with its threaded comments, profiles, \
        communities, compose and reply with a Markdown toolbar, search, keyword filters, a post shared as an image. It \
        writes plain SwiftUI (iOS 17 and macOS 14) into `into` (Shared/Views/Social), in Loom's look unless `style` \
        says `social` (a timeline) or `reader` (compact rows); all three are written and the app may switch with \
        `.socialStyle(_:)`. The views read five protocols, and `mappings` make the app's types conform, one line a \
        role: `role: Type word=value …`. Roles and their words: post (title, body, author, handle, avatar, community, \
        communityIcon, created, edited, score, upvotes, downvotes, vote, comments, url, linkTitle, thumbnail, media, \
        nsfw, saved, pinned, locked, removed, deleted, bot, admin, mine, permalink, source); comment (body, author, \
        handle, avatar, created, edited, score, upvotes, downvotes, vote, replies, depth, parent, op, post, community, \
        saved, removed, deleted, bot, admin, mine, permalink); user (name, display, handle, avatar, banner, bio, \
        joined, posts, comments, score, postScore, commentScore, followers, following, bot, admin, blocked, mine, \
        permalink); community (name, title, handle, icon, banner, about, subscribers, posts, comments, activeDay, \
        activeWeek, activeMonth, subscribed, nsfw, blocked, permalink); instance (name, domain, icon, banner, about, \
        users, posts, version, latency, connected, favorite, source, created). A bare path is read off the value \
        (`author=cook.name`, `score=stats?.likes`); anything else is Swift that may name `value` \
        (`title=value.name ?? "Untitled"`). A date may be a Date or an ISO string, a link a URL or a string, a count \
        any integer. Say `id=` only when the type has no `id` of its own; a type from a package needs `imports`. A \
        word left out takes a default, so map what the type has. The views are generic over the schema the call \
        writes, `AppSocial`, and never route: they call `SocialActions<AppSocial>` closures (vote, save, share, \
        reply, report, block, openPost, openUser, openCommunity, openLink, loadMore, refresh, submit, search), and \
        a control whose closure is nil is not drawn. Use them as `FeedView(title: Text("Home"), posts: posts, \
        phase: phase, actions: actions)`, `PostPageView(post:comments:phase:actions:)`, \
        `ComposeView(communities:actions:)`, `ProfileView(user:posts:comments:actions:)`. Every view has a #Preview. \
        A later call into the same folder adds to the kit there: what it already holds stays (its parts, features, \
        prefix and look), and its files are written again so they agree, so keep the app's changes in its own files. \
        Examples. The whole kit for a cooking community: \
        {"mappings": ["post: Dish title=name body=notes author=cook.name avatar=cook.photo community=club.name \
        score=likes comments=replyCount created=sharedAt url=link thumbnail=photo saved=isSaved", "comment: Note \
        body=text author=cook.name avatar=cook.photo score=likes parent=replyTo created=writtenAt", "user: Cook \
        name=handle display=name avatar=photo bio=about joined=since posts=dishCount", "community: Club \
        name=slug title=name icon=badge about=rules subscribers=members"]}. \
        A timeline with no communities, beside the app's own views of these names, starting in its look, writing \
        less: {"mappings": ["post: Status body=content author=account.displayName handle=account.acct \
        avatar=account.avatar score=favouritesCount comments=repliesCount created=createdAt \
        media=value.attachments.map(\\.url)"], "style": "social", "prefix": "Kit", "screens": ["feed", "post", \
        "thread", "profile", "reply"], "features": ["vote", "share", "reply", "markdown", "media"]}. \
        Later, two more screens into the same folder, with the colours from the asset catalog: {"screens": \
        ["search", "filter"], "colors": "assets"}. \
        A line it cannot read is refused with the reason and nothing is written: fix the line and call again. Not for \
        the app's services, its network client or its model types.
        """

    public static func output(from events: [LoomFrame]) -> LoomResult? { events.compactMap(\.result).last }

    public init() {}

    public func run(_ input: Input, context: Context) -> AsyncThrowingStream<LoomFrame, Error> {
        // The folder is the call's, else the host's (a host over the wire may give it only there), else the
        // process's: never the runner's working folder while the host named one.
        var resolved = input
        if resolved.directory == nil { resolved.directory = context.host.directory }
        let call = resolved
        return AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    let result = try Self.write(call, note: context.host.note) { continuation.yield($0) }
                    continuation.yield(.written(result))
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }

    /// The whole call: the lines read, the kit planned and made, staged, checked and written.
    static func write(_ input: Input, note: @Sendable (String) -> Void, yield: (LoomFrame) -> Void) throws -> LoomResult {
        var problems: [String] = []
        var mappings: [Mapping] = []
        for line in input.mappings ?? [] where !line.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            do { mappings.append(try MappingLine.parse(line)) } catch { problems.append("\(error)") }
        }
        var roles: Set<SocialRole> = []
        for mapping in mappings where !roles.insert(mapping.role).inserted {
            problems.append("\(mapping.role.rawValue) is mapped twice: one type a role, so unify several APIs' types into one first")
        }
        let imports = (input.imports ?? []).map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
        let conformanceFiles = ConformanceEmitter.emit(mappings, imports: imports)
        problems += conformanceFiles.problems
        let files = AgentFiles(directory: input.directory)
        let folder = files.resolve(input.into ?? "Shared/Views/Social")
        let conformances = folder.appendingPathComponent("Conformances", isDirectory: true)
        // What an earlier call left here: a later call adds to it, so the shared files keep what its views use.
        let disk = KitOnDisk.read(folder)
        let named = (input.prefix ?? "").trimmingCharacters(in: .whitespaces)
        if !named.isEmpty, !SwiftName.isTypeName(named) {
            problems.append("`\(named)` is not a prefix for type names: UpperCamelCase letters and digits, like `Kit`")
        }
        if input.prefix != nil, let held = disk.prefix, held != named {
            problems.append("\(files.relative(folder)) already holds the views \(held.isEmpty ? "without a prefix" : "prefixed `\(held)`"): leave `prefix` out to add to them, or write into another folder")
        }
        let prefix = input.prefix == nil ? (disk.prefix ?? "") : named
        for module in imports where !SwiftName.isModuleName(module) {
            problems.append("`\(module)` is not a module name")
        }
        guard problems.isEmpty else { throw LoomError.problems(problems) }

        let features = Set(input.features ?? LoomFeature.allCases).union(disk.features)
        var screens: [LoomScreen] = []
        for screen in input.screens ?? LoomScreen.allCases where !screens.contains(screen) { screens.append(screen) }
        let plan = KitPlan(features: features, screens: screens, holding: disk.parts)
        let style = input.style ?? disk.style ?? .loom
        let colors = input.colors ?? disk.colors ?? .code
        let flags = plan.flags.union(["style.\(style.rawValue)", "colors.\(colors.rawValue)"])
        yield(.read(mappings: mappings.count, views: plan.views.count))
        note("writing \(plan.views.count) views for \(screens.count) screen\(screens.count == 1 ? "" : "s") into \(files.relative(folder))")

        var planned: [(url: URL, text: String)] = []
        let views = plan.views
        func prefixed(_ text: String) -> String { TemplateRender.prefixing(text, names: views, prefix: prefix) }
        planned.append((folder.appendingPathComponent("SocialProtocols.swift"), ProtocolsEmitter.emit()))
        for part in plan.parts {
            let text = try TemplateRender.render(part.template, flags: flags)
            let file = (part.isView ? prefix : "") + part.name + ".swift"
            planned.append((folder.appendingPathComponent(file), prefixed(text)))
        }

        var schemaTypes: [SocialRole: String] = [:]
        var schemaImports = imports
        let earlier = ConformanceEmitter.earlier(in: conformances)
        for (role, type) in earlier.types { schemaTypes[role] = type }
        for module in earlier.imports where !schemaImports.contains(module) { schemaImports.append(module) }
        for mapping in mappings { schemaTypes[mapping.role] = mapping.type }
        for file in conformanceFiles.files {
            planned.append((conformances.appendingPathComponent(file.name), file.text))
        }
        var notes: [String] = []
        var schema: String?
        if schemaTypes.isEmpty {
            notes.append("No type is mapped yet: add `mappings` lines (`post: Dish title=name author=cook.name`) and the views show the app's types through `AppSocial`.")
        } else {
            schema = ConformanceEmitter.schemaName
            planned.append((conformances.appendingPathComponent(ConformanceEmitter.schemaName + ".swift"),
                            ConformanceEmitter.schema(schemaTypes, imports: schemaImports)))
            let absent = SocialRole.allCases.filter { schemaTypes[$0] == nil }.map(\.absentType)
            if !absent.isEmpty {
                notes.append("AppSocial uses \(absent.joined(separator: ", ")) for the roles no line maps.")
            }
        }
        let held = Set(disk.parts).subtracting(KitCatalog.core).count
        if held > 0 {
            notes.append("\(files.relative(folder)) already held \(held) parts of the kit: they were written again with this call's, so every shared file agrees; keep the app's own changes in its own files.")
        }
        if colors == .assets {
            notes.append("The colours are read from the asset catalog: colors/background, colors/alternateBackground, colors/secondaryBackground, colors/tertiaryBackground, colors/foreground and colors/secondaryForeground.")
        }

        let written = try files.write(planned)
        note("wrote \(written.count) files")
        return LoomResult(path: written.first, paths: written, views: views.map { prefix + $0 },
                          conformances: mappings.map { "\($0.type): \($0.role.rawValue)" }, schema: schema, notes: notes)
    }
}
