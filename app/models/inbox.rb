class Inbox < ActiveRecord::Base

belongs_to :profile

  def self.get_imessages_for_profile(current_profile)
    
    
    #@imessage_recipients = ImessageRecipient.find(:all)
    #@imessages = Imessage.find(:all)
    @imessages = current_profile.imessages
  end

end