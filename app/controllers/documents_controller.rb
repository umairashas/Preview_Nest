class DocumentsController < ApplicationController

  def index
    @documents = Document.all
    respond_to do |format|
      format.html # renders app/views/documents/index.html.erb
      format.json { render json: @documents }
    end
  end

  


  def new
    @folder = Folder.find(params[:folder_id])
    @document = Document.new
  end

  def create
  @folder = Folder.find(params[:folder_id])  # Ensure folder is correctly fetched

    @document = @folder.documents.build(document_params)

  if @document.save
    respond_to do |format|
      format.html { redirect_to folder_path(@folder), notice: 'Document was successfully uploaded.' }
      format.js { render json: { id: @document.id, name: @document.name } }
    end
  else
    respond_to do |format|
      format.html { render :new }
      format.js { render json: { error: @document.errors.full_messages }, status: :unprocessable_entity }
    end
  end
  end




  def destroy
  @folder = Folder.find(params[:folder_id])
  @document = @folder.documents.find(params[:id])

  @document.destroy
  respond_to do |format|
    format.html { redirect_to folder_path(@folder) }
    format.js   # This will trigger the destroy.js.erb view
  end
  end

  private

  def document_params
    params.require(:document).permit(:name, :pdf_document)
  end
end