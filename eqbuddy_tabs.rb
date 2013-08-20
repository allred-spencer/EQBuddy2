#EQBuddy_tabs
def eqbuddy_tabs
  case
  when @which_window == "a"
    @ment_image = "images/ments_sel.png"
    @people_image = "images/people_n_sel.png"
    @tools_image = "images/tools_n_sel.png"
  when @which_window == "p"
    @ment_image = "images/ments_n_sel.png"
    @people_image = "images/people_sel.png"
    @tools_image = "images/tools_n_sel.png"
  when @which_window == "t"
    @ment_image = "images/ments_n_sel2.png"
    @people_image = "images/people_n_sel2.png"
    @tools_image = "images/tools_sel.png"
  else
    @ment_image = "images/ments_n_sel2.png"
    @people_image = "images/people_n_sel.png"
    @tools_image = "images/tools_n_sel.png"   
  end
  
@tab_gray = rgb(168,175,183)
@tab_stripe = rgb(132,132,132)
@tab_lightgray = rgb(201,206,212)
@scheme1 = [rgb(0,51,102),rgb(255,248,220),rgb(204,204,153)] #0blue, 1cream, 2gold
@scheme2 = [darkred, seashell, black] #0crimson, 1cream, 2black
@color_scheme = @scheme1
@@color_scheme = @scheme1
background @color_scheme[1]

flow :height => 37 do
  background @color_scheme[0]
  background @tab_stripe, :bottom => 9, :height => 1
  background @tab_lightgray, :bottom => 8, :height => 1
  background @tab_gray, :bottom => 7, :height => 7
  if @which_window == "p"
    background black, :bottom => 1, :height => 1
  end
  stack :width => 212 do
    image @ment_image, do
      eqb_assignments
    end
  end
  stack :width => 196 do
    image @people_image do
      eqb_people
    end
  end
  stack :width => 196 do
    image @tools_image do
      eqb_tools
    end 
  end
end
end
