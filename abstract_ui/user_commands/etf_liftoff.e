note
	description: ""
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ETF_LIFTOFF
inherit 
	ETF_LIFTOFF_INTERFACE
create
	make
feature -- command 
	liftoff
    	do
			-- perform some update on the model state
			model.default_update
			etf_cmd_container.on_change.notify ([Current])
    	end

end
