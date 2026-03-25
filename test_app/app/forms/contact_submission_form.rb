# Scenario A: HTML form via form_with, form-level validations, conditional save.
# Mirrors WaterPollutionInterestForm from jlg-portal-uk.
class ContactSubmissionForm < RecordForm
  include ActionView::ModelNaming

  validates :first_name, :last_name, :marketing_consent, :email, presence: {message: "Required"}
  validates :email, format: {with: URI::MailTo::EMAIL_REGEXP, message: "Check email address"}, if: -> { email.present? }

  field :first_name
  field :last_name
  field :email
  field :phone
  field :postal_code
  field :message
  field :marketing_consent

  def valid_enough?
    valid? || errors[:email].empty? && errors[:marketing_consent].empty?
  end

  def continue(params, request)
    set_fields(params)
    object.ip_address ||= request.remote_ip
    object.user_agent ||= request.user_agent
    object.save if valid_enough?
  end

  def model_name = object.model_name

  private

  def _params_root(root: nil)
    case root.nil? ? params_root : root
    in true then model_name_from_record_or_class(object).param_key&.to_sym
    in false then nil
    in Symbol => sym then sym
    in String => str then str.to_sym
    end
  end
end
