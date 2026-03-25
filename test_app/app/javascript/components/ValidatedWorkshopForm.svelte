<script lang="ts">
  import RailsForm from "./railsform/RailsForm.svelte";
  import DataForm from "../lib/dataform/DataForm.svelte";
  import ClassicNestedFormSet from "./daisyform/ClassicNestedFormSet.svelte";
  import TextField from "./daisyform/TextField.svelte";
  import SelectField from "./daisyform/SelectField.svelte";

  let { action, method, data, errors, options } = $props();
</script>

<RailsForm {action} {method}>
  <DataForm name="workshop" {data} {errors}>
    <div class="card bg-base-100 shadow">
      <div class="card-body flex flex-col gap-4">
        <p class="text-sm opacity-60">
          This form has form-level validations (title min 5 chars, slug format)
          in addition to the model's own validations (title, slug, category presence).
        </p>

        <div class="grid grid-cols-2 gap-4">
          <TextField legend="Title (min 5 chars)" name="title" required />
          <TextField legend="Slug (lowercase, numbers, hyphens)" name="slug" required />
        </div>

        <div class="grid grid-cols-2 gap-4">
          <SelectField legend="Category" name="category" options={options.categories} required />
          <SelectField legend="Status" name="status" options={[["Draft", "draft"], ["Published", "published"], ["Archived", "archived"]]} />
        </div>

        <h3 class="font-bold text-lg">Materials</h3>
        <ClassicNestedFormSet name="materials">
          <div class="grid grid-cols-2 gap-3">
            <TextField legend="Name" name="name" required />
            <TextField legend="Quantity" name="quantity" type="number" />
          </div>
          {#snippet add(addItem)}
            <button type="button" class="btn btn-sm btn-outline" onclick={() => addItem()}>+ Add Material</button>
          {/snippet}
        </ClassicNestedFormSet>

        <div class="form-control mt-4">
          <button type="submit" class="btn btn-primary">Save Workshop</button>
        </div>
      </div>
    </div>
  </DataForm>
</RailsForm>
