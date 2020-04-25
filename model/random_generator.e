note
    description: "[
        The {RANDOM_GENERATOR} class is used to generate
        random numbers, either using the same seed 
        (deterministically).
    ]"
    author: "Kevin Banh"
    date: "April 30, 2019"
    revision: "1"

class
    RANDOM_GENERATOR

create {RANDOM_GENERATOR_ACCESS}
    make_debug

feature{NONE} -- attributes

    n_seed: RANDOM
         -- used to generate random numbers


feature{NONE} -- constructor

    make_debug
    	-- returns random numbers for debug purposes
        -- random variables are deterministic
        do
            create n_seed.make
            n_seed.set_seed (900)
        end


feature -- queries

    num: INTEGER
    	-- Returns the current number in a sequence of random numbers
        do
            result := n_seed.item
        end

feature -- commands

    forth
		-- Move to next number in a sequence of random numbers
        do
            n_seed.forth
        end

end
