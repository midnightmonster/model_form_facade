# Base class for forms that rely only on model validations (no form-level validations).
# Mirrors leadwithcharacter's ApplicationForm.
class ApplicationForm
  include ModelFormFacade
end
