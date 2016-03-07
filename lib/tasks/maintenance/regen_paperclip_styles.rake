namespace :maintenance do
	desc "clean up to match latest schema changes"
	task :regen_paperclip_styles => :environment do

		Image.all.each do |i|
			i.file.reprocess! :large, :original
		end

		puts "Done!\n"
	end
end
