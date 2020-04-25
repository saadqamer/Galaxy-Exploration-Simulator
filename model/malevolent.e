note
	description: "Summary description for {MALEVOLENT}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	MALEVOLENT
inherit
	MOVABLE_ENTITY

create
	make

feature --Constructor
	make
	do
		icon := 'M'
		max_fuel:= 3
		fuel:= 3
		reproduction_interval := 1
		actions_left_until_reproduction:=1
		destroyed := false
		create death_message.make_empty
	end

feature-- Commands
	desc_out:STRING
	do
		Result := ""
		Result.append("fuel:"+fuel.out+"/"+max_fuel.out+", actions_left_until_reproduction:"+actions_left_until_reproduction.out+"/"+reproduction_interval.out+", turns_left:"+turns_left.out)
	end







end
