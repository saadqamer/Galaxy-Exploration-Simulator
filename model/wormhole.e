note
	description: "Summary description for {WORMHOLE}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	WORMHOLE

inherit
	NONMOVABLE_ENTITY

create
	make

feature --Constructor
	make
		do
			icon := 'W'
			iD := 0
		end

feature --Commands
	desc_out: STRING
		do
			Result := ""
		end


end
