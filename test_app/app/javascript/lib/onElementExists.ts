type ElementFunction = (element: HTMLElement, cancel: CancelWatcherFunction) => (void | CleanupFunction);
type CancelWatcherFunction = () => void;
type CleanupFunction = (element: HTMLElement) => void;
type SelectorPair = [string, ElementFunction];

const selectors: Set<SelectorPair> = new Set();
let observer : MutationObserver;
const cleanupFunctions = Symbol("cleanupFunctions");

function observe(mutations : Array<MutationRecord>) {
  mutations.forEach(mutation => {
    if(selectors.size > 0) mutation.addedNodes.forEach(addedNode);
    mutation.removedNodes.forEach(removedNode);
  })
}

function addedNode(node : Node) {
  if(node.nodeType !== Node.ELEMENT_NODE) return;
  selectors.forEach((entry)=>{
    if(!applySelector(node as HTMLElement, ...entry)) selectors.delete(entry);
  })
}

function applySelector(element : HTMLElement, selector : string, fn : ElementFunction) : Boolean {
  let canceled = false
  const cancel = ()=>{ canceled = true }
  if(element.matches(selector)){
    let cleanup = fn(element, cancel);
    if(typeof cleanup === "function") {
      let functionArray = element[cleanupFunctions] = element[cleanupFunctions] || []
      functionArray.push(cleanup);
    }
  }
  element.querySelectorAll(selector).forEach(descendant => {
    if(canceled) return;
    let cleanup = fn(descendant as HTMLElement, cancel);
    if(typeof cleanup === "function") {
      let functionArray = descendant[cleanupFunctions] = descendant[cleanupFunctions] || []
      functionArray.push(cleanup);
    }
  });
  return !canceled;
}

function removedNode(node : Node) {
  if(node.nodeType !== Node.ELEMENT_NODE) return;
  const itr = document.createNodeIterator(node, NodeFilter.SHOW_ELEMENT);
  let element : HTMLElement
  while(element = itr.nextNode() as HTMLElement) {
    let fns = element[cleanupFunctions] as Array<CleanupFunction> | void
    if(!fns) continue;
    fns.forEach(fn=>fn(element));
  }
}

export default function onElementExists(selector: string, callback: ElementFunction): CancelWatcherFunction {
  const selectorPair : SelectorPair = [selector, callback];
  const cancelFn = ()=>selectors.delete(selectorPair);
  const root = document.querySelector("html");
  if(root) {
    if(!applySelector(root, selector, callback)) return cancelFn; // cancelFn is a noop here since it's already canceled
  }
  selectors.add(selectorPair);
  if(!observer) {
    observer = new MutationObserver(observe);
    observer.observe(document, {childList: true, subtree: true});
  }
  return cancelFn;
}

export { onElementExists };
export type { CancelWatcherFunction };
