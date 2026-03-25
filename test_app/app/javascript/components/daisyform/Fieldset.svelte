<script lang="ts">
  import type { Snippet } from "svelte";

  let {
    legend,
    note,
    error,
    class: className,
    legendClass,
    style,
    disabled = undefined,
    fieldset = $bindable<HTMLFieldSetElement>(),
    children,
    postfix = null
  } : {
    legend?: string;
    note?: string;
    error?: string;
    class?: string;
    legendClass?: string;
    style?: string;
    disabled?: boolean;
    fieldset? : HTMLFieldSetElement;
    children?: Snippet;
    postfix?: Snippet;
  } = $props()
</script>
<fieldset class="fieldset {className}" {disabled} bind:this={fieldset} {style}>
  {#if legend}
    <legend class="fieldset-legend {legendClass}">{legend}</legend>
  {/if}
  {@render children?.()}
  {#if error}
    <p class="label text-error">{error}</p>
  {:else if note}
    <p class="label">{note}</p>
  {/if}
  {@render postfix?.()}
</fieldset>
