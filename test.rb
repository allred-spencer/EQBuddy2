Shoes.app do
  range = 0..1000
  range.each do |num|
  @this_flow = flow do
      background white
      para num.to_s
      hover {|slot| slot.clear {background gray; para num.to_s}}
      leave {|slot| slot.clear {background white; para num.to_s}}
    end
  end
end
