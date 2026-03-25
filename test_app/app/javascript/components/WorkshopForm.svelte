<script lang="ts">
  import RailsForm from "./railsform/RailsForm.svelte";
  import DataForm from "../lib/dataform/DataForm.svelte";
  import NestedForm from "../lib/dataform/NestedForm.svelte";
  import ClassicNestedFormSet from "./daisyform/ClassicNestedFormSet.svelte";
  import TextField from "./daisyform/TextField.svelte";
  import SelectField from "./daisyform/SelectField.svelte";
  import Fieldset from "./daisyform/Fieldset.svelte";
  import { dataField } from "../lib/dataform/dataFormLib.svelte";

  let { action, method, data, errors, options } = $props();
</script>

<RailsForm {action} {method}>
  <DataForm name="workshop" {data} {errors}>
    <div class="card bg-base-100 shadow">
      <div class="card-body flex flex-col gap-4">
        <div class="grid grid-cols-2 gap-4">
          <TextField legend="Title" name="title" required />
          <TextField legend="Slug" name="slug" required />
        </div>

        <div class="grid grid-cols-3 gap-4">
          <SelectField legend="Category" name="category" options={options.categories} required />
          <SelectField legend="Status" name="status" options={[["Draft", "draft"], ["Published", "published"], ["Archived", "archived"]]} />
          <TextField legend="Max Capacity" name="max_capacity" type="number" />
        </div>

        <div class="grid grid-cols-2 gap-4">
          <TextField legend="Start Date" name="start_date" type="date" />
          <TextField legend="End Date" name="end_date" type="date" />
        </div>

        <NestedForm name="description">
          <TextField legend="Description (Markdown)" name="markdown" />
        </NestedForm>

        <NestedForm name="pricing_info">
          <TextField legend="Pricing Info (Markdown)" name="markdown" />
        </NestedForm>

        <h3 class="font-bold text-lg">Materials</h3>
        <ClassicNestedFormSet name="materials">
          <DataForm>
            <div class="grid grid-cols-4 gap-3">
              <TextField legend="Name" name="name" required />
              <TextField legend="Quantity" name="quantity" type="number" />
              <TextField legend="Unit Cost" name="unit_cost" type="number" />
              {#snippet hidden_field()}
                {@const field = dataField("hidden")}
                {@const [get, set] = field.asBoolean}
                <Fieldset legend="Hidden">
                  <input type="hidden" name={field.name} value="false" />
                  <label class="label cursor-pointer justify-start gap-2">
                    <input type="checkbox" name={field.name} class="checkbox" bind:checked={get, set} value="true" />
                    <span>Hidden</span>
                  </label>
                </Fieldset>
              {/snippet}
              {@render hidden_field()}
            </div>
          </DataForm>
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
