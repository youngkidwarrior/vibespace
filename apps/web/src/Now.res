type date

@new external makeDate: unit => date = "Date"
@send external toIsoString: date => string = "toISOString"

let nowIso = () => makeDate()->toIsoString->IsoTimestamp.make
