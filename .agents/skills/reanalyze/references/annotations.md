# Reanalyze Source Annotations

Use annotations to document real analysis boundaries. Do not use them to avoid
cleanup without a reason.

## `@dead`

Suppresses a dead-code report and records that code is intentionally retained.

```rescript
type user = {
  name: string,
  @dead age: int,
}
```

`@dead` code does not keep referenced code alive. Prefer removing true private
dead code instead of annotating it.

## `@live`

Marks a value as live when Reanalyze cannot see the external reachability path.

```rescript
@live
let attachToIframe = iframe => {
  // Called from JS or browser-owned code.
}
```

Use for JavaScript interop, generated JS imports, browser callbacks, framework
conventions, and dynamically named exports. `@live` code keeps referenced code
alive.

## `@throws`

Documents that a function may throw a concrete exception.

```rescript
exception InvalidProfilePatch

@throws(InvalidProfilePatch)
let parsePatchUnsafe = raw => {
  throw(InvalidProfilePatch)
}
```

For multiple exceptions:

```rescript
@throws([MissingValue, InvalidValue])
let parseUnsafe = raw => {
  // ...
}
```

Prefer `result` in new Vibespace domain code. Use `@throws` mainly for
intentional unsafe boundaries.

## `@doesNotThrow`

Silences exception analysis for a known call.

```rescript
let padded = (@doesNotThrow String.make)(12, ' ')
```

Use sparingly. If failure can happen in normal app flow, model it with
`option` or `result`.

## `@progress`

Documents expected progress for termination analysis. Treat this path as
experimental and avoid broad use until recursive code makes termination
findings repeatedly useful.
