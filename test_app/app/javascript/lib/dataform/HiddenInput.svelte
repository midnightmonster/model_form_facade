<script lang="ts">
  import { dataField } from "./dataFormLib.svelte";

  let {name} : {name:string} = $props()
  const field = dataField(name)
</script>
<input type="hidden" name={field.name} value={field.value} />