#Creates
#..........................
# Create Name Flows
#..........................
def create_name_flows(text, criteria)
  @arr_of_flows = [];
  @@people.each do |person|
    next unless !(person.is_married?) || person.gender == "Male"
    next unless person.search_elems =~ /#{text.downcase}/ 
    case #check which tab is selected
    when criteria == "All"
      nil
    when criteria == "Home Teaching Pool"
      next unless (person.receives == "true" || person.assigned_to != [] || person.taught_by != [])
    when criteria == "Move-ins"
      next unless person.receives == ""
    end
    @temporary_flow = flow :height => 25, :margin_top => 1 do
      background white
      para person.cup_fullname
      @most_recent_user = person.user_id
      click do |button, x, y|
        if @which_user == person.user_id
          @info_box_large.clear{info_box_large(person)}
          @photo_stack.clear{photo_stack(@@p_info[person.user_id])}
        end #if
      end #click
      hover do |slot|
        @which_user = person.user_id
        slot.clear do
          background rgb(220, 220, 220)
          para person.cup_fullname
        end # clear
      end # hover
      leave do |slot|
        slot.clear do
          background white
          para person.cup_fullname
        end # clear
      end # leave
    end #@temp_flow
    @arr_of_flows << @temporary_flow
  end #@@people.each do
  if @arr_of_flows.length == 1
    @info_box_large.clear{info_box_large(@@p_info[@most_recent_user])}
    @photo_stack.clear{photo_stack(@@p_info[@most_recent_user])}
  end # if
end #create_name_flows


