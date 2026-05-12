@@jsxConfig({version: 4, mode: "automatic", module_: "BaseUi.BaseUiJsxDOM"})

@module("tailwind-merge")
external cn: (string, option<string>) => string = "twMerge"

@react.componentWithProps(BaseUi.Types.DomProps.t)
@live
let make = (props: BaseUi.Types.DomProps.t) => {
  <textarea
    {...props}
    dataSlot="textarea"
    className={cn(
      "flex field-sizing-content min-h-16 w-full rounded-lg border border-neutral-300 bg-transparent px-2.5 py-2 text-base text-neutral-950 transition-colors outline-none placeholder:text-neutral-400 focus-visible:border-neutral-500 focus-visible:ring-3 focus-visible:ring-neutral-300/50 disabled:cursor-not-allowed disabled:bg-neutral-200/50 disabled:opacity-50 aria-invalid:border-red-500 aria-invalid:ring-3 aria-invalid:ring-red-200 md:text-sm",
      props.className,
    )}
  />
}
