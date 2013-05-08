class MessageAttachmentsController < ApplicationController

  def show
    asset = MessageAttachment.find(params[:id])
    # do security check here
    send_file asset.data.path, :type => asset.data_content_type
  end

  def destroy
    asset =  MessageAttachment.find(params[:id])
    @asset_id = asset.id.to_s
    @allowed = Task::Max_Attachments - asset.attachable.assets.count
    asset.destroy
  end

end
