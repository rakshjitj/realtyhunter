task :import_users => :environment do

  # make into commandline args
  company = Company.find_by(name: 'MyspaceNYC')
  default_office = Office.find_by(name: 'Crown Heights')
  default_password = "lorimer713"

	api_key = "7abe027d49624988b64c22acb9f196c5"
	nestio_url = "https://nestiolistings.com/api/v1/public/agents?key=#{api_key}"

	puts  "Getting data for all agents..."

	mechanize = Mechanize.new
	mechanize.user_agent_alias = "Mac Safari"
	mechanize.follow_meta_refresh = true

	total_pages = 99
  page = 1
  page_count_limit = 50
  
  done = false
  for j in 1..total_pages
  	if done
  		puts "Done!"
  		break
  	end

  	puts "Page #{j} ----------------------------"
  	page = mechanize.get("#{nestio_url}&page=#{j}" )
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

      #   $l->{headshot}->{original} || undef,
      #   $l->{headshot}->{thumbnail} || undef,
      #   $l->{title},
      #TODO: images
      item = items[i]

      if item['title'] == 'Licensed Real Estate Agent'
        new_title = EmployeeTitle.agent
      elsif item['title'] == 'Executive'
        new_title = EmployeeTitle.manager
      elsif item['title'] == 'Offline'
        # this is an inactive user, don't add them
        next
      else # catch-all
        new_title = EmployeeTitle.agent
      end

      found = User.find_by(name: item['name'])
      if !found
        user = User.create!({
          phone_number: item['phone_number'] || nil,
          mobile_phone_number: item['mobile_phone_number'],
          name: item['name'],
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

        headshot_img = item['headshot']['original']
        if headshot_img
          image = Image.new
          image.file = URI.parse(item['headshot']['original'])
          user.image = image
        end

        user.update_roles
        puts "... added [#{i}] #{item['name']}"
      else
        puts "... #{item['name']} already exists. Skipping."
      end
    end
  	
  end

end
