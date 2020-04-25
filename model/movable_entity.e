note
	description: "Summary description for {MOVABLE_ENTITY}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	MOVABLE_ENTITY

inherit
	ENTITY

feature--Attributes

	is_fueled: BOOLEAN --flag to check if movable entity requires fuel or not
	death_message: STRING
	max_fuel: INTEGER
	fuel: INTEGER
	reproduction_interval: INTEGER
	turns_left: INTEGER
	actions_left_until_reproduction: INTEGER
	destroyed: BOOLEAN

set_turns_left(t: INTEGER)
 	do
 		turns_left := t
 	end

 decrement_turns_left
 	do
 		turns_left := turns_left - 1
 	end

 	set_dstroyed_to_true
	do
		destroyed := true
	end

set_actions_left_until_reproduction(a_l_u_r: INTEGER)
	do
		actions_left_until_reproduction := a_l_u_r
	end

decrement_actions_left_until_rep
	do
		actions_left_until_reproduction:= actions_left_until_reproduction - 1
	end

decrement_fuel
	do
		fuel := fuel -1
	end

set_fuel(fuel_input: INTEGER)
	do
		fuel := fuel_input
	end


end
