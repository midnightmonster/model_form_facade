<script lang="ts">
  import RailsForm from "./railsform/RailsForm.svelte";
  import DataForm from "../lib/dataform/DataForm.svelte";
  import NestedForm from "../lib/dataform/NestedForm.svelte";
  import ClassicNestedFormSet from "./daisyform/ClassicNestedFormSet.svelte";
  import TextField from "./daisyform/TextField.svelte";
  import SelectField from "./daisyform/SelectField.svelte";

  let { action, method, data, errors, options } = $props();
</script>

<RailsForm {action} {method}>
  <DataForm name="registration" {data} {errors}>
    <div class="card bg-base-100 shadow">
      <div class="card-body flex flex-col gap-4">
        <h3 class="font-bold text-lg">Primary Attendee</h3>
        <NestedForm name="primary_attendee">
          <div class="grid grid-cols-2 gap-4">
            <TextField legend="First Name" name="first_name" required />
            <TextField legend="Last Name" name="last_name" required />
          </div>
          <div class="grid grid-cols-2 gap-4 mt-3">
            <TextField legend="Email" name="email" type="email" />
            <TextField legend="Phone" name="phone" type="tel" />
          </div>
          <div class="grid grid-cols-2 gap-4 mt-3">
            <TextField legend="Dietary Requirements" name="dietary_requirements" />
            <TextField legend="Age" name="age" type="number" />
          </div>
        </NestedForm>

        <h3 class="font-bold text-lg mt-4">Additional Attendees</h3>
        <ClassicNestedFormSet name="additional_attendees">
          <div class="grid grid-cols-2 gap-3">
            <TextField legend="First Name" name="first_name" required />
            <TextField legend="Last Name" name="last_name" required />
          </div>
          <div class="grid grid-cols-2 gap-3 mt-2">
            <TextField legend="Email" name="email" type="email" />
            <TextField legend="Phone" name="phone" type="tel" />
          </div>
          <div class="grid grid-cols-2 gap-3 mt-2">
            <TextField legend="Dietary Requirements" name="dietary_requirements" />
            <TextField legend="Age" name="age" type="number" />
          </div>
          {#snippet add(addItem)}
            <button type="button" class="btn btn-sm btn-outline" onclick={() => addItem()}>+ Add Attendee</button>
          {/snippet}
        </ClassicNestedFormSet>

        <div class="form-control mt-4">
          <button type="submit" class="btn btn-primary">Save Registration</button>
        </div>
      </div>
    </div>
  </DataForm>
</RailsForm>
