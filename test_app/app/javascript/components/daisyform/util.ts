import { partition } from "../../lib/iterable";

export function partitionNames(className: string | null | undefined, rx: RegExp) {
  if(!className) return ["", ""];
  return partition(className.match(/\S+/g) || [], rx)
    .map(names=>names.join(" "));
}