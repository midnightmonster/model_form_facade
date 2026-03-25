import type { JSONValue } from "../../lib/dataform/dataFormLib.svelte"

export function csrfToken(){
  const name = document.querySelector("meta[name=csrf-param]")?.getAttribute("content")
  const value = document.querySelector("meta[name=csrf-token]")?.getAttribute("content")
  return {name, value}
}

export type RawOption = {label: string, value: string} | [string, any] | string
export type Option = {label: string, value: string, [key: string]: JSONValue}

export function asOption(option: RawOption) {
  if(Array.isArray(option)) {
    let [label, value] = option;
    return {label, value};
  }
  if(typeof option === "object" && ("label" in option)) {
    return option;
  }
  return {label: option, value: option}
}

export function asOptions(options: Array<RawOption>) {
  return options.map(asOption);
}