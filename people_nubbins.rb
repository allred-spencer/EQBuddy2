#nubbins
#......................
#contact_info_cards (grabs both people) see contact_info_card for individual
#......................
def contact_info_cards(person)
# Add edit button that lets you edit this guy's information

  flow :margin_top => 5 do
    stack :width => 300, :margin_right => 5 do
      background lightgrey, :curve => 14
      background white, :width => "99%", :height => "99%", :curve => 12
      flow do # two stacks side by side to put a gear next to the name
        stack :width => "90%" do # name stack
          caption person.info_block_name
        end
        stack :width => "10%" do # gear stack
          image "images/gear.png", :width => 15, :height => 15, :top => 4, :left => 6 do
            contact_window(@@p_info[person.user_id], "isn't spouse")
          end #image do
        end # stack
      end # flow
      flow :height => 25 do
        if person.phone =~ /</ || person.phone =~ />/ 
          para person.phone, :stroke => lightgrey
        else
          para person.phone, :stroke => black
        end
      end
      flow :height => 25 do
        if person.email =~ /</ || person.email =~ />/ 
          para person.email, :stroke => lightgrey
        else
          para person.email, :stroke => black
        end
      end
      flow do
        para "Max no. of assignments: ", person.ments_count
      end
    end
    if person.is_married?
      stack :width => 300, :margin_right => 5 do
        background lightgrey, :curve => 14
        background white, :width => "99%", :height => "99%", :curve => 12
        flow do # two stacks side by side to put a gear next to the name
          stack :width => "90%" do # name stack
            caption person.spouse.info_block_name
          end
          stack :width => "10%" do # gear stack
            image "images/gear.png", :width => 15, :height => 15, :top => 4, :left => 6 do
              contact_window( @@p_info[person.spouse_id], "is spouse")
            end #image do
          end # stack
        end # flow
        flow :height => 25 do
          if person.spouse.phone =~ /</ || person.spouse.phone =~ />/ 
            para person.spouse.phone, :stroke => lightgrey
          else
            para person.spouse.phone, :stroke => black
          end
        end
        flow :height => 25 do
          if person.spouse.email =~ /</ || person.spouse.email =~ />/ 
            para person.spouse.email, :stroke => lightgrey
          else
            para person.spouse.email, :stroke => black
          end
        end
        flow do
          para "Max no. of assignments: ", person.spouse.ments_count
        end
      end #stack
    end #if
  end #flow
end #def

#......................
#contact_info_card (grabs only the person asked for) see contact_info_cards for more
#......................
def contact_info_card(person)
  stack :width => 300, :margin_right => 5 do
    background lightgrey, :curve => 14
    background white, :width => "99%", :height => "99%", :curve => 12
    click do
      refresh_people_tab(person)
    end # click
    flow do
      caption person.name
    end
    flow :height => 25 do
      if person.address.include?("<")
        para person.address, :stroke => lightgrey
      else
        para person.address, :stroke => black
      end
    end
    flow :height => 25 do
      if person.phone.include?("<")
        para person.phone, :stroke => lightgrey
      else
        para person.phone, :stroke => black
      end
    end
    flow :height => 25 do
      if person.email.include?("<")
        para person.email, :stroke => lightgrey
      else
        para person.email, :stroke => black
      end
    end
  end
end
    
