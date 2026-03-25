# Scenario C: Svelte DataForm with custom assign_attributes (buffer-and-transform).
class RegistrationsController < ApplicationController
  def index
  end

  def new
  end

  def create
    registration_form.set_fields(params)
    registration_form.save!
    redirect_to registrations_path, status: 303
  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotSaved
    render :new, status: :unprocessable_entity
  end

  def edit
  end

  def update
    registration_form.set_fields(params)
    registration_form.save!
    redirect_to registrations_path, status: 303
  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotSaved
    render :edit, status: :unprocessable_entity
  end

  private

  helper_method def registrations = Registration.includes(:workshop).order(created_at: :desc)

  helper_method def registration
    @registration ||= if params[:id]
      Registration.find(params[:id])
    else
      Registration.new(workshop: Workshop.first).tap do |r|
        r.attendees.build # primary attendee
      end
    end
  end

  helper_method def registration_form
    @registration_form ||= RegistrationForm.new(registration)
  end
end
