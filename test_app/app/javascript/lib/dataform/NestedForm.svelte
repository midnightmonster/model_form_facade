<script lang="ts">
  import type { Snippet } from "svelte";
  import { appendFormNameContext } from "./dataFormLib.svelte";
  import DataForm from "./DataForm.svelte";
  import HiddenInput from "./HiddenInput.svelte";

  let {
    name,
    children
  } : {
    name: string;
    children: Snippet
  } = $props()

  appendFormNameContext(name);
</script>
<DataForm>
  <HiddenInput name="id" />
  {@render children()}
</DataForm>