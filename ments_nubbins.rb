def drag_and_drop(user_id, x, y)
  @grabbed_id = user_id
  @x_diff = -x  #subtract local location from global to offset stack correctly
  @y_diff = -y  
  #  alert "click @x: " +  @x.to_s +  ", @y: " +  @y.to_s +  "\n x: " +  x.to_s +  ", y: " +  y.to_s
  @dragon_stack = stack :left => @x + @x_diff , :top => @y + @y_diff, :width => 200, :height => 25 do
    background white
    case
    when @small_zone == "teachers" 
      para @@p_info[user_id].name
    when @small_zone == "families" 
      para @@p_info[user_id].cup_fullname
    end
  end
end

#Sorry, teachers flow is ugly because I have to do an in-line click
#block in order to adjust the margin of the link it seems
def teachers_flow(ment, id_array)
  if @ment_hover && @grabbed_id != nil

    # check to see if teacher would home teach self
    @comp_check1 = "pass"
    if ment.families.include?(@grabbed_id) then @comp_check1 = "fail" end
    # check to see if teacher would home teach one of his own teachers
    @comp_check2 = "pass"
    ment.fam_ids.each do |id|
      if @@p_info[@grabbed_id].taught_by.include?(id) then @comp_check2 = "fail" end
    end
    # check to see if person would home teach any of his companions
    @comp_check3 = "pass"
    @@p_info[@grabbed_id].assigned_to.each do |ment_id| #round up all the guy I'm holding's home teaching assignments
      @@ment_info[ment_id].comp_ids.each do |id| #round up all the companions from those assignments
        if ment.families.include?(id) # are any of his companions in the assignment we're putting him in
          @comp_check3 = "fail"
        end
      end # each
    end # each
    # check to see if adding this guy would put him over his allowed count
    @comp_check4 = "pass"
    if @@p_info[@grabbed_id].ments_count == @@p_info[@grabbed_id].assigned_to.length then @comp_check4 == "fail" end


    #    alert "#{ @comp_check1 == "pass"} #{ @comp_check2 == "pass" } #{ @comp_check3 == "pass"}"
    @passed_comp_checks = @comp_check1 == "pass" && @comp_check2 == "pass" && @comp_check3 == "pass" && @comp_check4 == "pass"

    if @passed_comp_checks
      @dont_edit = false
    else
      @dont_edit = true
    end
  end
  @redraw_conditions_met = @from_type == "teachers" && !(id_array.include?(@grabbed_id)) && @ment_hover && @leave_block_redraw && @grabbed_id != nil && @editing_ments == false

  # alert "#{@from_type == "teachers"}  #{!(id_array.include?(@grabbed_id))} #{@ment_hover} #{ @leave_block_redraw} #{ @grabbed_id != nil } #{ @editing_ments == false} "

  flow height: 25 do
    background @back_color, width: "99%",curve: 6
    background @back_color, bottom: 12, height: 12, width: "99%"
    case
    when id_array.length == 0
      if @redraw_conditions_met 
        para @@p_info[@grabbed_id].ment_name, stroke: white unless @dont_edit
      end
      if @delete_ments
        delete_assignments(ment) unless @@ments.length == 1
        if @@ments.length == 1
          @delete_ments = "deleting"
        end
      end
    when id_array.length == 1
      para link(@@p_info[id_array[0]].ment_name).click{|button, x, y| drag_and_drop(id_array[0],  @x - @left - 10, @y - @top - 77); timer(0.7){ unless @mouse_down then info_window(@@p_info[id_array[0]], "teachers") end}}, margin_left: 10
      if @redraw_conditions_met 
        para " & ", stroke: white, margin_left: 7 unless @dont_edit
        para @@p_info[@grabbed_id].ment_name, stroke: white unless @dont_edit
      end
      if @delete_ments
        delete_assignments(ment) unless @@ments.length == 1
        if @@ments.length == 1
          @delete_ments = "deleting"
        end
      end
  when id_array.length == 2
    para link(@@p_info[id_array[0]].ment_name).click{|button, x, y| drag_and_drop(id_array[0],  @x - @left - 10, @y - @top- 77); timer(0.7){ unless @mouse_down then info_window(@@p_info[id_array[0]], "teachers") end}}, margin_left: 10 
    @and_para = para " & ", stroke: white, margin_left: 7 
    @comp2_para = para link(@@p_info[id_array[1]].ment_name).click{|button, x, y| drag_and_drop(id_array[1],  @x - @left - 50, @y - @top- 77); timer(0.7){ unless @mouse_down then info_window(@@p_info[id_array[1]], "teachers") end}}
    if @redraw_conditions_met 
      @and_para.remove unless @dont_edit
      @comp2_para.style(margin_left: 11) unless @dont_edit
      para " & ", stroke: white, margin_left: 7 unless @dont_edit
      para @@p_info[@grabbed_id].ment_name, stroke: white unless @dont_edit
    end
    if @delete_ments
      delete_assignments(ment) unless @@ments.length == 1
      if @@ments.length == 1
        @delete_ments = "deleting"
      end
    end
    when id_array.length == 3
      para link(@@p_info[id_array[0]].ment_name).click{|button, x, y| drag_and_drop(id_array[0],  @x - @left - 10,  @y - @top- 77); timer(0.7){ unless @mouse_down then info_window(@@p_info[id_array[0]], "teachers") end}}, margin_left: 10
      para link(@@p_info[id_array[1]].ment_name).click{|button, x, y| drag_and_drop(id_array[1],  @x - @left - 50, @y - @top- 77); timer(0.7){ unless @mouse_down then info_window(@@p_info[id_array[1]], "teachers") end}}, margin_left: 11
      para " & ", stroke: white, margin_left: 7
      para link(@@p_info[id_array[2]].ment_name).click{|button, x, y| drag_and_drop(id_array[2],  @x - @left - 90,  @y - @top- 77); timer(0.7){ unless @mouse_down then info_window(@@p_info[id_array[2]], "teachers") end}}
      if @delete_ments
        delete_assignments(ment) unless @@ments.length == 1
        if @@ments.length == 1
          @delete_ments = "deleting"
        end
      end
    end #case      
    click do
      # For some reason a blank assignment gets two alerts . . . but only if it's been hovered. I absolutely do not know why.
      # that's why we have the @not_colored variable
      if @grabbed_id == nil

        @not_colored = true
        timer (0.7) do
          @@color_check = "not set"
          @temp_flow3 = flow do
            every(0.2) do
              if @@color_check == "color set" 
                @@color_check = "done now"
                @grabbed_id = nil
                ment.color = @@chosen_color 
                save_and_reload_ments("only") 
                @ments_flow.clear{create_ment_stacks(@ments_search_bar_text,@ment_criteria)} 
                @ment_hover = false
                @old_ment = nil
                @large_zone = nil
                @temp_flow3.remove
              end
            end #every
          end #flow
          if @delete_ments == "deleting" then @dont_color = true else @dont_color = false end

          #   alert "#{@grabbed_id == nil} #{@not_colored} #{@delete_ments} #{@dont_color}"
          if @grabbed_id == nil && @not_colored && !(@dont_color) #if I hold nothing, and it's not colored, and we're not deleting
            choose_color 
          else
            @delete_ments = false
            @temp_flow3.remove
          end
          timer (1) do
            @not_colored = false
          end
        end # timer
      end # if grabbed id
    end # click
    hover {@small_zone = "teachers"}
    leave { if @large_zone == nil then @small_zone = nil end}
  end#flow
