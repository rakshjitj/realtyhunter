namespace :import do
  desc "import building LLC names. Data is used by Zoho"
  task building_llc_names: :environment do

    require 'csv'
    log = ActiveSupport::Logger.new('log/building_llc_names.log')
    start_time = Time.now

    puts "Reading CSV data..."
    log.info "Reading CSV data..."

    unmatched_bldgs = []
    count = 0
    CSV.foreach('lib/tasks/import/building_llc_names.csv', col_sep: ',') { |row|
      if count == 0
        count = count + 1
        next
      end
      count = count + 1

      # csv columns are as follows:
      # street address, city, state and zip, LLC name
      # puts row
      # puts "****" + row[3]
      # exit

      street_address = row[0]
      llc = row[3]
      if !llc
        # rows are not all the same lenght, but LLC is always the last entry
        llc = row[2]
        if !llc
          puts "No LLC identified for #{row}"
          exit
        end
      end

      bldg = Building.where("formatted_street_address ilike ?", "%#{street_address}%").first
      if bldg
        bldg.update_columns(llc_name: llc)
        puts "Updated #{street_address} to have #{llc}\n"
      else
        unmatched_bldgs = [street_address, llc]
      end
    }

    puts "\nThese buildings were not found in our system:\n"
    puts unmatched_bldgs
    puts "Done!\n"
    log.info "Done!\n"
    end_time = Time.now
    duration = (start_time - end_time) / 1.minute
    log.info "Task finished at #{end_time} and last #{duration} minutes."
    log.close
  end
end