#......................
#couple_info 
#......................
def couple_info(person)
    stack :width => 300, :margin_right => 5 do
      background lightgrey, :curve => 14
      background white, :width => "99%", :height => "99%", :curve => 12
      click { refresh_people_tab(person) }
      if person.is_married?
        flow do
          caption person.cup_fullname
        end
        #ADDRESS
        flow :height => 25 do
          if person.address.include? "<"
            para person.address, :stroke => lightgrey
          else 
            para person.address
          end
        end # address flow
        #PHONE
          case
          when person.phone.include?("<") && person.spouse.phone.include?("<")
            flow :height => 25 do
              para person.phone, :stroke => lightgrey
            end
          when !(person.phone.include?("<")) && !(person.spouse.phone.include?("<"))
            flow :height => 25 do          
              para person.pref_name, ": ", person.phone
            end
            flow :height => 25 do
              para person.spouse.pref_name, ": ", person.spouse.phone
            end            
          when person.spouse.phone.include?("<")
            flow :height => 25 do          
              para person.pref_name, ": ", person.phone
            end              
          when person.phone.include?("<")
            flow :height => 25 do          
              para person.spouse.pref_name, ": ", person.spouse.phone
            end              
          end
        #EMAIL
          case
          when person.email.include?("<") && person.spouse.email.include?("<")
            flow :height => 25 do          
              para person.email, :stroke => lightgrey
            end              
          when !(person.email.include?("<")) && !(person.spouse.email.include?("<"))
            flow :height => 25 do          
              para person.pref_name, ": ", person.email 
            end
            flow :height => 25 do
              para person.spouse.pref_name, ": ", person.spouse.email
            end              
          when person.spouse.email.include?("<")
            flow :height => 25 do          
              para person.pref_name, ": ", person.email
            end              
          when person.email.include?("<")
            flow :height => 25 do          
              para person.spouse.pref_name, ": ", person.spouse.email
            end              
          end      
      else #if they're not married
        caption person.name
        if person.address.include?("<")
          flow :height => 25 do        
            para person.address, :stroke => lightgrey
          end
        else
          flow :height => 25 do                
            para person.address
          end            
        end  
        if person.phone.include?("<")
          flow :height => 25 do        
            para person.phone, :stroke => lightgrey
          end            
        else
          flow :height => 25 do        
            para person.phone
          end            
        end
        if person.email.include?("<")
          flow :height => 25 do        
            para person.email, :stroke => lightgrey
          end            
        else
          flow :height => 25 do        
            para person.email
          end                    
        end
      end #if
    end #stack      
end #def

#......................
#info_box_large
#......................
def info_box_large(person)
  # Person name flows
  flow :height => 60 do 
    background black, :bottom => 12, :height => 2
    stack :width => "60%" do
      title person.cup_name
    end
    stack :width => "40%"  do
      if person.address =~ /</ || person.address =~ />/
        caption person.address, :align => "right", :top => 24, :stroke => lightgrey        
      else
        caption person.address, :align => "right", :top => 24
      end
    end
  end # flow
  contact_info_cards person
  # Home teachers flows
  if person.taught_by.respond_to?(:[])
    flow :height => 60 do 
      background black, :bottom => 12, :height => 2
      title "Home Teachers: "
    end
    flow do     
      person.taught_by.each do |ht|
        if @@p_info[person.taught_by[0]].spouse == person.taught_by[1]
          couple_info @@p_info[ht]
          break
        else
          contact_info_card @@p_info[ht]
        end
      end #each
    end #flow
  end #if
  # Assignments Flow
  if person.assigned_to.respond_to?(:[])
    flow :height => 60 do 
      background black, :bottom => 12, :height => 2
      title "Assignments: "
    end
    flow do
      person.assigned_to.each do |ment|
        stack do
          if @@ment_info[ment].comp_ids.length == 1
          caption @@ment_info[ment].comp_names_string, " is assigned to: "
          else
          caption @@ment_info[ment].comp_names_string, " are assigned to: "
          end
          flow do
            @@ment_info[ment].fam_ids.each do |fam_id|
              next unless !(@@p_info[fam_id].is_married?) || @@p_info[fam_id].gender == "Male"
              couple_info @@p_info[fam_id]
            end # each
          end # flow
        end #stack
      end #each
    end # flow
  end # if
end # def

