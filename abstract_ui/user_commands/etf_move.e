note
	description: ""
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ETF_MOVE
inherit
	ETF_MOVE_INTERFACE
create
	make
feature -- command
	move(dir: INTEGER_32)
		require else
			move_precond(dir)
    	do
			-- perform some update on the model state
			model.default_update
			if dir ~ N then
				model.move(1)
			elseif dir ~ NE then
				model.move(2)
			elseif dir ~ E then
				model.move(3)
			elseif dir ~ SE then
				model.move(4)
			elseif dir ~ S then
				model.move(5)
			elseif dir ~ SW then
				model.move(6)
			elseif dir ~ W then
				model.move(7)
			elseif dir ~ NW then
				model.move(8)
			end
			etf_cmd_container.on_change.notify ([Current])
    	end

end
