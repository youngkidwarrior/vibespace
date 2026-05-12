external editProgressPhaseRaw: RelaySchemaAssets_graphql.enum_EditProgressPhase => string = "%identity"
external inviteStatusRaw: RelaySchemaAssets_graphql.enum_InviteStatus => string = "%identity"
external profileEditSessionStatusRaw: RelaySchemaAssets_graphql.enum_ProfileEditSessionStatus => string =
  "%identity"
external userStatusRaw: RelaySchemaAssets_graphql.enum_UserStatus => string = "%identity"

let titleCaseEnum = value =>
  value
  ->String.split("_")
  ->Array.map(part =>
    switch part->String.toLowerCase {
    | "" => ""
    | lower =>
      lower->String.slice(~start=0, ~end=1)->String.toUpperCase ++
        lower->String.slice(~start=1, ~end=lower->String.length)
    }
  )
  ->Array.join(" ")

let editProgressPhase = phase =>
  switch phase->editProgressPhaseRaw {
  | "PREPARING" => "Preparing"
  | "PLANNING" => "Understanding request"
  | "CHECKING_WEB_CONTEXT" => "Checking web context"
  | "EXTRACTING_ASSETS" => "Finding safe images"
  | "GENERATING" => "Generating changes"
  | "VALIDATING" => "Validating"
  | "REPAIRING" => "Repairing markup"
  | "APPLYING" => "Applying"
  | value => value->titleCaseEnum
  }

let inviteStatus = status => status->inviteStatusRaw->titleCaseEnum
let profileEditSessionStatus = status => status->profileEditSessionStatusRaw->titleCaseEnum
let userStatus = status => status->userStatusRaw->titleCaseEnum
