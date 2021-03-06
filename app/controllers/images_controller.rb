# frozen_string_literal: true

class ImagesController < ApplicationController
  before_action :set_photo_album, only: %i[create destroy]
  before_action :set_image, only: %i[show edit]

  def show
    @photo_album = @image.photo_album
    @author = @photo_album.author
  end

  def edit
    authorize @image
    @photo_album = @image.photo_album
    @author = @photo_album.author
  end

  def create
    add_more_images(images_params[:images])
    flash[:error] = 'Failed uploading images' unless @photo_album.save
    redirect_to user_photo_album_path(current_user, @photo_album)
  end

  def update
    @image = Image.find_by_slug(params[:id])
    authorize @image
    if @image.update(images_params)
      flash[:success] = 'Image was successfuly updated'
      redirect_to @image
    else
      flash[:success] = 'There was a problem updating your image'
      render :edit
    end
  end

  def destroy
    @image = Image.find_by_slug(params[:id])
    authorize @image
    flash[:success] = if @image.destroy
                        'Image was successfuly destroyed'
                      else
                        'There was a problem destroying your image.'
                      end
    redirect_to edit_user_photo_album_path(current_user, @photo_album)
  end

  private

  def set_photo_album
    @photo_album = PhotoAlbum.find_by_slug(params[:photo_album_id])
  end

  def set_image
    @image = Image.includes(photo_album: :images).find_by_slug(params[:id])
  end

  def add_more_images(new_images)
    images = @photo_album.images
    images += new_images
    @photo_album.images = images
  end

  def images_params
    params.permit(:description, images: [])
  end
end
