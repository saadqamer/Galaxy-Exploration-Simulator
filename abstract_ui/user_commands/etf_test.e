note
	description: ""
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ETF_TEST
inherit
	ETF_TEST_INTERFACE
create
	make
feature -- command
	test(a_threshold: INTEGER_32 ; j_threshold: INTEGER_32 ; m_threshold: INTEGER_32 ; b_threshold: INTEGER_32 ; p_threshold: INTEGER_32)
		require else
			test_precond(a_threshold, j_threshold, m_threshold, b_threshold, p_threshold)
    	do
			-- perform some update on the model state
			model.default_update
			model.test(a_threshold, j_threshold, m_threshold, b_threshold, p_threshold)
			etf_cmd_container.on_change.notify ([Current])
    	end

end
