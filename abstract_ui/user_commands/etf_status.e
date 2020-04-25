note
	description: ""
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ETF_STATUS
inherit 
	ETF_STATUS_INTERFACE
create
	make
feature -- command 
	status
    	do
			-- perform some update on the model state
			model.default_update
			etf_cmd_container.on_change.notify ([Current])
    	end

end
