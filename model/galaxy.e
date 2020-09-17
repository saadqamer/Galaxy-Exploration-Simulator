note
	description: "Galaxy represents a game board in simodyssey."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	GALAXY

inherit ANY
	redefine
		out
	end

create
	make, make_dummy

feature -- attributes

	grid: ARRAY2 [SECTOR]
			-- the board

	gen: RANDOM_GENERATOR_ACCESS

	shared_info_access : SHARED_INFORMATION_ACCESS

	shared_info: SHARED_INFORMATION
		attribute
			Result:= shared_info_access.shared_info
		end

	movement_has_occured: BOOLEAN

	movement_string: STRING

	deaths_this_turn_flag: BOOLEAN

	death_string: STRING

	dead_entities: ARRAY[ENTITY]

	explorer_landed_on_planet_supports_life: BOOLEAN


feature --constructor

	make(a_thresh: INTEGER_32 ; j_thresh: INTEGER_32 ; m_thresh: INTEGER_32 ; b_thresh: INTEGER_32 ; p_thresh: INTEGER_32)
		-- creates a dummy of galaxy grid
		local
			row : INTEGER
			column : INTEGER
			dummy: DUMMY_ENTITY
			empty_fill_counter: INTEGER

		do
			create dummy.make
			create dead_entities.make_empty
			movement_has_occured := false
			deaths_this_turn_flag := false
			explorer_landed_on_planet_supports_life := false
			create death_string.make_empty
			create movement_string.make_empty
			shared_info.test (a_thresh, j_thresh, m_thresh, b_thresh, p_thresh)
			create grid.make_filled (create {SECTOR}.make_dummy, shared_info.number_rows, shared_info.number_columns)
			from
				row := 1
			until
				row > shared_info.number_rows
			loop

				from
					column := 1
				until
					column > shared_info.number_columns
				loop
					grid[row,column] := create {SECTOR}.make(row,column,create{EXPLORER}.make)
					column:= column + 1;
				end
				row := row + 1
			end
			set_stationary_items

			across
				grid as sector
			loop
				if sector.item.contents.is_empty then --if empty sector fill with 4 dummies
					from
						empty_fill_counter := 1
					until
						empty_fill_counter > 4
					loop
						sector.item.contents.force (dummy) --fill all dummies
						empty_fill_counter := empty_fill_counter + 1
					end
				elseif sector.item.contents.count = 1 then --if only 1 entity then fill 3
					from
						empty_fill_counter := 1
					until
						empty_fill_counter > 3
					loop
						sector.item.contents.force (dummy) --fill all dummies
						empty_fill_counter := empty_fill_counter + 1
					end
				elseif sector.item.contents.count = 2 then --if only 2 entities then fill 2
					from
						empty_fill_counter := 1
					until
						empty_fill_counter > 2
					loop
						sector.item.contents.force (dummy) --fill all dummies
						empty_fill_counter := empty_fill_counter + 1
					end
				elseif sector.item.contents.count = 3 then	--iff only 3 then fill 1
					sector.item.contents.force (dummy) --fill all dummies
				end

			end
	end

	make_dummy
		do
			create grid.make_filled (create {SECTOR}.make_dummy, shared_info.number_rows, shared_info.number_columns)
			explorer_landed_on_planet_supports_life := false
			create dead_entities.make_empty
			deaths_this_turn_flag := false
			movement_has_occured := false
			create movement_string.make_empty
			create death_string.make_empty
		end

feature --commands

	set_deaths_this_turn_flag_false
	do
		deaths_this_turn_flag := false
	end

	set_movement_has_occured_false
	do
		movement_has_occured := false
	end

	clear
	do
		grid.wipe_out
		shared_info.reset_movable_entity_counter
		shared_info.reset_nonmovable_entity_counter
	end

	this_is_the_explorer: EXPLORER
	local
		exp: EXPLORER
	do
		create Result.make
		across
			grid as sector
		loop
			across
				sector.item.contents as quadrant
			loop
				if quadrant.item.icon = 'E' then
					if attached{EXPLORER} quadrant.item as exp_alias then
						exp := exp_alias
						Result := exp
					end
				end
			end
		end

	end



	turn(action: INTEGER): STRING --RENAME THIS TO TURN and make a pass condition
	local
		movable_entities: ARRAY[ENTITY]
		mov_entity: MOVABLE_ENTITY
		planet: PLANET
		explorer: EXPLORER
	do
		Result := ""
		create movable_entities.make_empty
		explorer := this_is_the_explorer
		--get only the movable entities into an array except explorer
	if action ~ 9 then --9 means pass
	 --do nothing
	elseif action ~ 10 then -- 10 means land
		Result.append (land)
	elseif action ~ 1 then --1 means move N
		Result.append(find_and_move_explorer(1))
	elseif action ~ 2 then --1 means move NE
		Result.append(find_and_move_explorer(2))
	elseif action ~ 3 then --1 means move NE
		Result.append(find_and_move_explorer(3))
	elseif action ~ 4 then --1 means move SE
		Result.append(find_and_move_explorer(4))
	elseif action ~ 5 then --1 means move S
		Result.append(find_and_move_explorer(5))
	elseif action ~ 6 then --1 means move SW
		Result.append(find_and_move_explorer(6))
	elseif action ~ 7 then --1 means move W
		Result.append(find_and_move_explorer(7))
	elseif action ~ 8 then --1 means move NW
		Result.append(find_and_move_explorer(8))
	end


	check_if_alive(explorer)
