# ResGraph Schema Authoring

Use this reference when editing schema types, resolvers, comments, generated
files, or module structure.

## Best Practices

Annotate resolver functions explicitly. ResGraph infers a lot from ReScript
types, but unannotated resolver arguments or return values can expose a schema
shape that differs from intent. Prefer clear parameter and return types on
public resolver functions, especially for `option`, `array`, `ResGraph.id`,
interface resolver variants, custom scalar wrappers, and dataloader results.

Keep schema dumping active. In project config, enable schema SDL dumping when
the repo supports it; in Vibespace this is `dumpSchemaSdl: true` in
`apps/graphql/resgraph.json`. Treat the dumped schema as the review surface for
GraphQL changes.

Commit generated files when the project policy says to. Vibespace commits
`packages/schema/src/__generated__` so reviewers and agents can inspect schema
changes without rerunning the generator. Generated JavaScript can still remain
ignored if the repo already ignores ReScript compiler output.

Avoid circular dependencies by splitting schema ownership deliberately. If a
resolver needs generated interface helpers, keep that resolver in a module that
can import generated output without being imported by the core schema module.
In Vibespace, `BackendNodeResolvers.res` owns Relay `Node` lookups for this
reason.

Handle mutually recursive types with a small, explicit schema module rather
than scattering forward references across the project. Keep related object,
interface, and input definitions close enough that the recursion is visible to
reviewers, then move implementation-heavy resolvers into separate modules.

Treat interfaces as a schema design boundary. Define the interface shape first,
then verify every implementing object has the expected fields, generated
implementor variants, and resolver mapping. After changing an interface, inspect
both the generated helper module and dumped SDL before trusting client code.

## Schema Comments

Use ReScript doc comments on ResGraph types and fields so the generated
GraphQL schema is self-documenting. Comments on object types and `@gql.field`
values become GraphQL descriptions in the dumped SDL and Relay-visible schema.

```rescript
/** A user in the system. */
@gql.type
type user = {
  ...node,
  /** The first name of the user. */
  @gql.field firstName: string,
}

/** The full name of the user. */
@gql.field
let fullName = (user: user): option<string> =>
  Some(`${user.firstName} ${user.lastName}`)
```

For resolver functions, the first unlabelled argument controls which GraphQL
type receives the field. The resolver may be sync or async. Add an explicit
return type when inference could expose the wrong nullability, list shape, id
type, or scalar wrapper.

## Vibespace Schema Organization

Prefer the local schema's existing organization:

- Keep object and enum definitions in `BackendSchema.res` unless a boundary is
  already split out.
- Keep Relay `Node` lookup helpers in `BackendNodeResolvers.res`; importing
  generated interface helpers from the main schema module can create cycles.
- Add fields with `@gql.field` and rerun `yarn resgraph` before updating Relay.
- Keep generated ids and internal ids explicit. Do not guess at generated module
  names; inspect generated output or use `find-definition`.
