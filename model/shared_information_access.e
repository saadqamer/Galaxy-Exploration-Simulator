note
	description: "Singleton access for shared information."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

expanded class
	SHARED_INFORMATION_ACCESS

feature -- Query
    shared_info: SHARED_INFORMATION
        once
            create result.make
        end


invariant
	shared_info = shared_info

end
