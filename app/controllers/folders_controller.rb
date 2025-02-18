class FoldersController < ApplicationController
  before_action :set_folder, only: [:show, :combine_documents]

  def index
    @folders = Folder.all
  end

  def show
    @documents = @folder.documents
  end

  
def combine_documents
  combined_html = Array(params[:document_ids]).map { |id| process_document(id) }.compact.join

  if params[:preview] == "true"
    # Render inline preview as combined text (including HTML)
    render json: { preview_text: combined_html }
  else
    # Download combined PDF
    pdf = WickedPdf.new.pdf_from_string(combined_html, exe_path: "/home/ror/.rvm/gems/ruby-3.2.1/bin/wkhtmltopdf")
    send_data pdf, filename: "combined_documents.pdf", type: "application/pdf", disposition: "attachment"
  end
end

  private

  def set_folder
    @folder = Folder.find_by(id: params[:id]) or redirect_to folders_path, alert: "Folder not found"
  end

  def process_document(id)
    document = Document.find_by(id: id)
    return unless document&.pdf_document&.attached?
  
    case document.pdf_document.content_type
    when 'text/plain'
      "<pre>#{document.pdf_document.download}</pre>" # Wrap .txt content in <pre> tags
    when 'text/html'
      document.pdf_document.download # Keep .html content as-is
    else
      nil
    end
  end
end
