class Users::RegistrationsController < Devise::RegistrationsController
  def create
    super do |resource|
      if resource.persisted?
        SignUpMailJob.perform_later(resource.id)
      end
    end
  end
end

