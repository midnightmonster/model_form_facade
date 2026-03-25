<script lang="ts">
  import type { Snippet } from "svelte";
  import NestedFormItem from "./NestedFormItem.svelte";
  import { dataField, type JSONObject } from "./dataFormLib.svelte";
  import DataForm from "./DataForm.svelte";
  import HiddenInput from "./HiddenInput.svelte";

  let {
    name,
    value = $bindable(),
    add,
    restore,
    children
  } : {
    name: string;
    value? : JSONObject[];
    add?: Snippet<[(item?)=>void]>;
    restore?: Snippet<[()=>void, JSONObject?]>;
    children: Snippet;
  } = $props()

  const field = dataField(name);
  field.value ||= []
  value = (field.value as JSONObject[])
  export function addItem(item={}) {
    (field.value as JSONObject[]).push(item)
  }
  const restoreItemFn = (item)=>()=>item._destroy = null
</script>
{#each (field.value as JSONObject[]) as item, index}
  {#if item._destroy}
    <NestedFormItem {name} {index}>
      <DataForm><HiddenInput name="id" /><HiddenInput name="_destroy" /></DataForm>
      {@render restore?.(restoreItemFn(item), item)}
    </NestedFormItem>
  {:else}
    <NestedFormItem {name} {index}>
      <DataForm><HiddenInput name="id" /></DataForm>
      {@render children?.()}
    </NestedFormItem>
  {/if}
{/each}
{@render add?.(addItem)}
