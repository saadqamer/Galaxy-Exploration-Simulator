
expanded class
	ETF_MODEL_ACCESS

feature
	m: ETF_MODEL
		once
			create Result.make
		end

invariant
	m = m
end