--	--this whole across business only happens if explorer hasnt won
	if (explorer_landed_on_planet_supports_life = false) then

		across
			sorted_entities as sorted_entity
		loop
			if sorted_entity.item.icon = 'P' or sorted_entity.item.icon = 'A' or sorted_entity.item.icon = 'M' or sorted_entity.item.icon = 'B' or sorted_entity.item.icon = 'J' then
				movable_entities.force (sorted_entity.item, movable_entities.count + 1)
			end
		end
		--at this point all the movable entities in the galaxy should be in movable_entities
		--now go through the movable entities in order

		across
			movable_entities as m_e
		loop
			if attached {MOVABLE_ENTITY} m_e.item as m_e_alias then --dynamic binding of entity to movable entity
				mov_entity := m_e_alias

				if mov_entity.turns_left = 0 then

					if mov_entity.icon = 'P' and existence_of_star_in_corresponding_sector(mov_entity) then --if entity is a planet and theres a star in the sector of this entity
						if attached {PLANET} mov_entity as planet_alias then --dynamic binding of movable entity to planet

							planet := planet_alias

							if not planet.attached_to_star then


								planet.set_attached_to_true

								if existence_of_yellowdwarf_in_corresponding_sector(planet) then --if theres a yellowdwarf
									if gen.rchoose (1, 2) = 2 then --randomly choose if planet supports life
										planet.set_support_life_to_true
									end
								end

							end

						end-- end of if attached {PLANET}

					else--end of if entity is planet and star does not exists in sector

						if existence_of_wormhole_in_corresponding_sector(mov_entity) and (mov_entity.icon = 'M' or mov_entity.icon = 'B')  then --if there is wormhole in this sector and entity is M or B
							Result.append (wormhole(mov_entity))
						else
							Result.append (movement(mov_entity))
						end

						--check(entity) which checks if entity is alive after moving
						check_if_alive(mov_entity)
--						if entity did not die then
						if not mov_entity.destroyed then
							Result.append(reproduce(mov_entity)) --only M,B,J can reproduce
							Result.append(behave(mov_entity)) --BEHAVE IS CAUSING THE AT003 ISSUE
						end
