# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
folder1 = Folder.create(name: "Project Files")
folder2 = Folder.create(name: "Reports")

#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
folder1.documents.create(name: "Introduction.pdf", file_path: "sample_pdfs/introduction.pdf")
folder1.documents.create(name: "Overview.pdf", file_path: "sample_pdfs/overview.pdf")
