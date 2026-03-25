import { getContext, hasContext, setContext } from "svelte";

const FIELD_NAME = Symbol("FIELD_NAME")
const FORM_NAME = Symbol("FORM_NAME")
const DATA = Symbol("DATA")
const ERRORS = Symbol("ERRORS")

type NameContext = Array<string|number>;
export type JSONValue =
  | string
  | number
  | boolean
  | null
  | { [key: string]: JSONValue }
  | JSONValue[];
export type JSONObject = { [key: string]: JSONValue };

export function getFieldNameContext(){
  return (getContext(FIELD_NAME) || []) as NameContext;
}

export function setFieldNameContext(v: NameContext){
  setContext(FIELD_NAME, v);
}

export function getFormNameContext(){
  return (getContext(FORM_NAME) || []) as NameContext;
}

export function setFormNameContext(v: NameContext){
  setContext(FORM_NAME, v);
}

export function appendFieldNameContext(...names: NameContext) {
  let context = getFormNameContext();
  context = [...context, ...names.filter(v=>v)];
  setFieldNameContext(context);
}

export function appendFormNameContext(...names: NameContext) {
  let context = getFieldNameContext();
  context = [...context, ...names];
  setFormNameContext(context);
}

export function fieldName(name: string) {
  let context = getFieldNameContext();
  if(!context.length) return name;
  let [first, ...rest] = [...context, name];
  return `${first}[${rest.join("][")}]`
}

export function registerData(data, errors = null) {
  const dataState = $state(data || {});
  if(!hasContext(DATA)) setContext(DATA, dataState);
  const errorsState = $state(errors || {});
  if(!hasContext(ERRORS)) setContext(ERRORS, errorsState);
  return new DataField();
}

function dig(data : JSONObject, keys : Array<string|number>, throwError : boolean = false) {
  let pointer : JSONValue = data
  for(const key of keys) {
    pointer = pointer[key];
    if(pointer === null || typeof pointer === "undefined") {
      if(!throwError) break;
      const message = `Could not find data under [${keys.join(", ")}]`
      console.error(message, $state.snapshot(data))
      throw new Error(message);
    }
  }
  return pointer;
}

type ErrorReportingElement = HTMLButtonElement | HTMLFieldSetElement | HTMLInputElement | HTMLOutputElement | HTMLSelectElement | HTMLTextAreaElement

class DataField {
  #dataContext : JSONObject
  #errorsContext : JSONObject
  #nameContext : NameContext
  #fullNameContext : NameContext
  #localName : string | number | undefined
  #name : string
  #value = $derived.by(()=>dig(this.#dataContext, this.#fullNameContext))
  #error = $derived.by(()=>dig(this.#errorsContext, this.#fullNameContext))
  #errorElement : ErrorReportingElement
  #errorReporting : ()=>(()=>void)

  constructor(localName=null) {
    this.#fullNameContext = [...getFieldNameContext()]
    if(localName) this.#fullNameContext.push(localName);
    this.#nameContext = [...this.#fullNameContext];
    this.#localName = this.#nameContext.pop();
    this.#dataContext = getContext(DATA) as JSONObject;
    this.#errorsContext = getContext(ERRORS) as JSONObject;
  }

  get name(){
    if(!this.#name) {
      let [first, ...rest] = this.#fullNameContext
      this.#name = `${first}[${rest.join("][")}]`
    }
    return this.#name;
  }

  get value() {
    return this.#value;
  }

  set value(v){
    const obj = dig(this.#dataContext, this.#nameContext, true)
    if(!obj) {
      const msg = `Error setting ${this.#localName}: Object not found in dataContext at path [${this.#nameContext.join(",")}]`
      console.error(msg, {dataContext: this.#dataContext, nameContext: this.#nameContext})
      throw msg
    }
    if(!this.#localName) {
      throw "DataField without a localName is read-only"
    }
    obj[this.#localName] = v
  }

  // So far only meaningful in DataForm components that are children of a NestedFormSet
  get nth() {
    const parentContext = this.#fullNameContext.slice(0, -1)
    const parent = dig(this.#dataContext, parentContext)
    if(!Array.isArray(parent)) return undefined;
    const v = this.value
    const present = notDeleted(parent)
    for(let i=0; i < present.length; i++) {
      if(present[i] === v) return i;
    }
    return undefined; // This should only happen if this subform is currently deleted
  }

  getBoolean() {
    return !!this.#value && this.#value !== "false" && this.#value !== "f"
  }

  setBoolean(v : boolean) {
    this.value = v ? "true" : "false"
  }

  get asBoolean() {
    return [()=>this.getBoolean(), (v)=>this.setBoolean(v)] as const;
  }

  get error() {
    return this.#error;
  }

  set errorElement(el : ErrorReportingElement) {
    this.#errorElement = el
    if(!this.#errorReporting) {
      const unset = (event:Event)=>{
        (event.target as ErrorReportingElement)?.setCustomValidity("")
        event.target?.removeEventListener("input", unset)
      }
      this.#errorReporting = ()=>{
        const last = this.#errorElement
        if(this.#error) {
          this.#errorElement?.setCustomValidity(this.#error as string)
          this.#errorElement?.reportValidity()
          this.#errorElement?.addEventListener("input", unset)
        } else {
          this.#errorElement?.setCustomValidity("")
        }
        return ()=>{
          last?.setCustomValidity("")
        }
      }
      $effect(this.#errorReporting)
    }
  }
}

export function dataField(name) {
  return new DataField(name);
}

export function localFormData() {
  return dig(getContext(DATA), getFieldNameContext(), true) as JSONObject;
}

export function notDeleted(items) {
  return items.filter(item => !item._destroy)
}