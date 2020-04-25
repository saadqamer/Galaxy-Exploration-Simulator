note
	description: "Summary description for {PLANET}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	PLANET

inherit
	MOVABLE_ENTITY

create
	make

feature --Constructor
	make
	do
		icon := 'P'
		create death_message.make_empty
		attached_to_star:= false
		support_life:= false
		visited := false
	end

feature -- Attributes
	attached_to_star: BOOLEAN
	support_life: BOOLEAN
	visited: BOOLEAN

feature -- COmmands
	desc_out: STRING
		do
			Result := ""
			Result.append("attached?:")
			if attached_to_star then
				Result.append("T, ")
			else
				Result.append ("F, ")
			end
			Result.append("support_life?:")
			if support_life then
				Result.append("T, ")
			else
				Result.append ("F, ")
			end
			Result.append("visited?:")
			if visited then
				Result.append("T, ")
			else
				Result.append ("F, ")
			end

			if attached_to_star then
				Result.append("turns_left:N/A")
			else
				Result.append("turns_left:"+turns_left.out)
			end

		end

	set_attached_to_true
		do
			attached_to_star:= true
		end

	set_support_life_to_true
		do
			support_life:= true
		end


end
