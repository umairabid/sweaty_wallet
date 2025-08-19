# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: 'info@sweatywallet.ca'
  layout 'mailer'
end
