<script lang="ts">
  import type { Snippet } from 'svelte';
  import { csrfToken } from "./util";
  import type { FormEventHandler } from 'svelte/elements';
  let {
    action = "",
    method: logicalMethod = "get",
    class: className = null,
    id = null,
    onsubmit = null,
    form = $bindable(),
    children,
    ...props
  } : {
    action? : string;
    method? : string;
    class? : string;
    id? : string;
    onsubmit? : FormEventHandler<HTMLFormElement>;
    form? : HTMLFormElement;
    children? : Snippet;
    props? : {[key: string]: any};
  } = $props()
  let [method, railsMethod] = ["get", "post"].includes(logicalMethod.toLowerCase()) ? [logicalMethod, null] : ["post", logicalMethod]
</script>
<form bind:this={form} {action} {onsubmit} method={method as "get" | "post"} {id} class={className} {...props}>
  {#if railsMethod}
    <input type="hidden" autocomplete="off" name="_method" value={railsMethod}>
  {/if}
  {@render children?.()}
  {#if method.toLowerCase() !== "get"}
    <input type="hidden" autocomplete="off" {...csrfToken()}>
  {/if}
</form>
