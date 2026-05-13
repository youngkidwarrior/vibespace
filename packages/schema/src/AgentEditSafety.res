module ProfileVersionId = {
  type t = string

  let fromString = (value): option<t> => {
    let trimmed = value->String.trim
    trimmed == "" ? None : Some(trimmed)
  }

  let equal = (left: t, right: t) => left == right
}

type loadedCurrentVersionInput = {
  @live
  id: string,
}

type loadedEditStateInput = {
  @live
  currentVersion: loadedCurrentVersionInput,
}

type profileCurrentInput = {
  @live
  currentVersionId: Nullable.t<string>,
}

type currentVersionCheck = {
  @live
  ok: bool,
  @live
  message: string,
}

let currentVersionOk = {ok: true, message: ""}
let currentVersionFailure = message => {ok: false, message}

@live
let checkProfileCurrentVersionUnchanged = (profile, state) => {
  let currentVersionId =
    profile.currentVersionId->Nullable.toOption->Option.flatMap(ProfileVersionId.fromString)
  let baseVersionId = state.currentVersion.id->ProfileVersionId.fromString

  switch (currentVersionId, baseVersionId) {
  | (Some(current), Some(base)) if ProfileVersionId.equal(current, base) => currentVersionOk
  | (Some(_current), Some(_base)) =>
    currentVersionFailure("Profile changed while the assistant edit was running. Reload and try again.")
  | (None, Some(_base)) =>
    currentVersionFailure("Profile no longer has a current version to edit.")
  | (_, None) =>
    currentVersionFailure("Assistant edit session did not load a base profile version.")
  }
}

type generatedPatchInput = {
  @live
  html: string,
  @live
  css: string,
  @live
  summary: string,
  @live
  warnings: string,
}

type patchValidationResult = {
  @live
  ok: bool,
  @live
  message: string,
  @live
  patch: option<generatedPatchInput>,
}

let patchValidationFailure = message => {
  ok: false,
  message,
  patch: None,
}

let patchValidationSuccess = patch => {
  ok: true,
  message: "",
  patch: Some(patch),
}

@live
let validateGeneratedPatch = (patch, validationMessage) => {
  let validationMessage = validationMessage->String.trim

  if validationMessage != "" {
    patchValidationFailure(validationMessage)
  } else if patch.html->String.trim == "" {
    patchValidationFailure("Assistant output did not include profile HTML.")
  } else if patch.css->String.trim == "" {
    patchValidationFailure("Assistant output did not include profile CSS.")
  } else if patch.summary->String.trim == "" {
    patchValidationFailure("Assistant output did not include a profile summary.")
  } else {
    patchValidationSuccess(patch)
  }
}
