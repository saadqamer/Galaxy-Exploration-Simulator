note
	description: "Summary description for {BLACKHOLE}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	BLACKHOLE

inherit
	NONMOVABLE_ENTITY

create
	make

feature --Constructor
	make
		do
			icon := 'O'
			iD := -1
		end

feature --Commands
	desc_out: STRING
		do
			Result := ""
		end


end
