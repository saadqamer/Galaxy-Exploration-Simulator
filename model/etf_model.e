note
	description: "A default business model."
	author: "Jackie Wang"
	date: "$Date$"
	revision: "$Revision$"

class
	ETF_MODEL

inherit
	ANY
		redefine
			out
		end

create {ETF_MODEL_ACCESS}
	make

feature {NONE} -- Initialization
	make
			-- Initialization for `Current'.
		do
			create s.make_empty
			create galaxy.make_dummy
			game_in_prog:= false
			tested := false
			no_error:= true
			initial_test:= false
			aborted := false
			passed := false
			valid_action := false
			state_counter_1 := 0
			state_counter_2 := 0
			create explorer.make

		end

feature -- model attributes
	s : STRING
	state_counter_1 : INTEGER
	state_counter_2 : INTEGER
	galaxy: GALAXY
	game_in_prog: BOOLEAN
	tested: BOOLEAN
	no_error: BOOLEAN
	initial_test: BOOLEAN --this is just to have something that says test was just executed so movement is none
	aborted: BOOLEAN
	passed: BOOLEAN
	action_taken: INTEGER_32
	explorer: EXPLORER
	valid_action: BOOLEAN




feature -- model operations
	default_update
			-- Perform update to the model state.
		do
			state_counter_1 := state_counter_1 + 1
		end

	default_update2
		do
			state_counter_2 := state_counter_2 + 1
		end

	reset
			-- Reset model state.
		do
			make
		end

	abort
		do
			galaxy.clear
			aborted := true
		end

	test(a_t: INTEGER_32 ; j_t: INTEGER_32 ; m_t: INTEGER_32 ; b_t: INTEGER_32 ; p_t: INTEGER_32)
		do
			galaxy.make(a_t, j_t, m_t, b_t, p_t)
			game_in_prog := true
			tested := true
			initial_test := true
			state_counter_2 := 0
		end

	land
	do
		action_taken := 10 --10 means land
		valid_action := true
	end

	move(direct: INTEGER_32)
		do
		--	galaxy.move(direct, explorer)
			valid_action := true
			action_taken := direct --1-8 signifying move N to NW
		end

	pass
		do
			action_taken := 9 --9 means pass
			valid_action := true
		end

feature -- queries
	out : STRING
		do
			create Result.make_from_string ("  ")


			if not game_in_prog  then
				Result.append ("state:")
				Result.append (state_counter_1.out)
				Result.append (".")
				Result.append (state_counter_2.out)
				Result.append(", ok")
				Result.append ("%N  Welcome! Try test(3,5,7,15,30)")
			end

			if game_in_prog then
				Result.append ("state:")
				Result.append (state_counter_1.out)
				Result.append (".")
				Result.append (state_counter_2.out)

				if tested and no_error then
					if aborted then
						Result.append (", ok")
						Result.append ("%N  Mission aborted. Try test(3,5,7,15,30)")
						aborted := false
					else
						if valid_action then
							Result.append (galaxy.turn(action_taken))
							valid_action := false
						end
						Result.append(", mode:")
						Result.append("test, ok")
						Result.append ("%N  Movement:")
						Result.append (galaxy.out_movement)
						galaxy.set_movement_has_occured_false
						--movements
							if initial_test then --if first test then print none for movement
								initial_test := false
							else
								--print movements
							end
						Result.append ("%N  Sectors:")
						--sectors
						Result.append (galaxy.out_sectors)
						Result.append ("%N  Descriptions:")
						--Description
						Result.append (galaxy.out_description)
						--Deaths This Turn
						Result.append ("%N  Deaths This Turn:")
						Result.append (galaxy.out_deaths_this_turn)
						galaxy.set_deaths_this_turn_flag_false

						Result.append(galaxy.out)
					end

				end

			end

		end

end




