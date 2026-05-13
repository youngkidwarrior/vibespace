# RescriptRelay Patterns

These patterns should stay small and proven by code in this repo. Add detail
only after a Vibespace implementation compiles through ResGraph, Relay, and
ReScript.

## Route Query + Component Fragment

Use route queries for loading boundaries and component fragments for UI data
ownership.

- Route renderer `prepare` preloads the route query.
- Route module owns the root query and handles missing top-level data.
- Component module owns the fragment for the data it turns into UI state.
- Parent query spreads the child fragment and passes `fragmentRefs`.
- Child component calls `Fragment.use(fragmentRefs)` before reading fields.

Current proven shape:

```rescript
/* ProfileRoute.res */
module Query = %relay(`
  query ProfileRouteQuery {
    viewerProfile {
      ...ProfileDocumentData_profile
    }
  }
`)
```

```rescript
/* ProfileDocumentData.res */
module ProfileFragment = %relay(`
  fragment ProfileDocumentData_profile on Profile {
    currentVersion {
      html
      css
    }
  }
`)
```

The route query decides whether a `viewerProfile` exists. The fragment component
decides how profile fields become local frontend state.

## Naming

- Name fragments as `<ModuleName>_<schemaTypeLowercase>`.
- Keep the fragment module near the React component that consumes it.
- Keep route query names aligned with the route component, such as
  `ProfileRouteQuery`.

## Tilt Compiler Loop

When Tilt owns the compilers, do not start duplicate watch processes.

1. Edit ReScript source.
2. Let `frontend-relay-watch` regenerate Relay artifacts.
3. Let `frontend-rescript-watch` compile generated and source modules.
4. Read Tilt logs before running one-shot compiler commands:

```sh
tilt logs frontend-relay-watch --port "$TILT_PORT" --tail 200
tilt logs frontend-rescript-watch --port "$TILT_PORT" --tail 200
```

If schema changes are involved, check backend watchers too:

```sh
tilt logs graphql-rescript-watch --port "$TILT_PORT" --tail 200
tilt logs graphql-resgraph-lsp --port "$TILT_PORT" --tail 200
```

## Generated Artifacts

- Do not hand-edit files under `src/__generated__/relay`.
- Review generated artifacts with source changes because generated types reveal
  the actual Relay contract.
- If a fragment spread is added, expect a new fragment artifact and a changed
  parent query artifact.

## Mutation Module

Keep mutations in focused modules, separate from route renderers and large UI
components.

- Name mutation modules by feature, such as `ProfileVersionMutations`.
- Define one `%relay` module per mutation operation.
- Request only the payload fields the caller needs for confirmation, notices,
  and future store updates.
- Commit mutations after the local UI state has already passed validation.
- Treat the first mutation pass as persistence confirmation; add store updaters
  only after the response shape and UX are proven.

Current proven shape:

```rescript
/* ProfileVersionMutations.res */
module SaveManualProfileVersionMutation = %relay(`
  mutation ProfileVersionMutationsSaveManualProfileVersionMutation(
    $input: SaveManualProfileVersionInput!
  ) {
    saveManualProfileVersion(input: $input) {
      status
      summary
      error
      validationErrors
    }
  }
`)
```

The editor keeps a local-first document update for responsiveness, then commits
`saveManualProfileVersion` when a generated profile change is valid and a
backend `profileId` is available.

## Profile-Owned History Connection

Prefer profile-owned connection fields when the current route already loads a
profile and the child UI needs related records.

- Add the GraphQL field to the object that owns the related data, such as
  `Profile.versionHistory(first: 20)`.
- Keep route data loading in the existing route query by extending the component
  fragment, not by creating a second query solely to pass the current profile ID
  back to the server.
- Convert generated connection edges into a small UI-owned snapshot type before
  handing data to stateful editor code.
- For restore-style mutations, return the restored version's `html` and `css`
  in the mutation payload so the local editor can update immediately without a
  separate refetch.

Current proven shape:

```rescript
/* ProfileDocumentData.res */
module ProfileFragment = %relay(`
  fragment ProfileDocumentData_profile on Profile {
    versionHistory(first: 20) {
      edges {
        node {
          id
          revisionNumber
          html
          css
          summary
          createdAt
        }
      }
    }
  }
`)
```

```rescript
/* ProfileVersionMutations.res */
module RestoreProfileVersionMutation = %relay(`
  mutation ProfileVersionMutationsRestoreProfileVersionMutation(
    $input: RestoreProfileVersionInput!
  ) {
    restoreProfileVersion(input: $input) {
      error
      validationErrors
      profileVersion {
        id
        revisionNumber
        html
        css
        summary
        createdAt
      }
    }
  }
`)
```

## TODO

- Error, nullable field, union, and interface handling.
- Generated artifact review checklist.
