note
	description: "Summary description for {BLUEGIANT}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	BLUEGIANT

inherit
	NONMOVABLE_ENTITY


create
	make

feature --Constructor
	make
		do
			luminosity := 5
			icon := '*'
			iD := 0
		end

feature --Commands
	desc_out: STRING
		do
			Result := ""
			Result.append("Luminosity:"+luminosity.out)
		end



end
