--
-- PostgreSQL database dump
--

-- Dumped from database version 10.1
-- Dumped by pg_dump version 10.4

-- Started on 2018-11-08 13:05:33

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 1 (class 3079 OID 12924)
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- TOC entry 3041 (class 0 OID 0)
-- Dependencies: 1
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- TOC entry 249 (class 1255 OID 33409)
-- Name: discharge(integer, integer, integer, integer, integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.discharge(_agent_id integer, _terminal integer, _sim integer, _phone integer, _inactiv integer, _user integer) RETURNS void
    LANGUAGE plpgsql
    AS $$	DECLARE
	id_terminal_charge integer;
	id_terminal integer;
	id_pda integer;
	id_printer integer;
	id_sim_card_charge integer;
	id_phone_charge integer;

	BEGIN

	
	
	select max(id) from cellphones_charges where agent_id = _agent_id into id_phone_charge;

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
$$;


ALTER FUNCTION public.discharge(_agent_id integer, _terminal integer, _sim integer, _phone integer, _inactiv integer, _user integer) OWNER TO postgres;

--
-- TOC entry 253 (class 1255 OID 33283)
-- Name: insert_new_terminal(integer, character varying, character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.insert_new_terminal(_terminal_num integer, _pda character varying, _printer character varying, _iccid character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER FUNCTION public.insert_new_terminal(_terminal_num integer, _pda character varying, _printer character varying, _iccid character varying) OWNER TO postgres;

--
-- TOC entry 245 (class 1255 OID 34003)
-- Name: insert_new_terminal(integer, character varying, character varying, character varying, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.insert_new_terminal(_terminal_num integer, _pda character varying, _printer character varying, _iccid character varying, _user_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
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

	insert into terminals values (default, terminals_num_id, pda_id, printer_id, sim_cards_id, default, _user_id);

	END;
$$;


ALTER FUNCTION public.insert_new_terminal(_terminal_num integer, _pda character varying, _printer character varying, _iccid character varying, _user_id integer) OWNER TO postgres;

--
-- TOC entry 251 (class 1255 OID 33358)
-- Name: make_new_charge(character varying, integer, integer, integer, character varying, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.make_new_charge(_agent character varying, _off_num integer, _terminal_num integer, _sim integer, _imei character varying, _user integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
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
	select max(id) from terminals where terminals_num_id = terminal_num_id into terminal_id;
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
$$;


ALTER FUNCTION public.make_new_charge(_agent character varying, _off_num integer, _terminal_num integer, _sim integer, _imei character varying, _user integer) OWNER TO postgres;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 213 (class 1259 OID 33207)
-- Name: agents; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.agents (
    id integer NOT NULL,
    first_name character varying(45) NOT NULL,
    last_name character varying(45) NOT NULL,
    off_num integer,
    active smallint DEFAULT 1
);


ALTER TABLE public.agents OWNER TO postgres;

--
-- TOC entry 212 (class 1259 OID 33205)
-- Name: agents_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.agents_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.agents_id_seq OWNER TO postgres;

--
-- TOC entry 3042 (class 0 OID 0)
-- Dependencies: 212
-- Name: agents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.agents_id_seq OWNED BY public.agents.id;


--
-- TOC entry 219 (class 1259 OID 33286)
-- Name: cellphones; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cellphones (
    id integer NOT NULL,
    model_id integer NOT NULL,
    imei character varying(30) NOT NULL
);


ALTER TABLE public.cellphones OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 33307)
-- Name: cellphones_charges; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cellphones_charges (
    id integer NOT NULL,
    cellphone_id integer NOT NULL,
    agent_id integer NOT NULL,
    user_id integer NOT NULL,
    date timestamp without time zone DEFAULT now()
);


ALTER TABLE public.cellphones_charges OWNER TO postgres;

--
-- TOC entry 222 (class 1259 OID 33305)
-- Name: cellphones_charges_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.cellphones_charges_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.cellphones_charges_id_seq OWNER TO postgres;

--
-- TOC entry 3043 (class 0 OID 0)
-- Dependencies: 222
-- Name: cellphones_charges_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.cellphones_charges_id_seq OWNED BY public.cellphones_charges.id;


--
-- TOC entry 225 (class 1259 OID 33315)
-- Name: cellphones_charges_off; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cellphones_charges_off (
    id integer NOT NULL,
    cellphone_charge_id integer NOT NULL,
    user_id integer NOT NULL,
    date timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.cellphones_charges_off OWNER TO postgres;

--
-- TOC entry 224 (class 1259 OID 33313)
-- Name: cellphones_charges_off_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.cellphones_charges_off_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.cellphones_charges_off_id_seq OWNER TO postgres;

--
-- TOC entry 3044 (class 0 OID 0)
-- Dependencies: 224
-- Name: cellphones_charges_off_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.cellphones_charges_off_id_seq OWNED BY public.cellphones_charges_off.id;


--
-- TOC entry 218 (class 1259 OID 33284)
-- Name: cellphones_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.cellphones_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.cellphones_id_seq OWNER TO postgres;

--
-- TOC entry 3045 (class 0 OID 0)
-- Dependencies: 218
-- Name: cellphones_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.cellphones_id_seq OWNED BY public.cellphones.id;


--
-- TOC entry 221 (class 1259 OID 33294)
-- Name: models; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.models (
    id integer NOT NULL,
    title character varying(45) NOT NULL,
    purpose character varying(45) NOT NULL
);


ALTER TABLE public.models OWNER TO postgres;

--
-- TOC entry 220 (class 1259 OID 33292)
-- Name: cellphones_models_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.cellphones_models_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.cellphones_models_id_seq OWNER TO postgres;

--
-- TOC entry 3046 (class 0 OID 0)
-- Dependencies: 220
-- Name: cellphones_models_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.cellphones_models_id_seq OWNED BY public.models.id;


--
-- TOC entry 197 (class 1259 OID 24870)
-- Name: devices; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.devices (
    id integer NOT NULL,
    sn character varying(13) NOT NULL,
    nav_num character varying(20) NOT NULL,
    model_id integer,
    device_type_id integer
);


ALTER TABLE public.devices OWNER TO postgres;

--
-- TOC entry 196 (class 1259 OID 24868)
-- Name: devices_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.devices_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.devices_id_seq OWNER TO postgres;

--
-- TOC entry 3047 (class 0 OID 0)
-- Dependencies: 196
-- Name: devices_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.devices_id_seq OWNED BY public.devices.id;


--
-- TOC entry 211 (class 1259 OID 33189)
-- Name: devices_locations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.devices_locations (
    id integer NOT NULL,
    device_id integer NOT NULL,
    location_id integer NOT NULL
);


ALTER TABLE public.devices_locations OWNER TO postgres;

--
-- TOC entry 210 (class 1259 OID 33187)
-- Name: devices_locations_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.devices_locations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.devices_locations_id_seq OWNER TO postgres;

--
-- TOC entry 3048 (class 0 OID 0)
-- Dependencies: 210
-- Name: devices_locations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.devices_locations_id_seq OWNED BY public.devices_locations.id;


--
-- TOC entry 237 (class 1259 OID 34066)
-- Name: devices_softwares; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.devices_softwares (
    id integer NOT NULL,
    device_id integer NOT NULL,
    software_v_id integer NOT NULL,
    date timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.devices_softwares OWNER TO postgres;

--
-- TOC entry 236 (class 1259 OID 34064)
-- Name: devices_softwares_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.devices_softwares_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.devices_softwares_id_seq OWNER TO postgres;

--
-- TOC entry 3049 (class 0 OID 0)
-- Dependencies: 236
-- Name: devices_softwares_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.devices_softwares_id_seq OWNED BY public.devices_softwares.id;


--
-- TOC entry 233 (class 1259 OID 34006)
-- Name: devices_types; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.devices_types (
    id bigint NOT NULL,
    title character varying(45) NOT NULL
);


ALTER TABLE public.devices_types OWNER TO postgres;

--
-- TOC entry 232 (class 1259 OID 34004)
-- Name: devices_types_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.devices_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.devices_types_id_seq OWNER TO postgres;

--
-- TOC entry 3050 (class 0 OID 0)
-- Dependencies: 232
-- Name: devices_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.devices_types_id_seq OWNED BY public.devices_types.id;


--
-- TOC entry 239 (class 1259 OID 34085)
-- Name: devices_writes_off; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.devices_writes_off (
    id integer NOT NULL,
    device_id integer NOT NULL,
    date timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.devices_writes_off OWNER TO postgres;

--
-- TOC entry 238 (class 1259 OID 34083)
-- Name: devices_writes_off_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.devices_writes_off_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.devices_writes_off_id_seq OWNER TO postgres;

--
-- TOC entry 3051 (class 0 OID 0)
-- Dependencies: 238
-- Name: devices_writes_off_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.devices_writes_off_id_seq OWNED BY public.devices_writes_off.id;


--
-- TOC entry 209 (class 1259 OID 33181)
-- Name: locations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.locations (
    id integer NOT NULL,
    title character varying(45) NOT NULL
);


ALTER TABLE public.locations OWNER TO postgres;

--
-- TOC entry 208 (class 1259 OID 33179)
-- Name: locations_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.locations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.locations_id_seq OWNER TO postgres;

--
-- TOC entry 3052 (class 0 OID 0)
-- Dependencies: 208
-- Name: locations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.locations_id_seq OWNED BY public.locations.id;


--
-- TOC entry 207 (class 1259 OID 33168)
-- Name: priviledges; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.priviledges (
    id integer NOT NULL,
    title character varying(45) NOT NULL
);


ALTER TABLE public.priviledges OWNER TO postgres;

--
-- TOC entry 206 (class 1259 OID 33166)
-- Name: priviledges_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.priviledges_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.priviledges_id_seq OWNER TO postgres;

--
-- TOC entry 3053 (class 0 OID 0)
-- Dependencies: 206
-- Name: priviledges_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.priviledges_id_seq OWNED BY public.priviledges.id;


--
-- TOC entry 199 (class 1259 OID 24883)
-- Name: sim_cards; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sim_cards (
    id integer NOT NULL,
    network integer NOT NULL,
    num bigint NOT NULL,
    iccid character varying(21) NOT NULL,
    purpose character varying(20) NOT NULL
);


ALTER TABLE public.sim_cards OWNER TO postgres;

--
-- TOC entry 227 (class 1259 OID 33367)
-- Name: sim_cards_charges; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sim_cards_charges (
    id integer NOT NULL,
    sim_id integer NOT NULL,
    agent_id integer NOT NULL,
    user_id integer NOT NULL,
    date timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.sim_cards_charges OWNER TO postgres;

--
-- TOC entry 229 (class 1259 OID 33390)
-- Name: sim_cards_charges_off; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sim_cards_charges_off (
    id integer NOT NULL,
    sim_card_charge_id integer NOT NULL,
    user_id integer NOT NULL,
    date timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.sim_cards_charges_off OWNER TO postgres;

--
-- TOC entry 228 (class 1259 OID 33388)
-- Name: sim_cards_charges_off_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sim_cards_charges_off_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sim_cards_charges_off_id_seq OWNER TO postgres;

--
-- TOC entry 3054 (class 0 OID 0)
-- Dependencies: 228
-- Name: sim_cards_charges_off_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sim_cards_charges_off_id_seq OWNED BY public.sim_cards_charges_off.id;


--
-- TOC entry 198 (class 1259 OID 24881)
-- Name: sim_cards_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sim_cards_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sim_cards_id_seq OWNER TO postgres;

--
-- TOC entry 3055 (class 0 OID 0)
-- Dependencies: 198
-- Name: sim_cards_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sim_cards_id_seq OWNED BY public.sim_cards.id;


--
-- TOC entry 226 (class 1259 OID 33365)
-- Name: sims_charges_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sims_charges_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sims_charges_id_seq OWNER TO postgres;

--
-- TOC entry 3056 (class 0 OID 0)
-- Dependencies: 226
-- Name: sims_charges_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sims_charges_id_seq OWNED BY public.sim_cards_charges.id;


--
-- TOC entry 235 (class 1259 OID 34014)
-- Name: software_v; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.software_v (
    id integer NOT NULL,
    software bigint NOT NULL
);


ALTER TABLE public.software_v OWNER TO postgres;

--
-- TOC entry 234 (class 1259 OID 34012)
-- Name: software_v_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.software_v_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.software_v_id_seq OWNER TO postgres;

--
-- TOC entry 3057 (class 0 OID 0)
-- Dependencies: 234
-- Name: software_v_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.software_v_id_seq OWNED BY public.software_v.id;


--
-- TOC entry 203 (class 1259 OID 24940)
-- Name: terminals; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.terminals (
    id bigint NOT NULL,
    terminals_num_id integer NOT NULL,
    pda_id integer NOT NULL,
    printer_id integer NOT NULL,
    sim_cards_id integer NOT NULL,
    date_assembled timestamp without time zone DEFAULT now() NOT NULL,
    user_id integer NOT NULL
);


ALTER TABLE public.terminals OWNER TO postgres;

--
-- TOC entry 215 (class 1259 OID 33225)
-- Name: terminals_charges; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.terminals_charges (
    id integer NOT NULL,
    terminal_id integer NOT NULL,
    agent_id integer NOT NULL,
    user_id integer NOT NULL,
    date timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.terminals_charges OWNER TO postgres;

--
-- TOC entry 214 (class 1259 OID 33223)
-- Name: terminals_charges_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.terminals_charges_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.terminals_charges_id_seq OWNER TO postgres;

--
-- TOC entry 3058 (class 0 OID 0)
-- Dependencies: 214
-- Name: terminals_charges_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.terminals_charges_id_seq OWNED BY public.terminals_charges.id;


--
-- TOC entry 217 (class 1259 OID 33244)
-- Name: terminals_charges_off; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.terminals_charges_off (
    id integer NOT NULL,
    terminal_charge_id integer NOT NULL,
    users_id integer NOT NULL,
    date timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.terminals_charges_off OWNER TO postgres;

--
-- TOC entry 216 (class 1259 OID 33242)
-- Name: terminals_charges_off_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.terminals_charges_off_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.terminals_charges_off_id_seq OWNER TO postgres;

--
-- TOC entry 3059 (class 0 OID 0)
-- Dependencies: 216
-- Name: terminals_charges_off_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.terminals_charges_off_id_seq OWNED BY public.terminals_charges_off.id;


--
-- TOC entry 231 (class 1259 OID 33975)
-- Name: terminals_disassembled; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.terminals_disassembled (
    id bigint NOT NULL,
    terminal_id bigint NOT NULL,
    date_disassembled timestamp without time zone DEFAULT now() NOT NULL,
    user_id integer NOT NULL
);


ALTER TABLE public.terminals_disassembled OWNER TO postgres;

--
-- TOC entry 230 (class 1259 OID 33973)
-- Name: terminals_disassembled_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.terminals_disassembled_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.terminals_disassembled_id_seq OWNER TO postgres;

--
-- TOC entry 3060 (class 0 OID 0)
-- Dependencies: 230
-- Name: terminals_disassembled_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.terminals_disassembled_id_seq OWNED BY public.terminals_disassembled.id;


--
-- TOC entry 202 (class 1259 OID 24938)
-- Name: terminals_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.terminals_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.terminals_id_seq OWNER TO postgres;

--
-- TOC entry 3061 (class 0 OID 0)
-- Dependencies: 202
-- Name: terminals_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.terminals_id_seq OWNED BY public.terminals.id;


--
-- TOC entry 201 (class 1259 OID 24930)
-- Name: terminals_num; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.terminals_num (
    id integer NOT NULL,
    terminal_num integer NOT NULL
);


ALTER TABLE public.terminals_num OWNER TO postgres;

--
-- TOC entry 200 (class 1259 OID 24928)
-- Name: terminals_num_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.terminals_num_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.terminals_num_id_seq OWNER TO postgres;

--
-- TOC entry 3062 (class 0 OID 0)
-- Dependencies: 200
-- Name: terminals_num_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.terminals_num_id_seq OWNED BY public.terminals_num.id;


--
-- TOC entry 205 (class 1259 OID 33160)
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id integer NOT NULL,
    username character varying(45) NOT NULL,
    password character varying(45) NOT NULL,
    priviledge_id integer NOT NULL,
    active integer DEFAULT 1 NOT NULL
);


ALTER TABLE public.users OWNER TO postgres;

--
-- TOC entry 204 (class 1259 OID 33158)
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.users_id_seq OWNER TO postgres;

--
-- TOC entry 3063 (class 0 OID 0)
-- Dependencies: 204
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- TOC entry 2810 (class 2604 OID 33210)
-- Name: agents id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.agents ALTER COLUMN id SET DEFAULT nextval('public.agents_id_seq'::regclass);


--
-- TOC entry 2816 (class 2604 OID 33289)
-- Name: cellphones id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cellphones ALTER COLUMN id SET DEFAULT nextval('public.cellphones_id_seq'::regclass);


--
-- TOC entry 2818 (class 2604 OID 33310)
-- Name: cellphones_charges id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cellphones_charges ALTER COLUMN id SET DEFAULT nextval('public.cellphones_charges_id_seq'::regclass);


--
-- TOC entry 2820 (class 2604 OID 33318)
-- Name: cellphones_charges_off id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cellphones_charges_off ALTER COLUMN id SET DEFAULT nextval('public.cellphones_charges_off_id_seq'::regclass);


--
-- TOC entry 2800 (class 2604 OID 24873)
-- Name: devices id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.devices ALTER COLUMN id SET DEFAULT nextval('public.devices_id_seq'::regclass);


--
-- TOC entry 2809 (class 2604 OID 33192)
-- Name: devices_locations id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.devices_locations ALTER COLUMN id SET DEFAULT nextval('public.devices_locations_id_seq'::regclass);


--
-- TOC entry 2830 (class 2604 OID 34069)
-- Name: devices_softwares id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.devices_softwares ALTER COLUMN id SET DEFAULT nextval('public.devices_softwares_id_seq'::regclass);


--
-- TOC entry 2828 (class 2604 OID 34009)
-- Name: devices_types id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.devices_types ALTER COLUMN id SET DEFAULT nextval('public.devices_types_id_seq'::regclass);


--
-- TOC entry 2833 (class 2604 OID 34088)
-- Name: devices_writes_off id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.devices_writes_off ALTER COLUMN id SET DEFAULT nextval('public.devices_writes_off_id_seq'::regclass);


--
-- TOC entry 2808 (class 2604 OID 33184)
-- Name: locations id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.locations ALTER COLUMN id SET DEFAULT nextval('public.locations_id_seq'::regclass);


--
-- TOC entry 2817 (class 2604 OID 33297)
-- Name: models id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.models ALTER COLUMN id SET DEFAULT nextval('public.cellphones_models_id_seq'::regclass);


--
-- TOC entry 2807 (class 2604 OID 33171)
-- Name: priviledges id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.priviledges ALTER COLUMN id SET DEFAULT nextval('public.priviledges_id_seq'::regclass);


--
-- TOC entry 2801 (class 2604 OID 24886)
-- Name: sim_cards id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sim_cards ALTER COLUMN id SET DEFAULT nextval('public.sim_cards_id_seq'::regclass);


--
-- TOC entry 2822 (class 2604 OID 33370)
-- Name: sim_cards_charges id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sim_cards_charges ALTER COLUMN id SET DEFAULT nextval('public.sims_charges_id_seq'::regclass);


--
-- TOC entry 2824 (class 2604 OID 33393)
-- Name: sim_cards_charges_off id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sim_cards_charges_off ALTER COLUMN id SET DEFAULT nextval('public.sim_cards_charges_off_id_seq'::regclass);


--
-- TOC entry 2829 (class 2604 OID 34017)
-- Name: software_v id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.software_v ALTER COLUMN id SET DEFAULT nextval('public.software_v_id_seq'::regclass);


--
-- TOC entry 2803 (class 2604 OID 33956)
-- Name: terminals id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.terminals ALTER COLUMN id SET DEFAULT nextval('public.terminals_id_seq'::regclass);


--
-- TOC entry 2812 (class 2604 OID 33228)
-- Name: terminals_charges id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.terminals_charges ALTER COLUMN id SET DEFAULT nextval('public.terminals_charges_id_seq'::regclass);


--
-- TOC entry 2814 (class 2604 OID 33247)
-- Name: terminals_charges_off id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.terminals_charges_off ALTER COLUMN id SET DEFAULT nextval('public.terminals_charges_off_id_seq'::regclass);


--
-- TOC entry 2826 (class 2604 OID 33978)
-- Name: terminals_disassembled id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.terminals_disassembled ALTER COLUMN id SET DEFAULT nextval('public.terminals_disassembled_id_seq'::regclass);


--
-- TOC entry 2802 (class 2604 OID 24933)
-- Name: terminals_num id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.terminals_num ALTER COLUMN id SET DEFAULT nextval('public.terminals_num_id_seq'::regclass);


--
-- TOC entry 2805 (class 2604 OID 33163)
-- Name: users id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- TOC entry 2855 (class 2606 OID 33213)
-- Name: agents agents_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.agents
    ADD CONSTRAINT agents_pkey PRIMARY KEY (id);


--
-- TOC entry 2869 (class 2606 OID 33321)
-- Name: cellphones_charges_off cellphones_charges_off_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cellphones_charges_off
    ADD CONSTRAINT cellphones_charges_off_pkey PRIMARY KEY (id);


--
-- TOC entry 2867 (class 2606 OID 33312)
-- Name: cellphones_charges cellphones_charges_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cellphones_charges
    ADD CONSTRAINT cellphones_charges_pkey PRIMARY KEY (id);


--
-- TOC entry 2865 (class 2606 OID 33299)
-- Name: models cellphones_models_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.models
    ADD CONSTRAINT cellphones_models_pkey PRIMARY KEY (id);


--
-- TOC entry 2863 (class 2606 OID 33291)
-- Name: cellphones cellphones_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cellphones
    ADD CONSTRAINT cellphones_pkey PRIMARY KEY (id);


--
-- TOC entry 2853 (class 2606 OID 33194)
-- Name: devices_locations devices_locations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.devices_locations
    ADD CONSTRAINT devices_locations_pkey PRIMARY KEY (id);


--
-- TOC entry 2835 (class 2606 OID 24876)
-- Name: devices devices_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.devices
    ADD CONSTRAINT devices_pkey PRIMARY KEY (id);


--
-- TOC entry 2881 (class 2606 OID 34072)
-- Name: devices_softwares devices_softwares_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.devices_softwares
    ADD CONSTRAINT devices_softwares_pkey PRIMARY KEY (id);


--
-- TOC entry 2877 (class 2606 OID 34011)
-- Name: devices_types devices_types_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.devices_types
    ADD CONSTRAINT devices_types_pkey PRIMARY KEY (id);


--
-- TOC entry 2837 (class 2606 OID 24987)
-- Name: devices devices_ukey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.devices
    ADD CONSTRAINT devices_ukey UNIQUE (sn);


--
-- TOC entry 2883 (class 2606 OID 34091)
-- Name: devices_writes_off devices_writes_off_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.devices_writes_off
    ADD CONSTRAINT devices_writes_off_pkey PRIMARY KEY (id);


--
-- TOC entry 2851 (class 2606 OID 33186)
-- Name: locations locations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.locations
    ADD CONSTRAINT locations_pkey PRIMARY KEY (id);


--
-- TOC entry 2857 (class 2606 OID 33360)
-- Name: agents off_num_uk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.agents
    ADD CONSTRAINT off_num_uk UNIQUE (off_num);


--
-- TOC entry 2849 (class 2606 OID 33173)
-- Name: priviledges priviledges_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.priviledges
    ADD CONSTRAINT priviledges_pkey PRIMARY KEY (id);


--
-- TOC entry 2873 (class 2606 OID 33395)
-- Name: sim_cards_charges_off sim_cards_charges_off_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sim_cards_charges_off
    ADD CONSTRAINT sim_cards_charges_off_pkey PRIMARY KEY (id);


--
-- TOC entry 2839 (class 2606 OID 24888)
-- Name: sim_cards sim_cards_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sim_cards
    ADD CONSTRAINT sim_cards_pkey PRIMARY KEY (id);


--
-- TOC entry 2871 (class 2606 OID 33372)
-- Name: sim_cards_charges sims_charges_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sim_cards_charges
    ADD CONSTRAINT sims_charges_pkey PRIMARY KEY (id);


--
-- TOC entry 2879 (class 2606 OID 34019)
-- Name: software_v software_v_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.software_v
    ADD CONSTRAINT software_v_pkey PRIMARY KEY (id);


--
-- TOC entry 2861 (class 2606 OID 33249)
-- Name: terminals_charges_off terminals_charges_off_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.terminals_charges_off
    ADD CONSTRAINT terminals_charges_off_pkey PRIMARY KEY (id, users_id);


--
-- TOC entry 2859 (class 2606 OID 33231)
-- Name: terminals_charges terminals_charges_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.terminals_charges
    ADD CONSTRAINT terminals_charges_pkey PRIMARY KEY (id);


--
-- TOC entry 2875 (class 2606 OID 33981)
-- Name: terminals_disassembled terminals_disassembled_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.terminals_disassembled
    ADD CONSTRAINT terminals_disassembled_pkey PRIMARY KEY (id);


--
-- TOC entry 2841 (class 2606 OID 24935)
-- Name: terminals_num terminals_num_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.terminals_num
    ADD CONSTRAINT terminals_num_pkey PRIMARY KEY (id);


--
-- TOC entry 2843 (class 2606 OID 24937)
-- Name: terminals_num terminals_num_ukey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.terminals_num
    ADD CONSTRAINT terminals_num_ukey UNIQUE (terminal_num);


--
-- TOC entry 2845 (class 2606 OID 33958)
-- Name: terminals terminals_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.terminals
    ADD CONSTRAINT terminals_pkey PRIMARY KEY (id);


--
-- TOC entry 2847 (class 2606 OID 33165)
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- TOC entry 2905 (class 2606 OID 33378)
-- Name: sim_cards_charges agents_sc_charges_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sim_cards_charges
    ADD CONSTRAINT agents_sc_charges_id_fk FOREIGN KEY (agent_id) REFERENCES public.agents(id);


--
-- TOC entry 2898 (class 2606 OID 33300)
-- Name: cellphones cellphones_cp_models_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cellphones
    ADD CONSTRAINT cellphones_cp_models_fk FOREIGN KEY (model_id) REFERENCES public.models(id);


--
-- TOC entry 2900 (class 2606 OID 33335)
-- Name: cellphones_charges cpc_agents_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cellphones_charges
    ADD CONSTRAINT cpc_agents_fk FOREIGN KEY (agent_id) REFERENCES public.agents(id);


--
-- TOC entry 2899 (class 2606 OID 33330)
-- Name: cellphones_charges cpc_cellphones_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cellphones_charges
    ADD CONSTRAINT cpc_cellphones_fk FOREIGN KEY (cellphone_id) REFERENCES public.cellphones(id);


--
-- TOC entry 2901 (class 2606 OID 33340)
-- Name: cellphones_charges cpc_users_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cellphones_charges
    ADD CONSTRAINT cpc_users_fk FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- TOC entry 2902 (class 2606 OID 33345)
-- Name: cellphones_charges_off cpco_cpc_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cellphones_charges_off
    ADD CONSTRAINT cpco_cpc_fk FOREIGN KEY (cellphone_charge_id) REFERENCES public.cellphones_charges(id);


--
-- TOC entry 2903 (class 2606 OID 33350)
-- Name: cellphones_charges_off cpco_users_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cellphones_charges_off
    ADD CONSTRAINT cpco_users_fk FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- TOC entry 2885 (class 2606 OID 34031)
-- Name: devices devices_device_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.devices
    ADD CONSTRAINT devices_device_type_id_fkey FOREIGN KEY (device_type_id) REFERENCES public.devices_types(id);


--
-- TOC entry 2884 (class 2606 OID 34026)
-- Name: devices devices_model_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.devices
    ADD CONSTRAINT devices_model_id_fkey FOREIGN KEY (model_id) REFERENCES public.models(id);


--
-- TOC entry 2910 (class 2606 OID 34073)
-- Name: devices_softwares devices_softwares_device_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.devices_softwares
    ADD CONSTRAINT devices_softwares_device_id_fkey FOREIGN KEY (device_id) REFERENCES public.devices(id);


--
-- TOC entry 2911 (class 2606 OID 34078)
-- Name: devices_softwares devices_softwares_software_v_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.devices_softwares
    ADD CONSTRAINT devices_softwares_software_v_id_fkey FOREIGN KEY (software_v_id) REFERENCES public.software_v(id);


--
-- TOC entry 2912 (class 2606 OID 34092)
-- Name: devices_writes_off devices_writes_off_device_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.devices_writes_off
    ADD CONSTRAINT devices_writes_off_device_id_fkey FOREIGN KEY (device_id) REFERENCES public.devices(id);


--
-- TOC entry 2891 (class 2606 OID 33195)
-- Name: devices_locations dl_devices_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.devices_locations
    ADD CONSTRAINT dl_devices_fk FOREIGN KEY (device_id) REFERENCES public.devices(id);


--
-- TOC entry 2892 (class 2606 OID 33200)
-- Name: devices_locations dl_locations_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.devices_locations
    ADD CONSTRAINT dl_locations_fk FOREIGN KEY (location_id) REFERENCES public.locations(id);


--
-- TOC entry 2907 (class 2606 OID 33396)
-- Name: sim_cards_charges_off sc_charges_scco_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sim_cards_charges_off
    ADD CONSTRAINT sc_charges_scco_fk FOREIGN KEY (sim_card_charge_id) REFERENCES public.sim_cards_charges(id);


--
-- TOC entry 2904 (class 2606 OID 33373)
-- Name: sim_cards_charges sim_cards_sc_charges_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sim_cards_charges
    ADD CONSTRAINT sim_cards_sc_charges_fk FOREIGN KEY (sim_id) REFERENCES public.sim_cards(id);


--
-- TOC entry 2893 (class 2606 OID 33237)
-- Name: terminals_charges tc_agents_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.terminals_charges
    ADD CONSTRAINT tc_agents_fk FOREIGN KEY (agent_id) REFERENCES public.agents(id);


--
-- TOC entry 2895 (class 2606 OID 33959)
-- Name: terminals_charges tc_terminals_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.terminals_charges
    ADD CONSTRAINT tc_terminals_fk FOREIGN KEY (terminal_id) REFERENCES public.terminals(id);


--
-- TOC entry 2894 (class 2606 OID 33250)
-- Name: terminals_charges tc_users; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.terminals_charges
    ADD CONSTRAINT tc_users FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- TOC entry 2897 (class 2606 OID 33260)
-- Name: terminals_charges_off tco_tc_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.terminals_charges_off
    ADD CONSTRAINT tco_tc_fk FOREIGN KEY (terminal_charge_id) REFERENCES public.terminals_charges(id);


--
-- TOC entry 2896 (class 2606 OID 33255)
-- Name: terminals_charges_off tco_users_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.terminals_charges_off
    ADD CONSTRAINT tco_users_fk FOREIGN KEY (users_id) REFERENCES public.users(id);


--
-- TOC entry 2887 (class 2606 OID 24951)
-- Name: terminals terminals_devices_fk1; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.terminals
    ADD CONSTRAINT terminals_devices_fk1 FOREIGN KEY (pda_id) REFERENCES public.devices(id);


--
-- TOC entry 2888 (class 2606 OID 24956)
-- Name: terminals terminals_devices_fk2; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.terminals
    ADD CONSTRAINT terminals_devices_fk2 FOREIGN KEY (printer_id) REFERENCES public.devices(id);


--
-- TOC entry 2909 (class 2606 OID 33983)
-- Name: terminals_disassembled terminals_disassembled_terminals_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.terminals_disassembled
    ADD CONSTRAINT terminals_disassembled_terminals_fk FOREIGN KEY (terminal_id) REFERENCES public.terminals(id);


--
-- TOC entry 2889 (class 2606 OID 24961)
-- Name: terminals terminals_sim_cards_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.terminals
    ADD CONSTRAINT terminals_sim_cards_fk FOREIGN KEY (sim_cards_id) REFERENCES public.sim_cards(id);


--
-- TOC entry 2886 (class 2606 OID 24946)
-- Name: terminals terminals_terminals_num_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.terminals
    ADD CONSTRAINT terminals_terminals_num_fk FOREIGN KEY (terminals_num_id) REFERENCES public.terminals_num(id);


--
-- TOC entry 2890 (class 2606 OID 33174)
-- Name: users users_priviledges_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_priviledges_fk FOREIGN KEY (priviledge_id) REFERENCES public.priviledges(id);


--
-- TOC entry 2906 (class 2606 OID 33383)
-- Name: sim_cards_charges users_sc_charges_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sim_cards_charges
    ADD CONSTRAINT users_sc_charges_fk FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- TOC entry 2908 (class 2606 OID 33401)
-- Name: sim_cards_charges_off users_scco_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sim_cards_charges_off
    ADD CONSTRAINT users_scco_fk FOREIGN KEY (user_id) REFERENCES public.users(id);


-- Completed on 2018-11-08 13:05:33

--
-- PostgreSQL database dump complete
--

