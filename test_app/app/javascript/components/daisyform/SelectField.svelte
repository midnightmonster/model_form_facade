<script lang="ts">
  import { dataField } from "../../lib/dataform/dataFormLib.svelte";
  import Fieldset from "./Fieldset.svelte";
  import { asOptions, type RawOption, type Option } from "../railsform/util";
  import { partitionNames } from "./util";

  let {
    legend,
    name,
    required = false,
    disabled = undefined,
    options: rawOptions,
    selectedOption = $bindable(),
    prompt = "",
    class: className
  } : {
    legend?: string;
    name: string;
    required?: boolean;
    disabled?: boolean;
    options: Array<RawOption>;
    selectedOption?: Option | null;
    prompt?: string | false;
    class?: string;
  } = $props();

  let options = $derived(asOptions(rawOptions))
  let [inputClass, containerClass] = $derived.by(()=>partitionNames(className, /select-/))
  const field = dataField(name)
  $effect(()=>{
    selectedOption = options.find((opt)=>opt.value == field.value)
  })
</script>
<Fieldset error={field.error as string} {legend} {disabled} class={containerClass}>
  <select name={field.name} class="select w-full {inputClass}" class:select-error={field.error} bind:value={field.value} {required}>
    {#if prompt !== false}
      <option disabled selected={field.value === undefined || field.value === ""}>{prompt}</option>
    {/if}
    {#each options as {label, value}}
      <option {value}>{label}</option>
    {/each}
  </select>
</Fieldset>