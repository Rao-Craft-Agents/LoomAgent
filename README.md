# LoomAgent

Give a social app its screens without drawing them by hand. Say which of your types are the posts, comments, people
and communities, and `loom` writes the feeds, post pages, threaded comments, profiles, compose and reply, search and
keyword filters that show them, in Loom's look, as a timeline or as compact reader rows. What it writes is plain
SwiftUI that works in any app, with no Granite dependency in it.

## What you can ask

```
$loom the social screens for the cooking app: dishes as posts, notes as comments, cooks and clubs
$loom the feed, post, thread and profile screens over MarginKit's Post, Comment, User and Community
$loom a timeline of the app's Status type with replies and media, its views prefixed Kit
$loom add search and keyword filters to the social screens, with the colours from the asset catalog
```

Craft writes the call from your request, shows it on its agent map as `loom-1`, and builds and tests what it writes
with the turn.

## What you get

- **The screens a social app needs.** A feed, a post's page with its threaded comments, profiles, communities,
  compose and reply with a Markdown toolbar, search, instances, keyword filters, and a post shared as an image.
- **Your own types, shown as they are.** One line a type says which field is the title, the author or the score; the
  views read protocols, and your types are made to conform to them, without a change to the types themselves.
- **Three looks in one kit.** Loom's look, a timeline, or compact rows with thumbnails and scores, switched with
  `.socialStyle(_:)`, in Loom's colours for light and dark, from code or from your asset catalog.
- **Only the parts you ask for.** Votes, saves, sharing, replies, reports, blocks, an NSFW shield, Markdown, link
  previews, media, swipe actions and editing; leave one out and its controls are not written.
- **Views ready to drop in.** They take values and closures, hold no global state and never route, so your app keeps
  its own navigation; a control with no action is not drawn. Every view has a `#Preview`, every user-facing string is
  natural English, and every icon-only control is labelled for VoiceOver.

## How it works

- It reads each line and refuses one it cannot read with the reason and the words the role can map, every bad line
  at once, and writes nothing.
- It writes from templates and asks no model, so the same call makes the same files every time.
- Every file is parsed with `swiftc -parse` before any lands, and they land together. A later call into the same
  folder keeps what is already there and writes the kit again so its shared files agree.
- What it makes is built and tested with the turn.

## Works well with

`loom` writes the social layer; the other Rao Craft Agents fill in the rest. `models` and `network` write the types
it maps, `mocks` the data it shows before the server exists, and `granite` the pages that show its `FeedView`,
`PostPageView` and `ProfileView` and the services that load them.

## Get it

In Craft, install Loom from the Agent Store, or run
`craft agents add https://github.com/Rao-Craft-Agents/LoomAgent.git`, then say `$loom` in a request.

## Requirements

- A Mac on macOS 14 or later, with Xcode.
- The views target iOS 17 and macOS 14 and compile in Swift 5 and Swift 6 language modes. They are plain SwiftUI:
  no Granite, and no package to add.
- MIT licensed.

## For developers

What a call takes and answers, the mapping line and how the views are made are in the
[reference](Docs/Reference.md). The agent standard it follows is [Schema/Loom.md](Schema/Loom.md), and how it is
measured is [TESTING.md](TESTING.md).
