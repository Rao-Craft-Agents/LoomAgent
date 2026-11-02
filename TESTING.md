# Testing LoomAgent

How `loom` is tested: its own suite, its gated build of real output, and prompts run through
[Craft](https://github.com/riteshpakala/Craft) on a Mac with Craft's own local model, each logged below verbatim with
what came out. A prompt is run as a person would type it, in a project folder, with `$` naming the agent; nothing is
edited between the prompt and the screenshots. A test that needs a server uses mock backend responses, never a live
service.

## The suite

```
swift test                                  # the record, the schema, the lines, the files, a call through the roster
LOOM_BUILD=1 swift test --filter LoomBuildTests   # the output built for real (gated, minutes)
```

## Prompts run on this Mac

Setup: MacBook Pro M4 Max (128 GB), macOS 27, Xcode 27.1, Craft built from `main`, the model Craft loads
(`rao-studios/Qwen3-Coder-Next-REAP-48B-A3B-mlx-4bit`), permission mode bypass, the agent installed from this repository
with `craft agents add`.

### 1. Hearth's social screens over HearthKit's types (the journey's seventh prompt)

*2026-11-01 · Qwen3-Coder-Next-REAP-48B-A3B-mlx-4bit · 471 s*

**The prompt**, verbatim:

```text
Give Hearth its social screens with $loom, in Loom's look with the colours from the asset catalog, over HearthKit's Post, Comment, User and Community: post cards in a feed with votes, saves and sharing; a post's page with its threaded comments and replies; compose with the Markdown toolbar; profiles and community pages.
```

**The call the model wrote** to `loom`:

```json
{
  "colors": "assets",
  "features": [
    "vote",
    "save",
    "share",
    "reply",
    "report",
    "block",
    "nsfwShield",
    "markdown",
    "linkPreview",
    "media",
    "swipeActions",
    "editing"
  ],
  "into": "Shared/Views/Social",
  "mappings": [
    "post: Post title=title body=body author=author.name avatar=author.avatar community=community.title created=created_at score=score comments=comment_count saved=saved",
    "comment: Comment body=body author=author.name avatar=author.avatar score=score created=created_at parent=parent_id",
    "user: User name=name display=display_name avatar=avatar bio=bio",
    "community: Community name=name title=title icon=icon subscribers=subscriber_count"
  ],
  "screens": [
    "feed",
    "post",
    "thread",
    "compose",
    "reply",
    "profile",
    "community",
    "search"
  ],
  "style": "loom"
}
```

**What `loom` wrote** (44 files): `Shared/Views/Social/SocialProtocols.swift`, `Shared/Views/Social/SocialValue.swift`, `Shared/Views/Social/SocialFormat.swift`, `Shared/Views/Social/SocialContext.swift`, `Shared/Views/Social/SocialStyle.swift`, `Shared/Views/Social/SocialActions.swift`, `Shared/Views/Social/SocialPhase.swift`, `Shared/Views/Social/SocialMenu.swift`, `Shared/Views/Social/SocialThread.swift`, `Shared/Views/Social/SocialSwipe.swift`, `Shared/Views/Social/AvatarView.swift`, `Shared/Views/Social/BannerView.swift`, `Shared/Views/Social/CensorView.swift`, `Shared/Views/Social/MarkdownBodyView.swift`, `Shared/Views/Social/LinkPreviewView.swift`, `Shared/Views/Social/MediaGalleryView.swift`, `Shared/Views/Social/ContentStateView.swift`, `Shared/Views/Social/ContentMenuView.swift`, `Shared/Views/Social/ContentHeaderView.swift`, `Shared/Views/Social/ContentFooterView.swift`, `Shared/Views/Social/PostCardView.swift`, `Shared/Views/Social/CommentCardView.swift`, `Shared/Views/Social/CommentThreadView.swift`, `Shared/Views/Social/PostPageView.swift`, `Shared/Views/Social/FeedHeaderView.swift`, `Shared/Views/Social/FeedView.swift`, `Shared/Views/Social/FeedSplitView.swift`, `Shared/Views/Social/MarkdownEditorView.swift`, `Shared/Views/Social/ComposeView.swift`, `Shared/Views/Social/ReplyView.swift` …

**What the model changed itself**: `Shared/Views/Social/Conformances/AppSocial.swift`, `Shared/Views/Social/Conformances/Post+Post.swift`, `Shared/Views/Social/Conformances/Comment+Comment.swift`, `Shared/Views/Social/Conformances/User+User.swift`, `Shared/Views/Social/Conformances/Community+Community.swift`

**Verified by hand**:
- The macOS scheme builds with the kit and its conformances; the screens are drawn on the app's pages in later entries.

![The turn: one call to loom, the files it wrote, and the imports the model added by hand](Docs/Testing/1-7-loom.png)
*The turn: one call to loom, the files it wrote, and the imports the model added by hand*

**Notes**:
- The mappings read HearthKit's fields as they are spelled there (`created_at`, `comment_count`: HearthKit was made by a network release that kept the API's snake_case).
- The conformances did not build until the model imported HearthKit into five files: the line gave no `imports`, and loom did not know where Post was declared.
- Fixed in the next release: loom reads the app's own types, imports a mapped type's local package with a note, writes each path in the type's spelling (`created_at` read as `createdAt` where the type says so), and refuses a field the type does not have, listing the ones it has.
