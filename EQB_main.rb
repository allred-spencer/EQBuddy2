# EQBuddy
# It all works like this. There are 3 tabs -- Assignments, People, Tools
# By calling eqbuddy_tabs you create a flow at the top of the page
# with buttons linking you to these tabs. Whenever a button is clicked
# the whole app is cleared and you see the content of that tab.
# Each of those tabs is sitting in it's own file. These tabs call on a lot
# of the same things though like contact info block. So there is a file 
# called nubbins (hehe) which has those little methods in it.
# Sometimes we need to recreate the people and HTA structrs from scratch
# since their members have changed. Methods that do this are called 
# "Creates" and there is a file of them too.
#====================================================================
#Initial Definitions
#====================================================================
require 'csv-mapper'
require 'json'
#require 'pdf/reader'

require 'watir-webdriver'
require 'prawn'
require 'mechanize'
#require 'mail'

cd File.expand_path('~/.EQBuddy')
require 'eqbuddy_tabs'
require 'eqb_assignments' #tab 1
require 'eqb_people' # tab 2
require 'eqb_tools' # tab 3
require 'creates'
require 'ments_nubbins' # ments as in assignments
require 'people_nubbins' #nubbins 1
require 'print_tool'
require 'sync_tool'

module Enumerable
  def index_by
    return to_enum :index_by unless block_given?
    Hash[map { |elem| [yield(elem), elem] }]
  end
end

class Array
  def to_sentence_like
    case
    when self.length == 0
      nil
    when self.length == 1
      result = self[0]
    else
      result = "#{self[0, self.length-1].join(', ')} and #{self.last}"
    end
  end
end


#====================================================================
#Shoes App Proper
#====================================================================
Shoes.app :width => 1200, :height => 700, :title => "EQBuddy" do


style Link, underline: nil, stroke: white
style LinkHover, underline: nil, stroke: white 



#filename = "pdfs/test.pdf"
#
#PDF::Reader.open(filename) do |reader|
#  reader.pages.each do |page|
#    alert page.text
#  end
#end


#pdf = PDF::Writer.new
#pdf.select_font "Times-Roman"
#pdf.text "Chunky Bacon!!", :font_size => 72, :justification => :center
#
#i0 = pdf.image "images/chunkybacon.jpg", :resize => 0.75
#i1 = pdf.image "images/chunkybacon.png", :justification => :center, :resize => 0.75
#pdf.image i0, :justification => :right, :resize => 0.75
#
#pdf.text "Chunky Bacon!!", :font_size => 72, :justification => :center
#
#pdf.save_as("chunkybacon.pdf")


#Mail.defaults do
#  delivery_method :smtp, {
#    :address              => 'smtp.gmail.com',
#    :port                 => 587,
#    :user_name            => 'firstwardeldersquorum',
#    :password             => 'Hometeaching100',
#    :authentication       => 'plain',
#    :enable_starttls_auto => true
#  }
#end
#
#Mail.deliver do
#  to 'iamkcerb@gmail.com'
#  from 'firstwardeldersquorum@gmail.com'
#  subject 'It works! HAHA' 
#  body 'OK, now we can do some serious crap!'
#end
#
#alert "Mail is delivered Mon frere"


# Basically we're just going to define two types of structs here in the app
# The rest are methods that are created and defined else wheres.
create_people_raw

