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
    combined_html = ''
  
    document_ids.each do |id|
      begin
        document = Document.find(id)
        if document.pdf_document.attached?
          case document.pdf_document.content_type
          when 'text/plain'
            combined_html += "<pre>#{document.pdf_document.download}</pre>"
          when 'text/html'
            combined_html += document.pdf_document.download
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
      render json: { preview_text: combined_html }
    else
      pdf = WickedPdf.new.pdf_from_string(combined_html, exe_path: "/home/ror/.rvm/gems/ruby-3.2.1/bin/wkhtmltopdf")
      send_data pdf, filename: "combined_documents.pdf", type: "application/pdf", disposition: "attachment"
    end
  end


  private

  def set_folder
    @folder = Folder.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = "Folder not found"
    redirect_to folders_path
  end

  def text_to_pdf(content, content_type)
    pdf = Prawn::Document.new
  
    case content_type
    when 'text/html'
      # Parse HTML content and render it in the PDF
      doc = Nokogiri::HTML(content)
      doc.css('body').children.each do |element|
        case element.name
        when 'h1', 'h2', 'h3', 'h4', 'h5', 'h6'
          pdf.text element.text, size: 16, style: :bold
        when 'p'
          pdf.text element.text, size: 12
        when 'ul', 'ol'
          element.css('li').each do |li|
            pdf.text "• #{li.text}", size: 12
          end
        when 'a'
          pdf.text "Link: #{element['href']}", size: 12, color: '0000FF'
        when 'hr'
          pdf.stroke_horizontal_rule
        else
          pdf.text element.text, size: 12
        end
        pdf.move_down 10
      end
    when 'text/plain'
      # Render plain text as-is
      pdf.text content, size: 12
    else
      pdf.text "Unsupported content type: #{content_type}", size: 12
    end
  
    CombinePDF.parse(pdf.render)
  end
end
