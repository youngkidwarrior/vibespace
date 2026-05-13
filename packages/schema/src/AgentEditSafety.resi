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

@live
let checkProfileCurrentVersionUnchanged: (
  profileCurrentInput,
  loadedEditStateInput,
) => currentVersionCheck

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

@live
let validateGeneratedPatch: (generatedPatchInput, string) => patchValidationResult
