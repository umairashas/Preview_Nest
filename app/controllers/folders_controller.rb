require 'combine_pdf'
require 'nokogiri'
require 'prawn'

class FoldersController < ApplicationController
  before_action :set_folder, only: [:show, :combine_documents]

  def index
    @folders = Folder.all
  end

  def show
    @documents = @folder.documents
  end

 def combine_documents
  document_ids = params[:document_ids] || []
  pdf = CombinePDF.new
  combined_text = ''

  document_ids.each do |id|
    begin
      document = Document.find(id)
      if document.pdf_document.attached?
        case document.pdf_document.content_type
        when 'text/plain'
          text = document.pdf_document.download
          pdf << text_to_pdf(text)
          combined_text += text # Add text to combined text
        when 'text/html'
          html_content = document.pdf_document.download
          plain_text = Nokogiri::HTML(html_content).at('body')&.text || ''
          pdf << text_to_pdf(plain_text.strip)
          combined_text += plain_text.strip # Add text to combined text
        when 'application/pdf'
          pdf << CombinePDF.parse(document.pdf_document.download)
        else
          Rails.logger.warn "Unsupported content type: #{document.pdf_document.content_type}"
        end
      else
        Rails.logger.warn "Document with ID #{id} has no attached file."
      end
    rescue ActiveRecord::RecordNotFound => e
      Rails.logger.error "Document with ID #{id} not found: #{e.message}"
    rescue StandardError => e
      Rails.logger.error "Error processing document with ID #{id}: #{e.message}"
    end
  end

  if params[:preview] == "true"
    # Render inline preview as combined text
    render json: { preview_text: combined_text }
  else
    # Download combined PDF
    send_data pdf.to_pdf, filename: "combined_documents.pdf", type: "application/pdf", disposition: "attachment"
  end
end


  private

  def set_folder
    @folder = Folder.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = "Folder not found"
    redirect_to folders_path
  end

  def text_to_pdf(text)
    pdf = Prawn::Document.new
    pdf.text text
    CombinePDF.parse(pdf.render)
  end
end
