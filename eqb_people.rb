#====================================================================
#People
#====================================================================
@color_scheme1 = [rgb(204,204,204),rgb(0,51,102),rgb(255,255,255),rgb(204,204,153)];
def eqb_people
  @which_window = "p"
  app.clear()
  @tabs = eqbuddy_tabs #tabs at top
  sidebar # list of names
  @info_box_large = stack :width => "55%", :margin_left => 10 do
    para "Click on a name at left"
  end
  @photo_stack = stack :width => "20%", :margin_top => 15 do
    para ""
  end
end

#..................
#sidebar
#......................
def sidebar
  stack :width => "25%" do
    background @color_scheme[0]
    @top_flow = flow :height => 40, :margin_left => 6 do
      background @color_scheme[0]        
      image "images/plus.png", :width => 30, :height => 23, :margin_left => 8, :margin_top => 2 do
        @temp_flow2 = flow do
          @@spouse_check = "not yet"
          every(0.5) do
            if @@spouse_check == "now!"
              case
              when @@new_guy_has_spouse == "has spouse"
                @@spouse_check = "done now"
                @poss_chars =  [('a'..'z'),('0'..'9')].map{|i| i.to_a}.flatten
                @new_user_id = (0...9).map{ @poss_chars[rand(@poss_chars.length)] }.join
                @new_user_id2 = (0...9).map{ @poss_chars[rand(@poss_chars.length)] }.join                  
                @new_guy = Person.new
                @new_guy.user_id = @new_user_id
                @new_guy.spouse_id = @new_user_id2
                @new_guy.ments_count = 0
                @new_guy.receives = ""
                @new_guy.stat1 = ""
                @new_guy.stat2 = ""                    
                @new_guy.assign_ments = ""
                @new_guy.teachers_ment = ""
                @new_guy.comment = ""
                @new_guy.which_photo = "a"
                @new_guy.lds_vals = false
                @new_guy.lds_id = ""

                @new_guy_spouse = Person.new
                @new_guy_spouse.user_id = @new_user_id2
                @new_guy_spouse.spouse_id = @new_user_id               
                @new_guy_spouse.ments_count = 0
                @new_guy_spouse.receives = ""
                @new_guy_spouse.stat1 = ""
                @new_guy_spouse.stat2 = ""                    
                @new_guy_spouse.assign_ments = ""
                @new_guy_spouse.teachers_ment = ""
                @new_guy_spouse.comment = ""
                @new_guy_spouse.which_photo = "a"                    
                @new_guy_spouse.lds_vals = false
                @new_guy_spouse.lds_id = ""

                contact_window(@new_guy, @new_guy_spouse)
                @temp_flow2.remove                      
              when @@new_guy_has_spouse == "hasn't spouse"
                @@spouse_check = "done now"
                @poss_chars =  [('a'..'z'),('0'..'9')].map{|i| i.to_a}.flatten
                @new_user_id = (0...9).map{ @poss_chars[rand(@poss_chars.length)] }.join                  
                @new_guy = Person.new
                @new_guy.user_id = @new_user_id
                @new_guy.spouse_id = ""
                @new_guy.ments_count = 1
                @new_guy.receives = ""
                @new_guy.stat1 = ""
                @new_guy.stat2 = ""                    
                @new_guy.assign_ments = ""
                @new_guy.teachers_ment = ""
                @new_guy.comment = ""
                @new_guy.which_photo = "a"                   
                @new_guy.lds_vals = false
                @new_guy.lds_id = ""
                contact_window(@new_guy, @@new_guy_has_spouse)
                @temp_flow2.remove                  
              else
                @temp_flow2.remove                                  
              end
            end #if
          end #every
        end #temp_flow                 
        window :height => 200, :width => 300, :resizable => false do
          flow do
            background black
            para "Is the person you're adding married?", :stroke => white
          end
          flow do
            @yes_button = button "Yes"
            @no_button = button "No"
            @cancel_button = button "Cancel"
            @yes_button.click do
              @@spouse_check = "now!"
              @@new_guy_has_spouse = "has spouse"
              close()                
            end
            @no_button.click do
              @@spouse_check = "now!"              
              @@new_guy_has_spouse = "hasn't spouse"
              close()
            end
            @cancel_button.click do
              @@spouse_check = "now!"              
              close()
            end
          end
        end # end window
      end
      # search bar on left side
      @people_search_bar_text = ""
      @people_search_bar = edit_line :width => "75%" do |e|
        @people_search_bar_text = e.text
        @timer_flow.remove unless @timer_flow.class == NilClass
        @timer_flow = flow do
          @time = 0
          every(0.1) do
            @time = @time + 0.1
            if @time > 0.2
              @names_list.clear {create_name_flows(e.text,@search_options)}
              @timer_flow.remove
            end
          end #every
        end # flow
      end # edit_line do
    end # top_flow
    # search options
    list_box :margin_left => 6,
      :items => [ "All", "Home Teaching Pool","Move-ins"], 
      :choose => "All",
      do |list|
      @search_options = list.text
      @names_list.clear{create_name_flows(@people_search_bar.text,list.text)}
      end
    @names_list = stack :margin_right => 10, :margin_left => 10, scroll: true, margin_bottom: 20 do #Initialize names list
      @search_options = "All"
      create_name_flows(@people_search_bar_text,@search_options)
      every(0.5) do
        @p_windowheight = slot.height
        @p_height = @names_list.height + @tabs.height + @top_flow.height + 50
        unless @p_windowheight + 2 == @p_height
          @names_list.style(:height => @p_windowheight - @top_flow.height - @tabs.height - 30)
        end #unless
      end # every
    end
  end # stack
end #sidebar
