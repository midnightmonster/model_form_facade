<script lang="ts">
  import { type Snippet } from "svelte";
  import { appendFieldNameContext, dataField, registerData, type JSONObject } from "./dataFormLib.svelte";
  let {
    name,
    data,
    errors,
    value = $bindable(),
    formValue = $bindable(),
    nth = $bindable(),
    children
  } : {
    name? : string;
    data? : JSONObject;
    errors? : JSONObject;
    value? : JSONObject;
    formValue? : JSONObject;
    nth? : number | undefined;
    children : Snippet;
  } = $props()
  const entireForm = registerData(data, errors);
  formValue = entireForm.value as JSONObject;
  appendFieldNameContext(name);
  const field = dataField(null);
  value = field.value as JSONObject;

  export function remove(){
    (field.value as JSONObject)._destroy = 1
  }

  $effect(()=>{
    nth = field.nth
  })
</script>
{@render children()}