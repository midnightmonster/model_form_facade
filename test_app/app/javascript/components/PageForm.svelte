<script lang="ts">
  import RailsForm from "./railsform/RailsForm.svelte";
  import DataForm from "../lib/dataform/DataForm.svelte";
  import NestedForm from "../lib/dataform/NestedForm.svelte";
  import TextField from "./daisyform/TextField.svelte";
  import { dataField } from "../lib/dataform/dataFormLib.svelte";

  let { action, method, data, errors } = $props();

  // system is a read-only field serialized as "true" or ""
  let isSystem = $derived(data?.page?.system === "true");
</script>

<RailsForm {action} {method}>
  <DataForm name="page" {data} {errors}>
    <div class="card bg-base-100 shadow">
      <div class="card-body flex flex-col gap-4">
        {#if isSystem}
          <div class="alert alert-warning">
            <span>This is a system page. The name cannot be changed.</span>
          </div>
        {/if}

        <TextField legend="Name" name="name" required disabled={isSystem} />

        <NestedForm name="rich_content">
          <TextField legend="Content (Markdown)" name="markdown" />
        </NestedForm>

        <div class="form-control mt-4">
          <button type="submit" class="btn btn-primary">Save Page</button>
        </div>
      </div>
    </div>
  </DataForm>
</RailsForm>