def create_ment_stacks(text, criteria)  
  @index =0...@@ments.length
  @stack_index = 0
  @index.each do |i|
    @ment = @@ments[i]
    next unless @ment.search_elems.downcase =~ /#{text.downcase}/
    if @color_array != []
      unless @color_array.to_s.include?(@ment.color)
        next
      end
    end


    @temp_stack = stack width: 250, margin: 10 do
      background lightgrey, :curve => 14
      background white, width: "99%", height: "99%",  curve: 12
      @back_color = eval(@ment.color) 
      teachers_flow(@ment, @ment.comp_ids)
      #families stack
      @families_stack = stack do
        @ment.fam_ids.each do |id|
          flow :height => 25 do
            para @@p_info[id].cup_fullname
            # Yeah, this is to avoid the whole i trick with @y, too bad I can't get a local click location
            click do |button, x, y|
              case
              when @top + 102 < @y && @y <= @top + 127
                @offset = 102
              when @top + 127 < @y && @y <= @top + 152
                @offset = 127
              when @top + 152 < @y && @y <= @top + 177
                @offset = 152
              when @top + 177 < @y && @y <= @top + 202
                @offset = 177
              end
              #alert "top #{@top}, y #{@y}, offset #{@offset}"
              drag_and_drop(id, @x - @left - 10, @y - @top - @offset)
              timer(0.5){ unless @mouse_down then info_window(@@p_info[id], "families") end}
            end
          end
        end # end fam_ids.each
        @empty_spots = (5-@ment.fam_ids.length)
        if @empty_spots > 0
          flow height: @empty_spots * 25 do
            para " "
            hover do |slot|
              if @grabbed_id != nil
                #check to see if person home teaches potential teacher. If not allow check to pass
                @fam_check1 = "pass"
                @@ments[i].comp_ids.each do |id|
                  if @@p_info[id].taught_by.include?(@grabbed_id) then @fam_check1 = "fail" end
                end
                #check to see if person would home teach self
                @fam_check2 = "pass"
                if @@ments[i].comp_ids.include?(@grabbed_id) then @fam_check2 = "fail" end
                #check to see if person would be home taught by companion
                @fam_check3 = "pass"
                @@p_info[@grabbed_id].assigned_to.each do |ment_id| #round up all the guy I'm holding's home teaching assignments
                  @@ment_info[ment_id].comp_ids.each do |id| #round up all the companions from those assignments
                    if @@ments[i].comp_ids.include?(id) # are any of his companions in the assignment we're putting him in
                      @fam_check3 = "fail"
                    end
                  end # each
                end # each
                # check to see if person is already in assignment
                @fam_check4 = "pass"
                if @@ments[i].fam_ids.include?(@grabbed_id) then @fam_check4 = "fail" end
                
                
                # alert @fam_check1 + @fam_check2 + @fam_check3 + @fam_check4
                @passed_fam_checks = @fam_check1 == "pass" && @fam_check2 == "pass" && @fam_check3 == "pass" && @fam_check4 == "pass"

                if @from_type == "families" && @passed_fam_checks
                  slot.clear do
                    background lightgrey, curve: 12
                    background lightgrey, top: 0, height: 10
                    if @grabbed_id != nil
                      para @@p_info[@grabbed_id].cup_fullname, :stroke => white
                    else
                      para "drag someone here to add", :stroke => white
                    end
                  end # clear unless
                end # if
              end # if grabbed id ( big all enclosing if ) 
            end # hover
            leave do |slot|
              # if @from_type == "families"
              slot.clear do
                background lightgrey, curve: 14
                background white, width: 0.987, height: 0.97, curve: 12
                background white, width: 0.987, top: 0, height: 12
              end # clear
              # end # if
            end # leave
          end # flow
        end #if
        hover {@small_zone = "families"}
        leave {
          if @large_zone == nil
            @small_zone = nil
          end
        }
      end # families stack
      # Now we handle switching hovers. What's crazy here, is that sometimes the new hover gets called before the old leave!
      hover do |slot|
        if @ment_hover
          #leave block
          @old_ment = @large_zone # normally two hovers get called on diff ments
          # but it is possible that they're the same ment!
          if @old_ment == @@ments[i].ment_id
            @double_hover = true
          end
        end
        #hover block
        @ment_hover = true
        @large_zone = @@ments[i].ment_id 
        @curr_slot = slot
        @top = @curr_slot.top - @curr_slot.scroll_top
        @left = @curr_slot.left
        #check to see if the teacher is already a member of the companionship

        if @grabbed_id != nil && @from_type == "teachers" && !(@@ment_info[@large_zone].comp_ids.include?(@grabbed_id))
          @dont_edit = false
          @back_color = eval(@@ment_info[@large_zone].color)
          slot.contents[2].clear {teachers_flow(@@ment_info[@large_zone], @@ment_info[@large_zone].comp_ids)}
          @dont_edit = true
        end
        #  alert "old ment is: #{@old_ment}, large zone is: #{@large_zone}"
      end
      leave do |slot|
        #run leave block if hover didn't already run it
        if @old_ment == nil then @old_ment = @large_zone end # first time this runs set them equal
        if @double_hover == nil then @double_hover = false end
        if @old_ment == @large_zone
          @ment_hover = false unless @double_hover
          @large_zone = nil unless @double_hover
        end
        if @grabbed_id != nil && @from_type == "teachers" && @old_ment != nil
          if !(@@ment_info[@old_ment].comp_ids.include?(@grabbed_id))
            @dont_edit = false
            @leave_block_redraw = false
            @back_color = eval(@@ment_info[@old_ment].color)
            slot.contents[2].clear {teachers_flow(@@ment_info[@old_ment], @@ment_info[@old_ment].comp_ids)}
            @leave_block_redraw = true
            @dont_edit = true
          end
        end

        @old_ment = @large_zone
        # alert "old ment is: #{@old_ment}, large zone is: #{@large_zone}"
      end # leave
    end # stack
    @stack_index += 1
  end # ments.each
end

