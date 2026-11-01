# LoomAgent

Loom's social-app UI, written into any app as plain SwiftUI and shipped as a
[Granite](https://github.com/riteshpakala/Granite) agent package. A call names the app's own types with one line a
role (`post: Dish title=name author=cook.name score=likes`); the package writes the views a Reddit-, Lemmy- or
Mastodon-like app needs to show and make posts, comments, people and communities, the protocols they read, and the
conformances that make the app's types those protocols. In Loom's look unless the call asks for a timeline or a
reader list.

It is one of the [Rao Craft Agents](https://github.com/Rao-Craft-Agents): independent packages that, tagged in prompts
along the life of a project, build an app of [Loom](https://github.com/riteshpakala/Loom)'s quality. `loom` writes
the social layer: feeds, post cards and pages, threaded comments, profiles, communities, compose and reply, search,
keyword filters, and a post shared as an image.

## How an app finds it

LoomAgent is a `GraniteAgentPackage`, and it carries a record in its binary:

```swift
@used @section("__DATA_CONST,__granite")
let loomRecord: GraniteRoster.Record = { GraniteRoster.record(LoomAgent.self) }
```

In [Craft](https://github.com/riteshpakala/Craft), install it from the Agent Store or with
`craft agents add https://github.com/Rao-Craft-Agents/LoomAgent.git`, then say `$loom` in a request:

```
$loom the social screens for the cooking app: dishes as posts, notes as comments, cooks and clubs
```

The model writes the lines; the call shows on Craft's agent map as `loom-1`, and the files it names are built and
tested with the turn.

## What a call takes and answers

| Field | | |
|---|---|---|
| `into` | optional | the folder, relative to the project; `Shared/Views/Social` when left out |
| `mappings` | optional | one line a role (below) |
| `style` | optional | `loom` (Loom's look, the default), `social` (a timeline) or `reader` (compact rows with thumbnails and scores) |
| `colors` | optional | `code` (dynamic light and dark colours in code, the default) or `assets` (`colors/background`, `colors/foreground`, … from the asset catalog) |
| `features` | optional | the parts to write, every one when left out: `vote`, `save`, `share`, `reply`, `report`, `block`, `nsfwShield`, `markdown`, `linkPreview`, `media`, `swipeActions`, `editing` |
| `screens` | optional | the screens to write, every one when left out: `feed`, `post`, `thread`, `compose`, `reply`, `profile`, `community`, `search`, `instances`, `filter`, `share` |
| `prefix` | optional | a prefix for the view types when the app already has views of these names: `Kit` writes `KitPostCardView`; one prefix a folder |
| `imports` | optional | modules the conformances import: where a mapped type is declared |
| `directory` | the host's | the folder the host works in; a host fills it and does not show it to a model |

The answer is a `LoomResult`: every file written (`path`, `paths`, absolute), the views by name, the conformances, the
schema (`AppSocial`), and a sentence for what the app still has to do.

## The line

```
post: Dish title=name body=notes author=cook.name avatar=cook.photo community=club.name score=likes comments=replyCount created=sharedAt
comment: Note body=text author=cook.name score=likes parent=replyTo created=writtenAt
user: Cook name=handle display=name avatar=photo bio=about joined=since posts=dishCount
community: Club id=slug name=slug title=name icon=badge about=rules subscribers=members
```

A timeline's status is a post and a reply at once, with Swift where a path is not enough:

```
post: Status body=content author=account.displayName avatar=account.avatar media=value.attachments.map(\.url) comments=repliesCount
comment: Status body=content author=account.displayName avatar=account.avatar parent=inReplyToId
```

- A role (`post`, `comment`, `user`, `community`, `instance`), a colon, the type, then one `word=value` a thing the
  views show; spaces or commas between them. A bare path (`cook.name`, `stats?.likes`) is read off the value;
  anything else is Swift that may name `value`. A word left out takes the protocol's default.
- A value goes through `SocialValue`, so a date may be a `Date` or an ISO 8601 string (Lemmy's zone-less ones too), a
  link a `URL` or a string, a count any integer, a vote an `Int` or a liked flag.
- `id=` only when the type has no `id` of its own. One type may take two roles (a status is a post and a reply); what
  both protocols ask for is written once.
- A line it cannot read is refused with the reason and the words the role can map, every bad line at once, and
  nothing is written.

## How the views are made

| Step | What |
|---|---|
| Read | every line parsed into a role and its properties; a refused line names its reason |
| Plan | the screens asked for, every part they use, and only the features asked for (no vote buttons without `vote`) |
| Write | the views from templates that are Swift as written, their conditional blocks dropped and their names prefixed; `SocialProtocols.swift` from the role table; one conformance a line in `Conformances/`, and `AppSocial`, the schema the views are generic over |
| Use | the views take values and closures (`SocialActions<AppSocial>`), hold no global state and never route; a control whose closure is nil is not drawn |
| Look | three styles in one environment value (`.socialStyle(.reader)`), Loom's spacing layers and its colours for light and dark; every view has a `#Preview` from sample types in `SocialPreviews.swift` |
| Add | a later call into the same folder plans with what is already there (its parts, features, prefix and look) and writes the kit again, so the files every view shares never lose what an earlier view uses; app changes belong in the app's own files |
| Check | every file staged, parsed with `swiftc -parse`, then moved into the project together |

The views are plain SwiftUI for iOS 17 and macOS 14, compile in Swift 5 and Swift 6 language modes, read every
user-facing string as a natural-English literal, and label every icon-only control for VoiceOver. No model is asked:
the same call makes the same files every time.

## Testing

```
swift test                    # the record, the schema, the line, the plan, the templates, a call through the roster
LOOM_BUILD=1 swift test       # four apps built for the Mac and the iPhone simulator, Swift 5 and 6, every screen drawn
```

MIT licensed.
