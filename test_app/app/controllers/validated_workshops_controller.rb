# Scenario E: Form-level validations on top of model validations.
class ValidatedWorkshopsController < ApplicationController
  def new
  end

  def create
    validated_workshop_form.set_fields(params)
    validated_workshop_form.save!
    redirect_to workshops_path, status: 303
  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotSaved
    render :new, status: :unprocessable_entity
  end

  def edit
  end

  def update
    validated_workshop_form.set_fields(params)
    validated_workshop_form.save!
    redirect_to workshops_path, status: 303
  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotSaved
    render :edit, status: :unprocessable_entity
  end

  private

  helper_method def workshop
    @workshop ||= if params[:id]
      Workshop.find(params[:id])
    else
      Workshop.new
    end
  end

  helper_method def validated_workshop_form
    @validated_workshop_form ||= ValidatedWorkshopForm.new(workshop)
  end
end
