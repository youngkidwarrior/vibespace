type t<'key, 'value>

type options = {
  name: string,
}

@module("dataloader") @new external make: (
  array<'key> => promise<array<'value>>,
  options,
) => t<'key, 'value> = "default"

let makeBatched = (batchLoadFn, ~options) => make(batchLoadFn, options)

@send external load: (t<'key, 'value>, 'key) => promise<'value> = "load"
