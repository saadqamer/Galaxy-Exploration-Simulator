note
	description: "Summary description for {DUMMY_ENTITY}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	DUMMY_ENTITY

inherit
	ENTITY

create
	make

feature --Constructor
	make
	do
		icon := '-'
		id := -1000
	end

feature
	desc_out: STRING
	do
		Result := ""
	end



end




--					entity_row := sector.item.row
--					entity_col := sector.item.column --now we have the row and column of the entity to be moved
--					Result.append ("loop"+loop_counter.out)
--					Result.append ("%N"+entity_row.out)
--					Result.append (entity_col.out)
--					temp_entity := entity --store the entity
--					grid[entity_row, entity_col].contents[loop_counter] := dummy --replacement
--					Result.append (grid[entity_row, entity_col].contents[loop_counter].icon.out)
--					--find the sector trying to go to
--					--and change the entity_row and column to that new sector
--								if dir ~ 1 then --going north
--									if entity_row = 1 then
--										entity_row := 5
--									else
--										entity_row := entity_row - 1
--									end
--								elseif dir ~ 2 then --going NE
--									if entity_row = 1 then
--										entity_row := 5
--									else
--										entity_row := entity_row - 1
--									end

--									if entity_col = 5 then
--										entity_col := 1
--									else
--										entity_col := entity_col + 1
--									end

--								elseif dir ~ 3 then --going E
--									if entity_col = 5 then
--										entity_col := 1
--									else
--										entity_col := entity_col + 1
--									end

--								elseif dir ~ 4 then --going SE
--									if entity_col = 5 then
--										entity_col := 1
--									else
--										entity_col := entity_col + 1
--									end

--									if entity_row = 5 then
--										entity_row := 1
--									else
--										entity_row := entity_row + 1
--									end

--								elseif dir ~ 5 then --going S
--									if entity_row = 5 then
--										entity_row := 1
--									else
--										entity_row := entity_row + 1
--									end

--								elseif dir ~ 6 then --going SW
--									if entity_col = 1 then
--										entity_col := 5
--									else
--										entity_col := entity_col - 1
--									end

--									if entity_row = 5 then
--										entity_row := 1
--									else
--										entity_row := entity_row + 1
--									end

--								elseif dir ~ 7 then --going W
--									if entity_col = 1 then
--										entity_col := 5
--									else
--										entity_col := entity_col - 1
--									end

--								elseif dir ~ 8 then --going NW
--									if entity_col = 1 then
--										entity_col := 5
--									else
--										entity_col := entity_col - 1
--									end

--									if entity_row = 1 then
--										entity_row := 5
--									else
--										entity_row := entity_row - 1
--									end

--								end
--								-- end of directions
--								Result.append ("direction"+dir.out+" ")
--								Result.append ("newrow"+entity_row.out+" ")
--								Result.append ("newcol"+entity_col.out+" ")

--								if not grid[entity_row, entity_col].is_full then
--									Result.append ("looks like the destination sector isn't full lets go put "+temp_entity.icon.out)
--									Result.append(put_entity_in_next_avail_quadrant(grid[entity_row, entity_col], temp_entity))
--									Result.append (out)
--								end



--	across
--			grid as sector
--		loop
--			from
--				loop_counter := 1
--			until
--				loop_counter > 4
--			loop
--			
--				if sector.item.contents[loop_counter].id = entity.id then --found the entity to move
--					Result.append (entity.id.out)
--				end --end of giant if
--				loop_counter := loop_counter + 1

--			end-- end of from

--		end--end of across
