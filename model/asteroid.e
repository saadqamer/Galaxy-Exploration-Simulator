note
	description: "Summary description for {ASTEROID}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ASTEROID
inherit
	MOVABLE_ENTITY

create
	make

feature --Constructor
	make
	do
		icon := 'A'

		create death_message.make_empty
	end

feature--Commands
	desc_out:STRING
	do
		Result := ""
		Result.append("turns_left:"+turns_left.out)
	end


end