#..................
# Person
#..................
Person = Struct.new(*@@people_raw.first.members) do
  #create p_info and ment_info for this struct
  def people
    people_raw = CsvMapper.import('test_ward.csv') do
      read_attributes_from_file
    end
    people_raw.map {|person| Person.new(*person.to_a) }
  end
  def dup_names
    arr_of_names = people.map do |person| 
      next unless person.gender == "Male"
      person.pref_name
    end
    arr_of_names.delete_if {|e| e == nil}
    arr_of_names.group_by {|e| e}.select {|k,v| v.size > 1}.map(&:first)
  end  
  def p_info
    people.index_by &:user_id
  end
  #create p_info and ment_info for this struct  
  def ment_info
    htf_raw = CsvMapper.import('test_htf.csv') do
      read_attributes_from_file
    end
    ments = htf_raw.map {|htf| HTA.new(*htf.to_a) }
    ment_info = ments.index_by &:ment_id
  end
    
  
  #modify some parts of the struct and give them new names
  def assigned_to
    if assign_ments == "" || assign_ments == nil
      []
    else
      assign_ments.split(",")
    end
  end
  def taught_by
    if teachers_ment == "" || teachers_ment == nil
      []
    else
      ment_info[teachers_ment].companions.split(",")
    end
  end
  def teaches_stat
    if stat1 == "" || stat1 == nil
      []
    else
      stat1.split(",")
    end
  end
  def taught_stat
    if stat2 == "" || stat2 == nil
      []
    else
      stat2.split(",")
    end
  end
  def address
    if street_address == "" || street_address == " " || street_address == nil
      "<no address>"
    else
      street_address
    end
  end
  def phone
    if phone_number == "" || phone_number == " " || phone_number == nil
      "<no phone>"
    else
      phone_number
    end  
  end
  def email
    if email_address == "" || email_address == " " || email_address == nil
      "<no email>"
    else
      email_address
    end  
  end
  
  # names
  def name
    pref_name + " " + last_name
  end
  
  def is_married?
    !(spouse_id == "")
  end
  def spouse
    if is_married?
      p_info[spouse_id]
    else
      nil
    end
  end
  
 # def cup_fullname
 #   case
 #   when is_married? && last_name == spouse.last_name
 #     pref_name + " & " + spouse.pref_name + " " + last_name
 #   when is_married? && last_name != spouse.last_name
 #    name + " & " + spouse.name
 #   else
 #     name
 #   end
 # end
  
  def cup_name
    if is_married?
      pref_name + " & " + spouse.pref_name
    else
      pref_name
    end
  end

  def info_block_name
    if pref_name != first_name
      name + " (" + first_name + ")"
    else
      name
    end
  end

  def ment_name
  dup_names
    if dup_names.include?(pref_name)
      pref_name + " " + last_name.chars.first + "."
    else
      pref_name
    end
  end  
  def comps(ment) #array of names, if you want a string use the other one
    ment_info[ment].comp_names.delete_if {|comp_name| comp_name == name}
  end
  
  def fams(ment) #array of names, if you want a string use the other one
    ment_info[ment].fam_names
  end
  # Some useful strings
  def comps_string(ment)
    comps(ment).to_sentence_like
  end
  
 # def search_elems # A string of info for searching
 #   if is_married?
 #     searchstring = first_name + " " + name + " " + spouse.first_name + " " + spouse.name + " " +
 #     address + " " + phone + " " + email + " " + spouse.phone +
 #     " " + spouse.email
 #     searchstring.downcase
 #   else
 #     searchstring = name + " " + address + " " + phone + " " + email
 #     searchstring.downcase
 #   end
 # end  
  
end #end of "a Person is a new struct that has the following"
create_p_info












create_htf_raw
#.........................
# Home Teaching Assignment
#.........................

HTA = Struct.new(*@@htf_raw.first.members) do
  def p_info
    people_raw = CsvMapper.import('test_ward.csv') do
      read_attributes_from_file
    end
    people = people_raw.map {|person| Person.new(*person.to_a) }
    people.index_by &:user_id
  end
  def ment_info
    htf_raw = CsvMapper.import('test_htf.csv') do
      read_attributes_from_file
    end
    ments = htf_raw.map {|htf| hta.new(*htf.to_a) }
    ment_info = ments.index_by &:ment_id
  end

  def comp_ids #comps is an array of ids
    if companions == "" || companions == nil
      []
    else
      companions.split(",")
    end
  end
  def fam_ids #fams is an array of ids
    if families == "" || families == nil
      []
    else
      families.split(",")
    end
  end
  def search_elems
    comp_ids.map {|id| @@p_info[id].name}.join(" ") + " " + fam_ids.map{|id| @@p_info[id].cup_fullname}.join(" ")
  end
  def comp_names  #array of names
    comp_ids.map do |comp_id|
      p_info[comp_id].name
    end
  end
  def comp_names_string # a string
    comp_names.to_sentence_like
  end
  def fam_names #array of names
    fam_ids.map do |fam_id|
      p_info[fam_id].name
    end
  end
  def fam_names_string # a string
    fam_names.to_sentence_like
  end
