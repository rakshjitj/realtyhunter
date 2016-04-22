namespace :maintenance do
	desc "clean up to match latest schema changes"
	task regen_paperclip_styles: :environment do

    error_log = []
    imgs = Image.all
    # todo: use find_each to batch process
		imgs.each do |i|
      if i.user_id.nil? && i.company_id.nil? &&
          i.unit #&& i.unit.residential_listing && !i.unit.residential_listing.tenant_occupied &&
          #i.file_updated_at < Date.today
        puts "Processing image #{i.id} Last updated on: #{i.file_updated_at}"
        begin
    			i.file.reprocess! :medium #:large, :original
        rescue
          error_log << "FAILED image #{i.id} Last updated on: #{i.file_updated_at}"
        end
      end
		end

    puts error_log.join("\n")
		puts "Done!\n"
	end
end