def create_people_tabs
  case 
  when @which_tab == "teachers" 
    @teachers_tab = "images/need_ment_sel.png"
    @families_tab = "images/need_hts_n_sel.png"

  when @which_tab == "families"
    @teachers_tab = "images/need_ment_n_sel.png"
    @families_tab = "images/need_hts_sel.png"
  end
  background @tab_stripe, top: 28, height: 1
  background @tab_lightgray, top: 29, height: 1
  background @tab_gray, top: 30, height: 6
  background black, top: 36, height: 1

  stack width: 102 do
    image @teachers_tab do
      @which_tab = "teachers"
      @ments_names_list.clear {create_ments_name_flows(@ments_names_text, @which_tab, @sort_opt)}
      @people_tabs.clear {create_people_tabs}
    end
  end
  stack width: 86 do
    image @families_tab do
      @which_tab = "families"
      @ments_names_list.clear {create_ments_name_flows(@ments_names_text, @which_tab, @sort_opt)}
      @people_tabs.clear {create_people_tabs}
    end
  end
end

def create_ments_name_flows(text, criteria, sort_opt)
  @arr_of_flow_ids = []
  case
  when sort_opt == "Sort Alphabetically"
    @sorted_people = @@people.sort {|p1, p2| p1.last_name <=> p2.last_name}
  when sort_opt == "Sort by Home Teaching Stats" 
    # first sort by alpha so that matching stats are alphabetized
    @sorted_people_alt = @@people.sort {|p1, p2| p1.last_name <=> p2.last_name}
    case
    when criteria == "teachers"
      @sorted_people = @sorted_people_alt.sort {|p1,p2| p2.stat1 <=> p1.stat1} # low home teaching number means bottom of list
    when criteria == "families"
      @sorted_people = @sorted_people_alt.sort {|p1, p2| p1.stat2 <=> p2.stat2} # low home taught number means top of list
    end
  when sort_opt == "Sort by Address"
    @sorted_people_alt = @@people.sort {|p1, p2| p1.last_name <=> p2.last_name}
    @sorted_people = @sorted_people_alt.sort {|p1, p2| p1.address <=> p2.address}
  end

  @sorted_people.each do |person|
    next unless person.search_elems =~ /#{text.downcase}/ 
      case #check which tab is selected
      when criteria == "teachers"
        next unless (person.ments_count.to_i - person.assigned_to.length > 0)
      when criteria == "families"
        next unless !(person.is_married?) || person.gender == "Male"
        next unless person.receives == "true" && (person.teachers_ment == "" || person.teachers_ment == nil)
      end
    @arr_of_flow_ids << person.user_id
    flow height: 25, margin_top: 1, margin_left: 1 do
      background white
      case
      when @which_tab == "teachers"
        para person.name
      when @which_tab == "families"
        para person.cup_fullname
      end
      if sort_opt == "Sort by Address"
        para " #{person.address}"
      end
      @most_recent_user = person.user_id
      click do |button, x, y| 
        drag_and_drop(person.user_id, x, y - @y_offset)
        timer(0.7) do
          unless @mouse_down
            info_window(person, @which_tab)
          end
        end
      end
      hover do |slot|
        @which_user = person.user_id
        @y_offset = @arr_of_flow_ids.index(person.user_id) * 25
        slot.clear do
          background rgb(220, 220, 220)
          case
          when @which_tab == "teachers"
            para person.name
          when @which_tab == "families"
            para person.cup_fullname
          end
          if sort_opt == "Sort by Address"
            para " #{person.address}"
          end
        end # clear
      end # hover
      leave do |slot|
        slot.clear do
          background white
          case
          when @which_tab == "teachers"
            para person.name
          when @which_tab == "families"
            para person.cup_fullname
          end
          if sort_opt == "Sort by Address"
            para " #{person.address}"
          end
        end # clear
      end # leave
    end #@temp_flow
  end #@sorted_people.each do
end
#..........................
# Other smaller creates
#..........................
def create_people_raw
  @@people_raw = CsvMapper.import('test_ward.csv') do
    read_attributes_from_file
  end
end

def create_p_info
  @@people = @@people_raw.map {|person| Person.new(*person.to_a) }
  @@p_info = @@people.index_by &:user_id
end

def create_htf_raw
  @@htf_raw = CsvMapper.import('test_htf.csv') do
    read_attributes_from_file
  end
end

def create_ment_info
  @@ments = @@htf_raw.map {|htf| HTA.new(*htf.to_a) }
  @@ment_info = @@ments.index_by &:ment_id
end

