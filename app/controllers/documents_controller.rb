class DocumentsController < ApplicationController
  def index
    @documents = Document.all
  end

  def new
    @folder = Folder.find(params[:folder_id])
    @document = Document.new
  end

  def create
    @folder = Folder.find(params[:folder_id])
    @document = @folder.documents.build(document_params)

    if @document.save
      redirect_to folder_path(@folder), notice: 'Document was successfully uploaded.'
    else
      render :new
    end
  end

  def destroy
    @folder = Folder.find(params[:folder_id])
    @document = @folder.documents.find(params[:id])
    @document.destroy

    redirect_to folder_path(@folder)
  end

  private

  def document_params
    params.require(:document).permit(:name, :pdf_document)
  end
end
