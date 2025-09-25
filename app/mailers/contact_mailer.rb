class ContactMailer < ApplicationMailer
  default from: 'noreply@11b.dev'

  def new_contact(contact)
    @contact = contact
    @name = contact.name
    @email = contact.email
    @message = contact.message
    @phone = contact.phone

    mail(
      to: 'info@11b.dev', # Updated email address
      subject: "[11b Dev] New Contact from #{@name}"
    )
  end
end
