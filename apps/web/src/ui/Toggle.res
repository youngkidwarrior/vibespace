@@directive("'use client'")

@module("tailwind-merge")
external cn: (string, option<string>) => string = "twMerge"

module Variant = {
  @unboxed
  type t =
    | @as("default") Default
    | @as("outline") Outline
}

module Size = {
  @unboxed
  type t =
    | @as("default") Default
    | @as("sm") Sm
    | @live @as("lg") Lg
}

let toggleVariantClass = (~variant: Variant.t) =>
  switch variant {
  | Outline => "border-neutral-300 hover:bg-neutral-100 border bg-transparent"
  | Default => "bg-transparent"
  }

let toggleSizeClass = (~size: Size.t) =>
  switch size {
  | Sm => "h-7 min-w-7 rounded-lg px-1.5 text-[0.8rem]"
  | Lg => "h-9 min-w-9 px-2.5"
  | Default => "h-8 min-w-8 px-2"
  }

let toggleVariants = (~variant: Variant.t, ~size: Size.t) => {
  let base = "text-neutral-950 hover:text-neutral-950 aria-pressed:bg-neutral-100 focus-visible:border-neutral-500 focus-visible:ring-neutral-300/50 aria-invalid:ring-red-200 aria-invalid:border-red-500 data-[state=on]:bg-neutral-100 gap-1 rounded-lg text-sm font-medium transition-all [&_svg:not([class*='size-'])]:size-4 group/toggle hover:bg-neutral-100 inline-flex items-center justify-center whitespace-nowrap outline-none focus-visible:ring-[3px] disabled:pointer-events-none disabled:opacity-50 [&_svg]:pointer-events-none [&_svg]:shrink-0"
  `${base} ${toggleVariantClass(~variant)} ${toggleSizeClass(~size)}`
}

@react.component
@live
let make = (
  ~className=?,
  ~children=?,
  ~id=?,
  ~name=?,
  ~dir=?,
  ~disabled=?,
  ~pressed=?,
  ~defaultPressed=?,
  ~onPressedChange=?,
  ~onClick=?,
  ~onKeyDown=?,
  ~tabIndex=0,
  ~ariaLabel=?,
  ~type_=?,
  ~render=?,
  ~variant=Variant.Default,
  ~size=Size.Default,
) => {
  <BaseUi.Toggle
    ?id
    ?name
    ?dir
    ?disabled
    ?pressed
    ?defaultPressed
    ?onPressedChange
    ?onClick
    ?onKeyDown
    tabIndex
    ?ariaLabel
    ?type_
    ?render
    ?children
    dataSlot="toggle"
    className={cn(toggleVariants(~variant, ~size), className)}
  />
}
