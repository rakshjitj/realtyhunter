namespace :maintenance do
	desc "clean up to match latest schema changes"
	task regen_paperclip_styles: :environment do

		Image.all.each do |i|
      if i.file_updated_at < Date.today &&
        i.user_id.nil? &&
        i.company_id.nil?
        puts "Processing image #{i.id} Last updated on: #{i.file_updated_at}"
  			i.file.reprocess! :large, :original
      end
		end

		puts "Done!\n"
	end
end
