require 'combine_pdf'
require 'nokogiri'

class FoldersController < ApplicationController
  before_action :set_folder, only: [:show, :combine_documents]

  def index
    @folders = Folder.all
  end

  def show
    @documents = @folder.documents
  end

  def combine_documents
    document_ids = params[:document_ids]
    pdf = CombinePDF.new

    document_ids.each do |id|
      begin
        document = Document.find(id)
        
        if document.pdf_document.attached?
          case document.pdf_document.content_type
          when 'text/plain'
            text = document.pdf_document.download
            pdf << text_to_pdf(text)
          when 'text/html'
            html_content = document.pdf_document.download
            plain_text = Nokogiri::HTML(html_content).at('body')&.text || ''
            pdf << text_to_pdf(plain_text.strip)
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

    send_data pdf.to_pdf, filename: "combined_documents.pdf", type: "application/pdf", disposition: "attachment"
  end

  private

  def set_folder
    @folder = Folder.find(params[:id])
  end

  def text_to_pdf(text)
    pdf = CombinePDF.new
    temp_pdf = Prawn::Document.new
    temp_pdf.text text
    pdf << CombinePDF.parse(temp_pdf.render)
    pdf
  end
end
