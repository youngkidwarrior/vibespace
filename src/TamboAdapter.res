type agentPatch = {
  html: string,
  css: string,
}

@module("./TamboAdapter.js") external setProfileDocumentApplier: (agentPatch => unit) => unit = "setProfileDocumentApplier"
@module("./TamboAdapter.js") external hasTamboApiKey: unit => bool = "hasTamboApiKey"
