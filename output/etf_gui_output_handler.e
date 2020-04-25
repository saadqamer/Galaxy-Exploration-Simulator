note
	description: "An output handler for the GUI mode of ETF."
	author: "JSO and Jackie Wang"
	date: "$Date$"
	revision: "$Revision$"

class
	ETF_GUI_OUTPUT_HANDLER

inherit
	ETF_OUTPUT_HANDLER_INTERFACE
		redefine
			make, log_command
		end

create
	make

feature {NONE} -- Initialization

	make
		-- Initialization for `Current'.
	local
		m_access : ETF_MODEL_ACCESS
	do
		Precursor
		-- may also override the string 'initial_state'
		model := m_access.m
	end

feature -- Queries

	model : ETF_MODEL

	model_state : STRING
			-- Return a string representation of current model state
		local
--			s: STRING
		do
			create Result.make_empty
			Result.append (model.out)
			Result.append ("%N")
		end

feature -- Log to 'output'

	log_model_state
			-- Log current model state to 'output'
		do
			output := model_state
		end

	log_command (a_cmd: ETF_COMMAND)
			-- Log the effect of 'a_cmd' to 'output'
		local
			l_command_name: STRING
		do
			l_command_name := "->" + a_cmd.out + "%N"
			if a_cmd.etf_cmd_message.count = 0 then
				output := output + l_command_name
				-- also append model state to 'output'
				output.append (model_state)
			else
				output := output + l_command_name + "  Error: " + a_cmd.etf_cmd_message
			end
		end
end

