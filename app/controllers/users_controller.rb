class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: [:edit, :update]

  def edit
    # User is already set via before_action
  end

  def update
    # Use Devise's update_with_password for secure password updates
    if user_params[:password].blank?
      # If password is blank, update without password (email only)
      params_hash = user_params.except(:password, :password_confirmation, :current_password)
      if @user.update_without_password(params_hash)
        redirect_to root_path, notice: 'Profile updated successfully.'
      else
        # Store errors to show in modal
        flash[:profile_errors] = @user.errors.full_messages
        flash[:open_modal] = 'editProfileModal'
        redirect_to root_path
      end
    else
      # If password is provided, use update_with_password (requires current_password)
      if @user.update_with_password(user_params)
        redirect_to root_path, notice: 'Profile updated successfully.'
      else
        # Store errors to show in modal
        flash[:profile_errors] = @user.errors.full_messages
        flash[:open_modal] = 'editProfileModal'
        redirect_to root_path
      end
    end
  end

  private

  def set_user
    @user = current_user
  end

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation, :current_password)
  end
end

