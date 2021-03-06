# frozen_string_literal: true

class NotificationsController < ApplicationController
  def index
    respond_to do |format|
      format.json do
        @notifications ||= Notification.includes(:recipient,
                                                 :notifiable,
                                                 actor: :profile)
          .where(recipient: current_user)
          .recent
        @count = Notification.where(recipient: current_user).size
      end
      format.html do
        @all_notifications = Notification.includes(:notifiable,
                                                   actor: :profile)
          .where(recipient: current_user)
          .ordered
          .page(params[:page])
      end
    end
  end

  def mark_as_read
    @notifications = Notification.where(recipient: current_user).unread
    @notifications.update_all(read: true)
    render json: { success: true }
  end

  def clear
    notifications = Notification.where(recipient: current_user).read
    notifications.destroy_all
    flash[:success] = 'Notifications cleared'
    redirect_to notifications_path
  end
end
