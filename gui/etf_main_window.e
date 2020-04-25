note
	description: "Main window of ETF project."
	generator: "EiffelBuild"
	date: "$Date: 2010-12-22 10:39:24 -0800 (Wed, 22 Dec 2010) $"
	revision: "$Revision: 85202 $"

class
	ETF_MAIN_WINDOW

inherit
	ETF_MAIN_WINDOW_IMP
		rename
			raise as main_window_raise
		end

	EXCEPTIONS  -- need this to catch exception in rescue clause
		rename
			raise as exceptions_raise
		undefine
			default_create, copy
		end

feature {NONE} -- Initialization

	user_create_interface_objects
			-- Create any auxilliary objects needed for MAIN_WINDOW.
			-- Initialization for these objects must be performed in `user_initialization'.
		do
				create business_obj.make
				create session_file.make_with_name (session_file_path)
				output.insert_text (business_obj.model.out)
				status.insert_text ("List of commands: %N")
				status.insert_text ("================= %N")
				status.insert_text (business_obj.man_page)
		end

	user_initialization
			-- Perform any initialization on objects created by `user_create_interface_objects'
			-- and from within current class itself.
		do
		end

feature {NONE} -- Business Object
	business_obj: ETF_MODEL_FACADE
	session_file: PLAIN_TEXT_FILE
	session_file_path: STRING = "./session.txt"

feature {NONE} -- Auxiliary Commands
	clear_display
		do
			output.set_text ("")
			status.set_text ("")
			command.set_text ("")
			history.set_text ("")
		end

	display_history (trace: LIST[STRING])
		local
			i: INTEGER
		do
			from
				i := 1
				trace.start
			until
				trace.after
			loop
				history.append_text (trace.item)
				if i < trace.count then
					history.append_text ("%N")
				end
				trace.forth
				i := i + 1
			end
		end

feature {NONE} -- Implementation

	command_return_key_pressed
			-- Hit the return key to execute the typed command.
		do
			execute_pressed
		end

	execute_pressed
		local
			cmd: STRING
		do
			cmd := command.text

			execute_command (cmd)
			if not business_obj.error then
				-- This means that the history was empty before the
				-- valid command 'cmd' was executed.
				if business_obj.history.count = 1 then
					session_file.wipe_out
				end
				session_file.open_append
				session_file.put_string (cmd + "%N")
				session_file.close
			end
		end

	reset_pressed
			-- Reset the history.
			-- Two consecutive clicks of 'reset' will also
			-- wipe out the session file.
		do
			business_obj.reset
			clear_display
		end

	load_pressed
			-- Load the session file if it exists.
		local
			fu: ETF_FILE_UTILITY
		do
			create fu.read_text_from (session_file_path)
			if fu.error then
				clear_display
				status.insert_text (fu.error_string)
			else
				if not business_obj.history.is_empty then
					reset_pressed
				end
				fu.remove_comment_lines
				-- Loading an initial session file: execute all commands.
				-- Either at the start of the GUI, or after a 'reset'.
				across
					fu.items as cmd
				loop
					execute_command (cmd.item)
				end
			end
		end

feature {NONE}
	execute_command (cmd: STRING)
			-- Execute 'cmd' and
			-- print off stack trace if there's any contract violation.
		local
			problem: STRING
			error: BOOLEAN
		do
			create problem.make_empty

			if not error then
				business_obj.execute_cmd (cmd)
				clear_display
				display_history (business_obj.history)

				status.insert_text (business_obj.status_message)
				output.insert_text (business_obj.output_message)

				-- in case there's a syntax or type error,
				-- keep the typed command on the text field
				-- so that it can be fixed.
				if business_obj.error then
					command.set_text (cmd)
				end
			else
				problem.append ("%NThere was a problem:%N")

				-- print short statement of problem
				if attached meaning (exception) as s then
					problem.append ("  " + s + "%N")
				end
				if attached tag_name as s then
					problem.append ("  Tag: " + s + "%N")
				end
				if attached exception_trace as s then
					problem.append ("%NHere is the stack trace%N")
					problem.append (s)
					problem.append ("%NEnd of stack trace...%N")
				end

				clear_display
				-- the command executed caused an exception,
				-- still include it in the history.
				display_history (business_obj.history)
				status.insert_text (problem)
				output.insert_text (business_obj.output_message)
			end
		rescue
			error := true
			retry
		end
end


