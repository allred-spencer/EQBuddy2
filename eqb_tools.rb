#====================================================================
#Tools
#====================================================================
def eqb_tools
  @which_window = "t"
  app.clear()
  eqbuddy_tabs
  tool_buttons #this is just a flow of big buttons
end
  #......................
  #tool_buttons
  #......................
  def tool_buttons
    button "Send Emails" do alert "Emails sent!" end
    button "Print Assignments" do print_tool end
    button "Sync with LDS.org" do sync_tool end
    button "Why slow?" do 
      @begin = Time.now
      @@people.each do |person|
        if person.is_married?
          person.spouse.lds_id
        end
      end
      alert Time.now - @begin
    end
  end