#......................
#photo_stack
#......................
def photo_stack(person)
  flow do
    photo person
  end
  @comment_stack = stack do
    if person.comment == ""
      para "Click here to add comments", :stroke => lightgrey, :margin_left => @sugg_marg, :margin_right => gutter
    else
      para person.comment, :margin_left => @sugg_marg, :margin_right => gutter
    end
    click do
      @comment_stack.clear do
        @person_comment = person.comment
        edit_box text: @person_comment, width: "100%", height: 150, margin_left: @sugg_marg, margin_right: gutter, do |e|
          @person_comment = e.text
        end # edit box do
        flow :margin_left => @sugg_marg, :margin_right => gutter do #button flow
          button "Done" do
            person.comment = @person_comment
            save_and_reload_people("all")
            @photo_stack.clear do
              photo_stack(@@p_info[person.user_id])
            end # clear
          end # button
          button "Cancel" do
            @photo_stack.clear do
              photo_stack(@@p_info[person.user_id])
            end # clear
          end #button
        end # button flow  
      end #clear comment stack
    end #click comment stack
  end # comment stack
  # Gets Home Taught radio bar
  if person.is_married?
    @check_string = "Do " + person.cup_name + " need to be home-taught by the elders quorum right now?"
  else
    @check_string =  "Does " + person.pref_name + " need to be home-taught by the elders quorum right now?"
  end
  if person.receives == "true"
    @radios_background = palegreen
  else
    @radios_background = pink
  end
  flow :margin_left => @sugg_marg, :margin_right => gutter, :margin_top => 10 do
    background black, :height => 2
    para @check_string
  end # end flow
  flow :margin_left => @sugg_marg, :margin_right => gutter do
    background @radios_background
    @yes_radio = radio; para "Yes"
    @no_radio = radio; para "No"
    case
    when person.receives == "true"
      @yes_radio.style(:checked => true)
      @radios_background = palegreen
	  when person.receives == "false"
	    @no_radio.style(:checked => true)
	    @radios_background = pink
	  end
    @yes_radio.click do
      person.receives = true
      save_and_reload_people("all")
      @photo_stack.clear{ photo_stack(@@p_info[person.user_id])}
    end # click
    @no_radio.click do
      if confirm "Are you sure you want to remove #{person.cup_fullname} from the home teaching pool?"
        # change person.receives
        person.receives = false
        # delete person from teachers ment
        unless person.teachers_ment == "" || person.teachers_ment == nil
          @a_ment = @@ments[@@ments.find_index(@@ment_info[person.teachers_ment])]
          @a_ment.families.gsub!(/,#{person.user_id}|#{person.user_id},|#{person.user_id}/,'')
        end
        # delete teachers ment from person
        person.teachers_ment = ""

        save_and_reload
        refresh_people_tab(@@p_info[person.user_id])
      end # if they are sure they want to delete
    end #click on no radio
  end #radios flow
  button "Delete " + person.cup_name, :margin_left => @sugg_marg, :margin_top => 20 do
    @delete_check = ask "Type \"delete\" to permanently delete. "
    if @delete_check == "delete"
      @to_delete_id = person.user_id
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
      
      save_and_reload_people("only")
      save_and_reload_ments("all")      
      @names_list.clear {create_name_flows(@people_search_bar_text,@search_options)}                 
      @info_box_large.clear
      @photo_stack.clear
    end # if they are sure
  end # delete button
end # def


#......................
#photo
#......................
def photo(person)
    if File.file?("images/" + person.user_id + person.which_photo + ".jpg")
      @image_path = "images/" + person.user_id + person.which_photo + ".jpg"
    else
      @image_path = "images/default.png"
    end
    @photo = image @image_path do
      @new_photo_name = ask_open_file
      @break = false
      if File.extname(@new_photo_name).downcase != ".jpg" && File.extname(@new_photo_name).downcase != ".jpeg"
        alert "Sorry guy, only jpgs right now. :("    
        @break = true
      end
      File.delete(@image_path) unless (@image_path == "images/default.png" || @break)
      case
      when @break
        nil 
      when person.which_photo == "a"
        person.which_photo = "b"
      when person.which_photo == "b"
        person.which_photo = "c"
      when person.which_photo == "c"
        person.which_photo = "d"
      when person.which_photo == "d"
        person.which_photo = "e"
      when person.which_photo == "e"
        person.which_photo = "a"                        
      end
      copy_file(@new_photo_name, "images/" + person.user_id + person.which_photo + ".jpg") unless @break
      save_and_reload_people("all")
      @photo_stack.clear {photo_stack(@@p_info[person.user_id])}
    end # image do
    case
      when @photo.full_height < 300 && @photo.full_width < 230
        @image_height = @photo.full_height
        @image_width = @photo.full_width
        @sugg_marg = ((190 - @image_width).to_f/2).floor
      when @photo.full_height > @photo.full_width
        @scale = 290.0/@photo.full_height.to_f
        @image_height = 300
        @image_width = (@photo.full_width.to_f * @scale).floor
        @sugg_marg = 10
      when @photo.full_height <= @photo.full_width
        @scale = 230/@photo.full_width.to_f
        @image_height = (@photo.full_height.to_f * @scale).floor
        @image_width = 230
        @sugg_marg = 5        
    end     
    @photo.style(:height => @image_height, :width => @image_width, :margin_left => @sugg_marg)
end


#......................
# contact window
#......................
# Oh man, windows are so hard to work with . . .
# This is because the way I wrote this program
# everything is @att so when you open a window that stuff is
# gone. What's more I don't have any classes (they were tripping
# me up, something to do with Class << Shoes) so all of my methods
# and structs are lost when you get a new window. So hard. The following
# makes it work though. This code is too complex. I can't understand it
# Maybe some day some one will help me make it simple.
def contact_window(person, spouse_info)
  if spouse_info == "is new spouse"
    @temp_flow.remove
  end
  @temp_flow = flow do
    @@edited_check = "not edited"
    every(0.5) do
      if @@edited_check == "edited" && spouse_info != "is new spouse"
        case
        when spouse_info == "is spouse"
          @@edited_check = "done now"        
          refresh_people_tab(person.spouse)                
          @temp_flow.remove                  
        when spouse_info == "isn't spouse" || spouse_info == "hasn't spouse"  
          @@edited_check = "done now"
          refresh_people_tab(person)
          save_and_reload_people("all")
          @temp_flow.remove                  
        else
          @@edited_check = "done now"
          contact_window(spouse_info, "is new spouse") #what? yeah. you pass in a string or an object, if it's an object, do something with it!      
  
        end
        @temp_flow.remove
      end #if
    end #every
  end #temp_flow
  #we have to make two temp flows since they get deleted on spouse run
  if spouse_info == "is new spouse"  
    @@edited_check = "not edited"
    @temp_flow_sc = flow do
      every(0.5) do
        if @@edited_check == "edited"
          @@edited_check = "done now"        
          refresh_people_tab(person.spouse)
          @temp_flow_sc.remove 
        end
      end
    end # temp flow
  end # if spouse info
  window :height => 370, :width => 360, :resizable => false do
  # It's awful, but you have to redefine functions in a new window, this window
  # is actually the reason so many variables are @@. So the following lines are
  # repeats of a few methods that I need here
  # weird #101 = this if checks to see if spouse_info is an object and makes a string so that the csv writer knows to write
    if spouse_info == "is spouse" || spouse_info == "is new spouse" || spouse_info == "isn't spouse" || spouse_info == "hasn't spouse" 
       @spouse_info_check = spouse_info
     else
       @spouse_info_check = "has spouse"
    end
  
    cd File.expand_path('~/.EQBuddy')
    def create_people_raw
      @@people_raw = CsvMapper.import('test_ward.csv') do
        read_attributes_from_file
      end
    end
    
    def create_p_info
      @@people = @@people_raw.map {|person| Person.new(*person.to_a) }
      @@p_info = @@people.index_by &:user_id
    end
    if @spouse_info_check == "is new spouse"
      person.last_name = person.spouse.last_name
    end
    if @spouse_info_check == "is new spouse"
    person.street_address = person.spouse.address
    end
    flow do
      background black
      case
      when @spouse_info_check == "has spouse"
        @window_title_string = "Add a new person to EQBuddy. (Add his/her spouse on the next page.)"
      when @spouse_info_check == "is new spouse"
        @window_title_string = "Now add his/her spouse to EQBuddy."        
      when @spouse_info_check == "hasn't spouse"
        @window_title_string = "Add a new person to EQBuddy."      
      when @spouse_info_check == "isn't spouse" || @spouse_info_check == "is spouse" 
        @window_title_string = "Edit Contact Info"      
      end
      caption @window_title_string, :stroke => white
    end
    stack :width => "100%" do
      if @spouse_info_check == "has spouse" || @spouse_info_check == "hasn't spouse" || @spouse_info_check == "is new spouse"
        flow do
        @male_radio = radio; para "Male"
        @female_radio = radio; para "Female"
        if @spouse_info_check == "is new spouse"
          case
          when @@p_info[person.spouse_id].gender == "Male"
            @female_radio.style(:checked => true, :state => "disabled")
            @male_radio.style(:checked => false, :state => "disabled")            
          when @@p_info[person.spouse_id].gender == "Female"
            @female_radio.style(:checked => false, :state => "disabled")
            @male_radio.style(:checked => true, :state => "disabled")            
          else
          end
        end
        end
      end
      flow { para "First Name: ";       @fn = person.first_name;     edit_line( @fn, left: 130) { |e| @fn = e.text}}
      flow { para "Last Name: ";        @ln = person.last_name;      edit_line( @ln, left: 130) { |e| @ln = e.text}}
      flow { para "Preferred Name: ";   @pn = person.pref_name;      edit_line( @pn, left: 130) { |e| @pn = e.text}}
      flow { para "Street Address: ";   @ad = person.street_address; edit_line( @ad, left: 130) { |e| @ad = e.text}}
      flow { para "Phone Number: ";     @ph = person.phone;          edit_line( @ph, left: 130) { |e| @ph = e.text}}
      flow { para "Email Address: ";    @em = person.email;          edit_line( @em, left: 130) { |e| @em = e.text}}
      flow { para "Max Number of HT Assignments: "; @mn = person.ments_count; edit_line( @mn, width: 15) { |e| @mn = e.text}}
      flow do
        @ok_button = button "Save", :width => 80, :focus => true do
          @go_back = false
          if @fn == nil
            case
            when @pn == nil
            @fn = "Firstname"
            else
            @fn = @pn
            end
          end
          if @ln == nil
              @ln = "Lastname"
          end
          if @pn == nil || @pn == "" || @pn == " "
            @pn = @fn
          end
          if @ad == nil
            @ad = ""
          end
          if @ph == nil
            @ph = ""
          end
          if @em == nil
            @em = ""
          end
          if @spouse_info_check == "has spouse" || @spouse_info_check == "hasn't spouse" || @spouse_info_check == "is new spouse"
            case
            when @male_radio.checked?
              person.gender = "Male"
            when @female_radio.checked?
              person.gender = "Female"
            else
              alert "You need to select a gender"
              @go_back = true
            end
          end
          # now we set persons values to the one's that have been entered
          person.first_name = @fn
          person.last_name = @ln
          person.pref_name = @pn

          #cup_fullname
          case
          when person.is_married? && person.last_name == person.spouse.last_name
            person.cup_fullname = person.pref_name + " & " + person.spouse.pref_name + " " + person.last_name
          when person.is_married? && person.last_name != person.spouse.last_name
            person.cup_fullname = person.name + " & " + person.spouse.name
          else
            person.cup_fullname = person.name
          end
          #address
          person.street_address = @ad
          #phone
          if @ph.gsub(/\D/,'').length > 2
            @ph = @ph.gsub(/\D/,'').insert 3, "-"
            if @ph.length > 6
              @ph = @ph.insert 7, "-"
            end
          else
            @ph = ""
          end
          person.phone_number = @ph
          #email
          person.email_address = @em
          if @mn.to_i < person.assigned_to.length
            alert "Sorry, you can't make this number less than the number of assignments someone is in. \n to delete somebody from an assignment go to the assignments tab."
            @go_back = true
          else
            person.ments_count = @mn.to_i.to_s
          end
          # lds_vals = false now that this has been edited!
          person.lds_vals = false
          # search elems
          if person.is_married?
            person.search_elems = "#{person.first_name} #{person.name} #{person.spouse.first_name} #{person.spouse.name} #{person.address} #{person.phone} #{person.email} #{person.spouse.phone} #{person.spouse.email}".downcase
          else
            person.search_elems = "#{person.first_name} #{person.name} #{person.address} #{person.phone} #{person.email}".downcase
          end

          # Now we have to edit the spouse since cup_fullname and search_elems contains spouse info
          # I realize that it is annoying for the person to carry more than the spouse id but it really
          # speeds things up!
          if @spouse_info_check == "is spouse" || @spouse_info_check == "isn't spouse" && person.is_married?
            #cup_fullname
            @editing_spouse = @@people[@@people.find_index(@p_info[person.spouse_id])]
            case
            when person.last_name == person.spouse.last_name
              @editing_spouse.cup_fullname = person.spouse.pref_name + " & " + person.pref_name + " " + person.last_name
            when person.last_name != person.spouse.last_name
              @editing_spouse.cup_fullname = person.spouse.name + " & " + person.name
            end
            #search elems
             @editing_spouse.search_elems = "#{person.spouse.first_name} #{person.spouse.name} #{person.first_name} #{person.name} #{person.address} #{person.spouse.phone} #{person.spouse.email} #{person.phone} #{person.email}".downcase
             
          end # if editing a married person, then go change two pieces of their spouses info

          # Now as long as go_back is still false save it, otherwise, go back!
          unless @go_back
            CSV.open("test_ward.csv","wb") do |csv|
              csv << person.members
              @@people.each do |person|
                csv << person.values
              end
              if @spouse_info_check == "has spouse" || @spouse_info_check == "hasn't spouse" || @spouse_info_check == "is new spouse"
                csv << person.values
              end
            end #end csv
            create_people_raw 
            create_p_info 
            @@edited_check = "edited"
            close() 
          end
        end #ok button end
        @cancel_button = button "cancel" do
          close()
        end
      end # buttons flow
    end #stack
  end # window
end # def

def save_and_reload_people(opt)
  CSV.open("test_ward.csv","wb") do |csv|
    csv << @@people.first.members
    @@people.each do |person|
      csv << person.values
    end
  end #end csv
  create_people_raw
  create_p_info
  create_htf_raw unless opt == "only"
  create_ment_info unless opt == "only"
end

def save_and_reload_ments(opt)
  CSV.open("test_htf.csv","wb") do |csv|
    csv << @@ments.first.members
    @@ments.each do |ment|
      csv << ment.values
    end
  end #end csv
  create_people_raw unless opt == "only"
  create_p_info unless opt == "only"
  create_htf_raw
  create_ment_info
end

def save_and_reload
  CSV.open("test_ward.csv","wb") do |csv|
    csv << @@people.first.members
    @@people.each do |person|
      csv << person.values
    end
  end #end csv
  CSV.open("test_htf.csv","wb") do |csv|
    csv << @@ments.first.members
    @@ments.each do |ment|
      csv << ment.values
    end
  end #end csv
  create_people_raw
  create_p_info
  create_htf_raw
  create_ment_info  
end #def

def refresh_people_tab(person)
  @info_box_large.clear {info_box_large(person)}
  @photo_stack.clear { photo_stack(@@p_info[person.user_id])}         
  @names_list.clear {create_name_flows(@people_search_bar_text,@search_options)}                   
end


