class Document < ApplicationRecord
  belongs_to :folder
  has_one_attached :pdf_document
  validate :pdf_document_is_pdf
  validates :name, presence: true

  private

  def pdf_document_is_pdf
  if pdf_document.attached? && pdf_document.content_type != 'application/pdf'
    errors.add(:pdf_document, 'must be a PDF file')
    Rails.logger.debug "Validation error: #{errors.full_messages}"  # Debugging line
  end
end

end
