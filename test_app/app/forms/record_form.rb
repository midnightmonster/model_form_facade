# Base class for forms that include ActiveModel::Validations (form-level validations).
# Mirrors jlg-portal-uk's RecordForm.
class RecordForm
  include ModelFormFacade
  include ActiveModel::Validations
end
