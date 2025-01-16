class Document < ApplicationRecord
  belongs_to :folder
  has_one_attached :pdf_document
  validates :name, presence: true
  validate :validate_file_type

  private

  def validate_file_type
    if pdf_document.attached?
      unless %w[text/plain text/html].include?(pdf_document.content_type)
        errors.add(:pdf_document, 'must be a .txt or .html file')
      end
    end
  end
end
