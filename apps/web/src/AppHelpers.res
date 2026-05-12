type floatingPosition = {
  left: float,
  top: float,
}

let bubbleWidth = 360.0
let bubbleHeight = 540.0
let composerSafeTop = 76.0

let clamp = (value, low, high) => {
  let safeHigh = high < low ? low : high
  if value < low {
    low
  } else if value > safeHigh {
    safeHigh
  } else {
    value
  }
}

let positionForAnchor = (anchor: ProfileGeometry.anchor): floatingPosition => {
  let margin = 12.0
  let gap = 14.0
  let maxLeft = anchor.viewport.width - bubbleWidth - margin
  let maxTop = anchor.viewport.height - bubbleHeight - margin
  let rightSide = anchor.client.x + anchor.size.width + gap
  let leftSide = anchor.client.x - bubbleWidth - gap
  let left = if rightSide + bubbleWidth + margin < anchor.viewport.width {
    rightSide
  } else {
    clamp(leftSide, margin, maxLeft)
  }

  {
    left,
    top: clamp(anchor.client.y, composerSafeTop, maxTop),
  }
}

let anchorFromDraft = (draft: PromptDrafts.item): option<ProfileGeometry.anchor> =>
  if draft.anchor.size.width > 0.0 && draft.anchor.size.height > 0.0 {
    Some(draft.anchor)
  } else {
    None
  }

let shortText = value => {
  let trimmed = value->String.trim
  if trimmed == "" {
    "Empty draft"
  } else if trimmed->String.length > 64 {
    trimmed->String.slice(~start=0, ~end=64) ++ "..."
  } else {
    trimmed
  }
}
