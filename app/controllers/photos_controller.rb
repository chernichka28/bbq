class PhotosController < ApplicationController
  before_action :set_event, only: [:create, :destroy]
  before_action :set_photo, only: [:destroy]

  def create
    @new_photo = @event.photos.build(photo_params)

    @new_photo.user = current_user

    if @new_photo.save
      PhotoNotifySubscribersJob.perform_later(@new_photo)
      redirect_to @event, notice: t("controllers.photos.created")
    else
      render "events/show", alert: t("controllers.photos.error")
    end
  end

  def destroy
    message = {notice: t("controllers.photos.destroyed")}

    authorize @photo
    @photo.destroy

    redirect_to @event, message
  end

  private

  def set_event
    @event = Event.find(params[:event_id])
  end

  def set_photo
    @photo = @event.photos.find(params[:id])
  end

  def photo_params
    params.fetch(:photo, {}).permit(:photo)
  end
end
