class HomeController < ApplicationController
  before_filter :full_width, :except => :about
#layout 'home', :only=>['tour']
  def about
    @clip = params[ :clip ]
  end
  
  def file_too_large; end

  def contact
    if request.post?
      if params[:contact][:email].present?
        Mailer.deliver_feedback(params[:contact])
        add_notice "Thanks for your feedback!"
        redirect_to contact_url
      else
        add_error "Please enter a valid email address."
         redirect_to contact_url
      end
    end
  end


    def developers
    render
  end

    def developer_create
      if request.post?
      if params[:developer][:email].present?

        Mailer.deliver_developers(params[:developer])
        add_notice "Thanks for your interest towards Original Projects"
        redirect_to developers_url
      else
        add_error "Please enter a valid email address."
        puts "a"
        render :action=> "developers"
      end
      end
    end



   ###uncommented at the moment Aug31 for start your service(contact form)
#    def services_intro
#    if request.post?
#      if params[:contact][:email].present?
#        Mailer.deliver_feedback(params[:contact])
#        add_notice "Thanks for your interest in Original Services!"
#        redirect_to services_intro_url
#      else
#        add_error "Please enter a valid email address."
#      end
#    end
#  end

  def index
    @envelope_class = %w(full_width home)
  end

  def privacy
  end

  def report_problem
  end
  def tour

  end

  def tos
  end
  
  def about
    full_width unless logged_in?
  end
end
