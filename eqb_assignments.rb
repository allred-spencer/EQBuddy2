def eqb_assignments
  @which_window = "a"
  @ment_hover = false
  @leave_block_redraw = true
  @dont_edit = true
  @editing_ments = false
  @delete_ments = false
  @sort_opt = "Sort Alphabetically"
  app.clear()
  @tabs = eqbuddy_tabs     # tabs at top
  ments_box
  ments_people # people lists
  background @tab_gray, right: 0.255, width: 6
  background black, right: 0.255, width: 1
  background black, right: 0.25, width: 1
end
#......................
#ments_box
#......................
def ments_box
  stack :width => '75%', do
    @ments_top_bar = flow do
      background @color_scheme[0]
      #ADD ASSIGNMENT
      image "images/plus.png", :width => 25, :height => 28, :margin_top => 8, :margin_left => 5 do
        @new_ment = HTA.new
        @poss_chars =  [('a'..'z'),('0'..'9')].map{|i| i.to_a}.flatten
        @new_ment.ment_id = (0...9).map{ @poss_chars[rand(@poss_chars.length)] }.join
        @new_ment.companions = ""
        @new_ment.families = ""
        @new_ment.color = midnightblue
        @@ments << @new_ment
        save_and_reload_ments("only")
        @ments_flow.clear{create_ment_stacks(@ments_search_bar_text,@ment_criteria)}
      end
      image "images/minus.png", width: 28, height: 30, margin_top: 7, margin_left: 5 do
        if @delete_ments
          @delete_ments = false
          @ments_flow.clear{create_ment_stacks(@ments_search_bar_text,@ment_criteria)}
        else
          @delete_ments = true
          @ments_flow.clear{create_ment_stacks(@ments_search_bar_text,@ment_criteria)}
        end
      end
      #SEARCH BAR
      @ments_search_bar_text = ""        
      @ments_search_bar = edit_line do |e|
        @ments_search_bar_text = e.text
        @timer_flow.remove unless @timer_flow.class == NilClass
        @timer_flow = flow do
          @time = 0
          every(0.1) do
            @time = @time + 0.1
            if @time > 0.2
              @ments_flow.clear{create_ment_stacks(e.text,@ment_criteria)}
              @timer_flow.remove
            end
          end #every
        end # flow
      end # edit line do
      @color_array = []
      @colors_top = 10
      draw_colors
    end # top bar

    #MENTS FLOW
    @ments_flow = flow :height => @height, :scroll => true, margin_top: 6 do
      create_ment_stacks("","All")
    end

    #WINDOW SIZE ADJUST
    every(2) do
      @windowheight = slot.height # app height
      @height = @ments_flow.height + @tabs.height + @ments_top_bar.height - 2 #height of contents?
      unless @windowheight == @height + 6 # does the app match the contents? If not, make ments flow bigger
        @ments_flow.style(:height => @windowheight - @ments_top_bar.height - @tabs.height)          
      end # unless
    end # every
  end #stack
end # def ments_box

#......................
#ments_people
#......................  
def ments_people
  stack :width => '25%' do
    @ments_people_top = flow do 
      background @color_scheme[0]

      stack do
        # SEARCH BAR
        @ments_names_text = ""
        edit_line do |e|
          @ments_names_text = e.text
          @timer_flow.remove unless @timer_flow.class == NilClass
          @timer_flow = flow do
            @time = 0
            every(0.1) do
              @time = @time + 0.1
              if @time > 0.2
                @ments_names_list.clear {create_ments_name_flows(e.text, @which_tab,@sort_opt)}
                @timer_flow.remove
              end
            end #every
          end # flow
        end # edit line do
        # SORT OPTS
        list_box :items => ["Sort by Home Teaching Stats", "Sort Alphabetically", "Sort by Address"],
          choose: "Sort Alphabetically", do |sort_list|
            @sort_opt = sort_list.text
            @ments_names_list.clear {create_ments_name_flows(@ments_names_text, @which_tab,@sort_opt)}
          end

        # PEOPLE TABS
        @which_tab = "teachers"
        @people_tabs = flow do
          create_people_tabs 
        end
      end #stack
    end #stack

    @ments_names_list = stack :scroll => true, :height => @height2, :right_margin => gutter do
      create_ments_name_flows(@ments_names_text,@which_tab,@sort_opt)            
      hover {@small_zone = @which_tab; @large_zone = "name flows"}
      leave {@small_zone = nil; @large_zone = nil}
    end

    #WINDOW SIZE ADJUST
    every(0.5) do
      @windowheight2 = slot.height
      @height2 = @ments_names_list.height + @tabs.height + @ments_people_top.height - 2
      unless @windowheight2 == @height2
        @ments_names_list.style(:height => @windowheight2 - @ments_people_top.height - @tabs.height)
      end #unless
    end # every
  end
end
