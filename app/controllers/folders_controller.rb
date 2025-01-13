require 'combine_pdf'

class FoldersController < ApplicationController
  before_action :set_folder, only: [:show]
  
  def index
    @folders = Folder.all
  end

  def show
    @documents = @folder.documents
  end

  def destroy
    @document = @folder.documents.find(params[:id]) # Find the document by its ID
    if @document.destroy
      redirect_to folder_path(@folder), notice: "Document successfully deleted."
    else
      redirect_to folder_path(@folder), alert: "Failed to delete document."
    end
  end

  def combine_documents
  document_ids = params[:document_ids] # IDs of selected documents
  pdf = CombinePDF.new

  # Loop through selected documents and add them to the combined PDF
  document_ids.each do |id|
    document = Document.find(id)
    if document.pdf_document.attached? && document.pdf_document.content_type == 'application/pdf'
      pdf << CombinePDF.parse(document.pdf_document.download)
    end
  end

  # Send the combined PDF as a response
  send_data pdf.to_pdf,
            filename: "combined_documents.pdf",
            type: "application/pdf",
            disposition: "inline"
end


  private

  def set_folder
    @folder = Folder.find(params[:id])
  end
end
