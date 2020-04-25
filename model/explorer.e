note
	description: "Summary description for {EXPLORER}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	EXPLORER

inherit
	MOVABLE_ENTITY

create
	make

feature -- Attributes
	landed: BOOLEAN
	life: INTEGER

feature --Constructor
	make
		do
			fuel:= 3
			max_fuel:= 3
			landed := false
			create death_message.make_empty
			life := 3
			icon := 'E'
			iD := 0
		end

feature-- COmmand
	desc_out: STRING
	do
		Result := ""
		Result.append("fuel:"+fuel.out+"/"+max_fuel.out+", life:"+life.out+"/3, landed?:")
		if landed then
			Result.append("T")
		else
			Result.append ("F")
		end
	end

	kill
	do
		life := 0
	end

	decrement_life
	do
		life := life - 1
	end



end
