def sync_tool
  require 'sync_nubbins'
  @p_by_lds_id = @@people.index_by &:lds_id


  agent = Mechanize.new
  page = agent.get 'http://lds.org/directory'
  page.forms.each do |f|
    if f.action == '/login.html'
      @login_form = f
    end
  end
  @login_form.field_with( name: 'username').value = 'iamkcerb'
  @login_form.field_with( name: 'password').value = '1utp@Sb1stw'

  agent.submit(@login_form)

  @curr_ward_stake_info = agent.get 'https://www.lds.org/directory/services/ludrs/unit/current-user-ward-stake/'
  @cwsi_ascii = @curr_ward_stake_info.body.to_s.unpack("U*").map{|c|c.chr}.join
  @curr_ward = @cwsi_ascii[/wardUnitNo\":(\d+)/,1]

  @members_household_list = agent.get "https://www.lds.org/directory/services/ludrs/photo/household-members/#{@curr_ward}"
  @mhl_ascii = @members_household_list.body.to_s.unpack("U*").map{|c|c.chr}.join
  @househead_ids = @mhl_ascii.scan(/headOfHouseholdId\":(\d+)/)
  @househead_ids.flatten!
  @new_ids = []
  @househead_ids.each do |id|
    @check_person = @p_by_lds_id[id]
    if @check_person.class != Person # check that the id is on our list 
      @new_ids << id
      next #skip them for now
    end

    next unless @check_person.receives #don't sync if they're not in the home teahing pool (waste of time)

    @member_file = agent.get "https://www.lds.org/directory/services/ludrs/mem/householdProfile/#{id}"
    @member_string = @member_file.body.to_s.unpack("U*").map{|c|c.chr}.join

    # Head of household check
    @lds_address = @member_string[/addr1\":\"([^"]*)/,1]
    @lds_phone = @member_string[/phone\":\"([^"]*)/,1]
    @lds_email = @member_string[/email\":\"([^"]*)/,1]

    case
    when @lds_address != @check_person.address && @check_person.lds_vals
      @lds_sync_person = @@people[@@people.find_index(@check_person)]
      @lds_sync_person.street_address = @lds_address
      @updated_address == true
    when @lds_address != @check_person.address && !(@check_person.lds_vals) # if lds vals is false AND they're diff
      email_clerk_update(@check_person, @lds_address)
    when @lds_address == @check_person.address && !(@check_person.lds_vals) # if lds vals is false AND they're same
      @lds_sync_person = @@people[@@people.find_index(@check_person)]
      @lds_sync_person.lds_vals = true
    end
    case
    when @lds_phone != @check_person.phone && @check_person.lds_vals
      @lds_sync_person = @@people[@@people.find_index(@check_person)]
      @lds_sync_person.phone_number = @lds_phone
    when @lds_phone != @check_person.phone && !(@check_person.lds_vals) # if lds vals is false AND they're diff
      email_clerk_update(@check_person, @lds_phone)
    when @lds_phone == @check_person.phone && !(@check_person.lds_vals) # if lds vals is false AND they're same
      @lds_sync_person = @@people[@@people.find_index(@check_person)]
      @lds_sync_person.lds_vals = true
    end
    case
    when @lds_email != @check_person.email && @check_person.lds_vals
      @lds_sync_person = @@people[@@people.find_index(@check_person)]
      @lds_sync_person.email_address = @lds_email 
    when @lds_email != @check_person.email && !(@check_person.lds_vals)  # if lds vals is false AND they're diff
      email_clerk_update(@check_person, @lds_email)
    when @lds_email == @check_person.email && !(@check_person.lds_vals) # if lds vals is false AND they're same
      @lds_sync_person = @@people[@@people.find_index(@check_person)]
      @lds_sync_person.lds_vals = true
    end

    # Spouse check
    if @member_string[/spouse\":(.)/,1] == "{" # if they have a spouse this is true
      @lds_spouse_id = @member_string[/spouse(.*)individualId\":(\d+)/,2]
      @lds_spouse = @p_by_lds_id[@lds_spouse_id]

      @lds_spouse_phone = @member_string[/spouse(.*)phone\":\"([^"]*)/,2]
      @lds_spouse_email = @member_string[/spouse(.*)email\":\"([^"]*)/,2]

      if @updated_address
        @lds_sync_spouse = @@people[@@people.find_index(@lds_spouse)]
        @lds_sync_spouse.street_address = @lds_address
        @updated_address = false
      end

      case
      when @lds_spouse_phone != @lds_spouse.phone && @lds_spouse.lds_vals
        @lds_sync_spouse = @@people[@@people.find_index(@lds_spouse)]
        @lds_sync_spouse.phone_number = @lds_spouse_phone
      when @lds_spouse_phone != @lds_spouse.phone && !(@lds_spouse.lds_vals) # if lds vals is false AND they're diff
        email_clerk_update(@lds_spouse, @lds_spouse_phone)
      when @lds_spouse_phone == @lds_spouse.phone && !(@lds_spouse.lds_vals) # if lds vals is false AND they're same
        @lds_sync_spouse = @@people[@@people.find_index(@lds_spouse)]
        @lds_sync_spouse.lds_vals = true
      end

      case
      when @lds_spouse_email != @lds_spouse.email && @lds_spouse.lds_vals
        @lds_sync_spouse = @@people[@@people.find_index(@lds_spouse)]
        @lds_sync_spouse.email_address = @lds_spouse_email
      when @lds_spouse_email != @lds_spouse.email && !(@lds_spouse.lds_vals) #if lds vals is false AND they're diff
        email_clerk_update(@lds_spouse, @lds_spouse_email)
      when @lds_spouse_email == @lds_spouse.email && !(@lds_spouse.lds_vals) # if lds vals is false AND they're same
        @lds_sync_spouse = @@people[@@people.find_index(@lds_spouse)]
        @lds_sync_spouse.lds_vals = true
      end

    end # spouse check

    # Children check
    @child_string = @member_string[/otherHouseholdMembers(.*)spouse/m,0]
    @childrens_names = @child_string.scan(/name\":\"([^"]*)/).flatten.join("; ")
    if @check_person.children != @childrens_names
      @lds_sync_person = @@people[@@people.find_index(@check_person)]
      @lds_sync_person.children = @childrens_names
      if @member_string[/spouse\":(.)/,1] == "{" # little quick spouse check
        @lds_sync_spouse = @@people[@@people.find_index(@lds_spouse)]
        @lds_sync_spouse.children = @childrens_names
      end
    end



  end #househead_ids.each

  # ADD NEW PERSON
  if @new_ids != []
    @member_list = agent.get("https://www.lds.org/directory/services/ludrs/mem/member-list/#{@curr_ward}").body.to_s.unpack("U*").map{|c|c.chr}.join
  end

  @new_ids.each do |id|
    # first, suss out the gender, this is harder to get than you'd think!
    @guy_loc = @member_list.index("#{id}")
    @gender_string = @member_list[@guy_loc-30..@guy_loc]#[/gender\":\"(\w+)/,1] # gender comes before id . . 
    if @gender_string[/FEMALE/] == nil
      @new_lds_gender = "Male"
    else
      @new_lds_gender = "Female"
    end

    @member_string = agent.get("https://www.lds.org/directory/services/ludrs/mem/householdProfile/#{id}").body.to_s.unpack("U*").map{|c|c.chr}.join    
    @new_guy_comment = ""
    @household_string = @member_string[/householdInfo(.*?)},\"id/]

    # Name
    @new_lds_names = @member_string[/name\":\"([^"]*)/,1].split(",").collect{|x| x.strip}.force_encoding("ASCII")
    @new_lds_last_name = @new_lds_names[0]
    @new_lds_first_name = @new_lds_names[1].split(" ")[0] #first first name

    # Has a spouse?
    @has_spouse = @member_string[/spouse\":(.)/,1] == "{" 

    #cup_fullname
    if @has_spouse
      @new_lds_spouse_names = @member_string[/spouse(.*)name\":\"([^"]*)/,2].split(",").collect{|x| x.strip}
      @new_lds_spouse_last_name = @new_lds_spouse_names[0]
      @new_lds_spouse_first_name = @new_lds_spouse_names[1].split(" ")[0] 
      @new_lds_spouse_id = @member_string[/spouse(.*)individualId\":(\d+)/,2]
      @new_lds_spouse_phone = @member_string[/spouse(.*)phone\":\"([^"]*)/,2]
      @new_lds_spouse_email = @member_string[/spouse(.*)email\":\"([^"]*)/,2]
      case
      when @has_spouse && @new_lds_last_name == @new_lds_spouse_last_name
        @new_lds_cup_fullname = @new_lds_first_name + " & " + @new_lds_spouse_first_name + " " + @new_lds_last_name
      when @has_spouse && @new_lds_last_name != @new_lds_spouse_last_name
        @new_lds_cup_fullname = @new_lds_first_name + " " + @new_lds_last_name + " & " + @new_lds_spouse_first_name + " " + @new_lds_spouse_last_name
      end
    else #if not married
      @new_lds_cup_fullname = @new_lds_first_name + " " + @new_lds_last_name
    end


    # Has children?
    @child_string = @member_string[/otherHouseholdMembers(.*)spouse/m,0]
    @new_lds_children = @child_string.scan(/name\":\"([^"]*)/).flatten.join("; ")
    # street address
    @new_lds_address = @member_string[/addr1\":\"([^"]*)/,1]

    # phone number
    @new_lds_phone = @member_string[/phone\":\"([^"]*)/,1]
    @household_phone = @household_string[/phone\":\"([^"]*)/,1]
    case
    when @new_lds_phone == "" && @household_phone != ""
      @new_lds_phone = @household_phone
    when @new_lds_phone != "" && @household_phone != ""
      if @new_lds_phone.gsub(/\D/,"") != @household_phone.gsub(/\D/,"")
        @new_guy_comment = "Household phone is #{@household_phone}. " unless @household_phone == ""
      end
    end

    # email address
    @new_lds_email = @member_string[/email\":\"([^"]*)/,1]
    @household_email = @household_string[/email\":\"([^"]*)/,1]
    case
    when @new_lds_email == "" && @household_email != ""
      @new_lds_email = @household_email
    when @new_lds_email != "" && @household_email != ""
      if @new_lds_email != @household_email
        @new_guy_comment += "Household email is #{@household_email}. " unless @household_email == ""
      end
    end

    #search elems
    if @has_spouse
      @new_lds_search_elems = "#{@new_lds_first_name} #{@new_lds_last_name} #{@new_lds_spouse_first_name} #{@new_lds_spouse_last_name} #{@new_lds_address} #{@new_lds_phone} #{@new_lds_email} #{@new_lds_spouse_phone} #{@new_lds_spouse_email}".downcase
    else
      @new_lds_search_elems = "#{@new_lds_first_name} #{@new_lds_last_name} #{@new_lds_address} #{@new_lds_phone} #{@new_lds_email}".downcase
    end


    # now let's make this guy
    @poss_chars =  [('a'..'z'),('0'..'9')].map{|i| i.to_a}.flatten
    @new_user_id = (0...9).map{ @poss_chars[rand(@poss_chars.length)] }.join
    @new_user_id2 = (0...9).map{ @poss_chars[rand(@poss_chars.length)] }.join                  
    @new_guy = Person.new
    @new_guy.user_id = @new_user_id
    @new_guy.pref_name = @new_lds_first_name
    @new_guy.first_name = @new_lds_first_name
    @new_guy.last_name = @new_lds_last_name
    @new_guy.cup_fullname = @new_lds_cup_fullname
    @new_guy.gender = @new_lds_gender
    @new_guy.spouse_id = if @has_spouse then @new_user_id2 else "" end
    @new_guy.children = @new_lds_children
    @new_guy.street_address = @new_lds_address
    @new_guy.phone_number = @new_lds_phone
    @new_guy.email_address = @new_lds_email
    @new_guy.ments_count = 0
    @new_guy.receives = ""
    @new_guy.stat1 = ""
    @new_guy.stat2 = ""                    
    @new_guy.assign_ments = ""
    @new_guy.teachers_ment = ""
    @new_guy.comment = @new_guy_comment
    @new_guy.which_photo = "a" 
    @new_guy.lds_id = id
    @new_guy.lds_vals = true
    @new_guy.search_elems = @new_lds_search_elems

    if @has_spouse
      # and the spouse
      @new_guy_spouse = Person.new
      @new_guy_spouse.user_id = @new_user_id2
      @new_guy_spouse.pref_name = @new_lds_spouse_first_name
      @new_guy_spouse.first_name = @new_lds_spouse_first_name
      @new_guy_spouse.last_name = @new_lds_spouse_last_name
      @new_guy_spouse.cup_fullname = @new_lds_cup_fullname
      @new_guy_spouse.gender = if @new_lds_gender == "Male" then "Female" else "Male" end
      @new_guy_spouse.spouse_id = @new_user_id 
      @new_guy_spouse.children = @new_lds_children
      @new_guy_spouse.street_address = @new_lds_address
      @new_guy_spouse.phone_number = @new_lds_spouse_phone
      @new_guy_spouse.email_address = @new_lds_spouse_email
      @new_guy_spouse.ments_count = 0
      @new_guy_spouse.receives = ""
      @new_guy_spouse.stat1 = ""
      @new_guy_spouse.stat2 = ""                    
      @new_guy_spouse.assign_ments = ""
      @new_guy_spouse.teachers_ment = ""
      @new_guy_spouse.comment = ""
      @new_guy_spouse.which_photo = "a" 
      @new_guy_spouse.lds_id = @new_lds_spouse_id
      @new_guy_spouse.lds_vals = true
      @new_guy_spouse.search_elems = ""
    end #if has spouse

    @@people << @new_guy
    if @has_spouse
      @@people << @new_guy_spouse
    end

    save_and_reload
  end   # new_ids.each





  # DELETE PEOPLE WHO HAVE LDS_ID BUT IT'S NOT ON LDS.ORG ANYMORE
  @curr_lds_ids = []
  @@people.each do |person|
    @curr_lds_ids << person.lds_id unless person.lds_id == ""
  end
  @move_out_lds_ids = @curr_lds_ids - @househead_ids

  @move_out_lds_ids.each do |id|

    @curr_gender = @p_by_lds_id[id].gender

    if confirm "It looks like #{@p_by_lds_id[id].pref_name} moved out. Delete #{@curr_gender == "Male" ? "Him" : "Her"}? "

      @to_delete_id = @p_by_lds_id[id].user_id

      # delete person from assign_ments 
      person.assigned_to.each do |a_ment| 
        @a_ment = @@ments[@@ments.find_index(@@ment_info[a_ment])]
        @a_ment.companions.gsub!(/,#{person.user_id}|#{person.user_id},|#{person.user_id}/,'')
      end
      # delete person from teachers_ments
      if person.teachers_ment != ""
        @a_ment = @@ments[@@ments.find_index(@@ment_info[person.teachers_ment])]
        @a_ment.families.gsub!(/,#{person.user_id}|#{person.user_id},|#{person.user_id}/,'')
      end # if
      # delete person from @@people
      @@people.delete_if {|person| person.user_id == @to_delete_id}

      # delete person's spouse same as above
      if person.is_married?
        @to_delete_id = person.spouse.user_id
        person.spouse.assigned_to.each do |a_ment| 
          @a_ment = @@ments[@@ments.find_index(@@ment_info[a_ment])]
          @a_ment.companions.gsub!(/,#{person.user_id}|#{person.user_id},|#{person.user_id}/,'')
        end
        # delete person from @@people
        @@people.delete_if {|person| person.user_id == @to_delete_id}
      end # end if they are married

      save_and_reload    

    end
  end





  #update files
  save_and_reload


  File.open('test.txt', 'w') do |f2|  
    # use "\n" for two lines of text  
    f2.puts @out
  end
end