end
# choose color pop up window
def choose_color
  @choose_color_window =  window height: 100, width: 223, :title => "District Color" do
    stack do
      flow do
        background black, height: 40
        para "District Color", stroke: white
      end
      flow do
        @col_box_left = 10
        [midnightblue, firebrick, darkgreen, darkorange, saddlebrown, purple, black].each do |color|
          stroke color
          fill color
          @shape = rect @col_box_left, 20, 20, 20
          @col_box_left = @col_box_left + 30
          @shape.click do
            @@chosen_color = color
            @@color_check = "color set"
            close()
          end
        end
      end
    end
  end
end

def delete_assignments (ment)
  image "images/minus.png", height: 20, width: 20, right: 5, top: 2 do
    ment.comp_ids.each do |id|
      @@p_info[id].assign_ments.gsub!(/,#{ment.ment_id}|#{ment.ment_id},|#{ment.ment_id}/,'')
    end

    ment.fam_ids.each do |id|
      @@p_info[id].teachers_ment.gsub!(/,#{ment.ment_id}|#{ment.ment_id},|#{ment.ment_id}/,'')
    end

    @@ments.delete_if {|assignment| assignment.ment_id == ment.ment_id}
    save_and_reload
    @delete_ments = "deleting"
    @ments_flow.clear{create_ment_stacks(@ments_search_bar_text,@ment_criteria)}
    @ments_names_list.clear {create_ments_name_flows(@ments_names_text, @which_tab, @sort_opt)}
  end
end

# Colors at top of screen for filtering ments
def draw_colors
  @colors_left = 280
  [midnightblue, firebrick, darkgreen, darkorange, saddlebrown, purple, black].each do |color|
    stroke dimgray
    fill color
    if @color_array.include?(color) then stroke white end
    @shape = rect @colors_left, @colors_top, 15, 15
    @colors_left = @colors_left+ 25
    @shape.click do
      if @color_array.include?(color)
        @color_array.delete_if{|col| col == color}
      else
        @color_array << color
      end
      draw_colors
      @ments_flow.clear{create_ment_stacks(@ments_search_bar_text,@ment_criteria)}
      @ments_names_list.clear {create_ments_name_flows(@ments_names_text, @which_tab, @sort_opt)}
    end
  end
  @colors_top = 47
end

def info_window(person, which_type)
  @temp_photo = photo(person)
  if which_type == "teachers"
    @name = person.name
  else
    @name = person.cup_fullname
  end

  @adj_image_height = @image_height + 40
  if @name.length > 15 then @adj_image_height += 25 end
  if @name.length > 30 then @adj_image_height += 25 end


  @i_window = window height:  @adj_image_height, width: @image_width + 4,  :title => "Contact info" do
    background @@color_scheme[1]
    if which_type == "teachers"
      @name = person.name
    else
      @name = person.cup_fullname
    end

    stack do
      caption "#{@name}"
      if File.file?("images/#{person.user_id}#{person.which_photo}.jpg")
        @image_path = "images/#{person.user_id}#{person.which_photo}.jpg"
      else
        @image_path = "images/default.png"
      end
      @photo = image @image_path 

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
      

      @photo.style(:height => @image_height, :width => @image_width, margin: 6)
    end
  end #window
  @temp_photo.remove
  if Shoes.APPS.to_s =~ /Contact info/ && Shoes.APPS.to_s  =~ /District Color/
    #alert "The contact and color windows are open right now!"
    @choose_color_window.close
  end
end
