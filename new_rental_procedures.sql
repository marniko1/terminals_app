
--------------------------------------------------------------------------------------------------------------------

create or replace function INSERT_NEW_TERMINAL (_terminal_num integer, _pda character varying(13), _printer character varying(13), _iccid character varying(21))
returns void as
$$
	DECLARE
	terminals_num_id integer;
	pda_id integer;
	printer_id integer;
	sim_cards_id integer;

	BEGIN

	select id from terminals_num where terminal_num = _terminal_num into terminals_num_id;
	select id from devices where sn = _pda into pda_id;
	select id from devices where sn = _printer into printer_id;
	select id from sim_cards where iccid = _iccid into sim_cards_id;

	insert into terminals values (default, terminals_num_id, pda_id, printer_id, sim_cards_id);

	END;
$$
LANGUAGE plpgsql;

----------------------------------------------------------------------------------------------------------------------

create or replace function MAKE_NEW_CHARGE (_agent character varying(45), _off_num integer, _terminal_num integer, _sim integer, _imei character varying(30), _user integer)
returns void as
$$
	DECLARE
	agent_id integer;
	off_num_exist integer;
	terminal_num_id integer;
	terminal_id integer;
	pda_id integer;
	printer_id integer;
	sim_card_id integer;
	phone_id integer;
	num integer;
	first_name character varying(45);
	last_name character varying(45);
	new_agent_id integer;
	is_inactive integer;


	BEGIN

	select id from agents where concat(initcap(agents.first_name), ' ', initcap(agents.last_name)) = _agent into agent_id;
	select id from agents where agents.off_num = _off_num into off_num_exist;
	select id from terminals_num where terminal_num = _terminal_num into terminal_num_id;
	select id from terminals where terminals_num_id = terminal_num_id into terminal_id;
	select terminals.pda_id from terminals where terminals.id = terminal_id into pda_id;
	select terminals.printer_id from terminals where terminals.id = terminal_id into printer_id;
	select id from sim_cards where cast(sim_cards.num as text) = concat(882,_sim) into sim_card_id;
	select id from cellphones where imei = _imei into phone_id;
	-- if agent already exists in base
	if off_num_exist != 0 then
		select active from agents where agents.id = agent_id into is_inactive;
		if terminal_id != 0 then
			insert into terminals_charges values (default, terminal_id, agent_id, _user, default);
			update devices_locations set location_id = 3 where device_id = pda_id or device_id = printer_id;
		end if;
		if sim_card_id != 0 then
			insert into sim_cards_charges values (default, sim_card_id, agent_id, _user, default);
		end if;
		if _imei != '' then
		-- if phone doesnt exists in db, add phone to db??
			insert into cellphones_charges values (default, phone_id, agent_id, _user, default);
		end if;
		if is_inactive = 0 then
			update agents set active = 1 where id = agent_id;
		end if;
	end if;
	-- if agent is not in base
	if off_num_exist is null then
		select position(' ' in _agent) into num;
		select lower(substring(_agent from 0 for num)) into first_name;
		select lower(substring(_agent from (num + 1))) into last_name;

		insert into agents values (default, first_name, last_name, _off_num, default);

		select max(id) from agents into new_agent_id;

		if terminal_id != 0 then
			insert into terminals_charges values (default, terminal_id, new_agent_id, _user, default);
			update devices_locations set location_id = 3 where device_id = pda_id or device_id = printer_id;
		end if;
		if sim_card_id != 0 then
			insert into sim_cards_charges values (default, sim_card_id, new_agent_id, _user, default);
		end if;
		if _imei != '' then
		-- if phone doesnt exists in db, add phone to db??
			insert into cellphones_charges values (default, phone_id, new_agent_id, _user, default);
		end if;

	end if;

	END;
$$
LANGUAGE plpgsql;



----------------------------------------------------------------------------------------------------------------------

create or replace function DISCHARGE (_agent_id integer, _terminal integer, _sim integer, _phone integer, _inactiv integer, _user integer)
returns void as
$$
	DECLARE
	id_terminal_charge integer;
	id_terminal integer;
	id_pda integer;
	id_printer integer;
	id_sim_card_charge integer;
	id_phone_charge integer;

	BEGIN
	

	if _terminal != 0 then
		select max(id) from terminals_charges where agent_id = _agent_id into id_terminal_charge;
		select terminal_id from terminals_charges where terminals_charges.id = id_terminal_charge into id_terminal;
		select pda_id from terminals where terminals.id = id_terminal into id_pda;
		select printer_id from terminals where terminals.id = id_terminal into id_printer;

		insert into terminals_charges_off values (default, id_terminal_charge, _user, default);
		update devices_locations set location_id = 1 where device_id = id_pda;
		update devices_locations set location_id = 1 where device_id = id_printer;
	end if;
	if _sim != 0 then
		select max(id) from sim_cards_charges where agent_id = _agent_id into id_sim_card_charge;

		insert into sim_cards_charges_off values (default, id_sim_card_charge, _user, default);
	end if;
	if _phone != 0 then
		select max(id) from cellphones_charges where agent_id = _agent_id into id_phone_charge;

		insert into cellphones_charges_off values (default, id_phone_charge, _user, default);
	end if;
	if _inactiv != 0 then
		update agents set active = 0 where agents.id = _agent_id;
	end if;


	END;
$$
LANGUAGE plpgsql;

----------------------------------------------------------------------------------------------------------------------

select insert_new_terminal(44003, '117000009399', 'PMA005921UN16', '89381030000 23241515');

select MAKE_NEW_CHARGE('Aleksandar Avramović', 98510, 44001, 0, '', 1);

select MAKE_NEW_CHARGE('Aadam Nikolić', 98999, 44001, 0, '', 1);
select MAKE_NEW_CHARGE('Aadam Ninković', 98998, 44002, 8822114, '', 1);
select MAKE_NEW_CHARGE('Aadam Novković', 98997, 44003, 8822115, '356788068885730', 1);

update devices_locations set location_id = 1 where location_id = 3;