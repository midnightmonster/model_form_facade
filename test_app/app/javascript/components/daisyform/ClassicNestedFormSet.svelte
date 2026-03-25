<script lang="ts">
  import type { Snippet } from "svelte";
  import type { JSONObject } from "../../lib/dataform/dataFormLib.svelte";
  import NestedFormSet from "../../lib/dataform/NestedFormSet.svelte";

  let {
    name,
    value = $bindable(),
    add: providedAdd,
    restore: providedRestore,
    children
  } : {
    name: string;
    value? : JSONObject[];
    add?: Snippet<[(item?)=>void]>;
    restore?: Snippet<[()=>void, JSONObject?]>;
    children: Snippet;
  } = $props()
</script>
<div class="bg-base-200 shadow-inner rounded p-3 grid grid-cols-1 gap-3">
  <NestedFormSet {name} {value}>
    <div class="bg-base-100 shadow rounded p-3">
      {@render children()}
    </div>
    {#snippet add(addItem)}
      {#if providedAdd}
        <div class="bg-base-100 shadow rounded p-3 empty:hidden">{@render providedAdd(addItem)}</div>
      {/if}
    {/snippet}
    {#snippet restore(restoreItem, item)}
      {#if providedRestore}
        <div class="bg-base-100 shadow rounded p-3 empty:hidden">{@render providedRestore(restoreItem, item)}</div>
      {/if}
    {/snippet}
  </NestedFormSet>
</div>