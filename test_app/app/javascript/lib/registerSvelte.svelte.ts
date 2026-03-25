import { applyPatch } from "fast-json-patch";
import onElementExists, { type CancelWatcherFunction } from "./onElementExists";
import { type Component, createRawSnippet, mount, unmount } from "svelte";

type SvelteModule = {default: Component}
type ModuleOrLazyImport = SvelteModule | (()=>Promise<SvelteModule>)
type ComponentRegistration = { [key: string]: ModuleOrLazyImport };

const SVELTE_SELECTOR = "[data-svelte-component]"
const MOUNTED = "mountedComponent"
const UPDATE = Symbol("update")
const PATCH = Symbol("patch")
const beforeRender = "turbo:before-frame-render"
const beforeMorph = "turbo:before-morph-element"
let allComponents : Map<string, ModuleOrLazyImport> = new Map();
let cancelWatcher : CancelWatcherFunction
let didRegisterPermanentUpdate : boolean = false

function unmountFromElement(element : Element) {
  if(!element[MOUNTED]) {
    // If this is happening, there's probably something broken about our integration
    // with other JavaScript on the page, or the element managed to be removed in the
    // millisecond between being added and queueMicrotask firing?!
    if(!element.attributes["data-turbo-permanent"]) console.warn("Tried to unmount component that wasn't mounted", element);
    return;
  }
  delete element[PATCH];
  delete element[UPDATE];
  element.removeEventListener(beforeRender, onBeforeFrameRender);
  element.removeEventListener(beforeMorph, onBeforeMorphElement);
  unmount(element[MOUNTED]);
  delete element[MOUNTED];
}

declare global {
  interface Window {
    Turbo?: any;
  }
}

function sameComponent(a : HTMLElement, b : HTMLElement){
  return a.dataset.svelteComponent === b.dataset.svelteComponent
}

function updateComponent(target : HTMLElement, newElement : HTMLElement){
  target[UPDATE](snippetize(childJson(newElement)) || {})
}

function onBeforeFrameRender(event) {
  if(!sameComponent(event.target, event.detail.newFrame)) return;
  event.detail.render = updateComponent;
}

function onBeforeMorphElement(event) {
  console.log(event)
  const {target, detail: {newElement}} = event
  if(!sameComponent(target, newElement)) return;
  updateComponent(target, newElement)
  event.preventDefault()
}

function onBeforeRender(event) {
  const newBody = event.detail.newBody
  document.querySelectorAll(`[id][data-turbo-permanent]${SVELTE_SELECTOR}`).forEach(target => {
    if(!target[UPDATE]) return; // Can't think how this would happen
    const next = newBody.querySelector(`#${target.id}`);
    const nextProps = next && snippetize(childJson(next));
    if(nextProps) target[UPDATE](nextProps);
  })
}

async function mountRegistered(target : HTMLElement){
  if(target[MOUNTED]) {
    // Happens with data-turbo-permanent elements re-added to the DOM after a visit:
    // the original ("permanent"!) version of the component should remain.
    // onBeforeRender handles updating the component with possible new version of props.
    return;
  }
  let placeholder
  for(const element of target.children) {
    // Set placeholder if present, return early if there's anything here other than
    // placeholder and props <script> tag, because that means the component has been
    // rendered already. Happens during cached renders with turbo:drive, and AFAICT
    // the correct behavior is to do nothing.
    if(!placeholder && isPlaceholder(element as HTMLElement)) placeholder = element;
    else if(!isScriptJson(element)) return;
  }
  const data = target.dataset;
  const name = data.svelteComponent as string;
  const moduleOrImport = allComponents.get(name);
  if(!moduleOrImport) throw new Error(`Tried to mount unregistered Svelte component ${name}`);
  const component = ("default" in moduleOrImport) ? moduleOrImport.default : (await moduleOrImport()).default
  if(placeholder) target.removeChild(placeholder);
  const props = $state(snippetize(childJson(target)) || {})
  if(target.id) installStreamActions();
  target[UPDATE] = updateFn(props);
  target[PATCH] = patchFn(props);
  target[MOUNTED] = mount(component, {target, props});
  target.addEventListener(beforeRender, onBeforeFrameRender);
  target.addEventListener(beforeMorph, onBeforeMorphElement);
  // TODO: Figure out if turboPermanent is actually a good idea
  if(data.turboPermanent && !didRegisterPermanentUpdate) {
    didRegisterPermanentUpdate = true
    document.documentElement.addEventListener("turbo:before-render", onBeforeRender);
  }
}

function isPlaceholder(element: HTMLElement) {
  return !!element.dataset?.sveltePlaceholder;
}

function isScriptJson(element: Element) {
  return element.tagName.toUpperCase() === "SCRIPT" && element.attributes["type"]?.value === "application/json";
}

function childJson(element : HTMLElement){
  let json
  for(const child of element.children) {
    if(!isScriptJson(child)) continue;
    json = child.textContent;
    break;
  }
  if(!json) return null;
  return JSON.parse(json);
}

function snippetize(props) {
  for(const [key, value] of Object.entries(props)) {
    if(!value) continue;
    const html = value["_snippet"];
    if(html === undefined) continue;
    props[key] = createRawSnippet(()=>({render:()=>html || ""}))
  }
  return props;
}

function updateFn(props) {
  return function(nextProps){
    for (const [key, value] of Object.entries(nextProps)) {
      props[key] = value;
    }
  }
}

function patchFn(props){
  return function(jsonPatchDoc){
    applyPatch(props, jsonPatchDoc, false, true)
  }
}

function svelteSetTurboStreamAction() {
  this.targetElements.forEach(el=>updateComponent(el, this.templateContent))
}

function sveltePatchTurboStreamAction() {
  const jsonPatchDoc = childJson(this.templateContent);
  this.targetElements.forEach(el=>{
    // Haven't actually run into this problem, but it could happen if you write something very silly
    if(!el[PATCH]) return console.warn("Tried to patch Svelte props on element that doesn't have a Svelte component mounted", el);
    el[PATCH](jsonPatchDoc);
  })
}

function installStreamActions() {
  const StreamActions = globalThis.Turbo?.StreamActions
  if(StreamActions) {
    if(!StreamActions.svelte_set) StreamActions.svelte_set = svelteSetTurboStreamAction;
    if(!StreamActions.svelte_patch) StreamActions.svelte_patch = sveltePatchTurboStreamAction;
  }
}

export function registerSvelte(components : ComponentRegistration){
  if(cancelWatcher) cancelWatcher();
  allComponents = new Map([...allComponents, ...Object.entries(components)]);
  cancelWatcher = onElementExists(SVELTE_SELECTOR, (target)=>{
    // queueMicrotask (instead of doing it ASAP) to mount after Turbo Drive has
    // fully restored data-turbo-permanent, which may already have a component
    // mounted that doesn't need to be mounted again.
    queueMicrotask(()=>mountRegistered(target as HTMLElement))
    return unmountFromElement;
  });
}

export default registerSvelte;

export function globToComponents(globbedImport){
  return Object.entries(globbedImport).reduce((memo, kv)=>{
    const [path, imported] = kv
    const name = /[^\/.]+(?=\.svelte)/.exec(path)?.[0]
    if(!name) throw new Error("Only *.svelte globs supported");
    return Object.assign(memo, {[name]: imported})
  }, {})
}