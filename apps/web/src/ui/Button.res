@@directive("'use client'")

@module("tailwind-merge")
external cn: (string, string, string, option<string>) => string = "twMerge"

module Variant = {
  @unboxed
  type t =
    | @as("default") Default
    | @as("secondary") Secondary
    | @as("destructive") Destructive
    | @as("outline") Outline
    | @as("ghost") Ghost
    | @live @as("link") Link
}

module Size = {
  @unboxed
  type t =
    | @as("default") Default
    | @live @as("xs") Xs
    | @as("sm") Sm
    | @live @as("lg") Lg
    | @live @as("icon") Icon
    | @as("icon-xs") IconXs
    | @as("icon-sm") IconSm
    | @as("icon-lg") IconLg
}

let buttonVariantClass = (~variant: Variant.t) =>
  switch variant {
  | Default => "bg-neutral-950 text-white [a]:hover:bg-neutral-800"
  | Outline => "border-neutral-200 bg-white text-neutral-950 hover:bg-neutral-100 aria-expanded:bg-neutral-100"
  | Secondary => "bg-neutral-100 text-neutral-950 hover:bg-neutral-200 aria-expanded:bg-neutral-200"
  | Ghost => "text-neutral-950 hover:bg-neutral-100 aria-expanded:bg-neutral-100"
  | Destructive => "bg-red-50 text-red-700 hover:bg-red-100 focus-visible:border-red-300 focus-visible:ring-red-200"
  | Link => "text-neutral-950 underline-offset-4 hover:underline"
  }

let buttonSizeClass = (~size: Size.t) =>
  switch size {
  | Xs => "h-6 gap-1 rounded-md px-2 text-xs in-data-[slot=button-group]:rounded-lg has-data-[icon=inline-end]:pr-1.5 has-data-[icon=inline-start]:pl-1.5 [&_svg:not([class*='size-'])]:size-3"
  | Sm => "h-7 gap-1 rounded-lg px-2.5 text-[0.8rem] in-data-[slot=button-group]:rounded-lg has-data-[icon=inline-end]:pr-1.5 has-data-[icon=inline-start]:pl-1.5 [&_svg:not([class*='size-'])]:size-3.5"
  | Lg => "h-9 gap-1.5 rounded-lg px-2.5 has-data-[icon=inline-end]:pr-3 has-data-[icon=inline-start]:pl-3"
  | Icon => "size-8 rounded-lg"
  | IconXs => "size-6 rounded-md in-data-[slot=button-group]:rounded-lg [&_svg:not([class*='size-'])]:size-3"
  | IconSm => "size-7 rounded-lg in-data-[slot=button-group]:rounded-lg"
  | IconLg => "size-9 rounded-lg"
  | Default => "h-8 gap-1.5 rounded-lg px-2.5 has-data-[icon=inline-end]:pr-2 has-data-[icon=inline-start]:pl-2"
  }

let baseClass = "group/button inline-flex shrink-0 items-center justify-center rounded-lg border border-transparent bg-clip-padding text-sm font-medium whitespace-nowrap transition-all outline-none select-none focus-visible:border-neutral-400 focus-visible:ring-3 focus-visible:ring-neutral-300/50 active:translate-y-px disabled:pointer-events-none disabled:opacity-50 aria-invalid:border-red-500 aria-invalid:ring-3 aria-invalid:ring-red-200 [&_svg]:pointer-events-none [&_svg]:shrink-0 [&_svg:not([class*='size-'])]:size-4"

let buttonVariants = (~variant: Variant.t, ~size: Size.t, ~className=?) =>
  cn(baseClass, buttonVariantClass(~variant), buttonSizeClass(~size), className)

type props = {
  variant?: Variant.t,
  size?: Size.t,
  ...BaseUi.Types.BaseUIComponentProps.t,
  ...BaseUi.Types.NativeButtonProps.t,
  @live focusableWhenDisabled?: bool,
}

let toBaseUiProps: props => BaseUi.Button.props = %raw(`
  ({variant, size, ...rest}) => rest 
  `)

@react.componentWithProps(props)
@live
let make = (props: props) => {
  let variant = props.variant->Option.getOr(Default)
  let size = props.size->Option.getOr(Default)
  let className = props.className
  let baseUiProps = props->toBaseUiProps
  <BaseUi.Button
    {...baseUiProps}
    dataSlot={props.dataSlot->Option.getOr("button")}
    className={buttonVariants(~variant, ~size, ~className?)}
  />
}
