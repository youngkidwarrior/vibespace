@@jsxConfig({version: 4, mode: "automatic", module_: "BaseUi.BaseUiJsxDOM"})

@module("tailwind-merge")
external cn: (string, string, option<string>) => string = "twMerge"

@unboxed
type dataIcon =
  | @live @as("inline-start") InlineStart
  | @live @as("inline-end") InlineEnd

module Variant = {
  @unboxed
  type t =
    | @as("default") Default
    | @as("secondary") Secondary
    | @live @as("destructive") Destructive
    | @as("outline") Outline
    | @live @as("ghost") Ghost
    | @live @as("link") Link
}

let badgeVariantClass = (~variant: Variant.t) =>
  switch variant {
  | Default => "bg-neutral-950 text-white [a]:hover:bg-neutral-800"
  | Secondary => "bg-neutral-100 text-neutral-950 [a]:hover:bg-neutral-200"
  | Destructive => "bg-red-50 text-red-700 focus-visible:ring-red-200 [a]:hover:bg-red-100"
  | Outline => "border-neutral-200 text-neutral-950 [a]:hover:bg-neutral-100 [a]:hover:text-neutral-600"
  | Ghost => "text-neutral-950 hover:bg-neutral-100 hover:text-neutral-600"
  | Link => "text-neutral-950 underline-offset-4 hover:underline"
  }

let base = "group/badge inline-flex h-5 w-fit shrink-0 items-center justify-center gap-1 overflow-hidden rounded-full border border-transparent px-2 py-0.5 text-xs font-medium whitespace-nowrap transition-all focus-visible:border-neutral-400 focus-visible:ring-[3px] focus-visible:ring-neutral-300/50 has-data-[icon=inline-end]:pr-1.5 has-data-[icon=inline-start]:pl-1.5 aria-invalid:border-red-500 aria-invalid:ring-red-200 [&>svg]:pointer-events-none [&>svg]:size-3!"

@react.component
let make = (
  ~className=?,
  ~children=?,
  ~variant=Variant.Default,
  ~id=?,
  ~onClick=?,
  ~onKeyDown=?,
  ~style=?,
  ~render=?,
  ~dataIcon: option<dataIcon>=?,
) => {
  let props: BaseUi.Types.BaseUIComponentProps.t = {
    ?id,
    ?style,
    ?onClick,
    ?onKeyDown,
    ?children,
    dataIcon: ?{(dataIcon :> option<string>)},
    dataSlot: "badge",
    dataVariant: (variant :> string),
    className: cn(base, badgeVariantClass(~variant), className),
  }
  BaseUi.Render.use({defaultTagName: "span", props, ?render})
}
