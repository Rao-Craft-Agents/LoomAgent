# craft-agent/1 · loom

Writes a social app's UI as plain SwiftUI in Loom's look (feeds, post cards and pages, threaded comments, profiles, communities, compose, reply, search), made to show the app's own types from one mapping line a type.

loom's copy of Craft's agent standard (`craft-agent/1`, Craft's `Schema/Agent.md`), written by
`craft agents schema loom` from its record. Everything above **Changes** is written again each time; Changes is
loom's own log.

| File | What it holds |
| --- | --- |
| [`loom.input.schema.json`](loom.input.schema.json) | What it takes, as JSON Schema |
| [`loom.answer.schema.json`](loom.answer.schema.json) | What it answers: `granite-answer/1` with its own kinds |
| [`examples/loom.answer.json`](examples/loom.answer.json) | A real answer, from a regime run |

## What it takes

| Field | Required | What it is |
| --- | --- | --- |
| `into` | no | the folder for the views, relative to the project; Shared/Views/Social when left out |
| `mappings` | no | one line a role (post, comment, user, community, instance): `post: Dish title=name author=cook.name avatar=cook.photo score=likes comments=replyCount created=sharedAt`; a bare path is read off the value, anything else is Swift that may name `value` |
| `style` | no | loom (Loom's look, the default), social (a timeline) or reader (compact rows with thumbnails and scores); all three are written, this is the one the views start in |
| `colors` | no | code (colours in code for light and dark, the default) or assets (read colors/background, colors/foreground and the other roles from the asset catalog) |
| `features` | no | the parts to write, every one when left out: vote, save, share, reply, report, block, nsfwShield, markdown, linkPreview, media, swipeActions, editing |
| `screens` | no | the screens to write, every one when left out: feed, post, thread, compose, reply, profile, community, search, instances, filter, share |
| `prefix` | no | a prefix for the view types when the app already has views of these names: `Kit` writes KitPostCardView |
| `imports` | no | modules the conformances import, such as the package a mapped type is declared in |

`directory` is filled by Craft with the project folder. The person's request and the host's model are offered
beside the call, never in it.

## What it makes

| Kind | What | Into | Never |
| --- | --- | --- | --- |
| `view` | the social screens as reusable SwiftUI views (FeedView, PostPageView, CommentThreadView, ProfileView and the parts they are built from); a page shows them with FeedView(…), PostPageView(…), ProfileView(…) | `Shared/Views/Social/*` | routes; never a page, a service, a client or a model type |
| `conformance` | the app's own types made the views' types: one extension a mapping line, and AppSocial naming one type a role | `Shared/Views/Social/Conformances/*` | a change to the app's types themselves |

## What it answers

A `granite-answer/1` answer (Granite's `Schema/GraniteAgent.md` §4.2): `paths`, `made` against `expected` by kind and
name, `problems` for what it could only do in part, `payloads` for files that keep a standard of their own, and its
own keys beside them. Craft measures each call by what it made of what it expected.

## How it refuses

With an `AgentRefusal`: a kind and reasons, each with its fix. `input` and `call` are the call's to correct; `build`,
`device`, `reach`, `model` and `host` what stood in the way; `answer` and `parse` its own bug.

## Changes

Each change made to make this agent more precise, dated, with the regime run that measured it and what it
made of what it was asked before and after (`TESTING.md`). Newest first.

### 2026-11-04 · answer `granite-answer/1`; drop a `?` on a step that is not optional

loom says it makes reusable views (`view`, into Shared/Views/Social) that pages show, and conformances, so Craft's judicator reads FeedView and its parts as the screens asked for. It answers one `view` per view each asked-for screen is built from and one `conformance` per mapping line. A `?` the model wrote on a step that is not optional (`community?.name` when community is `Community`) is dropped with a note; it broke the build in the regime's checks turn. (bcf0c85)

Measured: not yet. Answers before this were pre-standard, so there is no precision to compare; the next regime chain on Margin is the first measure.

### 2026-11-04 · leave out a property written as nothing; refuse a field the property cannot show

In the Margin regime (2026-11-03/04) loom wrote the model's `edited=nil` as `SocialValue.flag(nil)`, which is ambiguous, and `edited=score`, an Int shown as a flag. Neither built, and the model rewrote the views by hand. (ee7ae44)

Measured: not yet. Answers before this were pre-standard, so there is no precision to compare; the next regime chain on Margin is the first measure.