end #end "an HTA is a new struct with the following:"
create_ment_info  




#Now we can get to the opening screen
@which_window = nil
flow do
  eqbuddy_tabs
  para "Welcome to EQBuddy. If you already know what you're doing then ",
  "you should just click on one of the buttons above. If you are new ",
  "then you should watch the tutorial video online. It will explain ",
  "how to import your current home teaching info and all of the features ",
  "of EQBuddy. Don't hesitate to ask the creator of this app your questions!"
end
motion do |x, y|
  if @mouse_down && @dragon_stack.class != NilClass
#    alert "motion @x: " + @x.to_s + ", @y: " + @y.to_s + "\n, x: " + x.to_s + ", y: " + y.to_s
    @dragon_stack.move( x + @x_diff, y + @y_diff)
  end
end
click {|button, x, y| @mouse_down = true;   @x = x;  @y = y; @from_type = @small_zone; @from_zone = @large_zone}
release do

  if @which_window = "a"
    @mouse_down = false 
    @dragon_stack.remove unless @dragon_stack.class == NilClass
    @dont_bother = false
    if @from_type == "teachers"
      @dont_bother = true unless @passed_comp_checks
    end
    if @from_type == "families"
      @dont_bother = true unless @passed_fam_checks
    end

    @to_zone = @large_zone #ment id if in a ment
    
    # there are three moves: ment to ment, flows to ment, ment to else
    if @from_zone == nil || @from_zone == "name flows"
      @from_ment = false
    else
      @from_ment = true
    end
    if @to_zone == nil || @to_zone == "name flows"
      @to_ment = false
    else
      @to_ment = true
    end
    # reset don't bother if it turns out they're deleting!
    if @from_ment && !(@to_ment)
      @dont_bother = false
    end

    # check to see if adding person would give them more than one set of home teachers
    @ment_ids = []
    @@ments.each do |ment|
      @ment_ids << ment.ment_id
    end
    if @from_type == "families" && @grabbed_id != nil && @from_zone != "name flows" && @ment_ids.include?(@from_zone)
      unless @@ment_info[@from_zone].families.include?(@grabbed_id)
        @dont_bother = true
      end
    end
    # Now we write an assignment
    # This must be done to @@ments, not @@ment_info
    # for the export.
    if @from_type != nil && @grabbed_id != nil
      @person_index = @@people.find_index(@@p_info[@grabbed_id])
      @edit_person  = @@people[@person_index] 
      @ment_index   = @@ments.find_index(@@ment_info[@from_zone]) if @from_ment 
      @fment_edit   = @@ments[@ment_index] if @from_ment
      @ment_index   = @@ments.find_index(@@ment_info[@to_zone]) if @to_ment
      @tment_edit   = @@ments[@ment_index] if @to_ment
      @editing_ments = true #a flag so that teachers flow doesn't think it needs to include changes in all teachers flows!