--						end

					end
				else --turns_left != 0
					mov_entity.decrement_turns_left

				end --end of if turns_left
			end --end of if attached {MOVABLE_ENTITY}

		end --end of going across movable entities

	end --end of if explorer landed

	end--end do

	land: STRING
	do
		Result := ""
		
	end


	check_if_alive(entity: MOVABLE_ENTITY)--check(entity)
	local
		quadrant: INTEGER
		nonmovable: NONMOVABLE_ENTITY

	do
		if (entity.icon = 'E' or entity.icon = 'M' or entity.icon = 'B' or entity.icon = 'J') then
			--i can put fuel decrementation in move because thats the only time it would happen anyway
			--second if is if there is a star in the sector the fuel of the movable entity gets adjusted
			across --find the sector associated with this entity
				grid as sector
			loop
				if sector.item.contents.has (entity) then --found
					from
						quadrant := sector.item.contents.lower
					until
						quadrant > sector.item.contents.upper
					loop
						if sector.item.contents[quadrant].icon = '*' or sector.item.contents[quadrant].icon = 'Y' then
							if attached{NONMOVABLE_ENTITY} sector.item.contents[quadrant] as nonmov_alias then
								nonmovable := nonmov_alias
								if (entity.fuel + nonmovable.luminosity) < entity.max_fuel  then
									entity.set_fuel (entity.fuel + nonmovable.luminosity)
								else
									entity.set_fuel (entity.max_fuel)
								end
							end
						end
						quadrant := quadrant + 1
					end
				end
			end -- gone through galaxy end across
			--at this point if the entity is EMBJ the fuel got adjusted in some way
		end--end if

		if (entity.icon = 'E' or entity.icon = 'M' or entity.icon = 'B' or entity.icon = 'J') and (entity.fuel = 0) then
			entity.set_dstroyed_to_true
		end--this says if the fuel is 0 then he entity is destroyed, basically dead

			across --find the sector associated with this entity to chck if there is a blackhole, if there is entity dies
				grid as sector
			loop
				if sector.item.row = 3 and sector.item.column = 3 and sector.item.contents.has (entity) then
					entity.set_dstroyed_to_true
				end
			end -- blackhole ate the entity

	end--end do


	reproduce(entity: MOVABLE_ENTITY): STRING
	local
		quadrant: INTEGER
		rep_row: INTEGER
		rep_col: INTEGER
		m: MALEVOLENT
		b: BENIGN
		j: JANITAUR
		quadrant_counter: INTEGER

	do
		Result := ""
		--find entity first
		across
			grid as sector
		loop
			from
				quadrant := 1
			until
				quadrant > sector.item.contents.upper
			loop
				if sector.item.contents[quadrant].id = entity.id then --found
					rep_row := sector.item.row
					rep_col:= sector.item.column -- store sector coordinates
				end
				quadrant := quadrant + 1
			end
		end
		---found entity at this poit
		if entity.icon = 'M' or entity.icon = 'B' or entity.icon = 'J' then
			if (not (grid[rep_row, rep_col].is_full)) and entity.actions_left_until_reproduction = 0 then
				if entity.icon = 'M' then
				--create a new malevolent
					create m.make
					m.set_id (shared_info.movable_entity_counter)
					m.set_turns_left (gen.rchoose (0, 2))
					m.set_actions_left_until_reproduction (1)
					entity.set_actions_left_until_reproduction (1)
					shared_info.increment_movable_entity_counter
					put_entity_in_next_avail_quadrant2(grid[rep_row,rep_col], m)
					movement_string.append ("%N      reproduced ["+m.id.out+","+m.icon.out+"] at ")

					--find the new entity
					across
						grid as sector
					loop
						from
							quadrant_counter := 1
						until
							quadrant_counter > 4
						loop
							if sector.item.contents[quadrant_counter].id = m.id then
								movement_string.append ("["+sector.item.row.out+","+sector.item.column.out+","+quadrant_counter.out+"]")
							end
							quadrant_counter := quadrant_counter + 1
						end
					end

				elseif entity.icon = 'B' then
					--create a new benign
					create b.make
					b.set_id (shared_info.movable_entity_counter)
					b.set_turns_left (gen.rchoose (0, 2))
					b.set_actions_left_until_reproduction (1)
					entity.set_actions_left_until_reproduction (1)
					shared_info.increment_movable_entity_counter
					put_entity_in_next_avail_quadrant2(grid[rep_row,rep_col], b)
					movement_string.append ("%N      reproduced ["+b.id.out+","+b.icon.out+"] at ")
					--find the new entity
									across
										grid as sector
									loop
										from
											quadrant_counter := 1
										until
											quadrant_counter > 4
										loop
											if sector.item.contents[quadrant_counter].id = b.id then
												movement_string.append ("["+sector.item.row.out+","+sector.item.column.out+","+quadrant_counter.out+"]")
											end
											quadrant_counter := quadrant_counter + 1
										end
									end
				elseif entity.icon = 'J'  then
					create j.make
					j.set_id (shared_info.movable_entity_counter)
					j.set_turns_left (gen.rchoose (0, 2))
					j.set_actions_left_until_reproduction (2)
					entity.set_actions_left_until_reproduction (2)
					shared_info.increment_movable_entity_counter
					put_entity_in_next_avail_quadrant2(grid[rep_row,rep_col], j)
					movement_string.append ("%N      reproduced ["+j.id.out+","+j.icon.out+"] at ")
					--find the new entity
									across
										grid as sector
									loop
										from
											quadrant_counter := 1
										until
											quadrant_counter > 4
										loop
											if sector.item.contents[quadrant_counter].id = j.id then
												movement_string.append ("["+sector.item.row.out+","+sector.item.column.out+","+quadrant_counter.out+"]")
											end
											quadrant_counter := quadrant_counter + 1
										end
									end
				end

				--at this point the entity should be added into the sector
			else
				if not (entity.actions_left_until_reproduction = 0) then
					entity.decrement_actions_left_until_rep
				elseif grid[rep_row, rep_col].is_full then
					--will try to reproduce the next time entity acts
				end
			end
		end
	end

	put_entity_in_next_avail_quadrant2(sector: SECTOR; entity: ENTITY) --this is only for reproduce to use
		local
			quadrant_counter: INTEGER
			added: BOOLEAN
		do
			added := false


			from
				quadrant_counter := 1
			until
				added or quadrant_counter > 4
			loop
				if grid[sector.row,sector.column].contents[quadrant_counter].icon = '-' then
					grid[sector.row,sector.column].contents[quadrant_counter] := entity
					added := true
				end
				quadrant_counter := quadrant_counter + 1
			end



		end



	out_movement:STRING
	do
		Result := ""
		if not movement_has_occured then
			Result.append("none")
		else
			Result.append (movement_string)
			movement_string.wipe_out
		end

	end

	out_deaths_this_turn: STRING
	do
		Result := ""
		if not deaths_this_turn_flag then
			Result.append("none")
		else
			Result.append (death_string)
		end

	end






	out_entity_exact_location(entity: ENTITY): STRING
	local
		q_c: INTEGER
		found: BOOLEAN
	do
		found := false
		Result := ""
		across
				grid as sector
		loop
			from
				q_c := sector.item.contents.lower
			until
				q_c > sector.item.contents.upper or found = true
			loop
				if entity.id = sector.item.contents[q_c].id then
					Result.append("["+sector.item.row.out+","+sector.item.column.out+","+q_c.out+"]")
					found := true
				end
				q_c := q_c + 1
			end

		end
	end

	sector_of_entity_print(entity: ENTITY): STRING
	do
		Result :=""
		across
			grid as sector
		loop
			across
				sector.item.contents as quadrant
			loop
				if entity.id = quadrant.item.id then
					Result.append(sector.item.row.out+":"+sector.item.column.out)
				end
			end
		end
	end

	get_rid_of_mentity_from_board(entity: ENTITY)
	local
		counter: INTEGER
		dummy: DUMMY_ENTITY
	do
		create dummy.make
			across
				grid as sector
			loop
				from
					counter := sector.item.contents.lower
				until
					counter > sector.item.contents.upper
				loop
					if sector.item.contents[counter].id = entity.id then
						dead_entities.force (sector.item.contents[counter], dead_entities.count + 1)
						sector.item.contents[counter] := dummy
					end
					counter := counter + 1
				end
			end
	end


	behave(entity: MOVABLE_ENTITY): STRING
	local
		not_landed_explorer: BOOLEAN
		benign_exists: BOOLEAN
		e: EXPLORER
		p: PLANET
		a: ASTEROID
		j: JANITAUR
		b: BENIGN
		m: MALEVOLENT
		mov_ent_row: INTEGER
		mov_ent_col: INTEGER
		movable_entities_in_sector: ARRAY[ENTITY]
		k: INTEGER
		k2: INTEGER
		temp: ENTITY
		mov_alias: MOVABLE_ENTITY
		exp_alias: EXPLORER
	do

		Result := ""
		create movable_entities_in_sector.make_empty
		benign_exists := false
		--find entity
		across
			grid as sector
		loop
			across
				sector.item.contents as quadrant
			loop
				if quadrant.item.id = entity.id then --found the entity
					mov_ent_row := sector.item.row
					mov_ent_col:= sector.item.column
				end
			end
		end


		--mov_ent_row and col have the sector coordinates of the entity to behave
		across
			grid[mov_ent_row, mov_ent_col].contents as ent
		loop
			if ent.item.icon = 'E' or ent.item.icon = 'M' or ent.item.icon = 'B' or ent.item.icon = 'J' or ent.item.icon = 'P' or ent.item.icon = 'A' then
				if not (ent.item.id = entity.id) then
					movable_entities_in_sector.force (ent.item, movable_entities_in_sector.count + 1)
				end
			end
		end -- at this point movable_entities_in_sector should have all the movable entities in the sectorof the item excluding itself

	if not movable_entities_in_sector.is_empty then
			--sort
		if movable_entities_in_sector.count > 1 then
			from
				k := movable_entities_in_sector.lower
			until
				k = movable_entities_in_sector.upper
			loop
				from
					k2 := movable_entities_in_sector.lower
				until
					k2 = movable_entities_in_sector.upper
				loop
					if movable_entities_in_sector[k2].id > movable_entities_in_sector[k2+1].id then
						temp := movable_entities_in_sector[k2]
						movable_entities_in_sector[k2] := movable_entities_in_sector[k2+1]
						movable_entities_in_sector[k2+1] := temp
					end
					k2 := k2 + 1
				end
				k := k + 1
			end
		end
	end
			--movable_entites_in_sector should be sorted at this point




		if entity.icon = 'A' then
			--go across movable entities in the current destination sector of the iteration to
			--destroy whoever needs to be destroyed

			across
				movable_entities_in_sector as m_e
			loop
				--if at iteration item is M,B,J,E then
					--item dies
					if m_e.item.icon = 'M' or m_e.item.icon = 'B' or m_e.item.icon = 'J' or m_e.item.icon = 'E' then
						if attached {MOVABLE_ENTITY} m_e.item as m_e_alias then
							mov_alias := m_e_alias
							if mov_alias.icon = 'M' or mov_alias.icon = 'B' or mov_alias.icon = 'J'then
								deaths_this_turn_flag := true
								mov_alias.set_dstroyed_to_true
								movement_string.append("%N      destroyed ["+mov_alias.id.out+","+mov_alias.icon.out+"] at "+out_entity_exact_location(mov_alias))
								death_string.append ("%N    ["+mov_alias.id.out+","+mov_alias.icon.out+"]->fuel:"+mov_alias.fuel.out+"/"+mov_alias.max_fuel.out+", actions_left_until_reproduction:"+mov_alias.actions_left_until_reproduction.out+"/1, turns_left:N/A,")
								if mov_alias.icon = 'B' then
									death_string.append ("%N      Benign got destroyed by asteroid (id: "+entity.id.out+") at Sector:"+sector_of_entity_print(mov_alias))
								end

								get_rid_of_mentity_from_board(mov_alias)


							end

							if mov_alias.icon = 'E'then
								if attached {EXPLORER} mov_alias as exp then
									exp_alias := exp
									exp_alias.kill
								end
							end
						end
					end
				--end
			--end across
			end



			if attached {ASTEROID} entity as a_alias then --dynamic binding of movable entity to planet
					a := a_alias

					a.set_turns_left (gen.rchoose (0, 2))
			end

		elseif entity.icon = 'J'then
			--go across movable entiter in the current destination secotr for the iteration
				--if item in across is an asteroid and entity.load < 2 then
				--item dies
				--load++
				--end if
			--end across
			if attached {JANITAUR} entity as j_alias then --dynamic binding of movable entity to planet
				j := j_alias
				across
					movable_entities_in_sector as m_e
				loop
					if m_e.item.icon = 'A' and (j.load < 2) then
						if attached {ASTEROID} m_e.item as asteroid_alias then
							a := asteroid_alias
							a.set_dstroyed_to_true
							--probably some destruction message
						end
						j.increment_load
					end
				end

			--if there is a wormhole in the curren destination sector for the iteration then
			--entity.load = 0
			--end if
				across
					grid[mov_ent_row, mov_ent_col].contents as quadrant
				loop
					if quadrant.item.icon = 'W' then
						j.set_load(0)
					end
				end
				j.set_turns_left (gen.rchoose (0, 2))
			end

		elseif entity.icon = 'B'then --benigns behaviour is to kill malevolents
			--go across movable entiter in the current destination secotr for the iteration
				--if item is a malevolent then
				--item dies
				--end
			--end across
				across
					movable_entities_in_sector as m_e
				loop
					if m_e.item.icon = 'M' then
						if attached {MALEVOLENT} m_e.item as mal_alias then
							m := mal_alias
							m.set_dstroyed_to_true
							--probably some kill message
						end
					end
				end

			if attached {BENIGN} entity as b_alias then --dynamic binding of movable entity to planet
					b := b_alias
					b.set_turns_left (gen.rchoose (0, 2))
			end
		elseif entity.icon = 'M' then --malevolent behaviour is to take explorers life if there is no benign to protect him and he hasnt landed
			--if there is a explorer at the current destination sector and there is no benign in the current destinaton sector for the iteration and
			-- explorer hasnt landed then
			-- decrement the explorers life by 1
			--end if
				across
					movable_entities_in_sector as m_e
				loop
					if m_e.item.icon = 'E' then
						if attached {EXPLORER} m_e.item as e_alias then --dynamic binding of movable entity to planet
							e := e_alias
							if not e.landed then
								not_landed_explorer := true
							else
							    not_landed_explorer := false
							end
						end
					end
				end

				across
					movable_entities_in_sector as m_e
				loop
					if m_e.item.icon = 'B' then
						benign_exists := true
					end
				end


				if (movable_entities_in_sector.has (this_is_the_explorer)) and (benign_exists = false) and (not_landed_explorer = true) then
				across
					movable_entities_in_sector as m_e
				loop
					if m_e.item.icon = 'E' then
						if attached {EXPLORER} m_e.item as e_alias then --dynamic binding of movable entity to planet
							e := e_alias
							e.decrement_life

							if e.life = 0 then
								e.set_dstroyed_to_true
							end
						end
					end
				end
				end


			if attached {MALEVOLENT} entity as m_alias then --dynamic binding of movable entity to planet
					m := m_alias
					m.set_turns_left (gen.rchoose (0, 2))
			end


		elseif entity.icon = 'P' then
			if existence_of_star_in_corresponding_sector(entity) then

				if attached {PLANET} entity as p_alias then --dynamic binding of movable entity to planet
					p := p_alias

					p.set_attached_to_true

					if existence_of_yellowdwarf_in_corresponding_sector(entity) then --if theres a yellowdwarf
						if gen.rchoose (1, 2) = 2 then --randomly choose if planet supports life
							p.set_support_life_to_true
						end
					end

				end-- end of if attached {PLANET}
			else
				entity.set_turns_left (gen.rchoose (0, 2))
			end
		  end --end of if with elseifs
	end --end do


	movement(entity: ENTITY): STRING
	local
		direction: INTEGER
		current_row: INTEGER
		current_col: INTEGER
		quadrant_counter: INTEGER
		current_quadrant: INTEGER

	do
		Result := ""
		direction := gen.rchoose (1, 8)
		quadrant_counter := 0

		across
			grid as sector
		loop
			from
				quadrant_counter := 1
			until
				quadrant_counter > 4
			loop
				if sector.item.contents[quadrant_counter].id = entity.id then
					current_row := sector.item.row
					current_col := sector.item.column
					current_quadrant := quadrant_counter
				end
				quadrant_counter := quadrant_counter + 1
			end
		end

		Result.append(move(direction, entity, grid[current_row, current_col], current_quadrant))
	end

	find_and_move_explorer(direction: INTEGER): STRING
	local
		quadrant_counter: INTEGER
		found: BOOLEAN
		grid_cursor: ARRAY_ITERATION_CURSOR[SECTOR]
		sector: SECTOR
	do
		Result := ""
		from
			grid_cursor := grid.new_cursor
			found := false
		until
			found or grid_cursor.after
		loop
			sector := grid_cursor.item
			quadrant_counter := 0
			across
				sector.contents as quadrant
			loop
				quadrant_counter := quadrant_counter + 1

				if attached {EXPLORER}quadrant.item as exp then
					Result.append(move(direction, exp, sector, quadrant_counter))
					found := true
				end
			end
			grid_cursor.forth
		end
	end

	--moves this entity in this direction with this orginl sector and this quadrant
	move(dir: INTEGER; entity: ENTITY; sector: SECTOR; quadrant: INTEGER): STRING
	local
		dummy: DUMMY_ENTITY
		entity_row: INTEGER
		entity_col: INTEGER
		temp_entity: ENTITY
		loop_counter: INTEGER
		grid_r:INTEGER
		grid_c:INTEGER
		contents_counter: INTEGER
	do
		--find entity
		Result := ""
		create dummy.make
		temp_entity := entity --store the entity

		--save current row and column
		entity_row := sector.row
		entity_col := sector.column



		--find the destination sector based on direction
								if dir ~ 1 then --going north
									if entity_row = 1 then
										entity_row := 5
									else
										entity_row := entity_row - 1
									end
								elseif dir ~ 2 then --going NE
									if entity_row = 1 then
										entity_row := 5
									else
										entity_row := entity_row - 1
									end

									if entity_col = 5 then
										entity_col := 1
									else
										entity_col := entity_col + 1
									end

								elseif dir ~ 3 then --going E
									if entity_col = 5 then
										entity_col := 1
									else
										entity_col := entity_col + 1
									end

								elseif dir ~ 4 then --going SE
									if entity_col = 5 then
										entity_col := 1
									else
										entity_col := entity_col + 1
									end

									if entity_row = 5 then
										entity_row := 1
									else
										entity_row := entity_row + 1
									end

								elseif dir ~ 5 then --going S
									if entity_row = 5 then
										entity_row := 1
									else
										entity_row := entity_row + 1
									end

								elseif dir ~ 6 then --going SW
									if entity_col = 1 then
										entity_col := 5
									else
										entity_col := entity_col - 1
									end

									if entity_row = 5 then
										entity_row := 1
									else
										entity_row := entity_row + 1
									end

								elseif dir ~ 7 then --going W
									if entity_col = 1 then
										entity_col := 5
									else
										entity_col := entity_col - 1
									end

								elseif dir ~ 8 then --going NW
									if entity_col = 1 then
										entity_col := 5
									else
										entity_col := entity_col - 1
									end

									if entity_row = 1 then
										entity_row := 5
									else
										entity_row := entity_row - 1
									end

								end
