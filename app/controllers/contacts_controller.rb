class ContactsController < ApplicationController
  def create
    @contact = Contact.new(contact_params)
    
    respond_to do |format|
      if @contact.save
        ContactMailer.new_contact(@contact).deliver_now
        format.html { redirect_to contact_path, notice: "Thanks for reaching out! We'll get back to you faster than a Deadhead chasing a tour bus." }
        format.turbo_stream { flash[:notice] = "Message sent successfully!" }
      else
        format.html { redirect_to contact_path, alert: "Oops! Something went wrong. Please check your info and try again." }
        format.turbo_stream { render turbo_stream: turbo_stream.replace("contact_form", partial: "pages/contact_form", locals: { contact: @contact }) }
      end
    end
  end

  private

  def contact_params
    params.require(:contact).permit(:name, :email, :message, :phone)
  end
end
