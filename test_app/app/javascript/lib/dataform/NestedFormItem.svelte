<script lang="ts">
  import type { Snippet } from "svelte";
  import { appendFormNameContext } from "./dataFormLib.svelte";

  let {
    name,
    index,
    children
  } : {
    name: string;
    index: number;
    children: Snippet
  } = $props()

  appendFormNameContext(name, index);
</script>
{@render children()}