# ResGraph Pagination And Connections

Use this reference when adding or reviewing connection-shaped GraphQL fields in
Vibespace.

Raw upstream reference saved in-repo:

- `docs/reference/resgraph/pagination.md`
- Source: `https://raw.githubusercontent.com/zth/resgraph/main/docs/docs/pagination.md`

## Connection Shape

Connections are plain ResGraph object types. Define explicit edge and connection
records, then return the connection from a field.

```rescript
@gql.type
type profileVersionEdge = {
  @gql.field cursor: string,
  @gql.field node: option<profileVersion>,
}

@gql.type
type profileVersionConnection = {
  @gql.field pageInfo: ResGraph.Connections.pageInfo,
  @gql.field edges: option<array<option<profileVersionEdge>>>,
  @gql.field totalCount: int,
}
```

Expose all standard connection args on fields:

```rescript
@gql.field
let versionHistory = async (
  profile: profile,
  ~first: option<int>,
  ~after: option<string>,
  ~before: option<string>,
  ~last: option<int>,
  ~ctx: ResGraphContext.context,
): profileVersionConnection => ...
```

## Helper Use

`ResGraph.Connections.connectionFromArray` is useful when the backing data is
already an array and is not expected to change while a client paginates through
it. It builds synthetic cursors from array indexes.

Use it for prototype or low-risk lists:

```rescript
let connection = items->ResGraph.Connections.connectionFromArray(
  ~args={first, after, before, last},
)
```

Avoid index cursors for append-heavy feeds or histories where newly inserted
items can shift every later index. In those cases, hand-roll the connection and
make cursors stable.

## Vibespace Pattern

Profile version history is append-only and newest-first. New versions are added
to the front, so array-index cursors can skip or duplicate items if the user
paginates after a save. Use stable cursors derived from version identity, such
as revision number plus id.

For profile version history:

- Keep the public field as `Profile.versionHistory`.
- Return `ProfileVersionConnection`.
- Keep `totalCount` on the connection for UI copy and quick audits.
- Use stable cursor strings; clients must treat them as opaque.
- Keep `pageInfo` accurate for the returned slice.
- Continue to expose complete `html` and `css` in editor-owned fragments until
  the frontend has a lighter version-summary surface.

For other current Vibespace connection stubs, synthetic array connections are
acceptable until the list becomes user-visible, high-volume, or frequently
paginated.
