namespace :import do
  desc "Import Nestio's user data into our database"
  task :users => :environment do
    log = ActiveSupport::Logger.new('log/import_users.log')
    
    def mark_done(log, start_time)
      puts "Done!\n"
      log.info "Done!\n"
      end_time = Time.now
      duration = (start_time - end_time) / 1.minute
      log.info "Task finished at #{end_time} and last #{duration} minutes."
      log.close
    end

    # TODO: make into commandline args
    start_time = Time.now
    company = Company.find_by(name: 'MyspaceNYC')
    default_office = Office.find_by(name: 'Crown Heights')
    default_password = "lorimer713"

    nestio_url = "https://nestiolistings.com/api/v1/public/agents?key=#{ENV['NESTIO_KEY']}"

  	mechanize = Mechanize.new
  	mechanize.user_agent_alias = "Mac Safari"
  	mechanize.follow_meta_refresh = true

  	total_pages = 99
    page = 1
    page_count_limit = 50
    
    puts "Pulling Nestio data for all agents..."
    log.info  "Pulling Nestio data for all agents..."

    done = false
    for j in 1..total_pages
    	if done
    		mark_done(log, start_time)
    		break
    	end

    	puts "Page #{j} ----------------------------"
      log.info "Page #{j} ----------------------------"
    	page = mechanize.get("#{nestio_url}&page=#{j}")
    	json_data = JSON.parse page.body
    	
      total_pages = json_data['total_pages']
      page = json_data['page']
      total_items = json_data['total_items']
      items = json_data['items']

      for i in 0..page_count_limit-1
        count = (page-1) * page_count_limit + i
        if count >= json_data['total_items']
          done = true
          break
        end

        item = items[i]
        if item['title'] == 'Licensed Real Estate Agent'
          new_title = EmployeeTitle.agent
        elsif item['title'] == 'Executive'
          new_title = EmployeeTitle.manager
        elsif item['title'] == 'Offline'
          new_title = EmployeeTitle.agent
        else # catch-all
          new_title = EmployeeTitle.agent
        end

        # a few gotchas...
        if item['email'] == 'jcastillo@myspacenyc.com' || 
          item['email'] == 'sbrewer@myspacen.com'
          new_title = EmployeeTitle.manager
        end

        found = User.find_by(name: item['name'])
        if !found
          user = User.create!({
            phone_number: item['phone_number'] || nil,
            mobile_phone_number: item['mobile_phone_number'],
            name: item['name'].strip,
            email: item['email'],
            bio: item['bio'] || nil,
            company: company,
            employee_title: new_title,
            office: default_office,
            activated: true, 
            activated_at: Time.zone.now,
            approved: true, 
            approved_at: Time.zone.now,
            password: default_password, 
            password_confirmation: default_password, 
          })

          # headshot_img = item['headshot']['original']
          # if headshot_img
          #   image = Image.new
          #   image.file = URI.parse(item['headshot']['original'])
          #   image.save
          #   user.image = image
          # end

          user.update_roles
          puts "[#{i}/#{page_count_limit}] #{item['name']} - added"
          log.info "[#{i}/#{page_count_limit}] #{item['name']} - added"
        else
          puts "[#{i}/#{page_count_limit}] #{item['name']} - already exists"
          log.info "[#{i}/#{page_count_limit}] #{item['name']} - already exists"
        end
      end
    	
    end

    if !done
      mark_done(log, start_time)
    end
  end
end