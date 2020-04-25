note
	description: "Summary description for {JANITAUR}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	JANITAUR

inherit
	MOVABLE_ENTITY

create
	make

feature --Constructor
	make
	do
		icon := 'J'
		max_fuel:= 5
		fuel := 5
		load := 0
		reproduction_interval := 2
		actions_left_until_reproduction:=2
		destroyed := false
		create death_message.make_empty
	end

feature--Attributes
	load: INTEGER
	max_load: INTEGER =2

feature-- Commands
	desc_out:STRING
	do
		Result := ""
		Result.append("fuel:"+fuel.out+"/"+max_fuel.out+", load:"+load.out+"/"+max_load.out+"actions_left_until_reproduction:"+actions_left_until_reproduction.out+"/"+reproduction_interval.out+", turns_left:"+turns_left.out)
	end

	increment_load
	do
		load := load + 1
	end

	set_load(load_input: INTEGER)
	do
		load := load_input
	end




end
