note
	description: "Summary description for {ENTITY}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	ENTITY

feature --Attributes

	iD: INTEGER
	icon: CHARACTER

feature--Query

 is_stationary: BOOLEAN
          -- Return if current item is stationary.
    	do
           if icon = 'W' or icon = 'Y' or icon = '*' or icon = 'O' then
           		Result := True
           end
        end

 set_id(identifier: INTEGER)
 	do
 		if icon = 'E' then
 			iD := 0
 		else
 			iD := identifier
 		end

 	end

 desc_out: STRING
 	deferred

 	end

end
