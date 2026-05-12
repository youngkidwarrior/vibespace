# ResGraph Unions And Errors As Data

Use this reference when modeling GraphQL unions, mutation result unions, or
expected domain failures.

## When To Use Unions

Use GraphQL unions for expected domain outcomes, especially mutation results
where clients must distinguish success from validation, permission, missing
record, unavailable persistence, or business-rule failures. Reserve GraphQL
transport errors for unexpected server failures.

Prefer explicit `@gql.union` types for stable public contracts:

```rescript
/** The update succeeded. */
@gql.type
type updateUserSucceeded = {@gql.field user: user}

/** The request did not pass validation. */
@gql.type
type updateUserValidationFailed = {
  @gql.field message: string,
  @gql.field fields: array<string>,
}

/** Result of updating a user. */
@gql.union
type updateUserResult =
  | Succeeded(updateUserSucceeded)
  | ValidationFailed(updateUserValidationFailed)
```

## Exhaustive Mapping

Map an internal domain variant into the GraphQL union with one exhaustive
`switch`:

```rescript
type updateUserOutcome =
  | UserUpdated(updateUserSucceeded)
  | UserInvalid(updateUserValidationFailed)

let toUpdateUserResult = (outcome: updateUserOutcome): updateUserResult =>
  switch outcome {
  | UserUpdated(result) => Succeeded(result)
  | UserInvalid(error) => ValidationFailed(error)
  }
```

This makes new outcome cases a compiler problem instead of a hidden nullable
payload bug.

## Explicit, Inline, And Inferred Unions

Prefer named `@gql.type` union member records for stable public schemas,
reusable result members, and Relay-facing APIs.

Use inline records for quick one-off mutation results. They synthesize names
from `<unionName><caseName>`, which is convenient but less controlled.

Use inferred polymorphic-variant unions for prototypes and local fields. They
cannot use doc strings, cannot control the generated union name, and cannot be
reused.

## Relay SDL Caveat

For Relay-facing SDL, put doc comments on named `@gql.type` union member objects
rather than directly on union variant cases. ResGraph can emit variant case
comments into the SDL, but Relay may reject comments attached to union members.

## References

- Local upstream reference: `docs/reference/resgraph/unions.md`
- Upstream source: https://raw.githubusercontent.com/zth/resgraph/refs/heads/main/docs/docs/unions.md