--								-- end of directions at tis point entity_row and col have the destination sector cordinates


--								--check if destination sector is not full
								if not grid[entity_row, entity_col].is_full then
									grid[sector.row, sector.column].contents[quadrant] := dummy --get rid of the entity
									movement_has_occured := true
									movement_string.append ("%N    ["+entity.id.out+","+entity.icon.out+"]:["+sector.row.out+","+sector.column.out+","+quadrant.out+"]->")
									Result.append(put_entity_in_next_avail_quadrant(grid[entity_row, entity_col], entity))
								else
									movement_string.append ("%N    ["+entity.id.out+","+entity.icon.out+"]:["+sector.row.out+","+sector.column.out+","+quadrant.out+"]")
								end

	end --end do

	put_entity_in_next_avail_quadrant(sector: SECTOR; entity: ENTITY): STRING
		local
			dummy: DUMMY_ENTITY
			quadrant_counter: INTEGER
			added: BOOLEAN
			movabl_entity_alias: MOVABLE_ENTITY --only movable entities would move anyway
		do
			create dummy.make
			Result := ""
			added := false


			from
				quadrant_counter := 1
			until
				added or quadrant_counter > 4
			loop
				if grid[sector.row,sector.column].contents[quadrant_counter].icon = '-' then
					grid[sector.row,sector.column].contents[quadrant_counter] := entity
					if entity.icon = 'E' or entity.icon = 'M' or entity.icon = 'J'or entity.icon = 'B' then
						if attached {MOVABLE_ENTITY} entity as some_alias then
							movabl_entity_alias := some_alias
							movabl_entity_alias.decrement_fuel
						end
					end
					movement_string.append ("["+sector.row.out+","+sector.column.out+","+quadrant_counter.out+"]")
					added := true
				end
				quadrant_counter := quadrant_counter + 1
			end



		end





	wormhole(entity: ENTITY): STRING
	local
		added: BOOLEAN
		temp_row: INTEGER
		temp_column: INTEGER
		new_entity: ENTITY
		wentity_id :INTEGER
		l_c: INTEGER --loop counter
		empty_space_found: BOOLEAN
		occupant: DUMMY_ENTITY
		sector_row: INTEGER
		sector_column: INTEGER

	do
		Result := ""
		create occupant.make
		new_entity := entity --store the entity
		wentity_id := entity.id --store the id of the entity to be wormholed
		across --find the entity
			grid as sector
		loop
			from
				l_c := 1
			until
				l_c > sector.item.contents.count
			loop

				if sector.item.contents[l_c].id = wentity_id then --found the entity to be wormholed



					if new_entity.icon = 'E' or new_entity.icon = 'M' or new_entity.icon = 'B' then --if wormholing E,M,B then proceed
							from
								added := false
							until
								added = true
							loop
								temp_row := gen.rchoose (1, 5)
								temp_column := gen.rchoose (1, 5) --pick a random point/sector in galaxy
								if not grid[temp_row, temp_column].is_full then --if the randomly chosen sector in the grid is not full
									sector.item.contents[l_c] := occupant --replace entity to be wormholed with dummy
									movement_string.append ("%N    ["+entity.id.out+","+entity.icon.out+"]:["+sector.item.row.out+","+sector.item.column.out+","+l_c.out+"]->")
									Result.append(put_wormholed_entity_in_next_avail_quadrant(grid[temp_row, temp_column], new_entity))

									added := true
								end

							end
					end


				end
				l_c := l_c + 1
			end

		end


	end


	put_wormholed_entity_in_next_avail_quadrant(sector: SECTOR; entity: ENTITY): STRING
		local
			dummy: DUMMY_ENTITY
			quadrant_counter: INTEGER
			added: BOOLEAN
			movabl_entity_alias: MOVABLE_ENTITY --only movable entities would move anyway
		do
			create dummy.make
			Result := ""
			added := false


			from
				quadrant_counter := 1
			until
				added or quadrant_counter > 4
			loop
				if grid[sector.row,sector.column].contents[quadrant_counter].icon = '-' then
					grid[sector.row,sector.column].contents[quadrant_counter] := entity
					if entity.icon = 'E' or entity.icon = 'M' or entity.icon = 'J'or entity.icon = 'B' then
						if attached {MOVABLE_ENTITY} entity as some_alias then
							movabl_entity_alias := some_alias
							movabl_entity_alias.decrement_fuel
						end
					end
					movement_string.append ("["+sector.row.out+","+sector.column.out+","+quadrant_counter.out+"]")
					added := true
				end
				quadrant_counter := quadrant_counter + 1
			end



		end




	set_stationary_items
			-- distribute stationary items amongst the sectors in the grid.
			-- There can be only one stationary item in a sector
		local
			loop_counter: INTEGER
			check_sector: SECTOR
			temp_row: INTEGER
			temp_column: INTEGER
		do
			from
				loop_counter := 1
			until
				loop_counter > shared_info.number_of_stationary_items
			loop

				temp_row :=  gen.rchoose (1, shared_info.number_rows)
				temp_column := gen.rchoose (1, shared_info.number_columns)
				check_sector := grid[temp_row,temp_column]
				if (not check_sector.has_stationary) and (not check_sector.is_full) then
					grid[temp_row,temp_column].put (create_stationary_item)
					loop_counter := loop_counter + 1
				end -- if
			end -- loop
		end -- feature set_stationary_items

	create_stationary_item: NONMOVABLE_ENTITY
			-- this feature randomly creates one of the possible types of stationary actors
		local
			chance: INTEGER
		do
			chance := gen.rchoose (1, 3)
			inspect chance
			when 1 then
				Result := create {YELLOWDWARF}.make
			when 2 then
				Result := create {BLUEGIANT}.make
			when 3 then
				Result := create {WORMHOLE}.make
			else
				Result := create {YELLOWDWARF}.make -- create more yellow dwarfs this will never happen, but create by default
			end -- inspect

			Result.set_id (shared_info.nonmovable_entity_counter)
			shared_info.decrement_nonmovable_entity_counter
		end