#alert "from zone: #{@from_zone}, from type: #{@from_type}, to zone: #{@to_zone}, from ment? #{@from_ment}, to ment? #{@to_ment}"

      case # flow to ment? Don't bother, ment to ment? ment to nil? CASE!!
      when @dont_bother
        nil
      # FROM FLOW TO ELSE
      when @from_zone == "name flows" && !(@to_ment)
        @dont_bother = true
      # FROM MENT TO MENT
      when @from_ment && @to_ment
        case
        when @fment_edit == @tment_edit
          @dont_bother = true
        # EDIT TEACHERS
        when @from_type == "teachers"
          # Add person to ment as comp
          if @tment_edit.companions == ""
            @tment_edit.companions << @grabbed_id
          else
            @tment_edit.companions << "," + @grabbed_id
          end
          # Add ment to person
          if @edit_person.assign_ments == ""
            @edit_person.assign_ments << @to_zone
          else
            @edit_person.assign_ments << "," + @to_zone
          end
          # Delete person from old ment
          @fment_edit.companions.gsub!(/,#{@grabbed_id}|#{@grabbed_id},|#{@grabbed_id}/,'')
          # Delete old ment from person
          @edit_person.assign_ments.gsub!(/,#{@from_zone}|#{@from_zone},|#{@from_zone}/,'')
        
        # EDIT FAMILIES
        when @from_type == "families"
          # Add person to ment as fam
          if @tment_edit.families == ""
            @tment_edit.families << @grabbed_id
          else
            @tment_edit.families << "," + @grabbed_id
          end
          # Add ment to person
          if @edit_person.teachers_ment == ""
            @edit_person.teachers_ment << @to_zone
          else
            @edit_person.teachers_ment << "," + @to_zone
          end

          # Delete person from old ment
          @fment_edit.families.gsub!(/,#{@grabbed_id}|#{@grabbed_id},|#{@grabbed_id}/,'')
          # Delete old ment from person
          @edit_person.teachers_ment.gsub!(/,#{@from_zone}|#{@from_zone},|#{@from_zone}/,'')
        end

      # FROM FLOW TO MENT
      when @from_zone == "name flows" && @to_ment
        case 
        #EDIT TEACHERS
        when @from_type == "teachers"
          # Add person to ment as comp
          if @tment_edit.companions == ""
            @tment_edit.companions << @grabbed_id
          else
            @tment_edit.companions << "," + @grabbed_id
          end

          # Add ment to person
          if @edit_person.assign_ments == ""
            @edit_person.assign_ments << @to_zone
          else
            @edit_person.assign_ments << "," + @to_zone
          end

        # EDIT FAMILIES
        when @from_type == "families"
          alert "this block is running"
          # Add person to ment as fam
          if @tment_edit.families == ""
            @tment_edit.families << @grabbed_id
          else
            @tment_edit.families << "," + @grabbed_id
          end

          # Add ment to person
          if @edit_person.teachers_ment == ""
            @edit_person.teachers_ment << @to_zone
          else
            @edit_person.teachers_ment << "," + @to_zone
          end

        end

      # FROM MENT TO ELSE
      when @from_ment && !(@to_ment)
        case 
        # EDIT TEACHERS
        when @from_type == "teachers"
          # Delete person from ment
          @fment_edit.companions.gsub!(/,#{@grabbed_id}|#{@grabbed_id},|#{@grabbed_id}/,'')
          # Delete ment from person
          @edit_person.assign_ments.gsub!(/,#{@from_zone}|#{@from_zone},|#{@from_zone}/,'')
        
        # EDIT FAMILIES
        when @from_type == "families"
          # Delete person from ment
          @fment_edit.families.gsub!(/,#{@grabbed_id}|#{@grabbed_id},|#{@grabbed_id}/,'')
          # Delete ment from person
          @edit_person.teachers_ment.gsub!(/,#{@from_zone}|#{@from_zone},|#{@from_zone}/,'')
        end
      end # major case statement
      save_and_reload  unless @dont_bother
      @ments_flow.clear{create_ment_stacks(@ments_search_bar_text,@ment_criteria)} unless @dont_bother
      @ments_names_list.clear {create_ments_name_flows(@ments_names_text, @which_tab, @sort_opt)} unless @dont_bother
    end # if
    @editing_ments = false
    @to_zone = nil
    @grabbed_id = nil
    @from_type = nil
    @ment_hover = false
    @old_ment = nil
    @large_zone = nil
  end
end
end #Shoes.app
