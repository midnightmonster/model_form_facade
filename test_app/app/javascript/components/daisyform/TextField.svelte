<script lang="ts">
  import type { Snippet } from "svelte";
  import { dataField } from "../../lib/dataform/dataFormLib.svelte";
  import Fieldset from "./Fieldset.svelte";
  import { partitionNames } from "./util";

  let {
    legend,
    name,
    required = false,
    disabled = undefined,
    type = "text",
    class : className,
    postfix = null,
    ...rest
  } : {
    legend?: string;
    name: string;
    required?: boolean;
    disabled?: boolean;
    type?: string;
    class?: string;
    postfix?: Snippet
  } = $props();

  let [inputClass, containerClass] = $derived.by(()=>partitionNames(className, /input-/))
  const field = dataField(name)
</script>
<Fieldset error={field.error as string} {legend} {disabled} class={containerClass} {postfix} {...rest}>
  <input {type} name={field.name} class="input w-full {inputClass}" class:input-error={field.error} bind:value={field.value} {required} />
</Fieldset>