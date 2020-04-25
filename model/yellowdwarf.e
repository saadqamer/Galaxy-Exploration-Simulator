note
	description: "Summary description for {YELLOWDWARF}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	YELLOWDWARF

inherit
	NONMOVABLE_ENTITY

create
	make

feature --Constructor
	make
		do
			luminosity := 2
			icon := 'Y'
			iD := 0
		end

feature --Commands
	desc_out: STRING
		do
			Result := ""
			Result.append("Luminosity:"+luminosity.out)
		end



end