feature -- query

	existence_of_wormhole_in_corresponding_sector(entity: ENTITY):BOOLEAN
		--check if there is a wormhole in the sector associated with this entity
		do
			Result := false

			across --find the sector associated with this entity
				grid as sector
			loop
				if sector.item.contents.has (entity) then --found

					across --go across quadrants to find a wormhole
						sector.item.contents as quadrant
					loop
						if quadrant.item.icon = 'W' then --if looking at a star
							Result := true
						end
					end --done going through sector

				end
			end -- gone through galaxy
		end

	existence_of_yellowdwarf_in_corresponding_sector(entity: ENTITY):BOOLEAN
		--check if there is a yellowdwarf in the sector associated with this entity
		do
			Result := false

			across --find the sector associated with this entity
				grid as sector
			loop
				if sector.item.contents.has (entity) then --found

					across --go across quadrants to find a star
						sector.item.contents as quadrant
					loop
						if quadrant.item.icon = 'Y' then --if looking at a star
							Result := true
						end
					end --done going through sector

				end
			end -- gone through galaxy
		end

	existence_of_star_in_corresponding_sector(entity: ENTITY):BOOLEAN
		--check if there is a star in the sector associated with this entity
		do
			Result := false

			across --find the sector associated with this entity
				grid as sector
			loop
				if sector.item.contents.has (entity) then --found

					across --go across quadrants to find a star
						sector.item.contents as quadrant
					loop
						if quadrant.item.icon = '*' or quadrant.item.icon = 'Y' then --if looking at a star
							Result := true
						end
					end --done going through sector

				end
			end -- gone through galaxy
		end

	out_sectors: STRING
		local
			grid_row: INTEGER
			grid_col: INTEGER
			quadrant_counter: INTEGER --used to print remaining -,s
		do
			Result := ""

			from
				grid_row := 1
			until
				grid_row > shared_info.number_rows
			loop

				from
					grid_col := 1
				until
					grid_col > shared_info.number_columns
				loop

					Result.append ("%N    [")
					Result.append (grid_row.out)
					Result.append (",")
					Result.append (grid_col.out)
					Result.append ("]->")
					quadrant_counter := 0
						across
							grid[grid_row, grid_col].contents as quadrant
						loop
								if quadrant.item.id = -1000 then --if its a dummy
									Result.append("-")
								else
									Result.append("[")
									Result.append (quadrant.item.id.out + ",")
									Result.append(quadrant.item.icon.out)
									Result.append ("]")
								end

								if not (quadrant.is_last) then
									Result.append(",")
								end
								quadrant_counter := quadrant_counter + 1
						end --at this point the print looks like [1,1]->[E]

						if quadrant_counter = 1 then
							Result.append(",-,-,-")
						elseif quadrant_counter = 2 then
							Result.append(",-,-")
						elseif quadrant_counter = 3 then
							Result.append(",-")
						end

					grid_col:= grid_col + 1;
				end
				grid_row := grid_row + 1
			 end

		end

	sorted_entities: ARRAY[ENTITY]
		local
			lowest_id :INTEGER
			j: INTEGER
			temp: ENTITY
			k: INTEGER
		do

			create Result.make_empty
			Result.compare_objects
			lowest_id := 0
			j := 1
			k := 1

			across
				grid as sectors
			loop
				across
					sectors.item.contents as quadrant
				loop
					Result.force(quadrant.item, Result.count + 1)
				end
			end--unsorted array of entities

			--sort
			from
				k := Result.lower
			until
				k = Result.upper
			loop
				from
					j := Result.lower
				until
					j = Result.upper
				loop
					if Result[j].id > Result[j+1].id then
						temp := Result[j]
						Result[j] := Result[j+1]
						Result[j+1] := temp
					end
					j := j + 1
				end
				k := k + 1
			end

			--Result should be sorted at this point


		end




	out_description: STRING
	local
		sorted_array_of_entities: ARRAY[ENTITY]

		desc_counter: INTEGER
	do
		Result := ""
		sorted_array_of_entities := sorted_entities


		from
			desc_counter := sorted_array_of_entities.lower
		until
			desc_counter > sorted_array_of_entities.upper
		loop
			if not (sorted_array_of_entities[desc_counter].id = -1000) then
			Result.append ("%N    [")
			Result.append (sorted_array_of_entities[desc_counter].id.out)
			Result.append (",")
			Result.append (sorted_array_of_entities[desc_counter].icon.out)
			Result.append ("]->")
			Result.append (sorted_array_of_entities[desc_counter].desc_out)
			end
			desc_counter := desc_counter + 1
		end

	end


	out: STRING
	--Returns grid in string form
	local
		string1: STRING
		string2: STRING
		row_counter: INTEGER
		column_counter: INTEGER
		contents_counter: INTEGER
		temp_sector: SECTOR
		temp_component: ENTITY
		printed_symbols_counter: INTEGER
	do
		create Result.make_empty
		create string1.make(7*shared_info.number_rows)
		create string2.make(7*shared_info.number_columns)
		string1.append("%N")

		from
			row_counter := 1
		until
			row_counter > shared_info.number_rows
		loop
			string1.append("    ")
			string2.append("    ")

			from
				column_counter := 1
			until
				column_counter > shared_info.number_columns
			loop
				temp_sector:= grid[row_counter, column_counter]
			    string1.append("(")
            	string1.append(temp_sector.print_sector)
                string1.append(")")
			    string1.append("  ")
				from
					contents_counter := 1
					printed_symbols_counter:=0
				until
					contents_counter > temp_sector.contents.count
				loop
					temp_component := temp_sector.contents[contents_counter]
					if attached temp_component as character then
						string2.append_character(character.icon)
					else
						string2.append("-")
					end -- if
					printed_symbols_counter:=printed_symbols_counter+1
					contents_counter := contents_counter + 1
				end -- loop

--				from
--				until (shared_info.max_capacity - printed_symbols_counter)=0
--				loop
--						string2.append("-")
--						printed_symbols_counter:=printed_symbols_counter+1

--				end
				string2.append("   ")
				column_counter := column_counter + 1
			end -- loop
			string1.append("%N")
			if not (row_counter = shared_info.number_rows) then
				string2.append("%N")
			end
			Result.append (string1.twin)
			Result.append (string2.twin)

			row_counter := row_counter + 1
			string1.wipe_out
			string2.wipe_out
		end
	end


end
