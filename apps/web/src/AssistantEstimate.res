type mode =
  | Fast
  | Reasoning

let label = mode =>
  switch mode {
  | Fast => "about 2-3 min"
  | Reasoning => "about 3-5 min"
  }

let detail = mode =>
  switch mode {
  | Fast => "Most profile edits finish in about 2-3 min."
  | Reasoning => "Deeper reasoning edits usually take about 3-5 min."
  }

let waitingCopy = mode =>
  "Estimated wait: " ++ mode->label ++ ". You can keep exploring while Vibespace builds this."
