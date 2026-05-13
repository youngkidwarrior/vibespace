# Input Objects

ResGraph generates GraphQL input object types from ReScript records annotated
with `@gql.inputObject`. Use them for every mutation argument and for any query
that takes more than one meaningful scalar.

Authoritative pattern in this repo: `packages/schema/src/BackendSchema.res`
already declares input objects for `submitAgentEditInput`,
`saveManualProfileVersionInput`, `cancelProfileEditSessionInput`,
`requestTargetedAgentEditRepairInput`, etc. New mutations should match that
shape.

## Declaring an input object

```rescript
@gql.inputObject
type saveManualProfileVersionInput = {
  profileId: ResGraph.id,
  html: string,
  css: string,
  summary?: string,
}
```

Rules:

- Annotate the type with `@gql.inputObject`. Do not annotate fields with
  `@gql.field`; every record field on an input object is exposed automatically.
- Use `ResGraph.id` for any id-shaped argument so the GraphQL surface is `ID!`,
  not `String!`.
- A trailing `?` on a record field makes it optional (`nullable` in GraphQL):
  `summary?: string` produces `summary: String`. A bare field is non-null.
- Name the type with the `Input` suffix and matching PascalCase. ResGraph
  derives the GraphQL type name from the ReScript type name; keep the names in
  sync so generated SDL is greppable.
- Keep the input object next to the mutation it serves in BackendSchema.res.
  Do not split inputs into separate modules just because they look similar.

## Using an input object in a mutation

```rescript
@live @gql.field
let saveManualProfileVersion = async (
  _: mutation,
  ~input: saveManualProfileVersionInput,
  ~ctx: ResGraphContext.context,
): saveManualProfileVersionResult => { ... }
```

The single labeled argument is always called `~input`. Authorization and
context loading reuse `loadProfileById`, `profileWriteActorIdForViewer`, etc.,
exactly like the existing mutations in the file. Errors-as-data unions (see
`references/unions-errors-as-data.md`) are the standard result shape.

## When to use an input object vs labeled args

- **Always for mutations.** Future-proof: adding a field to an input object is
  non-breaking; adding a labeled argument to a mutation is.
- **For queries with one logical scalar argument**, labeled args are
  idiomatic: `profileByHandle(~handle: string)`, `inviteByCode(~code: string)`,
  `sendtagLookup(~sendtag: string)`.
- **For Relay connection-style queries** (`~first`, `~after`, `~before`,
  `~last`, plus a parent id), keep the connection cursor args inline. That is
  the Relay convention; ResGraph and the Relay client both expect it.
- **Avoid mixing multiple unrelated scalars** on a non-connection query.
  Promote them to an input object instead.

## Non-GraphQL helper types

Records used as JS FFI argument shells (e.g. binding to `AgentEditService.js`)
are not input objects. Do **not** annotate them with `@gql.inputObject` even
if their fields mirror an input shape. Keep them as ordinary ReScript records
local to the binding so they cannot accidentally leak into the schema. A
common convention is to name them with a different suffix (e.g.
`agentServiceInput`, `targetedAgentEditRepairInput`) so they read as service
inputs, not GraphQL inputs.

## Verification

After adding or changing an input object:

```sh
yarn rescript:backend
yarn resgraph
yarn relay:validate
```

Inspect `packages/schema/src/__generated__/schema.graphql` to confirm:

- The new `input <Name>Input { ... }` block is present with the expected
  field types and `!` markers.
- The mutation that uses it has the right input argument type.
