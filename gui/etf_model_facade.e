note
	description: "A facade class for easy manipulation of the business objects."
	author: "Jackie Wang"
	date: "$Date$"
	revision: "$Revision$"

class
	ETF_MODEL_FACADE

create
	make

feature -- Queries
	model: ETF_MODEL

	error: BOOLEAN

	status_message: STRING

	output_message: STRING

	history: LIST[STRING]
		-- Return the trace of events executed so far.

feature {NONE} -- Implementation
	sys: ETF_SOFTWARE_OPERATION
	input: ETF_INPUT_HANDLER
	output: ETF_GUI_OUTPUT_HANDLER
	ui: ETF_ABSTRACT_UI

feature -- Constructor
	make
			-- Initialize.
		local
			model_access: ETF_MODEL_ACCESS
		do
			model := model_access.m
			create sys.make
			create ui.make
	      	create input.make_without_running("dummy", ui)
	      	create output.make
	      	output.model.reset
			input.on_error.attach (agent output.log_error)

			create {LINKED_LIST[STRING]} history.make
			error := FALSE
			create status_message.make_from_string (man_page)
			create output_message.make_empty
		end

	execute_cmd (cmd: STRING)
			-- Execute 'cmd'.
			-- Set 'error_message' or 'output_message', but not both.
		do
			if cmd ~ "man" then
				error := FALSE
				create status_message.make_from_string (man_page)
				create output_message.make_empty
			else
				create input.make_without_running(cmd, ui)
				input.on_error.attach (agent output.log_error)
				input.parse_and_validate_input_string
				if input.etf_error then
					error := TRUE
					create status_message.make_from_string (output.error_message)
					status_message.prepend ("Command entered: " + cmd + "%N")
					-- 'output_message' is retained
				else
					history.extend (cmd)
					sys.execute_without_log (cmd)
					error := FALSE
					create status_message.make_empty
					create output_message.make_from_string (output.model_state)
				end
			end
		end

	reset
		do
			make
		end

	man_page : STRING = "[
  test(
      a_threshold: THRESHOLD = 1 .. 101 ; 
      j_threshold: THRESHOLD = 1 .. 101 ; 
      m_threshold: THRESHOLD = 1 .. 101 ; 
      b_threshold: THRESHOLD = 1 .. 101 ; 
      p_threshold: THRESHOLD = 1 .. 101
  )
  play
  abort
  move(
      dir: DIRECTION = {N, NE, E, SE, S, SW, W, NW}
  )
  land
  liftoff
  pass
  wormhole
  status
]"

invariant
	err_msg_set:
		error implies not status_message.is_empty
end