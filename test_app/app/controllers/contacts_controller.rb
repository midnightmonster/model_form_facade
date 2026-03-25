# Scenario A: HTML form with form_with, form-level validations, conditional save.
class ContactsController < ApplicationController
  def show
  end

  def update
    contact_form.continue(params, request)
    @success = contact_form.valid?
    render :show
  end

  private

  helper_method def contact_submission
    @contact_submission ||= ContactSubmission.new
  end

  helper_method def contact_form
    @contact_form ||= ContactSubmissionForm.new(contact_submission)
  end

  helper_method def form_id = "contact-form"
end
