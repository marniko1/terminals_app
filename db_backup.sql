toc.dat                                                                                             0000600 0004000 0002000 00000174533 13367436530 0014466 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        PGDMP       	                
    v         	   terminals    10.1    10.4 �               0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                       false                    0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                       false                    0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                       false                    1262    24707 	   terminals    DATABASE     �   CREATE DATABASE terminals WITH TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'Serbian (Latin)_Serbia.1250' LC_CTYPE = 'Serbian (Latin)_Serbia.1250';
    DROP DATABASE terminals;
             postgres    false                     2615    2200    public    SCHEMA        CREATE SCHEMA public;
    DROP SCHEMA public;
             postgres    false                    0    0    SCHEMA public    COMMENT     6   COMMENT ON SCHEMA public IS 'standard public schema';
                  postgres    false    3                     3079    12924    plpgsql 	   EXTENSION     ?   CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;
    DROP EXTENSION plpgsql;
                  false                    0    0    EXTENSION plpgsql    COMMENT     @   COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';
                       false    1         �            1255    33409 ?   discharge(integer, integer, integer, integer, integer, integer)    FUNCTION     ;  CREATE FUNCTION public.discharge(_agent_id integer, _terminal integer, _sim integer, _phone integer, _inactiv integer, _user integer) RETURNS void
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
 �   DROP FUNCTION public.discharge(_agent_id integer, _terminal integer, _sim integer, _phone integer, _inactiv integer, _user integer);
       public       postgres    false    3    1         �            1255    33283 U   insert_new_terminal(integer, character varying, character varying, character varying)    FUNCTION     �  CREATE FUNCTION public.insert_new_terminal(_terminal_num integer, _pda character varying, _printer character varying, _iccid character varying) RETURNS void
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
 �   DROP FUNCTION public.insert_new_terminal(_terminal_num integer, _pda character varying, _printer character varying, _iccid character varying);
       public       postgres    false    1    3         �            1255    34003 ^   insert_new_terminal(integer, character varying, character varying, character varying, integer)    FUNCTION     �  CREATE FUNCTION public.insert_new_terminal(_terminal_num integer, _pda character varying, _printer character varying, _iccid character varying, _user_id integer) RETURNS void
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
 �   DROP FUNCTION public.insert_new_terminal(_terminal_num integer, _pda character varying, _printer character varying, _iccid character varying, _user_id integer);
       public       postgres    false    3    1         �            1255    33358 Y   make_new_charge(character varying, integer, integer, integer, character varying, integer)    FUNCTION     f  CREATE FUNCTION public.make_new_charge(_agent character varying, _off_num integer, _terminal_num integer, _sim integer, _imei character varying, _user integer) RETURNS void
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
 �   DROP FUNCTION public.make_new_charge(_agent character varying, _off_num integer, _terminal_num integer, _sim integer, _imei character varying, _user integer);
       public       postgres    false    3    1         �            1259    33207    agents    TABLE     �   CREATE TABLE public.agents (
    id integer NOT NULL,
    first_name character varying(45) NOT NULL,
    last_name character varying(45) NOT NULL,
    off_num integer,
    active smallint DEFAULT 1
);
    DROP TABLE public.agents;
       public         postgres    false    3         �            1259    33205    agents_id_seq    SEQUENCE     �   CREATE SEQUENCE public.agents_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 $   DROP SEQUENCE public.agents_id_seq;
       public       postgres    false    213    3                    0    0    agents_id_seq    SEQUENCE OWNED BY     ?   ALTER SEQUENCE public.agents_id_seq OWNED BY public.agents.id;
            public       postgres    false    212         �            1259    33286 
   cellphones    TABLE     �   CREATE TABLE public.cellphones (
    id integer NOT NULL,
    model_id integer NOT NULL,
    imei character varying(30) NOT NULL
);
    DROP TABLE public.cellphones;
       public         postgres    false    3         �            1259    33307    cellphones_charges    TABLE     �   CREATE TABLE public.cellphones_charges (
    id integer NOT NULL,
    cellphone_id integer NOT NULL,
    agent_id integer NOT NULL,
    user_id integer NOT NULL,
    date timestamp without time zone DEFAULT now()
);
 &   DROP TABLE public.cellphones_charges;
       public         postgres    false    3         �            1259    33305    cellphones_charges_id_seq    SEQUENCE     �   CREATE SEQUENCE public.cellphones_charges_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 0   DROP SEQUENCE public.cellphones_charges_id_seq;
       public       postgres    false    223    3                    0    0    cellphones_charges_id_seq    SEQUENCE OWNED BY     W   ALTER SEQUENCE public.cellphones_charges_id_seq OWNED BY public.cellphones_charges.id;
            public       postgres    false    222         �            1259    33315    cellphones_charges_off    TABLE     �   CREATE TABLE public.cellphones_charges_off (
    id integer NOT NULL,
    cellphone_charge_id integer NOT NULL,
    user_id integer NOT NULL,
    date timestamp without time zone DEFAULT now() NOT NULL
);
 *   DROP TABLE public.cellphones_charges_off;
       public         postgres    false    3         �            1259    33313    cellphones_charges_off_id_seq    SEQUENCE     �   CREATE SEQUENCE public.cellphones_charges_off_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 4   DROP SEQUENCE public.cellphones_charges_off_id_seq;
       public       postgres    false    225    3                    0    0    cellphones_charges_off_id_seq    SEQUENCE OWNED BY     _   ALTER SEQUENCE public.cellphones_charges_off_id_seq OWNED BY public.cellphones_charges_off.id;
            public       postgres    false    224         �            1259    33284    cellphones_id_seq    SEQUENCE     �   CREATE SEQUENCE public.cellphones_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 (   DROP SEQUENCE public.cellphones_id_seq;
       public       postgres    false    3    219                    0    0    cellphones_id_seq    SEQUENCE OWNED BY     G   ALTER SEQUENCE public.cellphones_id_seq OWNED BY public.cellphones.id;
            public       postgres    false    218         �            1259    33294    models    TABLE     b   CREATE TABLE public.models (
    id integer NOT NULL,
    title character varying(45) NOT NULL
);
    DROP TABLE public.models;
       public         postgres    false    3         �            1259    33292    cellphones_models_id_seq    SEQUENCE     �   CREATE SEQUENCE public.cellphones_models_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 /   DROP SEQUENCE public.cellphones_models_id_seq;
       public       postgres    false    221    3                    0    0    cellphones_models_id_seq    SEQUENCE OWNED BY     J   ALTER SEQUENCE public.cellphones_models_id_seq OWNED BY public.models.id;
            public       postgres    false    220         �            1259    24870    devices    TABLE     �   CREATE TABLE public.devices (
    id integer NOT NULL,
    sn character varying(13) NOT NULL,
    nav_num character varying(20) NOT NULL,
    model_id integer,
    device_type_id integer
);
    DROP TABLE public.devices;
       public         postgres    false    3         �            1259    24868    devices_id_seq    SEQUENCE     �   CREATE SEQUENCE public.devices_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 %   DROP SEQUENCE public.devices_id_seq;
       public       postgres    false    3    197                    0    0    devices_id_seq    SEQUENCE OWNED BY     A   ALTER SEQUENCE public.devices_id_seq OWNED BY public.devices.id;
            public       postgres    false    196         �            1259    33189    devices_locations    TABLE     �   CREATE TABLE public.devices_locations (
    id integer NOT NULL,
    device_id integer NOT NULL,
    location_id integer NOT NULL
);
 %   DROP TABLE public.devices_locations;
       public         postgres    false    3         �            1259    33187    devices_locations_id_seq    SEQUENCE     �   CREATE SEQUENCE public.devices_locations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 /   DROP SEQUENCE public.devices_locations_id_seq;
       public       postgres    false    3    211                    0    0    devices_locations_id_seq    SEQUENCE OWNED BY     U   ALTER SEQUENCE public.devices_locations_id_seq OWNED BY public.devices_locations.id;
            public       postgres    false    210         �            1259    34066    devices_softwares    TABLE     �   CREATE TABLE public.devices_softwares (
    id integer NOT NULL,
    device_id integer NOT NULL,
    software_v_id integer NOT NULL,
    date timestamp without time zone DEFAULT now() NOT NULL
);
 %   DROP TABLE public.devices_softwares;
       public         postgres    false    3         �            1259    34064    devices_softwares_id_seq    SEQUENCE     �   CREATE SEQUENCE public.devices_softwares_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 /   DROP SEQUENCE public.devices_softwares_id_seq;
       public       postgres    false    238    3                    0    0    devices_softwares_id_seq    SEQUENCE OWNED BY     U   ALTER SEQUENCE public.devices_softwares_id_seq OWNED BY public.devices_softwares.id;
            public       postgres    false    237         �            1259    34006    devices_types    TABLE     h   CREATE TABLE public.devices_types (
    id bigint NOT NULL,
    title character varying(45) NOT NULL
);
 !   DROP TABLE public.devices_types;
       public         postgres    false    3         �            1259    34004    devices_types_id_seq    SEQUENCE     }   CREATE SEQUENCE public.devices_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 +   DROP SEQUENCE public.devices_types_id_seq;
       public       postgres    false    3    234                    0    0    devices_types_id_seq    SEQUENCE OWNED BY     M   ALTER SEQUENCE public.devices_types_id_seq OWNED BY public.devices_types.id;
            public       postgres    false    233         �            1259    34085    devices_writes_off    TABLE     �   CREATE TABLE public.devices_writes_off (
    id integer NOT NULL,
    device_id integer NOT NULL,
    date timestamp without time zone DEFAULT now() NOT NULL
);
 &   DROP TABLE public.devices_writes_off;
       public         postgres    false    3         �            1259    34083    devices_writes_off_id_seq    SEQUENCE     �   CREATE SEQUENCE public.devices_writes_off_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 0   DROP SEQUENCE public.devices_writes_off_id_seq;
       public       postgres    false    3    240                    0    0    devices_writes_off_id_seq    SEQUENCE OWNED BY     W   ALTER SEQUENCE public.devices_writes_off_id_seq OWNED BY public.devices_writes_off.id;
            public       postgres    false    239         �            1259    33181 	   locations    TABLE     e   CREATE TABLE public.locations (
    id integer NOT NULL,
    title character varying(45) NOT NULL
);
    DROP TABLE public.locations;
       public         postgres    false    3         �            1259    33179    locations_id_seq    SEQUENCE     �   CREATE SEQUENCE public.locations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 '   DROP SEQUENCE public.locations_id_seq;
       public       postgres    false    3    209                    0    0    locations_id_seq    SEQUENCE OWNED BY     E   ALTER SEQUENCE public.locations_id_seq OWNED BY public.locations.id;
            public       postgres    false    208         �            1259    33355    num    TABLE     4   CREATE TABLE public.num (
    "position" integer
);
    DROP TABLE public.num;
       public         postgres    false    3         �            1259    33168    priviledges    TABLE     g   CREATE TABLE public.priviledges (
    id integer NOT NULL,
    title character varying(45) NOT NULL
);
    DROP TABLE public.priviledges;
       public         postgres    false    3         �            1259    33166    priviledges_id_seq    SEQUENCE     �   CREATE SEQUENCE public.priviledges_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 )   DROP SEQUENCE public.priviledges_id_seq;
       public       postgres    false    3    207                    0    0    priviledges_id_seq    SEQUENCE OWNED BY     I   ALTER SEQUENCE public.priviledges_id_seq OWNED BY public.priviledges.id;
            public       postgres    false    206         �            1259    24883 	   sim_cards    TABLE     �   CREATE TABLE public.sim_cards (
    id integer NOT NULL,
    network integer NOT NULL,
    num bigint NOT NULL,
    iccid character varying(21) NOT NULL,
    purpose character varying(20) NOT NULL
);
    DROP TABLE public.sim_cards;
       public         postgres    false    3         �            1259    33367    sim_cards_charges    TABLE     �   CREATE TABLE public.sim_cards_charges (
    id integer NOT NULL,
    sim_id integer NOT NULL,
    agent_id integer NOT NULL,
    user_id integer NOT NULL,
    date timestamp without time zone DEFAULT now() NOT NULL
);
 %   DROP TABLE public.sim_cards_charges;
       public         postgres    false    3         �            1259    33390    sim_cards_charges_off    TABLE     �   CREATE TABLE public.sim_cards_charges_off (
    id integer NOT NULL,
    sim_card_charge_id integer NOT NULL,
    user_id integer NOT NULL,
    date timestamp without time zone DEFAULT now() NOT NULL
);
 )   DROP TABLE public.sim_cards_charges_off;
       public         postgres    false    3         �            1259    33388    sim_cards_charges_off_id_seq    SEQUENCE     �   CREATE SEQUENCE public.sim_cards_charges_off_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 3   DROP SEQUENCE public.sim_cards_charges_off_id_seq;
       public       postgres    false    230    3                    0    0    sim_cards_charges_off_id_seq    SEQUENCE OWNED BY     ]   ALTER SEQUENCE public.sim_cards_charges_off_id_seq OWNED BY public.sim_cards_charges_off.id;
            public       postgres    false    229         �            1259    24881    sim_cards_id_seq    SEQUENCE     �   CREATE SEQUENCE public.sim_cards_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 '   DROP SEQUENCE public.sim_cards_id_seq;
       public       postgres    false    3    199                    0    0    sim_cards_id_seq    SEQUENCE OWNED BY     E   ALTER SEQUENCE public.sim_cards_id_seq OWNED BY public.sim_cards.id;
            public       postgres    false    198         �            1259    33365    sims_charges_id_seq    SEQUENCE     �   CREATE SEQUENCE public.sims_charges_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 *   DROP SEQUENCE public.sims_charges_id_seq;
       public       postgres    false    3    228                     0    0    sims_charges_id_seq    SEQUENCE OWNED BY     P   ALTER SEQUENCE public.sims_charges_id_seq OWNED BY public.sim_cards_charges.id;
            public       postgres    false    227         �            1259    34014 
   software_v    TABLE     Z   CREATE TABLE public.software_v (
    id integer NOT NULL,
    software bigint NOT NULL
);
    DROP TABLE public.software_v;
       public         postgres    false    3         �            1259    34012    software_v_id_seq    SEQUENCE     �   CREATE SEQUENCE public.software_v_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 (   DROP SEQUENCE public.software_v_id_seq;
       public       postgres    false    236    3         !           0    0    software_v_id_seq    SEQUENCE OWNED BY     G   ALTER SEQUENCE public.software_v_id_seq OWNED BY public.software_v.id;
            public       postgres    false    235         �            1259    24940 	   terminals    TABLE     '  CREATE TABLE public.terminals (
    id bigint NOT NULL,
    terminals_num_id integer NOT NULL,
    pda_id integer NOT NULL,
    printer_id integer NOT NULL,
    sim_cards_id integer NOT NULL,
    date_assembled timestamp without time zone DEFAULT now() NOT NULL,
    user_id integer NOT NULL
);
    DROP TABLE public.terminals;
       public         postgres    false    3         �            1259    33225    terminals_charges    TABLE     �   CREATE TABLE public.terminals_charges (
    id integer NOT NULL,
    terminal_id integer NOT NULL,
    agent_id integer NOT NULL,
    user_id integer NOT NULL,
    date timestamp without time zone DEFAULT now() NOT NULL
);
 %   DROP TABLE public.terminals_charges;
       public         postgres    false    3         �            1259    33223    terminals_charges_id_seq    SEQUENCE     �   CREATE SEQUENCE public.terminals_charges_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 /   DROP SEQUENCE public.terminals_charges_id_seq;
       public       postgres    false    3    215         "           0    0    terminals_charges_id_seq    SEQUENCE OWNED BY     U   ALTER SEQUENCE public.terminals_charges_id_seq OWNED BY public.terminals_charges.id;
            public       postgres    false    214         �            1259    33244    terminals_charges_off    TABLE     �   CREATE TABLE public.terminals_charges_off (
    id integer NOT NULL,
    terminal_charge_id integer NOT NULL,
    users_id integer NOT NULL,
    date timestamp without time zone DEFAULT now() NOT NULL
);
 )   DROP TABLE public.terminals_charges_off;
       public         postgres    false    3         �            1259    33242    terminals_charges_off_id_seq    SEQUENCE     �   CREATE SEQUENCE public.terminals_charges_off_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 3   DROP SEQUENCE public.terminals_charges_off_id_seq;
       public       postgres    false    217    3         #           0    0    terminals_charges_off_id_seq    SEQUENCE OWNED BY     ]   ALTER SEQUENCE public.terminals_charges_off_id_seq OWNED BY public.terminals_charges_off.id;
            public       postgres    false    216         �            1259    33975    terminals_disassembled    TABLE     �   CREATE TABLE public.terminals_disassembled (
    id bigint NOT NULL,
    terminal_id bigint NOT NULL,
    date_disassembled timestamp without time zone DEFAULT now() NOT NULL,
    user_id integer NOT NULL
);
 *   DROP TABLE public.terminals_disassembled;
       public         postgres    false    3         �            1259    33973    terminals_disassembled_id_seq    SEQUENCE     �   CREATE SEQUENCE public.terminals_disassembled_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 4   DROP SEQUENCE public.terminals_disassembled_id_seq;
       public       postgres    false    3    232         $           0    0    terminals_disassembled_id_seq    SEQUENCE OWNED BY     _   ALTER SEQUENCE public.terminals_disassembled_id_seq OWNED BY public.terminals_disassembled.id;
            public       postgres    false    231         �            1259    24938    terminals_id_seq    SEQUENCE     �   CREATE SEQUENCE public.terminals_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 '   DROP SEQUENCE public.terminals_id_seq;
       public       postgres    false    3    203         %           0    0    terminals_id_seq    SEQUENCE OWNED BY     E   ALTER SEQUENCE public.terminals_id_seq OWNED BY public.terminals.id;
            public       postgres    false    202         �            1259    24930    terminals_num    TABLE     b   CREATE TABLE public.terminals_num (
    id integer NOT NULL,
    terminal_num integer NOT NULL
);
 !   DROP TABLE public.terminals_num;
       public         postgres    false    3         �            1259    24928    terminals_num_id_seq    SEQUENCE     �   CREATE SEQUENCE public.terminals_num_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 +   DROP SEQUENCE public.terminals_num_id_seq;
       public       postgres    false    201    3         &           0    0    terminals_num_id_seq    SEQUENCE OWNED BY     M   ALTER SEQUENCE public.terminals_num_id_seq OWNED BY public.terminals_num.id;
            public       postgres    false    200         �            1259    33160    users    TABLE     �   CREATE TABLE public.users (
    id integer NOT NULL,
    username character varying(45) NOT NULL,
    password character varying(45) NOT NULL,
    priviledge_id integer NOT NULL
);
    DROP TABLE public.users;
       public         postgres    false    3         �            1259    33158    users_id_seq    SEQUENCE     �   CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 #   DROP SEQUENCE public.users_id_seq;
       public       postgres    false    205    3         '           0    0    users_id_seq    SEQUENCE OWNED BY     =   ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;
            public       postgres    false    204         �
           2604    33210 	   agents id    DEFAULT     f   ALTER TABLE ONLY public.agents ALTER COLUMN id SET DEFAULT nextval('public.agents_id_seq'::regclass);
 8   ALTER TABLE public.agents ALTER COLUMN id DROP DEFAULT;
       public       postgres    false    212    213    213                    2604    33289    cellphones id    DEFAULT     n   ALTER TABLE ONLY public.cellphones ALTER COLUMN id SET DEFAULT nextval('public.cellphones_id_seq'::regclass);
 <   ALTER TABLE public.cellphones ALTER COLUMN id DROP DEFAULT;
       public       postgres    false    219    218    219                    2604    33310    cellphones_charges id    DEFAULT     ~   ALTER TABLE ONLY public.cellphones_charges ALTER COLUMN id SET DEFAULT nextval('public.cellphones_charges_id_seq'::regclass);
 D   ALTER TABLE public.cellphones_charges ALTER COLUMN id DROP DEFAULT;
       public       postgres    false    222    223    223                    2604    33318    cellphones_charges_off id    DEFAULT     �   ALTER TABLE ONLY public.cellphones_charges_off ALTER COLUMN id SET DEFAULT nextval('public.cellphones_charges_off_id_seq'::regclass);
 H   ALTER TABLE public.cellphones_charges_off ALTER COLUMN id DROP DEFAULT;
       public       postgres    false    224    225    225         �
           2604    24873 
   devices id    DEFAULT     h   ALTER TABLE ONLY public.devices ALTER COLUMN id SET DEFAULT nextval('public.devices_id_seq'::regclass);
 9   ALTER TABLE public.devices ALTER COLUMN id DROP DEFAULT;
       public       postgres    false    197    196    197         �
           2604    33192    devices_locations id    DEFAULT     |   ALTER TABLE ONLY public.devices_locations ALTER COLUMN id SET DEFAULT nextval('public.devices_locations_id_seq'::regclass);
 C   ALTER TABLE public.devices_locations ALTER COLUMN id DROP DEFAULT;
       public       postgres    false    210    211    211                    2604    34069    devices_softwares id    DEFAULT     |   ALTER TABLE ONLY public.devices_softwares ALTER COLUMN id SET DEFAULT nextval('public.devices_softwares_id_seq'::regclass);
 C   ALTER TABLE public.devices_softwares ALTER COLUMN id DROP DEFAULT;
       public       postgres    false    237    238    238                    2604    34009    devices_types id    DEFAULT     t   ALTER TABLE ONLY public.devices_types ALTER COLUMN id SET DEFAULT nextval('public.devices_types_id_seq'::regclass);
 ?   ALTER TABLE public.devices_types ALTER COLUMN id DROP DEFAULT;
       public       postgres    false    233    234    234                    2604    34088    devices_writes_off id    DEFAULT     ~   ALTER TABLE ONLY public.devices_writes_off ALTER COLUMN id SET DEFAULT nextval('public.devices_writes_off_id_seq'::regclass);
 D   ALTER TABLE public.devices_writes_off ALTER COLUMN id DROP DEFAULT;
       public       postgres    false    239    240    240         �
           2604    33184    locations id    DEFAULT     l   ALTER TABLE ONLY public.locations ALTER COLUMN id SET DEFAULT nextval('public.locations_id_seq'::regclass);
 ;   ALTER TABLE public.locations ALTER COLUMN id DROP DEFAULT;
       public       postgres    false    209    208    209                    2604    33297 	   models id    DEFAULT     q   ALTER TABLE ONLY public.models ALTER COLUMN id SET DEFAULT nextval('public.cellphones_models_id_seq'::regclass);
 8   ALTER TABLE public.models ALTER COLUMN id DROP DEFAULT;
       public       postgres    false    221    220    221         �
           2604    33171    priviledges id    DEFAULT     p   ALTER TABLE ONLY public.priviledges ALTER COLUMN id SET DEFAULT nextval('public.priviledges_id_seq'::regclass);
 =   ALTER TABLE public.priviledges ALTER COLUMN id DROP DEFAULT;
       public       postgres    false    207    206    207         �
           2604    24886    sim_cards id    DEFAULT     l   ALTER TABLE ONLY public.sim_cards ALTER COLUMN id SET DEFAULT nextval('public.sim_cards_id_seq'::regclass);
 ;   ALTER TABLE public.sim_cards ALTER COLUMN id DROP DEFAULT;
       public       postgres    false    198    199    199         	           2604    33370    sim_cards_charges id    DEFAULT     w   ALTER TABLE ONLY public.sim_cards_charges ALTER COLUMN id SET DEFAULT nextval('public.sims_charges_id_seq'::regclass);
 C   ALTER TABLE public.sim_cards_charges ALTER COLUMN id DROP DEFAULT;
       public       postgres    false    227    228    228                    2604    33393    sim_cards_charges_off id    DEFAULT     �   ALTER TABLE ONLY public.sim_cards_charges_off ALTER COLUMN id SET DEFAULT nextval('public.sim_cards_charges_off_id_seq'::regclass);
 G   ALTER TABLE public.sim_cards_charges_off ALTER COLUMN id DROP DEFAULT;
       public       postgres    false    229    230    230                    2604    34017    software_v id    DEFAULT     n   ALTER TABLE ONLY public.software_v ALTER COLUMN id SET DEFAULT nextval('public.software_v_id_seq'::regclass);
 <   ALTER TABLE public.software_v ALTER COLUMN id DROP DEFAULT;
       public       postgres    false    235    236    236         �
           2604    33956    terminals id    DEFAULT     l   ALTER TABLE ONLY public.terminals ALTER COLUMN id SET DEFAULT nextval('public.terminals_id_seq'::regclass);
 ;   ALTER TABLE public.terminals ALTER COLUMN id DROP DEFAULT;
       public       postgres    false    202    203    203         �
           2604    33228    terminals_charges id    DEFAULT     |   ALTER TABLE ONLY public.terminals_charges ALTER COLUMN id SET DEFAULT nextval('public.terminals_charges_id_seq'::regclass);
 C   ALTER TABLE public.terminals_charges ALTER COLUMN id DROP DEFAULT;
       public       postgres    false    215    214    215                    2604    33247    terminals_charges_off id    DEFAULT     �   ALTER TABLE ONLY public.terminals_charges_off ALTER COLUMN id SET DEFAULT nextval('public.terminals_charges_off_id_seq'::regclass);
 G   ALTER TABLE public.terminals_charges_off ALTER COLUMN id DROP DEFAULT;
       public       postgres    false    217    216    217                    2604    33978    terminals_disassembled id    DEFAULT     �   ALTER TABLE ONLY public.terminals_disassembled ALTER COLUMN id SET DEFAULT nextval('public.terminals_disassembled_id_seq'::regclass);
 H   ALTER TABLE public.terminals_disassembled ALTER COLUMN id DROP DEFAULT;
       public       postgres    false    232    231    232         �
           2604    24933    terminals_num id    DEFAULT     t   ALTER TABLE ONLY public.terminals_num ALTER COLUMN id SET DEFAULT nextval('public.terminals_num_id_seq'::regclass);
 ?   ALTER TABLE public.terminals_num ALTER COLUMN id DROP DEFAULT;
       public       postgres    false    200    201    201         �
           2604    33163    users id    DEFAULT     d   ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);
 7   ALTER TABLE public.users ALTER COLUMN id DROP DEFAULT;
       public       postgres    false    204    205    205         �          0    33207    agents 
   TABLE DATA                     public       postgres    false    213       3054.dat �          0    33286 
   cellphones 
   TABLE DATA                     public       postgres    false    219       3060.dat �          0    33307    cellphones_charges 
   TABLE DATA                     public       postgres    false    223       3064.dat �          0    33315    cellphones_charges_off 
   TABLE DATA                     public       postgres    false    225       3066.dat �          0    24870    devices 
   TABLE DATA                     public       postgres    false    197       3038.dat �          0    33189    devices_locations 
   TABLE DATA                     public       postgres    false    211       3052.dat           0    34066    devices_softwares 
   TABLE DATA                     public       postgres    false    238       3079.dat           0    34006    devices_types 
   TABLE DATA                     public       postgres    false    234       3075.dat 	          0    34085    devices_writes_off 
   TABLE DATA                     public       postgres    false    240       3081.dat �          0    33181 	   locations 
   TABLE DATA                     public       postgres    false    209       3050.dat �          0    33294    models 
   TABLE DATA                     public       postgres    false    221       3062.dat �          0    33355    num 
   TABLE DATA                     public       postgres    false    226       3067.dat �          0    33168    priviledges 
   TABLE DATA                     public       postgres    false    207       3048.dat �          0    24883 	   sim_cards 
   TABLE DATA                     public       postgres    false    199       3040.dat �          0    33367    sim_cards_charges 
   TABLE DATA                     public       postgres    false    228       3069.dat �          0    33390    sim_cards_charges_off 
   TABLE DATA                     public       postgres    false    230       3071.dat           0    34014 
   software_v 
   TABLE DATA                     public       postgres    false    236       3077.dat �          0    24940 	   terminals 
   TABLE DATA                     public       postgres    false    203       3044.dat �          0    33225    terminals_charges 
   TABLE DATA                     public       postgres    false    215       3056.dat �          0    33244    terminals_charges_off 
   TABLE DATA                     public       postgres    false    217       3058.dat           0    33975    terminals_disassembled 
   TABLE DATA                     public       postgres    false    232       3073.dat �          0    24930    terminals_num 
   TABLE DATA                     public       postgres    false    201       3042.dat �          0    33160    users 
   TABLE DATA                     public       postgres    false    205       3046.dat (           0    0    agents_id_seq    SEQUENCE SET     =   SELECT pg_catalog.setval('public.agents_id_seq', 287, true);
            public       postgres    false    212         )           0    0    cellphones_charges_id_seq    SEQUENCE SET     H   SELECT pg_catalog.setval('public.cellphones_charges_id_seq', 27, true);
            public       postgres    false    222         *           0    0    cellphones_charges_off_id_seq    SEQUENCE SET     L   SELECT pg_catalog.setval('public.cellphones_charges_off_id_seq', 13, true);
            public       postgres    false    224         +           0    0    cellphones_id_seq    SEQUENCE SET     ?   SELECT pg_catalog.setval('public.cellphones_id_seq', 6, true);
            public       postgres    false    218         ,           0    0    cellphones_models_id_seq    SEQUENCE SET     F   SELECT pg_catalog.setval('public.cellphones_models_id_seq', 4, true);
            public       postgres    false    220         -           0    0    devices_id_seq    SEQUENCE SET     >   SELECT pg_catalog.setval('public.devices_id_seq', 621, true);
            public       postgres    false    196         .           0    0    devices_locations_id_seq    SEQUENCE SET     H   SELECT pg_catalog.setval('public.devices_locations_id_seq', 629, true);
            public       postgres    false    210         /           0    0    devices_softwares_id_seq    SEQUENCE SET     H   SELECT pg_catalog.setval('public.devices_softwares_id_seq', 320, true);
            public       postgres    false    237         0           0    0    devices_types_id_seq    SEQUENCE SET     B   SELECT pg_catalog.setval('public.devices_types_id_seq', 2, true);
            public       postgres    false    233         1           0    0    devices_writes_off_id_seq    SEQUENCE SET     H   SELECT pg_catalog.setval('public.devices_writes_off_id_seq', 1, false);
            public       postgres    false    239         2           0    0    locations_id_seq    SEQUENCE SET     >   SELECT pg_catalog.setval('public.locations_id_seq', 3, true);
            public       postgres    false    208         3           0    0    priviledges_id_seq    SEQUENCE SET     @   SELECT pg_catalog.setval('public.priviledges_id_seq', 3, true);
            public       postgres    false    206         4           0    0    sim_cards_charges_off_id_seq    SEQUENCE SET     K   SELECT pg_catalog.setval('public.sim_cards_charges_off_id_seq', 13, true);
            public       postgres    false    229         5           0    0    sim_cards_id_seq    SEQUENCE SET     @   SELECT pg_catalog.setval('public.sim_cards_id_seq', 606, true);
            public       postgres    false    198         6           0    0    sims_charges_id_seq    SEQUENCE SET     B   SELECT pg_catalog.setval('public.sims_charges_id_seq', 42, true);
            public       postgres    false    227         7           0    0    software_v_id_seq    SEQUENCE SET     ?   SELECT pg_catalog.setval('public.software_v_id_seq', 3, true);
            public       postgres    false    235         8           0    0    terminals_charges_id_seq    SEQUENCE SET     H   SELECT pg_catalog.setval('public.terminals_charges_id_seq', 112, true);
            public       postgres    false    214         9           0    0    terminals_charges_off_id_seq    SEQUENCE SET     K   SELECT pg_catalog.setval('public.terminals_charges_off_id_seq', 70, true);
            public       postgres    false    216         :           0    0    terminals_disassembled_id_seq    SEQUENCE SET     K   SELECT pg_catalog.setval('public.terminals_disassembled_id_seq', 6, true);
            public       postgres    false    231         ;           0    0    terminals_id_seq    SEQUENCE SET     ?   SELECT pg_catalog.setval('public.terminals_id_seq', 21, true);
            public       postgres    false    202         <           0    0    terminals_num_id_seq    SEQUENCE SET     D   SELECT pg_catalog.setval('public.terminals_num_id_seq', 320, true);
            public       postgres    false    200         =           0    0    users_id_seq    SEQUENCE SET     :   SELECT pg_catalog.setval('public.users_id_seq', 1, true);
            public       postgres    false    204         *           2606    33213    agents agents_pkey 
   CONSTRAINT     P   ALTER TABLE ONLY public.agents
    ADD CONSTRAINT agents_pkey PRIMARY KEY (id);
 <   ALTER TABLE ONLY public.agents DROP CONSTRAINT agents_pkey;
       public         postgres    false    213         8           2606    33321 2   cellphones_charges_off cellphones_charges_off_pkey 
   CONSTRAINT     p   ALTER TABLE ONLY public.cellphones_charges_off
    ADD CONSTRAINT cellphones_charges_off_pkey PRIMARY KEY (id);
 \   ALTER TABLE ONLY public.cellphones_charges_off DROP CONSTRAINT cellphones_charges_off_pkey;
       public         postgres    false    225         6           2606    33312 *   cellphones_charges cellphones_charges_pkey 
   CONSTRAINT     h   ALTER TABLE ONLY public.cellphones_charges
    ADD CONSTRAINT cellphones_charges_pkey PRIMARY KEY (id);
 T   ALTER TABLE ONLY public.cellphones_charges DROP CONSTRAINT cellphones_charges_pkey;
       public         postgres    false    223         4           2606    33299    models cellphones_models_pkey 
   CONSTRAINT     [   ALTER TABLE ONLY public.models
    ADD CONSTRAINT cellphones_models_pkey PRIMARY KEY (id);
 G   ALTER TABLE ONLY public.models DROP CONSTRAINT cellphones_models_pkey;
       public         postgres    false    221         2           2606    33291    cellphones cellphones_pkey 
   CONSTRAINT     X   ALTER TABLE ONLY public.cellphones
    ADD CONSTRAINT cellphones_pkey PRIMARY KEY (id);
 D   ALTER TABLE ONLY public.cellphones DROP CONSTRAINT cellphones_pkey;
       public         postgres    false    219         (           2606    33194 (   devices_locations devices_locations_pkey 
   CONSTRAINT     f   ALTER TABLE ONLY public.devices_locations
    ADD CONSTRAINT devices_locations_pkey PRIMARY KEY (id);
 R   ALTER TABLE ONLY public.devices_locations DROP CONSTRAINT devices_locations_pkey;
       public         postgres    false    211                    2606    24876    devices devices_pkey 
   CONSTRAINT     R   ALTER TABLE ONLY public.devices
    ADD CONSTRAINT devices_pkey PRIMARY KEY (id);
 >   ALTER TABLE ONLY public.devices DROP CONSTRAINT devices_pkey;
       public         postgres    false    197         D           2606    34072 (   devices_softwares devices_softwares_pkey 
   CONSTRAINT     f   ALTER TABLE ONLY public.devices_softwares
    ADD CONSTRAINT devices_softwares_pkey PRIMARY KEY (id);
 R   ALTER TABLE ONLY public.devices_softwares DROP CONSTRAINT devices_softwares_pkey;
       public         postgres    false    238         @           2606    34011     devices_types devices_types_pkey 
   CONSTRAINT     ^   ALTER TABLE ONLY public.devices_types
    ADD CONSTRAINT devices_types_pkey PRIMARY KEY (id);
 J   ALTER TABLE ONLY public.devices_types DROP CONSTRAINT devices_types_pkey;
       public         postgres    false    234                    2606    24987    devices devices_ukey 
   CONSTRAINT     M   ALTER TABLE ONLY public.devices
    ADD CONSTRAINT devices_ukey UNIQUE (sn);
 >   ALTER TABLE ONLY public.devices DROP CONSTRAINT devices_ukey;
       public         postgres    false    197         F           2606    34091 *   devices_writes_off devices_writes_off_pkey 
   CONSTRAINT     h   ALTER TABLE ONLY public.devices_writes_off
    ADD CONSTRAINT devices_writes_off_pkey PRIMARY KEY (id);
 T   ALTER TABLE ONLY public.devices_writes_off DROP CONSTRAINT devices_writes_off_pkey;
       public         postgres    false    240         &           2606    33186    locations locations_pkey 
   CONSTRAINT     V   ALTER TABLE ONLY public.locations
    ADD CONSTRAINT locations_pkey PRIMARY KEY (id);
 B   ALTER TABLE ONLY public.locations DROP CONSTRAINT locations_pkey;
       public         postgres    false    209         ,           2606    33360    agents off_num_uk 
   CONSTRAINT     O   ALTER TABLE ONLY public.agents
    ADD CONSTRAINT off_num_uk UNIQUE (off_num);
 ;   ALTER TABLE ONLY public.agents DROP CONSTRAINT off_num_uk;
       public         postgres    false    213         $           2606    33173    priviledges priviledges_pkey 
   CONSTRAINT     Z   ALTER TABLE ONLY public.priviledges
    ADD CONSTRAINT priviledges_pkey PRIMARY KEY (id);
 F   ALTER TABLE ONLY public.priviledges DROP CONSTRAINT priviledges_pkey;
       public         postgres    false    207         <           2606    33395 0   sim_cards_charges_off sim_cards_charges_off_pkey 
   CONSTRAINT     n   ALTER TABLE ONLY public.sim_cards_charges_off
    ADD CONSTRAINT sim_cards_charges_off_pkey PRIMARY KEY (id);
 Z   ALTER TABLE ONLY public.sim_cards_charges_off DROP CONSTRAINT sim_cards_charges_off_pkey;
       public         postgres    false    230                    2606    24888    sim_cards sim_cards_pkey 
   CONSTRAINT     V   ALTER TABLE ONLY public.sim_cards
    ADD CONSTRAINT sim_cards_pkey PRIMARY KEY (id);
 B   ALTER TABLE ONLY public.sim_cards DROP CONSTRAINT sim_cards_pkey;
       public         postgres    false    199         :           2606    33372 #   sim_cards_charges sims_charges_pkey 
   CONSTRAINT     a   ALTER TABLE ONLY public.sim_cards_charges
    ADD CONSTRAINT sims_charges_pkey PRIMARY KEY (id);
 M   ALTER TABLE ONLY public.sim_cards_charges DROP CONSTRAINT sims_charges_pkey;
       public         postgres    false    228         B           2606    34019    software_v software_v_pkey 
   CONSTRAINT     X   ALTER TABLE ONLY public.software_v
    ADD CONSTRAINT software_v_pkey PRIMARY KEY (id);
 D   ALTER TABLE ONLY public.software_v DROP CONSTRAINT software_v_pkey;
       public         postgres    false    236         0           2606    33249 0   terminals_charges_off terminals_charges_off_pkey 
   CONSTRAINT     x   ALTER TABLE ONLY public.terminals_charges_off
    ADD CONSTRAINT terminals_charges_off_pkey PRIMARY KEY (id, users_id);
 Z   ALTER TABLE ONLY public.terminals_charges_off DROP CONSTRAINT terminals_charges_off_pkey;
       public         postgres    false    217    217         .           2606    33231 (   terminals_charges terminals_charges_pkey 
   CONSTRAINT     f   ALTER TABLE ONLY public.terminals_charges
    ADD CONSTRAINT terminals_charges_pkey PRIMARY KEY (id);
 R   ALTER TABLE ONLY public.terminals_charges DROP CONSTRAINT terminals_charges_pkey;
       public         postgres    false    215         >           2606    33981 2   terminals_disassembled terminals_disassembled_pkey 
   CONSTRAINT     p   ALTER TABLE ONLY public.terminals_disassembled
    ADD CONSTRAINT terminals_disassembled_pkey PRIMARY KEY (id);
 \   ALTER TABLE ONLY public.terminals_disassembled DROP CONSTRAINT terminals_disassembled_pkey;
       public         postgres    false    232                    2606    24935     terminals_num terminals_num_pkey 
   CONSTRAINT     ^   ALTER TABLE ONLY public.terminals_num
    ADD CONSTRAINT terminals_num_pkey PRIMARY KEY (id);
 J   ALTER TABLE ONLY public.terminals_num DROP CONSTRAINT terminals_num_pkey;
       public         postgres    false    201                    2606    24937     terminals_num terminals_num_ukey 
   CONSTRAINT     c   ALTER TABLE ONLY public.terminals_num
    ADD CONSTRAINT terminals_num_ukey UNIQUE (terminal_num);
 J   ALTER TABLE ONLY public.terminals_num DROP CONSTRAINT terminals_num_ukey;
       public         postgres    false    201                     2606    33958    terminals terminals_pkey 
   CONSTRAINT     V   ALTER TABLE ONLY public.terminals
    ADD CONSTRAINT terminals_pkey PRIMARY KEY (id);
 B   ALTER TABLE ONLY public.terminals DROP CONSTRAINT terminals_pkey;
       public         postgres    false    203         "           2606    33165    users users_pkey 
   CONSTRAINT     N   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);
 :   ALTER TABLE ONLY public.users DROP CONSTRAINT users_pkey;
       public         postgres    false    205         \           2606    33378 )   sim_cards_charges agents_sc_charges_id_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.sim_cards_charges
    ADD CONSTRAINT agents_sc_charges_id_fk FOREIGN KEY (agent_id) REFERENCES public.agents(id);
 S   ALTER TABLE ONLY public.sim_cards_charges DROP CONSTRAINT agents_sc_charges_id_fk;
       public       postgres    false    2858    228    213         U           2606    33300 "   cellphones cellphones_cp_models_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.cellphones
    ADD CONSTRAINT cellphones_cp_models_fk FOREIGN KEY (model_id) REFERENCES public.models(id);
 L   ALTER TABLE ONLY public.cellphones DROP CONSTRAINT cellphones_cp_models_fk;
       public       postgres    false    221    219    2868         W           2606    33335     cellphones_charges cpc_agents_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.cellphones_charges
    ADD CONSTRAINT cpc_agents_fk FOREIGN KEY (agent_id) REFERENCES public.agents(id);
 J   ALTER TABLE ONLY public.cellphones_charges DROP CONSTRAINT cpc_agents_fk;
       public       postgres    false    213    223    2858         V           2606    33330 $   cellphones_charges cpc_cellphones_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.cellphones_charges
    ADD CONSTRAINT cpc_cellphones_fk FOREIGN KEY (cellphone_id) REFERENCES public.cellphones(id);
 N   ALTER TABLE ONLY public.cellphones_charges DROP CONSTRAINT cpc_cellphones_fk;
       public       postgres    false    219    2866    223         X           2606    33340    cellphones_charges cpc_users_fk    FK CONSTRAINT     ~   ALTER TABLE ONLY public.cellphones_charges
    ADD CONSTRAINT cpc_users_fk FOREIGN KEY (user_id) REFERENCES public.users(id);
 I   ALTER TABLE ONLY public.cellphones_charges DROP CONSTRAINT cpc_users_fk;
       public       postgres    false    205    2850    223         Y           2606    33345 "   cellphones_charges_off cpco_cpc_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.cellphones_charges_off
    ADD CONSTRAINT cpco_cpc_fk FOREIGN KEY (cellphone_charge_id) REFERENCES public.cellphones_charges(id);
 L   ALTER TABLE ONLY public.cellphones_charges_off DROP CONSTRAINT cpco_cpc_fk;
       public       postgres    false    225    2870    223         Z           2606    33350 $   cellphones_charges_off cpco_users_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.cellphones_charges_off
    ADD CONSTRAINT cpco_users_fk FOREIGN KEY (user_id) REFERENCES public.users(id);
 N   ALTER TABLE ONLY public.cellphones_charges_off DROP CONSTRAINT cpco_users_fk;
       public       postgres    false    2850    225    205         H           2606    34031 #   devices devices_device_type_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.devices
    ADD CONSTRAINT devices_device_type_id_fkey FOREIGN KEY (device_type_id) REFERENCES public.devices_types(id);
 M   ALTER TABLE ONLY public.devices DROP CONSTRAINT devices_device_type_id_fkey;
       public       postgres    false    2880    234    197         G           2606    34026    devices devices_model_id_fkey    FK CONSTRAINT     ~   ALTER TABLE ONLY public.devices
    ADD CONSTRAINT devices_model_id_fkey FOREIGN KEY (model_id) REFERENCES public.models(id);
 G   ALTER TABLE ONLY public.devices DROP CONSTRAINT devices_model_id_fkey;
       public       postgres    false    221    197    2868         a           2606    34073 2   devices_softwares devices_softwares_device_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.devices_softwares
    ADD CONSTRAINT devices_softwares_device_id_fkey FOREIGN KEY (device_id) REFERENCES public.devices(id);
 \   ALTER TABLE ONLY public.devices_softwares DROP CONSTRAINT devices_softwares_device_id_fkey;
       public       postgres    false    2838    197    238         b           2606    34078 6   devices_softwares devices_softwares_software_v_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.devices_softwares
    ADD CONSTRAINT devices_softwares_software_v_id_fkey FOREIGN KEY (software_v_id) REFERENCES public.software_v(id);
 `   ALTER TABLE ONLY public.devices_softwares DROP CONSTRAINT devices_softwares_software_v_id_fkey;
       public       postgres    false    236    2882    238         c           2606    34092 4   devices_writes_off devices_writes_off_device_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.devices_writes_off
    ADD CONSTRAINT devices_writes_off_device_id_fkey FOREIGN KEY (device_id) REFERENCES public.devices(id);
 ^   ALTER TABLE ONLY public.devices_writes_off DROP CONSTRAINT devices_writes_off_device_id_fkey;
       public       postgres    false    2838    240    197         N           2606    33195    devices_locations dl_devices_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.devices_locations
    ADD CONSTRAINT dl_devices_fk FOREIGN KEY (device_id) REFERENCES public.devices(id);
 I   ALTER TABLE ONLY public.devices_locations DROP CONSTRAINT dl_devices_fk;
       public       postgres    false    2838    211    197         O           2606    33200 !   devices_locations dl_locations_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.devices_locations
    ADD CONSTRAINT dl_locations_fk FOREIGN KEY (location_id) REFERENCES public.locations(id);
 K   ALTER TABLE ONLY public.devices_locations DROP CONSTRAINT dl_locations_fk;
       public       postgres    false    209    2854    211         ^           2606    33396 (   sim_cards_charges_off sc_charges_scco_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.sim_cards_charges_off
    ADD CONSTRAINT sc_charges_scco_fk FOREIGN KEY (sim_card_charge_id) REFERENCES public.sim_cards_charges(id);
 R   ALTER TABLE ONLY public.sim_cards_charges_off DROP CONSTRAINT sc_charges_scco_fk;
       public       postgres    false    228    2874    230         [           2606    33373 )   sim_cards_charges sim_cards_sc_charges_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.sim_cards_charges
    ADD CONSTRAINT sim_cards_sc_charges_fk FOREIGN KEY (sim_id) REFERENCES public.sim_cards(id);
 S   ALTER TABLE ONLY public.sim_cards_charges DROP CONSTRAINT sim_cards_sc_charges_fk;
       public       postgres    false    228    2842    199         P           2606    33237    terminals_charges tc_agents_fk    FK CONSTRAINT        ALTER TABLE ONLY public.terminals_charges
    ADD CONSTRAINT tc_agents_fk FOREIGN KEY (agent_id) REFERENCES public.agents(id);
 H   ALTER TABLE ONLY public.terminals_charges DROP CONSTRAINT tc_agents_fk;
       public       postgres    false    215    2858    213         R           2606    33959 !   terminals_charges tc_terminals_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.terminals_charges
    ADD CONSTRAINT tc_terminals_fk FOREIGN KEY (terminal_id) REFERENCES public.terminals(id);
 K   ALTER TABLE ONLY public.terminals_charges DROP CONSTRAINT tc_terminals_fk;
       public       postgres    false    215    2848    203         Q           2606    33250    terminals_charges tc_users    FK CONSTRAINT     y   ALTER TABLE ONLY public.terminals_charges
    ADD CONSTRAINT tc_users FOREIGN KEY (user_id) REFERENCES public.users(id);
 D   ALTER TABLE ONLY public.terminals_charges DROP CONSTRAINT tc_users;
       public       postgres    false    205    2850    215         T           2606    33260    terminals_charges_off tco_tc_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.terminals_charges_off
    ADD CONSTRAINT tco_tc_fk FOREIGN KEY (terminal_charge_id) REFERENCES public.terminals_charges(id);
 I   ALTER TABLE ONLY public.terminals_charges_off DROP CONSTRAINT tco_tc_fk;
       public       postgres    false    2862    215    217         S           2606    33255 "   terminals_charges_off tco_users_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.terminals_charges_off
    ADD CONSTRAINT tco_users_fk FOREIGN KEY (users_id) REFERENCES public.users(id);
 L   ALTER TABLE ONLY public.terminals_charges_off DROP CONSTRAINT tco_users_fk;
       public       postgres    false    2850    217    205         J           2606    24951    terminals terminals_devices_fk1    FK CONSTRAINT        ALTER TABLE ONLY public.terminals
    ADD CONSTRAINT terminals_devices_fk1 FOREIGN KEY (pda_id) REFERENCES public.devices(id);
 I   ALTER TABLE ONLY public.terminals DROP CONSTRAINT terminals_devices_fk1;
       public       postgres    false    2838    197    203         K           2606    24956    terminals terminals_devices_fk2    FK CONSTRAINT     �   ALTER TABLE ONLY public.terminals
    ADD CONSTRAINT terminals_devices_fk2 FOREIGN KEY (printer_id) REFERENCES public.devices(id);
 I   ALTER TABLE ONLY public.terminals DROP CONSTRAINT terminals_devices_fk2;
       public       postgres    false    203    2838    197         `           2606    33983 :   terminals_disassembled terminals_disassembled_terminals_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.terminals_disassembled
    ADD CONSTRAINT terminals_disassembled_terminals_fk FOREIGN KEY (terminal_id) REFERENCES public.terminals(id);
 d   ALTER TABLE ONLY public.terminals_disassembled DROP CONSTRAINT terminals_disassembled_terminals_fk;
       public       postgres    false    203    232    2848         L           2606    24961     terminals terminals_sim_cards_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.terminals
    ADD CONSTRAINT terminals_sim_cards_fk FOREIGN KEY (sim_cards_id) REFERENCES public.sim_cards(id);
 J   ALTER TABLE ONLY public.terminals DROP CONSTRAINT terminals_sim_cards_fk;
       public       postgres    false    203    2842    199         I           2606    24946 $   terminals terminals_terminals_num_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.terminals
    ADD CONSTRAINT terminals_terminals_num_fk FOREIGN KEY (terminals_num_id) REFERENCES public.terminals_num(id);
 N   ALTER TABLE ONLY public.terminals DROP CONSTRAINT terminals_terminals_num_fk;
       public       postgres    false    203    201    2844         M           2606    33174    users users_priviledges_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_priviledges_fk FOREIGN KEY (priviledge_id) REFERENCES public.priviledges(id);
 D   ALTER TABLE ONLY public.users DROP CONSTRAINT users_priviledges_fk;
       public       postgres    false    2852    207    205         ]           2606    33383 %   sim_cards_charges users_sc_charges_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.sim_cards_charges
    ADD CONSTRAINT users_sc_charges_fk FOREIGN KEY (user_id) REFERENCES public.users(id);
 O   ALTER TABLE ONLY public.sim_cards_charges DROP CONSTRAINT users_sc_charges_fk;
       public       postgres    false    2850    228    205         _           2606    33401 #   sim_cards_charges_off users_scco_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.sim_cards_charges_off
    ADD CONSTRAINT users_scco_fk FOREIGN KEY (user_id) REFERENCES public.users(id);
 M   ALTER TABLE ONLY public.sim_cards_charges_off DROP CONSTRAINT users_scco_fk;
       public       postgres    false    2850    205    230                                                                                                                                                                             3054.dat                                                                                            0000600 0004000 0002000 00000075200 13367436530 0014263 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (1, 'duška', 'krivošija', 98003, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (2, 'milka', 'stanković', 98004, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (3, 'aleksandar', 'milenković', 98010, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (4, 'daniel', 'blagojević', 98011, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (5, 'marko', 'krneta', 98014, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (6, 'dragan', 'terzić', 98017, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (7, 'ivana', 'lukić', 98021, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (8, 'goran', 'getić', 98029, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (9, 'harun', 'mehmedali', 98030, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (10, 'svetlana', 'milenković đinđić', 98057, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (11, 'milan', 'panić', 98058, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (12, 'valentina', 'milić', 98059, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (13, 'dragana', 'vejinović', 98061, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (14, 'željko', 'bubanja', 98067, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (15, 'nenad', 'mrkić', 98071, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (16, 'boban', 'banković', 98073, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (17, 'nebojša', 'petrović', 98074, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (18, 'katarina', 'babić', 98082, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (19, 'marija', 'knežević', 98084, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (20, 'slađana', 'lazić bošković', 98087, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (21, 'ana', 'jelenić', 98089, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (22, 'jelena', 'milinković', 98090, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (23, 'svetlana', 'kandić', 98091, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (24, 'vesna', 'damnjanović', 98099, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (25, 'slađana', 'orašanin', 98100, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (26, 'milan', 'milošević', 98106, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (27, 'miloš', 'todorović', 98117, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (28, 'jelena', 'đorđević', 98119, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (29, 'marko', 'dimitrijević', 98123, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (30, 'marko', 'banković', 98129, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (31, 'aleksandar', 'glišić', 98132, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (32, 'jelena', 'nedeljković', 98135, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (33, 'aleksandar', 'stanković', 98141, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (34, 'daliborka', 'arsić', 98214, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (35, 'milena', 'janković', 98215, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (36, 'zlatko', 'arsenović', 98217, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (37, 'miroljub', 'đurović', 98219, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (38, 'željka', 'kalinić', 98230, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (39, 'veljko', 'kocoljevac', 98239, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (40, 'dragana', 'ristić', 98243, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (41, 'marko', 'stojanović', 98244, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (42, 'zoran', 'pavlović', 98247, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (43, 'milan', 'adamović', 98252, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (44, 'tijana', 'cvetanović', 98277, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (45, 'danijela', 'nešić', 98280, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (46, 'svetlana', 'karadžić', 98281, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (47, 'goran', 'duduković', 98289, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (48, 'vojislav', 'mladenović', 98292, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (49, 'nenad', 'caranović', 98294, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (50, 'marija', 'zdravković', 98298, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (51, 'danijela', 'jovanović', 98299, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (52, 'dragana', 'knežević', 98300, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (53, 'nenad', 'stanković', 98310, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (54, 'igor', 'ristić', 98311, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (55, 'aleksandar', 'petrović', 98319, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (56, 'ana', 'dedić', 98320, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (57, 'branislav', 'bovan', 98321, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (58, 'žaklina', 'tucović', 98322, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (59, 'mariana', 'kocić', 98328, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (60, 'dejan', 'vladimirov', 98333, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (61, 'vida', 'mirković', 98336, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (62, 'svetlana', 'koković', 98341, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (63, 'marijana', 'mirković', 98345, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (64, 'milan', 'mišković', 98349, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (65, 'mirjana', 'dostanić', 98351, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (66, 'ivana', 'stojilković', 98356, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (67, 'maja', 'jovanović', 98357, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (68, 'dijana', 'đekić', 98363, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (69, 'nikola', 'stojić', 98364, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (70, 'ivan', 'zorić', 98371, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (71, 'igor', 'stojanović', 98374, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (72, 'dragana', 'dimitrijević', 98380, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (73, 'radoslav', 'milenković', 98381, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (74, 'bogdan', 'nikolić', 98385, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (75, 'gordana', 'radojević', 98392, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (76, 'fatima', 'šabanović', 98394, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (77, 'jelena', 'perišić', 98398, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (78, 'radivoje', 'sarić', 98402, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (79, 'aleksandar', 'kenjić', 98404, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (80, 'leposava', 'maksimović', 98409, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (81, 'maja', 'cvetić', 98415, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (82, 'milan', 'milenković', 98424, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (83, 'borko', 'dedić', 98426, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (85, 'goran', 'papić', 98430, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (86, 'jasminka', 'trifković', 98431, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (87, 'dragan', 'jovanović', 98432, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (88, 'greta', 'filipović', 98433, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (89, 'milan', 'mikez', 98434, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (90, 'zorana', 'živić', 98437, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (91, 'velinka', 'kerekeš', 98441, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (92, 'snežana', 'kalezić', 98443, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (93, 'mirela', 'rabljenović', 98445, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (94, 'predrag', 'živanković', 98446, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (95, 'predrag', 'popović', 98447, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (96, 'tatjana', 'stojanović', 98451, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (97, 'milica', 'čanković', 98453, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (98, 'vladan', 'živanović', 98454, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (99, 'lazar', 'jovanović', 98457, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (100, 'goran', 'pavlović', 98459, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (101, 'slavoljub', 'tomanić', 98460, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (102, 'miloš', 'vučinić', 98462, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (103, 'jasmina', 'milivojević', 98465, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (104, 'jelena', 'drobnjak', 98467, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (105, 'aleksandar', 'radovanović', 98468, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (106, 'dragan', 'stojkov', 98469, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (107, 'dejan', 'ignjatović', 98470, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (108, 'ljiljana', 'alavanja', 98473, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (109, 'milan', 'marinković', 98475, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (110, 'milica', 'bucalo', 98477, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (111, 'stefan', 'filipović', 98479, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (112, 'magdalena', 'd addea', 98480, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (113, 'jovica', 'avramović', 98481, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (114, 'marko', 'jevđić', 98482, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (115, 'svetlana', 'vlaisavljević ostojin', 98483, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (116, 'aleksandra', 'stojiljković', 98486, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (117, 'slavica', 'pantić', 98487, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (118, 'zvonko', 'šćekić', 98489, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (119, 'milomir', 'đorđević', 98490, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (120, 'nikola', 'ivanović', 98491, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (121, 'slađana', 'marković', 98494, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (122, 'vinko', 'arambašić', 98495, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (123, 'jovan', 'knežević', 98496, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (124, 'gojka', 'pušonjić', 98497, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (125, 'emina', 'pantelić', 98498, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (126, 'biljana', 'maksimović', 98499, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (127, 'renata', 'juhas', 98503, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (128, 'slaviša', 'todorov', 98504, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (129, 'aleksandra', 'lazić', 98505, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (130, 'maja', 'simonović', 98506, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (131, 'mira', 'radovanović', 98507, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (132, 'mirjana', 'popović', 98508, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (133, 'aleksandar', 'avramović', 98510, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (134, 'slaviša', 'gašić', 98511, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (135, 'branko', 'lemić', 98516, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (136, 'nikola', 'vukmirović', 98517, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (137, 'dragan', 'mitrović', 98518, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (138, 'radiša', 'ibrić', 98519, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (139, 'jelena', 'petrović', 98520, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (140, 'milica', 'mirosavljević', 98521, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (141, 'biljana', 'živković', 99205, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (142, 'vesna', 'stanković', 99206, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (143, 'marija', 'milojević', 99217, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (144, 'natalija', 'idžaković', 99218, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (145, 'slobodan', 'ivković', 99224, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (146, 'milan', 'vojnović', 99227, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (147, 'gordana', 'debeljak', 99233, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (148, 'nenad', 'obradović', 99241, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (149, 'ivica', 'živanović', 99244, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (150, 'tatjana', 'cvijanović', 99251, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (151, 'mirjana', 'pantelić', 99252, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (152, 'danijela', 'miladinović', 99256, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (153, 'dragan', 'đorđević', 99258, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (154, 'jasmina', 'vojinović', 99274, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (155, 'jelena', 'belencan', 99278, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (156, 'desa', 'bjeljac', 99282, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (157, 'marina', 'valjić', 99285, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (158, 'zdenko', 'radivojević', 99289, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (159, 'vladanka', 'miljušević', 99303, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (160, 'dejan', 'savić', 99305, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (161, 'marija', 'orelj', 99310, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (162, 'zoran', 'mišković', 99315, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (164, 'slađana', 'dojčinović', 99321, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (165, 'miroslav', 'ilić', 99328, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (166, 'stanika', 'jovanović', 99329, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (167, 'vladimir', 'milić', 99334, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (168, 'branislava', 'popović', 99338, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (169, 'slobodanka', 'manojlović', 99340, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (170, 'mirjana', 'rakas', 99341, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (171, 'katarina', 'ranđelović', 99344, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (172, 'aleksandar', 'dmitrić', 99345, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (173, 'slavica', 'panić', 99346, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (174, 'predrag', 'topalović', 99348, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (175, 'branka', 'radojević', 99356, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (176, 'dušica', 'miletić', 99363, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (177, 'nenad', 'ivanušić', 99366, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (178, 'marija', 'karić', 99372, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (179, 'milan', 'pavlović', 99375, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (180, 'marijana', 'popović', 99379, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (181, 'mirjana', 'topić', 99381, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (182, 'zorica', 'milićević', 99386, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (183, 'veljko', 'alavanja', 99392, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (184, 'nevenka', 'živanović', 99397, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (185, 'milenko', 'pušonjić', 99401, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (186, 'aleksandar', 'bogdanovski', 99405, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (187, 'zoran', 'ilić', 99407, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (188, 'jelena', 'lazarević', 99415, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (189, 'dragan', 'devetaković', 99416, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (190, 'žaklina', 'stojiljković', 99417, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (191, 'ljiljana', 'janković', 99420, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (192, 'milena', 'stanojević', 99423, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (193, 'milorad', 'jović', 99426, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (194, 'marija', 'mraković', 99427, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (195, 'danijela', 'bradić', 99428, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (196, 'gorana', 'stričević', 99434, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (197, 'darko', 'pupovac', 99437, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (198, 'milanka', 'radovanović', 99439, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (199, 'dobrila', 'đurić', 99440, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (200, 'vesna', 'maksimović', 99441, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (201, 'branko', 'vukašinović', 99448, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (202, 'brankica', 'vukić', 99453, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (203, 'milko', 'radović', 99466, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (204, 'radislavko', 'matić', 99467, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (205, 'dragan', 'pribaković', 99468, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (206, 'biljana', 'stefanović', 99470, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (207, 'milorad', 'ljiljak', 99471, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (208, 'ratko', 'mrkaić', 99502, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (209, 'vesna', 'puhača', 99544, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (210, 'dražen', 'gakov', 99548, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (211, 'slobodan', 'šuput', 99577, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (212, 'slađana', 'živanić', 99581, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (213, 'darko', 'pendić', 99583, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (214, 'radojka', 'avramović', 99584, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (215, 'gorica', 'nestorović', 99585, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (216, 'ljiljana', 'marković', 99587, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (217, 'slobodan', 'đorđević', 99588, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (218, 'radomir', 'pavlović', 99589, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (219, 'dobrila', 'mitrović', 99591, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (220, 'darko', 'isailović', 99592, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (221, 'jelena', 'bigović', 99596, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (222, 'predrag', 'vasić', 99598, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (223, 'željko', 'tadić', 99601, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (224, 'željko', 'žmurić', 99602, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (225, 'željko', 'mitrović', 99604, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (226, 'jagodina', 'radovanović', 99605, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (227, 'ana', 'jevđić', 99608, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (228, 'slađana', 'nišavić', 99609, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (229, 'slobodan', 'andrejić', 99611, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (230, 'siniša', 'perenčević', 99616, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (231, 'ivana', 'antonić-ivanušić', 99620, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (232, 'draško', 'babić', 99641, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (233, 'slađan', 'stanisavljević', 99653, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (234, 'borko', 'topalović', 99657, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (235, 'marija', 'marković', 99661, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (236, 'dejan', 'bošnjaković', 99667, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (237, 'miloš', 'marković', 99676, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (238, 'goran', 'bursać', 99686, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (239, 'bojan', 'feratović', 99694, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (240, 'zoran', 'stošić', 99717, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (241, 'bojana', 'stanojević', 99724, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (242, 'draginja', 'jeremić', 99746, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (243, 'ljiljana', 'gorgievski', 99752, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (244, 'nenad', 'tmušić', 99755, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (245, 'marija', 'petrović', 99757, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (246, 'danilo', 'nikolić', 99772, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (247, 'marija', 'jovanović', 99776, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (248, 'snežana', 'stojanović', 99780, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (249, 'marina', 'živković', 99788, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (250, 'svetlana', 'mićićelović', 99797, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (251, 'mirjana', 'đorđijevski', 99909, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (252, 'marijana', 'pavlović', 99913, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (253, 'jelena', 'kamberović', 99951, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (254, 'katica', 'minić', 99956, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (255, 'jovanka', 'stanković', 99982, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (256, 'brankica', 'maksimović', 99988, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (257, 'olgica', 'andrejić', 99992, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (258, 'bora', 'stanojević', 99993, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (281, 'dragana', 'bijelić', 98528, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (84, 'dušan', 'gnjatović', 98427, 0);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (280, 'biljana', 'petrović', 98526, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (163, 'zoran', 'cvetković', 99317, 0);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (282, 'jasmina', 'mitrović', 98524, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (283, 'dragan', 'mitrović', 98523, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (284, 'zoran', 'leposavić', 98522, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (285, 'bojan', 'glišić', 98525, 1);
INSERT INTO public.agents (id, first_name, last_name, off_num, active) VALUES (286, 'marija', 'jović', 98527, 1);


                                                                                                                                                                                                                                                                                                                                                                                                3060.dat                                                                                            0000600 0004000 0002000 00000001000 13367436530 0014243 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        INSERT INTO public.cellphones (id, model_id, imei) VALUES (1, 4, '356788068885730');
INSERT INTO public.cellphones (id, model_id, imei) VALUES (2, 4, '356788068923515');
INSERT INTO public.cellphones (id, model_id, imei) VALUES (3, 4, '356788068948835');
INSERT INTO public.cellphones (id, model_id, imei) VALUES (4, 4, '356788068818319');
INSERT INTO public.cellphones (id, model_id, imei) VALUES (5, 4, '356788068910298');
INSERT INTO public.cellphones (id, model_id, imei) VALUES (6, 4, '356788068915073');


3064.dat                                                                                            0000600 0004000 0002000 00000000002 13367436530 0014250 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        

                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              3066.dat                                                                                            0000600 0004000 0002000 00000000002 13367436530 0014252 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        

                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              3038.dat                                                                                            0000600 0004000 0002000 00000220503 13367436530 0014263 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (55, '117162902453', 'OS7166', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (56, '117162902455', 'OS7167', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (57, '117162902456', 'OS7168', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (58, '117162902454', 'OS7169', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (59, '117162902488', 'OS7170', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (60, '117162902451', 'OS7171', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (61, '117162902460', 'OS7172', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (62, '117162902459', 'OS7173', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (63, '117162902452', 'OS7174', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (64, '117162902447', 'OS7175', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (65, '117162902446', 'OS7176', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (66, '117162902444', 'OS7177', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (67, '117162902442', 'OS7178', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (68, '117162902424', 'OS7179', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (69, '117162902438', 'OS7180', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (70, '117162902445', 'OS7181', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (71, '117162902437', 'OS7182', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (72, '117162902419', 'OS7183', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (73, '117162902422', 'OS7184', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (74, '117162902439', 'OS7185', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (75, '117162902426', 'OS7186', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (76, '117162902425', 'OS7187', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (77, '117162902416', 'OS7188', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (78, '117162902420', 'OS7189', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (79, '117162902423', 'OS7190', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (80, '117162902418', 'OS7191', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (81, '117162902408', 'OS7192', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (82, '117162902411', 'OS7193', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (83, '117162902415', 'OS7194', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (84, '117162902407', 'OS7195', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (85, '117162902403', 'OS7196', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (86, '117162902485', 'OS7197', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (87, '117162902494', 'OS7198', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (88, '117162902496', 'OS7199', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (89, '117162902491', 'OS7200', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (90, '117162902497', 'OS7201', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (91, '117162902492', 'OS7202', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (92, '117162902493', 'OS7203', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (93, '117162902499', 'OS7204', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (94, '117162902498', 'OS7205', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (95, '117162902495', 'OS7206', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (96, '117162902417', 'OS7207', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (97, '117162902412', 'OS7208', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (98, '117162902428', 'OS7209', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (99, '117162902413', 'OS7210', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (100, '117162902427', 'OS7211', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (101, '117162902421', 'OS7212', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (102, '117162902404', 'OS7213', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (103, '117162902409', 'OS7214', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (104, '117162902429', 'OS7215', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (105, '117162902402', 'OS7216', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (106, '117162902406', 'OS7217', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (107, '117162902410', 'OS7218', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (108, '117162902405', 'OS7219', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (109, '117162902414', 'OS7220', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (110, '117162902401', 'OS7221', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (111, '117162902461', 'OS7222', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (112, '117162902469', 'OS7223', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (113, '117162902466', 'OS7224', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (114, '117162902430', 'OS7225', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (115, '117162902473', 'OS7226', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (116, '117162902464', 'OS7227', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (117, '117162902463', 'OS7228', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (118, '117162902467', 'OS7229', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (119, '117162902475', 'OS7230', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (120, '117162902471', 'OS7231', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (121, '117163400001', 'OS7232', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (122, '117163400002', 'OS7233', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (123, '117163400003', 'OS7234', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (124, '117163400004', 'OS7235', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (125, '117163400005', 'OS7236', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (126, '117163400006', 'OS7237', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (127, '117163400007', 'OS7238', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (128, '117163400008', 'OS7239', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (129, '117163400009', 'OS7240', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (130, '117163400010', 'OS7241', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (131, '117163400011', 'OS7242', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (132, '117163400012', 'OS7243', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (133, '117163400013', 'OS7244', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (134, '117163400014', 'OS7245', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (135, '117163400015', 'OS7246', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (136, '117163400016', 'OS7247', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (137, '117163400017', 'OS7248', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (138, '117163400018', 'OS7249', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (139, '117163400019', 'OS7250', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (140, '117163400020', 'OS7251', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (141, '117163400021', 'OS7252', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (142, '117163400022', 'OS7253', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (143, '117163400023', 'OS7254', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (144, '117163400024', 'OS7255', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (145, '117163400025', 'OS7256', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (146, '117163400026', 'OS7257', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (147, '117163400027', 'OS7258', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (148, '117163400028', 'OS7259', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (149, '117163400029', 'OS7260', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (150, '117163400030', 'OS7261', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (151, '117163400031', 'OS7262', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (152, '117163400032', 'OS7263', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (153, '117163400033', 'OS7264', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (154, '117163400034', 'OS7265', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (155, '117163400035', 'OS7266', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (156, '117163400036', 'OS7267', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (157, '117163400037', 'OS7268', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (158, '117163400038', 'OS7269', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (159, '117163400039', 'OS7270', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (353, 'PMA005891UN16', 'FA-V5-0032', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (160, '117163400040', 'OS7271', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (161, '117163400041', 'OS7272', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (162, '117163400042', 'OS7273', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (163, '117163400043', 'OS7274', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (164, '117163400044', 'OS7275', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (165, '117163400045', 'OS7276', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (166, '117163400046', 'OS7277', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (167, '117163400047', 'OS7278', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (168, '117163400048', 'OS7279', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (169, '117163400049', 'OS7280', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (170, '117163400050', 'OS7281', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (171, '117163400051', 'OS7282', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (172, '117163400052', 'OS7283', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (173, '117163400053', 'OS7284', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (174, '117163400054', 'OS7285', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (175, '117163400055', 'OS7286', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (176, '117163400056', 'OS7287', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (177, '117163400057', 'OS7288', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (178, '117163400058', 'OS7289', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (179, '117163400059', 'OS7290', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (180, '117163400060', 'OS7291', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (181, '117163400061', 'OS7292', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (182, '117163400062', 'OS7293', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (183, '117163400063', 'OS7294', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (184, '117163400064', 'OS7295', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (185, '117163400065', 'OS7296', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (186, '117163400066', 'OS7297', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (187, '117163400067', 'OS7298', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (188, '117163400068', 'OS7299', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (189, '117163400069', 'OS7300', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (190, '117163400070', 'OS7301', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (191, '117163400071', 'OS7302', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (192, '117163400072', 'OS7303', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (193, '117163400073', 'OS7304', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (194, '117163400074', 'OS7305', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (195, '117163400075', 'OS7306', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (196, '117163400076', 'OS7307', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (197, '117163400077', 'OS7308', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (198, '117163400078', 'OS7309', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (199, '117163400079', 'OS7310', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (200, '117163400080', 'OS7311', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (201, '117163400081', 'OS7312', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (202, '117163400082', 'OS7313', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (203, '117163400083', 'OS7314', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (204, '117163400084', 'OS7315', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (9, '117000009397', 'OS7120', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (241, '117163400121', 'OS7352', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (242, '117163400122', 'OS7353', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (243, '117163400123', 'OS7354', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (244, '117163400124', 'OS7355', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (245, '117163400125', 'OS7356', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (246, '117163400126', 'OS7357', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (247, '117163400127', 'OS7358', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (248, '117163400128', 'OS7359', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (249, '117163400129', 'OS7360', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (250, '117163400130', 'OS7361', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (251, '117163400131', 'OS7362', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (252, '117163400132', 'OS7363', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (253, '117163400133', 'OS7364', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (254, '117163400134', 'OS7365', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (255, '117163400135', 'OS7366', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (256, '117163400136', 'OS7367', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (257, '117163400137', 'OS7368', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (258, '117163400138', 'OS7369', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (259, '117163400139', 'OS7370', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (260, '117163400140', 'OS7371', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (227, '117163400107', 'OS7338', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (228, '117163400108', 'OS7339', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (229, '117163400109', 'OS7340', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (230, '117163400110', 'OS7341', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (231, '117163400111', 'OS7342', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (232, '117163400112', 'OS7343', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (233, '117163400113', 'OS7344', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (234, '117163400114', 'OS7345', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (235, '117163400115', 'OS7346', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (236, '117163400116', 'OS7347', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (237, '117163400117', 'OS7348', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (238, '117163400118', 'OS7349', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (239, '117163400119', 'OS7350', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (240, '117163400120', 'OS7351', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (294, '117163400174', 'OS7405', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (295, '117163400175', 'OS7406', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (296, '117163400176', 'OS7407', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (297, '117163400177', 'OS7408', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (298, '117163400178', 'OS7409', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (299, '117163400179', 'OS7410', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (300, '117163400180', 'OS7411', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (301, '117163400181', 'OS7412', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (302, '117163400182', 'OS7413', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (303, '117163400183', 'OS7414', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (304, '117163400184', 'OS7415', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (305, '117163400185', 'OS7416', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (306, '117163400186', 'OS7417', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (307, '117163400187', 'OS7418', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (308, '117163400188', 'OS7419', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (309, '117163400189', 'OS7420', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (310, '117163400190', 'OS7421', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (311, '117163400191', 'OS7422', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (312, '117163400192', 'OS7423', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (313, '117163400193', 'OS7424', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (314, '117163400194', 'OS7425', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (315, '117163400195', 'OS7426', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (316, '117163400196', 'OS7427', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (317, '117163400197', 'OS7428', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (318, '117163400198', 'OS7429', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (1, '117000009405', 'OS7112', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (261, '117163400141', 'OS7372', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (262, '117163400142', 'OS7373', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (263, '117163400143', 'OS7374', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (264, '117163400144', 'OS7375', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (265, '117163400145', 'OS7376', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (266, '117163400146', 'OS7377', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (319, '117163400199', 'OS7430', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (320, '117163400200', 'OS7431', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (2, '117000009404', 'OS7113', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (3, '117000009401', 'OS7114', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (4, '117000009402', 'OS7115', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (5, '117000009403', 'OS7116', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (6, '117000009400', 'OS7117', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (7, '117000009398', 'OS7118', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (8, '117000009399', 'OS7119', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (10, '117000009406', 'OS7121', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (11, '117000009412', 'OS7122', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (12, '117000009413', 'OS7123', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (13, '117000009479', 'OS7124', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (14, '117000009476', 'OS7125', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (15, '117000009477', 'OS7126', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (16, '117000009475', 'OS7127', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (17, '117000009474', 'OS7128', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (18, '117000009473', 'OS7129', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (19, '117000009478', 'OS7130', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (20, '117000009414', 'OS7131', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (21, '117162902465', 'OS7132', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (22, '117162902435', 'OS7133', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (23, '117162902462', 'OS7134', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (24, '117162902433', 'OS7135', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (25, '117162902440', 'OS7136', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (26, '117162902468', 'OS7137', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (27, '117162902472', 'OS7138', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (28, '117162902474', 'OS7139', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (29, '117162902434', 'OS7140', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (30, '117162902432', 'OS7141', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (31, '117162902441', 'OS7142', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (32, '117162902443', 'OS7143', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (33, '117162902431', 'OS7144', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (34, '117162902436', 'OS7145', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (35, '117162902470', 'OS7146', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (36, '117162902457', 'OS7147', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (37, '117162902481', 'OS7148', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (38, '117162902477', 'OS7149', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (39, '117162902476', 'OS7150', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (40, '117162902478', 'OS7151', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (41, '117162902482', 'OS7152', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (321, 'PMC000064UN13', 'FA-V5', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (322, 'PMA005860UN16', 'FA-V5-0001', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (323, 'PMA005861UN16', 'FA-V5-0002', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (324, 'PMA005862UN16', 'FA-V5-0003', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (325, 'PMA005863UN16', 'FA-V5-0004', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (326, 'PMA005864UN16', 'FA-V5-0005', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (327, 'PMA005865UN16', 'FA-V5-0006', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (328, 'PMA005866UN16', 'FA-V5-0007', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (329, 'PMA005867UN16', 'FA-V5-0008', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (330, 'PMA005868UN16', 'FA-V5-0009', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (331, 'PMA005869UN16', 'FA-V5-0010', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (332, 'PMA005870UN16', 'FA-V5-0011', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (333, 'PMA005871UN16', 'FA-V5-0012', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (334, 'PMA005872UN16', 'FA-V5-0013', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (335, 'PMA005873UN16', 'FA-V5-0014', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (336, 'PMA005874UN16', 'FA-V5-0015', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (337, 'PMA005875UN16', 'FA-V5-0016', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (338, 'PMA005876UN16', 'FA-V5-0017', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (339, 'PMA005877UN16', 'FA-V5-0018', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (340, 'PMA005878UN16', 'FA-V5-0019', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (341, 'PMA005879UN16', 'FA-V5-0020', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (342, 'PMA005880UN16', 'FA-V5-0021', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (343, 'PMA005881UN16', 'FA-V5-0022', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (354, 'PMA005892UN16', 'FA-V5-0033', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (355, 'PMA005893UN16', 'FA-V5-0034', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (356, 'PMA005894UN16', 'FA-V5-0035', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (357, 'PMA005895UN16', 'FA-V5-0036', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (358, 'PMA005896UN16', 'FA-V5-0037', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (359, 'PMA005897UN16', 'FA-V5-0038', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (360, 'PMA005898UN16', 'FA-V5-0039', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (361, 'PMA005899UN16', 'FA-V5-0040', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (362, 'PMA005900UN16', 'FA-V5-0041', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (363, 'PMA005901UN16', 'FA-V5-0042', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (364, 'PMA005902UN16', 'FA-V5-0043', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (365, 'PMA005903UN16', 'FA-V5-0044', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (366, 'PMA005904UN16', 'FA-V5-0045', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (367, 'PMA005905UN16', 'FA-V5-0046', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (368, 'PMA005906UN16', 'FA-V5-0047', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (369, 'PMA005907UN16', 'FA-V5-0048', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (370, 'PMA005908UN16', 'FA-V5-0049', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (371, 'PMA005909UN16', 'FA-V5-0050', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (372, 'PMA005910UN16', 'FA-V5-0051', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (373, 'PMA005911UN16', 'FA-V5-0052', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (374, 'PMA005912UN16', 'FA-V5-0053', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (375, 'PMA005913UN16', 'FA-V5-0054', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (376, 'PMA005914UN16', 'FA-V5-0055', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (377, 'PMA005915UN16', 'FA-V5-0056', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (378, 'PMA005916UN16', 'FA-V5-0057', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (379, 'PMA005917UN16', 'FA-V5-0058', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (380, 'PMA005918UN16', 'FA-V5-0059', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (381, 'PMA005919UN16', 'FA-V5-0060', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (382, 'PMA005920UN16', 'FA-V5-0061', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (383, 'PMA005921UN16', 'FA-V5-0062', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (384, 'PMA005922UN16', 'FA-V5-0063', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (385, 'PMA005923UN16', 'FA-V5-0064', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (386, 'PMA005924UN16', 'FA-V5-0065', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (387, 'PMA005925UN16', 'FA-V5-0066', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (388, 'PMA005926UN16', 'FA-V5-0067', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (389, 'PMA005927UN16', 'FA-V5-0068', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (390, 'PMA005928UN16', 'FA-V5-0069', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (391, 'PMA005929UN16', 'FA-V5-0070', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (392, 'PMA005930UN16', 'FA-V5-0071', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (393, 'PMA005931UN16', 'FA-V5-0072', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (394, 'PMA005932UN16', 'FA-V5-0073', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (395, 'PMA005933UN16', 'FA-V5-0074', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (396, 'PMA005934UN16', 'FA-V5-0075', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (397, 'PMA005935UN16', 'FA-V5-0076', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (398, 'PMA005936UN16', 'FA-V5-0077', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (399, 'PMA005937UN16', 'FA-V5-0078', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (400, 'PMA005938UN16', 'FA-V5-0079', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (401, 'PMA005939UN16', 'FA-V5-0080', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (402, 'PMA005940UN16', 'FA-V5-0081', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (403, 'PMA005941UN16', 'FA-V5-0082', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (404, 'PMA005942UN16', 'FA-V5-0083', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (405, 'PMA005943UN16', 'FA-V5-0084', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (406, 'PMA005944UN16', 'FA-V5-0085', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (407, 'PMA005945UN16', 'FA-V5-0086', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (408, 'PMA005946UN16', 'FA-V5-0087', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (409, 'PMA005947UN16', 'FA-V5-0088', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (410, 'PMA005948UN16', 'FA-V5-0089', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (547, 'PMA006551UN16', 'FA-V5-0226', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (411, 'PMA005949UN16', 'FA-V5-0090', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (412, 'PMA005950UN16', 'FA-V5-0091', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (413, 'PMA005951UN16', 'FA-V5-0092', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (414, 'PMA005952UN16', 'FA-V5-0093', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (415, 'PMA005953UN16', 'FA-V5-0094', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (416, 'PMA005954UN16', 'FA-V5-0095', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (417, 'PMA005955UN16', 'FA-V5-0096', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (418, 'PMA005956UN16', 'FA-V5-0097', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (419, 'PMA005957UN16', 'FA-V5-0098', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (420, 'PMA005958UN16', 'FA-V5-0099', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (421, 'PMA005959UN16', 'FA-V5-0100', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (435, 'PMA006024UN16', 'FA-V5-0114', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (205, '117163400085', 'OS7316', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (206, '117163400086', 'OS7317', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (207, '117163400087', 'OS7318', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (208, '117163400088', 'OS7319', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (209, '117163400089', 'OS7320', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (210, '117163400090', 'OS7321', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (211, '117163400091', 'OS7322', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (212, '117163400092', 'OS7323', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (213, '117163400093', 'OS7324', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (214, '117163400094', 'OS7325', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (215, '117163400095', 'OS7326', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (216, '117163400096', 'OS7327', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (217, '117163400097', 'OS7328', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (218, '117163400098', 'OS7329', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (219, '117163400099', 'OS7330', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (220, '117163400100', 'OS7331', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (221, '117163400101', 'OS7332', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (222, '117163400102', 'OS7333', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (223, '117163400103', 'OS7334', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (224, '117163400104', 'OS7335', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (225, '117163400105', 'OS7336', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (226, '117163400106', 'OS7337', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (267, '117163400147', 'OS7378', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (268, '117163400148', 'OS7379', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (269, '117163400149', 'OS7380', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (270, '117163400150', 'OS7381', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (271, '117163400151', 'OS7382', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (272, '117163400152', 'OS7383', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (273, '117163400153', 'OS7384', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (274, '117163400154', 'OS7385', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (275, '117163400155', 'OS7386', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (276, '117163400156', 'OS7387', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (277, '117163400157', 'OS7388', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (278, '117163400158', 'OS7389', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (279, '117163400159', 'OS7390', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (280, '117163400160', 'OS7391', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (281, '117163400161', 'OS7392', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (282, '117163400162', 'OS7393', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (283, '117163400163', 'OS7394', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (284, '117163400164', 'OS7395', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (285, '117163400165', 'OS7396', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (286, '117163400166', 'OS7397', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (287, '117163400167', 'OS7398', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (288, '117163400168', 'OS7399', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (289, '117163400169', 'OS7400', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (290, '117163400170', 'OS7401', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (291, '117163400171', 'OS7402', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (292, '117163400172', 'OS7403', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (293, '117163400173', 'OS7404', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (436, 'PMA006025UN16', 'FA-V5-0115', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (437, 'PMA006026UN16', 'FA-V5-0116', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (438, 'PMA006027UN16', 'FA-V5-0117', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (580, 'PMA006584UN16', 'FA-V5-0259', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (581, 'PMA006585UN16', 'FA-V5-0260', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (582, 'PMA006586UN16', 'FA-V5-0261', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (583, 'PMA006587UN16', 'FA-V5-0262', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (584, 'PMA006588UN16', 'FA-V5-0263', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (585, 'PMA006589UN16', 'FA-V5-0264', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (586, 'PMA006590UN16', 'FA-V5-0265', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (587, 'PMA006591UN16', 'FA-V5-0266', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (588, 'PMA006592UN16', 'FA-V5-0267', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (589, 'PMA006593UN16', 'FA-V5-0268', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (590, 'PMA006594UN16', 'FA-V5-0269', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (591, 'PMA006595UN16', 'FA-V5-0270', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (592, 'PMA006596UN16', 'FA-V5-0271', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (593, 'PMA006597UN16', 'FA-V5-0272', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (594, 'PMA006598UN16', 'FA-V5-0273', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (595, 'PMA006599UN16', 'FA-V5-0274', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (596, 'PMA006600UN16', 'FA-V5-0275', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (597, 'PMA006601UN16', 'FA-V5-0276', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (598, 'PMA006602UN16', 'FA-V5-0277', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (599, 'PMA006603UN16', 'FA-V5-0278', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (600, 'PMA006604UN16', 'FA-V5-0279', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (601, 'PMA006605UN16', 'FA-V5-0280', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (439, 'PMA006028UN16', 'FA-V5-0118', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (440, 'PMA006029UN16', 'FA-V5-0119', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (441, 'PMA006030UN16', 'FA-V5-0120', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (442, 'PMA006031UN16', 'FA-V5-0121', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (443, 'PMA006032UN16', 'FA-V5-0122', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (444, 'PMA006033UN16', 'FA-V5-0123', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (445, 'PMA006034UN16', 'FA-V5-0124', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (446, 'PMA006035UN16', 'FA-V5-0125', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (447, 'PMA006036UN16', 'FA-V5-0126', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (448, 'PMA006037UN16', 'FA-V5-0127', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (449, 'PMA006038UN16', 'FA-V5-0128', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (450, 'PMA006039UN16', 'FA-V5-0129', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (451, 'PMA006040UN16', 'FA-V5-0130', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (452, 'PMA006041UN16', 'FA-V5-0131', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (453, 'PMA006042UN16', 'FA-V5-0132', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (454, 'PMA006043UN16', 'FA-V5-0133', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (455, 'PMA006044UN16', 'FA-V5-0134', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (456, 'PMA006045UN16', 'FA-V5-0135', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (457, 'PMA006046UN16', 'FA-V5-0136', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (458, 'PMA006047UN16', 'FA-V5-0137', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (459, 'PMA006048UN16', 'FA-V5-0138', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (460, 'PMA006049UN16', 'FA-V5-0139', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (461, 'PMA006050UN16', 'FA-V5-0140', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (462, 'PMA006051UN16', 'FA-V5-0141', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (463, 'PMA006052UN16', 'FA-V5-0142', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (464, 'PMA006053UN16', 'FA-V5-0143', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (465, 'PMA006054UN16', 'FA-V5-0144', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (466, 'PMA006055UN16', 'FA-V5-0145', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (467, 'PMA006056UN16', 'FA-V5-0146', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (468, 'PMA006057UN16', 'FA-V5-0147', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (469, 'PMA006058UN16', 'FA-V5-0148', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (470, 'PMA006059UN16', 'FA-V5-0149', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (471, 'PMA006060UN16', 'FA-V5-0150', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (472, 'PMA006061UN16', 'FA-V5-0151', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (473, 'PMA006062UN16', 'FA-V5-0152', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (474, 'PMA006063UN16', 'FA-V5-0153', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (475, 'PMA006064UN16', 'FA-V5-0154', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (476, 'PMA006065UN16', 'FA-V5-0155', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (477, 'PMA006066UN16', 'FA-V5-0156', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (478, 'PMA006067UN16', 'FA-V5-0157', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (479, 'PMA006068UN16', 'FA-V5-0158', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (480, 'PMA006069UN16', 'FA-V5-0159', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (481, 'PMA006070UN16', 'FA-V5-0160', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (482, 'PMA006071UN16', 'FA-V5-0161', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (483, 'PMA006072UN16', 'FA-V5-0162', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (484, 'PMA006073UN16', 'FA-V5-0163', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (485, 'PMA006074UN16', 'FA-V5-0164', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (486, 'PMA006075UN16', 'FA-V5-0165', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (487, 'PMA006076UN16', 'FA-V5-0166', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (488, 'PMA006077UN16', 'FA-V5-0167', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (489, 'PMA006078UN16', 'FA-V5-0168', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (490, 'PMA006079UN16', 'FA-V5-0169', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (491, 'PMA006080UN16', 'FA-V5-0170', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (492, 'PMA006081UN16', 'FA-V5-0171', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (493, 'PMA006082UN16', 'FA-V5-0172', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (494, 'PMA006083UN16', 'FA-V5-0173', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (495, 'PMA006084UN16', 'FA-V5-0174', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (496, 'PMA006085UN16', 'FA-V5-0175', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (497, 'PMA006086UN16', 'FA-V5-0176', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (498, 'PMA006087UN16', 'FA-V5-0177', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (499, 'PMA006088UN16', 'FA-V5-0178', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (422, 'PMA006011UN16', 'FA-V5-0101', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (423, 'PMA006012UN16', 'FA-V5-0102', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (424, 'PMA006013UN16', 'FA-V5-0103', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (425, 'PMA006014UN16', 'FA-V5-0104', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (426, 'PMA006015UN16', 'FA-V5-0105', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (427, 'PMA006016UN16', 'FA-V5-0106', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (428, 'PMA006017UN16', 'FA-V5-0107', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (429, 'PMA006018UN16', 'FA-V5-0108', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (430, 'PMA006019UN16', 'FA-V5-0109', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (431, 'PMA006020UN16', 'FA-V5-0110', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (432, 'PMA006021UN16', 'FA-V5-0111', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (433, 'PMA006022UN16', 'FA-V5-0112', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (434, 'PMA006023UN16', 'FA-V5-0113', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (566, 'PMA006570UN16', 'FA-V5-0245', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (567, 'PMA006571UN16', 'FA-V5-0246', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (568, 'PMA006572UN16', 'FA-V5-0247', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (569, 'PMA006573UN16', 'FA-V5-0248', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (570, 'PMA006574UN16', 'FA-V5-0249', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (571, 'PMA006575UN16', 'FA-V5-0250', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (572, 'PMA006576UN16', 'FA-V5-0251', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (573, 'PMA006577UN16', 'FA-V5-0252', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (574, 'PMA006578UN16', 'FA-V5-0253', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (575, 'PMA006579UN16', 'FA-V5-0254', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (576, 'PMA006580UN16', 'FA-V5-0255', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (577, 'PMA006581UN16', 'FA-V5-0256', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (578, 'PMA006582UN16', 'FA-V5-0257', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (579, 'PMA006583UN16', 'FA-V5-0258', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (602, 'PMA006606UN16', 'FA-V5-0281', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (603, 'PMA006607UN16', 'FA-V5-0282', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (604, 'PMA006608UN16', 'FA-V5-0283', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (605, 'PMA006609UN16', 'FA-V5-0284', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (606, 'PMA006610UN16', 'FA-V5-0285', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (607, 'PMA006611UN16', 'FA-V5-0286', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (608, 'PMA006612UN16', 'FA-V5-0287', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (609, 'PMA006613UN16', 'FA-V5-0288', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (610, 'PMA006614UN16', 'FA-V5-0289', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (611, 'PMA006615UN16', 'FA-V5-0290', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (612, 'PMA006616UN16', 'FA-V5-0291', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (613, 'PMA006617UN16', 'FA-V5-0292', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (614, 'PMA006618UN16', 'FA-V5-0293', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (615, 'PMA006619UN16', 'FA-V5-0294', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (616, 'PMA006620UN16', 'FA-V5-0295', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (617, 'PMA006621UN16', 'FA-V5-0296', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (618, 'PMA006622UN16', 'FA-V5-0297', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (619, 'PMA006623UN16', 'FA-V5-0298', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (620, 'PMA006624UN16', 'FA-V5-0299', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (621, 'PMA006625UN16', 'FA-V5-0300', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (42, '117162902480', 'OS7153', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (43, '117162902484', 'OS7154', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (44, '117162902487', 'OS7155', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (45, '117162902489', 'OS7156', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (46, '117162902479', 'OS7157', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (47, '117162902490', 'OS7158', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (48, '117162902483', 'OS7159', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (49, '117162902486', 'OS7160', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (50, '117162902458', 'OS7161', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (51, '117162902500', 'OS7162', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (52, '117162902448', 'OS7163', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (53, '117162902449', 'OS7164', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (54, '117162902450', 'OS7165', 5, 1);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (500, 'PMA006089UN16', 'FA-V5-0179', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (501, 'PMA006090UN16', 'FA-V5-0180', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (502, 'PMA006091UN16', 'FA-V5-0181', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (503, 'PMA006092UN16', 'FA-V5-0182', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (504, 'PMA006093UN16', 'FA-V5-0183', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (505, 'PMA006094UN16', 'FA-V5-0184', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (506, 'PMA006095UN16', 'FA-V5-0185', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (507, 'PMA006096UN16', 'FA-V5-0186', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (508, 'PMA006097UN16', 'FA-V5-0187', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (509, 'PMA006098UN16', 'FA-V5-0188', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (510, 'PMA006099UN16', 'FA-V5-0189', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (511, 'PMA006100UN16', 'FA-V5-0190', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (512, 'PMA006101UN16', 'FA-V5-0191', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (513, 'PMA006102UN16', 'FA-V5-0192', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (514, 'PMA006103UN16', 'FA-V5-0193', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (515, 'PMA006104UN16', 'FA-V5-0194', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (516, 'PMA006105UN16', 'FA-V5-0195', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (517, 'PMA006106UN16', 'FA-V5-0196', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (518, 'PMA006107UN16', 'FA-V5-0197', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (519, 'PMA006108UN16', 'FA-V5-0198', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (520, 'PMA006109UN16', 'FA-V5-0199', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (521, 'PMA006110UN16', 'FA-V5-0200', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (522, 'PMA006526UN16', 'FA-V5-0201', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (523, 'PMA006527UN16', 'FA-V5-0202', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (524, 'PMA006528UN16', 'FA-V5-0203', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (525, 'PMA006529UN16', 'FA-V5-0204', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (526, 'PMA006530UN16', 'FA-V5-0205', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (527, 'PMA006531UN16', 'FA-V5-0206', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (528, 'PMA006532UN16', 'FA-V5-0207', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (529, 'PMA006533UN16', 'FA-V5-0208', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (530, 'PMA006534UN16', 'FA-V5-0209', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (531, 'PMA006535UN16', 'FA-V5-0210', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (532, 'PMA006536UN16', 'FA-V5-0211', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (533, 'PMA006537UN16', 'FA-V5-0212', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (534, 'PMA006538UN16', 'FA-V5-0213', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (535, 'PMA006539UN16', 'FA-V5-0214', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (536, 'PMA006540UN16', 'FA-V5-0215', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (537, 'PMA006541UN16', 'FA-V5-0216', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (538, 'PMA006542UN16', 'FA-V5-0217', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (539, 'PMA006543UN16', 'FA-V5-0218', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (540, 'PMA006544UN16', 'FA-V5-0219', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (541, 'PMA006545UN16', 'FA-V5-0220', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (542, 'PMA006546UN16', 'FA-V5-0221', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (543, 'PMA006547UN16', 'FA-V5-0222', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (544, 'PMA006548UN16', 'FA-V5-0223', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (545, 'PMA006549UN16', 'FA-V5-0224', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (546, 'PMA006550UN16', 'FA-V5-0225', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (548, 'PMA006552UN16', 'FA-V5-0227', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (549, 'PMA006553UN16', 'FA-V5-0228', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (550, 'PMA006554UN16', 'FA-V5-0229', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (551, 'PMA006555UN16', 'FA-V5-0230', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (552, 'PMA006556UN16', 'FA-V5-0231', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (553, 'PMA006557UN16', 'FA-V5-0232', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (554, 'PMA006558UN16', 'FA-V5-0233', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (555, 'PMA006559UN16', 'FA-V5-0234', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (556, 'PMA006560UN16', 'FA-V5-0235', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (557, 'PMA006561UN16', 'FA-V5-0236', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (558, 'PMA006562UN16', 'FA-V5-0237', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (559, 'PMA006563UN16', 'FA-V5-0238', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (560, 'PMA006564UN16', 'FA-V5-0239', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (561, 'PMA006565UN16', 'FA-V5-0240', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (562, 'PMA006566UN16', 'FA-V5-0241', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (563, 'PMA006567UN16', 'FA-V5-0242', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (564, 'PMA006568UN16', 'FA-V5-0243', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (344, 'PMA005882UN16', 'FA-V5-0023', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (345, 'PMA005883UN16', 'FA-V5-0024', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (346, 'PMA005884UN16', 'FA-V5-0025', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (347, 'PMA005885UN16', 'FA-V5-0026', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (348, 'PMA005886UN16', 'FA-V5-0027', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (349, 'PMA005887UN16', 'FA-V5-0028', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (350, 'PMA005888UN16', 'FA-V5-0029', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (351, 'PMA005889UN16', 'FA-V5-0030', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (352, 'PMA005890UN16', 'FA-V5-0031', 6, 2);
INSERT INTO public.devices (id, sn, nav_num, model_id, device_type_id) VALUES (565, 'PMA006569UN16', 'FA-V5-0244', 6, 2);


                                                                                                                                                                                             3052.dat                                                                                            0000600 0004000 0002000 00000152242 13367436530 0014263 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (373, 373, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (9, 9, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (466, 466, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (1, 1, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (46, 46, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (47, 47, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (48, 48, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (49, 49, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (50, 50, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (51, 51, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (52, 52, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (53, 53, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (54, 54, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (55, 55, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (57, 57, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (58, 58, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (59, 59, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (60, 60, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (61, 61, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (62, 62, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (63, 63, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (64, 64, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (65, 65, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (66, 66, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (67, 67, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (68, 68, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (69, 69, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (70, 70, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (71, 71, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (72, 72, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (73, 73, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (74, 74, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (75, 75, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (76, 76, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (77, 77, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (78, 78, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (79, 79, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (80, 80, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (81, 81, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (82, 82, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (83, 83, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (84, 84, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (85, 85, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (86, 86, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (87, 87, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (88, 88, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (89, 89, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (90, 90, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (91, 91, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (92, 92, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (93, 93, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (94, 94, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (95, 95, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (96, 96, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (97, 97, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (98, 98, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (99, 99, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (100, 100, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (565, 565, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (566, 566, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (567, 567, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (568, 568, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (569, 569, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (570, 570, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (571, 571, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (572, 572, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (573, 573, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (574, 574, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (102, 102, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (103, 103, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (104, 104, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (186, 186, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (152, 152, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (153, 153, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (154, 154, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (155, 155, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (156, 156, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (157, 157, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (158, 158, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (159, 159, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (160, 160, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (161, 161, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (162, 162, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (163, 163, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (164, 164, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (165, 165, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (166, 166, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (167, 167, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (168, 168, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (169, 169, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (170, 170, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (171, 171, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (172, 172, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (173, 173, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (174, 174, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (175, 175, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (176, 176, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (177, 177, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (178, 178, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (179, 179, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (180, 180, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (181, 181, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (182, 182, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (183, 183, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (184, 184, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (185, 185, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (187, 187, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (188, 188, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (189, 189, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (190, 190, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (191, 191, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (192, 192, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (193, 193, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (194, 194, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (195, 195, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (196, 196, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (197, 197, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (198, 198, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (199, 199, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (200, 200, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (201, 201, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (202, 202, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (203, 203, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (204, 204, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (205, 205, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (206, 206, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (207, 207, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (208, 208, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (209, 209, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (210, 210, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (211, 211, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (212, 212, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (213, 213, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (214, 214, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (215, 215, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (216, 216, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (217, 217, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (218, 218, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (219, 219, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (220, 220, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (221, 221, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (222, 222, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (223, 223, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (224, 224, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (225, 225, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (226, 226, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (227, 227, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (228, 228, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (229, 229, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (230, 230, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (233, 233, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (234, 234, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (235, 235, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (236, 236, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (237, 237, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (238, 238, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (239, 239, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (240, 240, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (241, 241, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (242, 242, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (243, 243, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (244, 244, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (245, 245, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (246, 246, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (247, 247, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (248, 248, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (249, 249, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (250, 250, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (251, 251, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (252, 252, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (253, 253, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (254, 254, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (255, 255, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (256, 256, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (257, 257, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (258, 258, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (259, 259, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (260, 260, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (261, 261, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (262, 262, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (263, 263, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (264, 264, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (265, 265, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (266, 266, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (267, 267, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (268, 268, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (269, 269, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (270, 270, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (271, 271, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (272, 272, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (273, 273, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (274, 274, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (275, 275, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (276, 276, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (277, 277, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (278, 278, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (279, 279, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (280, 280, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (281, 281, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (282, 282, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (283, 283, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (284, 284, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (286, 286, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (287, 287, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (288, 288, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (289, 289, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (290, 290, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (291, 291, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (292, 292, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (293, 293, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (294, 294, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (295, 295, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (296, 296, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (297, 297, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (298, 298, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (299, 299, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (300, 300, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (301, 301, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (302, 302, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (303, 303, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (304, 304, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (305, 305, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (306, 306, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (307, 307, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (308, 308, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (309, 309, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (310, 310, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (311, 311, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (312, 312, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (313, 313, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (7, 7, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (314, 314, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (315, 315, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (316, 316, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (317, 317, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (318, 318, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (319, 319, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (320, 320, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (321, 321, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (322, 322, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (323, 323, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (324, 324, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (325, 325, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (326, 326, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (327, 327, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (328, 328, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (329, 329, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (330, 330, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (331, 331, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (332, 332, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (333, 333, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (334, 334, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (335, 335, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (336, 336, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (337, 337, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (371, 371, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (339, 339, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (340, 340, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (341, 341, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (343, 343, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (344, 344, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (345, 345, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (346, 346, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (347, 347, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (348, 348, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (349, 349, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (350, 350, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (351, 351, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (352, 352, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (353, 353, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (354, 354, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (355, 355, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (356, 356, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (357, 357, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (358, 358, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (359, 359, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (360, 360, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (361, 361, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (362, 362, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (363, 363, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (364, 364, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (365, 365, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (366, 366, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (367, 367, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (368, 368, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (369, 369, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (370, 370, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (372, 372, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (374, 374, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (375, 375, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (376, 376, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (377, 377, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (378, 378, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (379, 379, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (380, 380, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (381, 381, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (384, 384, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (385, 385, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (386, 386, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (387, 387, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (388, 388, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (389, 389, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (390, 390, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (391, 391, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (392, 392, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (393, 393, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (394, 394, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (395, 395, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (396, 396, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (397, 397, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (398, 398, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (399, 399, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (400, 400, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (401, 401, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (402, 402, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (403, 403, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (404, 404, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (405, 405, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (406, 406, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (407, 407, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (408, 408, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (409, 409, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (410, 410, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (411, 411, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (412, 412, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (413, 413, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (414, 414, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (415, 415, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (416, 416, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (418, 418, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (419, 419, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (512, 512, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (513, 513, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (514, 514, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (515, 515, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (516, 516, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (517, 517, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (518, 518, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (519, 519, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (520, 520, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (521, 521, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (522, 522, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (523, 523, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (524, 524, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (525, 525, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (526, 526, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (527, 527, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (528, 528, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (529, 529, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (530, 530, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (531, 531, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (532, 532, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (533, 533, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (534, 534, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (535, 535, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (536, 536, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (537, 537, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (538, 538, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (558, 558, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (559, 559, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (560, 560, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (561, 561, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (562, 562, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (563, 563, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (564, 564, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (2, 2, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (3, 3, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (4, 4, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (5, 5, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (6, 6, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (10, 10, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (11, 11, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (12, 12, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (13, 13, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (14, 14, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (15, 15, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (16, 16, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (17, 17, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (18, 18, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (19, 19, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (20, 20, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (21, 21, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (22, 22, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (23, 23, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (24, 24, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (26, 26, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (27, 27, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (28, 28, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (29, 29, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (30, 30, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (31, 31, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (32, 32, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (33, 33, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (34, 34, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (35, 35, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (36, 36, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (37, 37, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (38, 38, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (39, 39, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (40, 40, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (41, 41, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (42, 42, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (43, 43, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (44, 44, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (45, 45, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (101, 101, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (285, 285, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (342, 342, 3);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (417, 417, 3);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (25, 25, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (556, 556, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (557, 557, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (105, 105, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (106, 106, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (107, 107, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (56, 56, 3);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (108, 108, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (109, 109, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (110, 110, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (111, 111, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (112, 112, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (113, 113, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (114, 114, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (115, 115, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (116, 116, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (117, 117, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (118, 118, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (119, 119, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (120, 120, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (121, 121, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (122, 122, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (123, 123, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (124, 124, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (125, 125, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (126, 126, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (127, 127, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (128, 128, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (129, 129, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (130, 130, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (131, 131, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (132, 132, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (133, 133, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (134, 134, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (135, 135, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (136, 136, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (137, 137, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (138, 138, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (139, 139, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (140, 140, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (141, 141, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (142, 142, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (143, 143, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (144, 144, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (145, 145, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (146, 146, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (147, 147, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (148, 148, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (149, 149, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (150, 150, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (151, 151, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (231, 231, 3);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (232, 232, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (420, 420, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (421, 421, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (422, 422, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (423, 423, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (424, 424, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (425, 425, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (426, 426, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (427, 427, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (428, 428, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (429, 429, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (430, 430, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (431, 431, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (432, 432, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (433, 433, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (434, 434, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (435, 435, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (436, 436, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (437, 437, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (438, 438, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (439, 439, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (440, 440, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (441, 441, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (442, 442, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (443, 443, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (444, 444, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (445, 445, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (446, 446, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (447, 447, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (448, 448, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (449, 449, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (450, 450, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (451, 451, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (452, 452, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (453, 453, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (454, 454, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (455, 455, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (456, 456, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (457, 457, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (458, 458, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (459, 459, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (460, 460, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (461, 461, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (462, 462, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (463, 463, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (464, 464, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (465, 465, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (467, 467, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (468, 468, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (469, 469, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (470, 470, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (471, 471, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (472, 472, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (473, 473, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (511, 511, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (474, 474, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (475, 475, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (476, 476, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (477, 477, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (478, 478, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (479, 479, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (480, 480, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (481, 481, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (482, 482, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (483, 483, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (484, 484, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (485, 485, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (486, 486, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (487, 487, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (488, 488, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (489, 489, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (490, 490, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (491, 491, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (492, 492, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (493, 493, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (494, 494, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (495, 495, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (496, 496, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (497, 497, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (498, 498, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (499, 499, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (500, 500, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (501, 501, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (502, 502, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (503, 503, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (504, 504, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (505, 505, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (506, 506, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (507, 507, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (508, 508, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (509, 509, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (510, 510, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (539, 539, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (540, 540, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (541, 541, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (542, 542, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (543, 543, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (544, 544, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (545, 545, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (546, 546, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (547, 547, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (548, 548, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (549, 549, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (550, 550, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (551, 551, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (552, 552, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (553, 553, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (554, 554, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (555, 555, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (575, 575, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (576, 576, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (577, 577, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (578, 578, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (579, 579, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (580, 580, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (581, 581, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (582, 582, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (583, 583, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (584, 584, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (585, 585, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (586, 586, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (587, 587, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (588, 588, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (589, 589, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (590, 590, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (591, 591, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (592, 592, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (593, 593, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (594, 594, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (595, 595, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (596, 596, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (597, 597, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (598, 598, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (599, 599, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (600, 600, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (601, 601, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (602, 602, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (603, 603, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (604, 604, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (605, 605, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (606, 606, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (607, 607, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (608, 608, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (609, 609, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (610, 610, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (611, 611, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (612, 612, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (613, 613, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (614, 614, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (615, 615, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (616, 616, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (617, 617, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (618, 618, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (619, 619, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (620, 620, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (621, 621, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (382, 382, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (8, 8, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (383, 383, 1);
INSERT INTO public.devices_locations (id, device_id, location_id) VALUES (338, 338, 1);


                                                                                                                                                                                                                                                                                                                                                              3079.dat                                                                                            0000600 0004000 0002000 00000116223 13367436530 0014273 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (1, 1, 2, '2018-11-02 12:12:49.299651');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (2, 2, 2, '2018-11-02 12:12:49.348654');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (3, 3, 2, '2018-11-02 12:12:49.350654');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (4, 4, 2, '2018-11-02 12:12:49.350654');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (5, 5, 2, '2018-11-02 12:12:49.352654');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (6, 6, 2, '2018-11-02 12:12:49.352654');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (7, 7, 2, '2018-11-02 12:12:49.353654');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (8, 8, 2, '2018-11-02 12:12:49.371655');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (9, 9, 2, '2018-11-02 12:12:49.372656');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (10, 10, 2, '2018-11-02 12:12:49.373656');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (11, 11, 2, '2018-11-02 12:12:49.374656');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (12, 12, 2, '2018-11-02 12:12:49.375656');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (13, 13, 2, '2018-11-02 12:12:49.376656');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (14, 14, 2, '2018-11-02 12:12:49.377656');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (15, 15, 2, '2018-11-02 12:12:49.378656');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (16, 16, 2, '2018-11-02 12:12:49.379656');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (17, 17, 2, '2018-11-02 12:12:49.380656');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (18, 18, 2, '2018-11-02 12:12:49.381656');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (19, 19, 2, '2018-11-02 12:12:49.382656');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (20, 20, 2, '2018-11-02 12:12:49.383656');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (21, 21, 2, '2018-11-02 12:12:49.384656');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (22, 22, 2, '2018-11-02 12:12:49.385656');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (23, 23, 2, '2018-11-02 12:12:49.385656');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (24, 24, 2, '2018-11-02 12:12:49.387656');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (25, 25, 2, '2018-11-02 12:12:49.388656');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (26, 26, 2, '2018-11-02 12:12:49.388656');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (27, 27, 2, '2018-11-02 12:12:49.389656');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (28, 28, 2, '2018-11-02 12:12:49.390657');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (29, 29, 2, '2018-11-02 12:12:49.391657');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (30, 30, 2, '2018-11-02 12:12:49.392657');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (31, 31, 2, '2018-11-02 12:12:49.393657');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (32, 32, 2, '2018-11-02 12:12:49.394657');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (33, 33, 2, '2018-11-02 12:12:49.396657');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (34, 34, 2, '2018-11-02 12:12:49.397657');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (35, 35, 2, '2018-11-02 12:12:49.420658');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (36, 36, 2, '2018-11-02 12:12:49.421658');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (37, 37, 2, '2018-11-02 12:12:49.421658');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (38, 38, 2, '2018-11-02 12:12:49.422658');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (39, 39, 2, '2018-11-02 12:12:49.423658');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (40, 40, 2, '2018-11-02 12:12:49.424658');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (41, 41, 2, '2018-11-02 12:12:49.425659');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (42, 42, 2, '2018-11-02 12:12:49.426659');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (43, 43, 2, '2018-11-02 12:12:49.428659');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (44, 44, 2, '2018-11-02 12:12:49.431659');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (45, 45, 2, '2018-11-02 12:12:49.432659');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (46, 46, 2, '2018-11-02 12:12:49.433659');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (47, 47, 2, '2018-11-02 12:12:49.434659');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (48, 48, 2, '2018-11-02 12:12:49.435659');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (49, 49, 2, '2018-11-02 12:12:49.436659');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (50, 50, 2, '2018-11-02 12:12:49.437659');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (51, 51, 2, '2018-11-02 12:12:49.437659');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (52, 52, 2, '2018-11-02 12:12:49.438659');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (53, 53, 2, '2018-11-02 12:12:49.439659');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (54, 54, 2, '2018-11-02 12:12:49.440659');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (55, 55, 2, '2018-11-02 12:12:49.441659');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (56, 56, 2, '2018-11-02 12:12:49.45566');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (57, 57, 2, '2018-11-02 12:12:49.45666');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (58, 58, 2, '2018-11-02 12:12:49.45766');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (59, 59, 2, '2018-11-02 12:12:49.45866');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (60, 60, 2, '2018-11-02 12:12:49.45966');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (61, 61, 2, '2018-11-02 12:12:49.45966');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (62, 62, 2, '2018-11-02 12:12:49.460661');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (63, 63, 2, '2018-11-02 12:12:49.462661');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (64, 64, 2, '2018-11-02 12:12:49.463661');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (65, 65, 2, '2018-11-02 12:12:49.464661');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (66, 66, 2, '2018-11-02 12:12:49.465661');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (67, 67, 2, '2018-11-02 12:12:49.466661');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (68, 68, 2, '2018-11-02 12:12:49.467661');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (69, 69, 2, '2018-11-02 12:12:49.469661');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (70, 70, 2, '2018-11-02 12:12:49.470661');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (71, 71, 2, '2018-11-02 12:12:49.471661');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (72, 72, 2, '2018-11-02 12:12:49.472661');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (73, 73, 2, '2018-11-02 12:12:49.473661');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (74, 74, 2, '2018-11-02 12:12:49.473661');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (75, 75, 2, '2018-11-02 12:12:49.474661');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (76, 76, 2, '2018-11-02 12:12:49.475661');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (77, 77, 2, '2018-11-02 12:12:49.476661');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (78, 78, 2, '2018-11-02 12:12:49.477662');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (79, 79, 2, '2018-11-02 12:12:49.479662');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (80, 80, 2, '2018-11-02 12:12:49.480662');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (81, 81, 2, '2018-11-02 12:12:49.481662');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (82, 82, 2, '2018-11-02 12:12:49.482662');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (83, 83, 2, '2018-11-02 12:12:49.483662');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (84, 84, 2, '2018-11-02 12:12:49.483662');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (85, 85, 2, '2018-11-02 12:12:49.484662');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (86, 86, 2, '2018-11-02 12:12:49.485662');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (87, 87, 2, '2018-11-02 12:12:49.486662');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (88, 88, 2, '2018-11-02 12:12:49.487662');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (89, 89, 2, '2018-11-02 12:12:49.488662');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (90, 90, 2, '2018-11-02 12:12:49.489662');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (91, 91, 2, '2018-11-02 12:12:49.490662');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (92, 92, 2, '2018-11-02 12:12:49.491662');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (93, 93, 2, '2018-11-02 12:12:49.491662');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (94, 94, 2, '2018-11-02 12:12:49.492662');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (95, 95, 2, '2018-11-02 12:12:49.493662');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (96, 96, 2, '2018-11-02 12:12:49.494662');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (97, 97, 2, '2018-11-02 12:12:49.496663');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (98, 98, 2, '2018-11-02 12:12:49.497663');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (99, 99, 2, '2018-11-02 12:12:49.498663');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (100, 100, 2, '2018-11-02 12:12:49.499663');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (101, 101, 2, '2018-11-02 12:12:49.500663');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (102, 102, 2, '2018-11-02 12:12:49.501663');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (103, 103, 2, '2018-11-02 12:12:49.502663');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (104, 104, 2, '2018-11-02 12:12:49.504663');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (105, 105, 2, '2018-11-02 12:12:49.505663');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (106, 106, 2, '2018-11-02 12:12:49.505663');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (107, 107, 2, '2018-11-02 12:12:49.506663');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (108, 108, 2, '2018-11-02 12:12:49.507663');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (109, 109, 2, '2018-11-02 12:12:49.508663');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (110, 110, 2, '2018-11-02 12:12:49.509663');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (111, 111, 2, '2018-11-02 12:12:49.510663');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (112, 112, 2, '2018-11-02 12:12:49.511663');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (113, 113, 2, '2018-11-02 12:12:49.513664');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (114, 114, 2, '2018-11-02 12:12:49.514664');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (115, 115, 2, '2018-11-02 12:12:49.515664');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (116, 116, 2, '2018-11-02 12:12:49.516664');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (117, 117, 2, '2018-11-02 12:12:49.517664');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (118, 118, 2, '2018-11-02 12:12:49.518664');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (119, 119, 2, '2018-11-02 12:12:49.519664');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (120, 120, 2, '2018-11-02 12:12:49.520664');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (121, 121, 2, '2018-11-02 12:12:49.522664');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (122, 122, 2, '2018-11-02 12:12:49.523664');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (123, 123, 2, '2018-11-02 12:12:49.524664');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (124, 124, 2, '2018-11-02 12:12:49.527664');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (125, 125, 2, '2018-11-02 12:12:49.530665');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (126, 126, 2, '2018-11-02 12:12:49.531665');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (127, 127, 2, '2018-11-02 12:12:49.532665');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (128, 128, 2, '2018-11-02 12:12:49.533665');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (129, 129, 2, '2018-11-02 12:12:49.534665');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (130, 130, 2, '2018-11-02 12:12:49.535665');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (131, 131, 2, '2018-11-02 12:12:49.537665');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (132, 132, 2, '2018-11-02 12:12:49.538665');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (133, 133, 2, '2018-11-02 12:12:49.539665');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (134, 134, 2, '2018-11-02 12:12:49.540665');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (135, 135, 2, '2018-11-02 12:12:49.541665');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (136, 136, 2, '2018-11-02 12:12:49.542665');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (137, 137, 2, '2018-11-02 12:12:49.542665');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (138, 138, 2, '2018-11-02 12:12:49.543665');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (139, 139, 2, '2018-11-02 12:12:49.544665');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (140, 140, 2, '2018-11-02 12:12:49.547666');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (141, 141, 2, '2018-11-02 12:12:49.549666');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (142, 142, 2, '2018-11-02 12:12:49.550666');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (143, 143, 2, '2018-11-02 12:12:49.551666');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (144, 144, 2, '2018-11-02 12:12:49.552666');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (145, 145, 2, '2018-11-02 12:12:49.553666');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (146, 146, 2, '2018-11-02 12:12:49.554666');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (147, 147, 2, '2018-11-02 12:12:49.555666');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (148, 148, 2, '2018-11-02 12:12:49.556666');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (149, 149, 2, '2018-11-02 12:12:49.557666');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (150, 150, 2, '2018-11-02 12:12:49.558666');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (151, 151, 2, '2018-11-02 12:12:49.559666');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (152, 152, 2, '2018-11-02 12:12:49.560666');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (153, 153, 2, '2018-11-02 12:12:49.560666');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (154, 154, 2, '2018-11-02 12:12:49.561666');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (155, 155, 2, '2018-11-02 12:12:49.563666');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (156, 156, 2, '2018-11-02 12:12:49.564666');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (157, 157, 2, '2018-11-02 12:12:49.565667');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (158, 158, 2, '2018-11-02 12:12:49.566667');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (159, 159, 2, '2018-11-02 12:12:49.569667');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (160, 160, 2, '2018-11-02 12:12:49.570667');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (161, 161, 2, '2018-11-02 12:12:49.571667');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (162, 162, 2, '2018-11-02 12:12:49.572667');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (163, 163, 2, '2018-11-02 12:12:49.573667');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (164, 164, 2, '2018-11-02 12:12:49.574667');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (165, 165, 2, '2018-11-02 12:12:49.575667');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (166, 166, 2, '2018-11-02 12:12:49.576667');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (167, 167, 2, '2018-11-02 12:12:49.576667');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (168, 168, 2, '2018-11-02 12:12:49.577667');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (169, 169, 2, '2018-11-02 12:12:49.580667');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (170, 170, 2, '2018-11-02 12:12:49.581667');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (171, 171, 2, '2018-11-02 12:12:49.583668');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (172, 172, 2, '2018-11-02 12:12:49.584668');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (173, 173, 2, '2018-11-02 12:12:49.585668');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (174, 174, 2, '2018-11-02 12:12:49.586668');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (175, 175, 2, '2018-11-02 12:12:49.587668');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (176, 176, 2, '2018-11-02 12:12:49.588668');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (177, 177, 2, '2018-11-02 12:12:49.589668');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (178, 178, 2, '2018-11-02 12:12:49.589668');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (179, 179, 2, '2018-11-02 12:12:49.590668');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (180, 180, 2, '2018-11-02 12:12:49.591668');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (181, 181, 2, '2018-11-02 12:12:49.592668');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (182, 182, 2, '2018-11-02 12:12:49.593668');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (183, 183, 2, '2018-11-02 12:12:49.594668');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (184, 184, 2, '2018-11-02 12:12:49.596668');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (185, 185, 2, '2018-11-02 12:12:49.597668');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (186, 186, 2, '2018-11-02 12:12:49.598668');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (187, 187, 2, '2018-11-02 12:12:49.599668');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (188, 188, 2, '2018-11-02 12:12:49.600669');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (189, 189, 2, '2018-11-02 12:12:49.601669');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (190, 190, 2, '2018-11-02 12:12:49.602669');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (191, 191, 2, '2018-11-02 12:12:49.603669');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (192, 192, 2, '2018-11-02 12:12:49.604669');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (193, 193, 2, '2018-11-02 12:12:49.605669');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (194, 194, 2, '2018-11-02 12:12:49.606669');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (195, 195, 2, '2018-11-02 12:12:49.607669');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (196, 196, 2, '2018-11-02 12:12:49.608669');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (197, 197, 2, '2018-11-02 12:12:49.609669');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (198, 198, 2, '2018-11-02 12:12:49.610669');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (199, 199, 2, '2018-11-02 12:12:49.611669');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (200, 200, 2, '2018-11-02 12:12:49.613669');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (201, 201, 2, '2018-11-02 12:12:49.614669');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (202, 202, 2, '2018-11-02 12:12:49.615669');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (203, 203, 2, '2018-11-02 12:12:49.616669');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (204, 204, 2, '2018-11-02 12:12:49.61767');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (205, 205, 2, '2018-11-02 12:12:49.61867');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (206, 206, 2, '2018-11-02 12:12:49.62067');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (207, 207, 2, '2018-11-02 12:12:49.62067');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (208, 208, 2, '2018-11-02 12:12:49.62267');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (209, 209, 2, '2018-11-02 12:12:49.62267');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (210, 210, 2, '2018-11-02 12:12:49.62367');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (211, 211, 2, '2018-11-02 12:12:49.62467');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (212, 212, 2, '2018-11-02 12:12:49.62567');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (213, 213, 2, '2018-11-02 12:12:49.62667');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (214, 214, 2, '2018-11-02 12:12:49.62767');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (215, 215, 2, '2018-11-02 12:12:49.62767');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (216, 216, 2, '2018-11-02 12:12:49.63067');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (217, 217, 2, '2018-11-02 12:12:49.63167');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (218, 218, 2, '2018-11-02 12:12:49.63167');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (219, 219, 2, '2018-11-02 12:12:49.63367');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (220, 220, 2, '2018-11-02 12:12:49.63467');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (221, 221, 2, '2018-11-02 12:12:49.635671');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (222, 222, 2, '2018-11-02 12:12:49.636671');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (223, 223, 2, '2018-11-02 12:12:49.637671');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (224, 224, 2, '2018-11-02 12:12:49.638671');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (225, 225, 2, '2018-11-02 12:12:49.639671');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (226, 226, 2, '2018-11-02 12:12:49.639671');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (227, 227, 2, '2018-11-02 12:12:49.640671');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (228, 228, 2, '2018-11-02 12:12:49.641671');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (229, 229, 2, '2018-11-02 12:12:49.642671');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (230, 230, 2, '2018-11-02 12:12:49.643671');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (231, 231, 2, '2018-11-02 12:12:49.644671');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (232, 232, 2, '2018-11-02 12:12:49.646671');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (233, 233, 2, '2018-11-02 12:12:49.647671');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (234, 234, 2, '2018-11-02 12:12:49.648671');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (235, 235, 2, '2018-11-02 12:12:49.649671');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (236, 236, 2, '2018-11-02 12:12:49.651671');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (237, 237, 2, '2018-11-02 12:12:49.652672');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (238, 238, 2, '2018-11-02 12:12:49.657672');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (239, 239, 2, '2018-11-02 12:12:49.658672');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (240, 240, 2, '2018-11-02 12:12:49.660672');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (241, 241, 2, '2018-11-02 12:12:49.660672');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (242, 242, 2, '2018-11-02 12:12:49.661672');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (243, 243, 2, '2018-11-02 12:12:49.664672');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (244, 244, 2, '2018-11-02 12:12:49.665672');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (245, 245, 2, '2018-11-02 12:12:49.666672');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (246, 246, 2, '2018-11-02 12:12:49.667672');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (247, 247, 2, '2018-11-02 12:12:49.669672');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (248, 248, 2, '2018-11-02 12:12:49.670673');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (249, 249, 2, '2018-11-02 12:12:49.671673');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (250, 250, 2, '2018-11-02 12:12:49.672673');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (251, 251, 2, '2018-11-02 12:12:49.673673');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (252, 252, 2, '2018-11-02 12:12:49.673673');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (253, 253, 2, '2018-11-02 12:12:49.674673');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (254, 254, 2, '2018-11-02 12:12:49.675673');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (255, 255, 2, '2018-11-02 12:12:49.676673');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (256, 256, 2, '2018-11-02 12:12:49.677673');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (257, 257, 2, '2018-11-02 12:12:49.680673');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (258, 258, 2, '2018-11-02 12:12:49.681673');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (259, 259, 2, '2018-11-02 12:12:49.683673');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (260, 260, 2, '2018-11-02 12:12:49.684673');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (261, 261, 2, '2018-11-02 12:12:49.685673');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (262, 262, 2, '2018-11-02 12:12:49.686673');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (263, 263, 2, '2018-11-02 12:12:49.687674');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (264, 264, 2, '2018-11-02 12:12:49.688674');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (265, 265, 2, '2018-11-02 12:12:49.705675');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (266, 266, 2, '2018-11-02 12:12:49.707675');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (267, 267, 2, '2018-11-02 12:12:49.708675');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (268, 268, 2, '2018-11-02 12:12:49.709675');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (269, 269, 2, '2018-11-02 12:12:49.709675');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (270, 270, 2, '2018-11-02 12:12:49.710675');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (271, 271, 2, '2018-11-02 12:12:49.712675');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (272, 272, 2, '2018-11-02 12:12:49.713675');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (273, 273, 2, '2018-11-02 12:12:49.714675');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (274, 274, 2, '2018-11-02 12:12:49.715675');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (275, 275, 2, '2018-11-02 12:12:49.716675');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (276, 276, 2, '2018-11-02 12:12:49.717675');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (277, 277, 2, '2018-11-02 12:12:49.718675');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (278, 278, 2, '2018-11-02 12:12:49.719675');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (279, 279, 2, '2018-11-02 12:12:49.720675');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (280, 280, 2, '2018-11-02 12:12:49.721675');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (281, 281, 2, '2018-11-02 12:12:49.721675');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (282, 282, 2, '2018-11-02 12:12:49.722676');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (283, 283, 2, '2018-11-02 12:12:49.723676');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (284, 284, 2, '2018-11-02 12:12:49.724676');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (285, 285, 2, '2018-11-02 12:12:49.725676');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (286, 286, 2, '2018-11-02 12:12:49.726676');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (287, 287, 2, '2018-11-02 12:12:49.727676');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (288, 288, 2, '2018-11-02 12:12:49.729676');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (289, 289, 2, '2018-11-02 12:12:49.730676');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (290, 290, 2, '2018-11-02 12:12:49.731676');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (291, 291, 2, '2018-11-02 12:12:49.732676');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (292, 292, 2, '2018-11-02 12:12:49.733676');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (293, 293, 2, '2018-11-02 12:12:49.735676');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (294, 294, 2, '2018-11-02 12:12:49.736676');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (295, 295, 2, '2018-11-02 12:12:49.737676');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (296, 296, 2, '2018-11-02 12:12:49.738676');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (297, 297, 2, '2018-11-02 12:12:49.739676');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (298, 298, 2, '2018-11-02 12:12:49.739676');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (299, 299, 2, '2018-11-02 12:12:49.740677');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (300, 300, 2, '2018-11-02 12:12:49.741677');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (301, 301, 2, '2018-11-02 12:12:49.742677');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (302, 302, 2, '2018-11-02 12:12:49.743677');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (303, 303, 2, '2018-11-02 12:12:49.744677');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (304, 304, 2, '2018-11-02 12:12:49.745677');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (305, 305, 2, '2018-11-02 12:12:49.747677');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (306, 306, 2, '2018-11-02 12:12:49.748677');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (307, 307, 2, '2018-11-02 12:12:49.749677');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (308, 308, 2, '2018-11-02 12:12:49.750677');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (309, 309, 2, '2018-11-02 12:12:49.751677');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (310, 310, 2, '2018-11-02 12:12:49.753677');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (311, 311, 2, '2018-11-02 12:12:49.754677');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (312, 312, 2, '2018-11-02 12:12:49.755677');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (313, 313, 2, '2018-11-02 12:12:49.756677');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (314, 314, 2, '2018-11-02 12:12:49.757678');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (315, 315, 2, '2018-11-02 12:12:49.758678');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (316, 316, 2, '2018-11-02 12:12:49.759678');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (317, 317, 2, '2018-11-02 12:12:49.760678');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (318, 318, 2, '2018-11-02 12:12:49.761678');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (319, 319, 2, '2018-11-02 12:12:49.763678');
INSERT INTO public.devices_softwares (id, device_id, software_v_id, date) VALUES (320, 320, 2, '2018-11-02 12:12:49.764678');


                                                                                                                                                                                                                                                                                                                                                                             3075.dat                                                                                            0000600 0004000 0002000 00000000206 13367436530 0014260 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        INSERT INTO public.devices_types (id, title) VALUES (1, 'pda');
INSERT INTO public.devices_types (id, title) VALUES (2, 'printer');


                                                                                                                                                                                                                                                                                                                                                                                          3081.dat                                                                                            0000600 0004000 0002000 00000000002 13367436530 0014247 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        

                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              3050.dat                                                                                            0000600 0004000 0002000 00000000302 13367436530 0014246 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        INSERT INTO public.locations (id, title) VALUES (1, 'magacin');
INSERT INTO public.locations (id, title) VALUES (2, 'servis');
INSERT INTO public.locations (id, title) VALUES (3, 'kontrola');


                                                                                                                                                                                                                                                                                                                              3062.dat                                                                                            0000600 0004000 0002000 00000000603 13367436530 0014255 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        INSERT INTO public.models (id, title) VALUES (1, 'LG');
INSERT INTO public.models (id, title) VALUES (2, 'Nokia 100');
INSERT INTO public.models (id, title) VALUES (3, 'Nokia 106');
INSERT INTO public.models (id, title) VALUES (4, 'Alcatel One Touch');
INSERT INTO public.models (id, title) VALUES (5, 'Vega 3000');
INSERT INTO public.models (id, title) VALUES (6, 'Datecs DPP-350C');


                                                                                                                             3067.dat                                                                                            0000600 0004000 0002000 00000000062 13367436530 0014261 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        INSERT INTO public.num ("position") VALUES (6);


                                                                                                                                                                                                                                                                                                                                                                                                                                                                              3048.dat                                                                                            0000600 0004000 0002000 00000000307 13367436530 0014262 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        INSERT INTO public.priviledges (id, title) VALUES (1, 'user');
INSERT INTO public.priviledges (id, title) VALUES (2, 'admin');
INSERT INTO public.priviledges (id, title) VALUES (3, 'super_admin');


                                                                                                                                                                                                                                                                                                                         3040.dat                                                                                            0000600 0004000 0002000 00000227310 13367436530 0014257 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (1, 38165, 8822109, '89381030000 154297925', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (2, 38165, 8822113, '89381030000 154297933', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (3, 38165, 8822114, '89381030000 154297941', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (4, 38165, 8822115, '89381030000 154297958', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (5, 38165, 8822119, '89381030000 154297990', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (6, 38165, 8822124, '89381030000 154298014', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (7, 38165, 8822127, '89381030000 154298048', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (8, 38165, 8822137, '89381030000 154298113', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (9, 38165, 8822138, '89381030000 154298121', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (10, 38165, 8822139, '89381030000 154298139', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (11, 38165, 8822140, '89381030000 154298147', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (12, 38165, 8822142, '89381030000 154298154', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (13, 38165, 8822143, '89381030000 154298162', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (14, 38165, 8822148, '89381030000 154298196', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (15, 38165, 8822149, '89381030000 154298204', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (16, 38165, 8822152, '89381030000 260249455', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (17, 38165, 8822154, '89381030000 154298246', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (18, 38165, 8822156, '89381030000 154298253', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (19, 38165, 8822160, '89381030000 154298279', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (20, 38165, 8822164, '89381030000 154378311', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (21, 38165, 8822165, '89381030000 154378329', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (22, 38165, 8822166, '89381030000 154378337', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (23, 38165, 8822168, '89381030000 154378352', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (24, 38165, 8822171, '89381030000 154378360', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (25, 38165, 8822172, '89381030000 154378378', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (26, 38165, 8822174, '89381030000 154378394', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (27, 38165, 8822175, '89381030000 154378402', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (28, 38165, 8822176, '89381030000 154378410', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (29, 38165, 8822177, '89381030000 154378428', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (30, 38165, 8822178, '89381030000 154378436', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (31, 38165, 8822179, '89381030000 154378444', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (32, 38165, 8822183, '89381030000 154378469', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (33, 38165, 8822184, '89381030000 154378477', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (34, 38165, 8822187, '89381030000 154378501', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (35, 38165, 8822189, '89381030000 154378519', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (36, 38165, 8822192, '89381030000 154378535', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (37, 38165, 8822193, '89381030000 154378543', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (38, 38165, 8822194, '89381030000 154378550', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (39, 38165, 8822195, '89381030000 154378568', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (40, 38165, 8822196, '89381030000 154378576', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (41, 38165, 8822198, '89381030000 154378592', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (42, 38165, 8822201, '89381030000 154378626', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (43, 38165, 8822202, '89381030000 154378618', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (44, 38165, 8822206, '89381030000 155496450', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (45, 38165, 8822213, '89381030000 154378683', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (46, 38165, 8822214, '89381030000 154378691', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (47, 38165, 8822215, '89381030000 154763371', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (48, 38165, 8822218, '89381030000 154378725', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (49, 38165, 8822219, '89381030000 154378733', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (50, 38165, 8822236, '89381030000 154378774', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (51, 38165, 8822237, '89381030000 154378782', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (52, 38165, 8822238, '89381030000 165491855', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (53, 38165, 8822239, '89381030000 154378808', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (54, 38165, 8822240, '89381030000 154378816', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (55, 38165, 8822243, '89381030000 154378832', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (56, 38165, 8822246, '89381030000 169690791', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (57, 38165, 8822249, '89381030000 154378857', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (58, 38165, 8822250, '89381030000 243631753', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (59, 38165, 8822251, '89381030000 154378873', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (60, 38165, 8822253, '89381030000 255183149', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (61, 38165, 8822254, '89381030000 154378899', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (62, 38165, 8822257, '89381030000 154378915', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (63, 38165, 8822259, '89381030000 154378931', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (64, 38165, 8822260, '89381030000 154378949', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (65, 38165, 8822267, '89381030000 154378998', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (66, 38165, 8822268, '89381030000 154379004', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (67, 38165, 8822271, '89381030000 154379020', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (68, 38165, 8822274, '89381030000 154379046', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (69, 38165, 8822278, '89381030000 154379079', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (70, 38165, 8822280, '89381030000 154379095', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (71, 38165, 8822281, '89381030000 165117856', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (72, 38165, 8822283, '89381030000 154379111', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (73, 38165, 8822287, '89381030000 154379152', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (74, 38165, 8822290, '89381030000 154379160', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (75, 38165, 8822291, '89381030000 154379178', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (76, 38165, 8822292, '89381030000 154379186', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (77, 38165, 8822295, '89381030000 154379210', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (78, 38165, 8822298, '89381030000 154379236', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (79, 38165, 8822304, '89381030000 154379251', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (80, 38165, 8822305, '89381030000 154379269', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (81, 38165, 8822310, '89381030000 154379301', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (82, 38165, 8822313, '89381030000 154379327', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (83, 38165, 8822314, '89381030000 154379335', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (84, 38165, 8822315, '89381030000 154379343', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (85, 38165, 8822316, '89381030000 154379350', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (86, 38165, 8822318, '89381030000 154379376', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (87, 38165, 8822320, '89381030000 154379392', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (88, 38165, 8822323, '89381030000 154379400', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (89, 38165, 8822324, '89381030000 154379418', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (90, 38165, 8822327, '89381030000 231436819', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (91, 38165, 8822329, '89381030000 154379467', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (92, 38165, 8822330, '89381030000 154379475', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (93, 38165, 8822331, '89381030000 231205065', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (94, 38165, 8822337, '89381030000 154379509', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (95, 38165, 8822339, '89381030000 154379517', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (96, 38165, 8822341, '89381030000 154379525', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (97, 38165, 8822346, '89381030000 154379533', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (98, 38165, 8822348, '89381030000 154379541', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (99, 38165, 8822350, '89381030000 154379566', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (100, 38165, 8822351, '89381030000 154379574', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (101, 38165, 8822353, '89381030000 154379590', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (102, 38165, 8822354, '89381030000 154379608', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (103, 38165, 8822356, '89381030000 154379624', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (104, 38165, 8822358, '89381030000 154379632', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (105, 38165, 8822359, '89381030000 154379640', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (106, 38165, 8822360, '89381030000 154379657', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (107, 38165, 8822361, '89381030000 154379665', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (108, 38165, 8822362, '89381030000 154379673', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (109, 38165, 8822363, '89381030000 154379681', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (110, 38165, 8822364, '89381030000 154379699', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (111, 38165, 8822366, '89381030000 154379715', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (112, 38165, 8822367, '89381030000 154379723', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (113, 38165, 8822369, '89381030000 154379749', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (114, 38165, 8822370, '89381030000 154379756', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (115, 38165, 8822371, '89381030000 154379764', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (116, 38165, 8822372, '89381030000 154379772', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (117, 38165, 8822373, '89381030000 154379780', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (118, 38165, 8822374, '89381030000 154379798', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (119, 38165, 8822376, '89381030000 154379806', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (120, 38165, 8822377, '89381030000 154379814', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (121, 38165, 8822378, '89381030000 154379822', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (122, 38165, 8822385, '89381030000 154379897', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (123, 38165, 8822386, '89381030000 154379905', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (124, 38165, 8822397, '89381030000 154542171', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (125, 38165, 8822452, '89381030000 154656443', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (126, 38165, 8822466, '89381030000 155308937', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (127, 38165, 8822469, '89381030000 155308945', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (128, 38165, 8822475, '89381030000 155309000', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (129, 38165, 8822476, '89381030000 155309018', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (130, 38165, 8822477, '89381030000 155309026', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (131, 38165, 8822480, '89381030000 230849509', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (132, 38165, 8822481, '89381030000 155309067', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (133, 38165, 8822483, '89381030000 155309075', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (134, 38165, 8822486, '89381030000 155309091', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (135, 38165, 8822487, '89381030000 155309109', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (136, 38165, 8822489, '89381030000 155309117', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (137, 38165, 8822491, '89381030000 155309133', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (138, 38165, 8822493, '89381030000 155309158', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (139, 38165, 8822495, '89381030000 155309174', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (140, 38165, 8822498, '89381030000 155309208', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (141, 38165, 8822503, '89381030000 155309240', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (142, 38165, 8822504, '89381030000 155309257', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (143, 38165, 8822507, '89381030000 185794114', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (144, 38165, 8822512, '89381030000 155309323', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (145, 38165, 8822513, '89381030000 155309331', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (146, 38165, 8822514, '89381030000 155309349', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (147, 38165, 8822516, '89381030000 155309364', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (148, 38165, 8822517, '89381030000 155309372', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (149, 38165, 8822518, '89381030000 155309380', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (150, 38165, 8822519, '89381030000 155309398', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (151, 38165, 8822524, '89381030000 155309430', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (152, 38165, 8822527, '89381030000 155309455', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (153, 38165, 8822528, '89381030000 155309463', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (154, 38165, 8822530, '89381030000 155309489', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (155, 38165, 8822533, '89381030000 155309505', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (156, 38165, 8822536, '89381030000 155309539', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (157, 38165, 8822537, '89381030000 155309547', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (158, 38165, 8822539, '89381030000 155309562', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (159, 38165, 8822542, '89381030000 155309596', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (160, 38165, 8822544, '89381030000 155309604', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (161, 38165, 8822546, '89381030000 230727812', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (162, 38165, 8822547, '89381030000 155309638', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (163, 38165, 8822549, '89381030000 230726152', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (164, 38165, 8822554, '89381030000 259982421', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (165, 38165, 8822563, '89381030000 155309695', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (166, 38165, 8822565, '89381030000 155309703', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (167, 38165, 8822568, '89381030000 155309711', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (168, 38165, 8822573, '89381030000 155309745', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (169, 38165, 8822578, '89381030000 155309786', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (170, 38165, 8822579, '89381030000 155309794', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (171, 38165, 8822580, '89381030000 155309802', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (172, 38165, 8822582, '89381030000 155309828', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (173, 38165, 8822586, '89381030000 155309844', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (174, 38165, 8822587, '89381030000 230657894', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (175, 38165, 8822591, '89381030000 155309877', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (176, 38165, 8822593, '89381030000 155309885', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (177, 38165, 8822594, '89381030000 155309893', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (178, 38165, 8822598, '89381030000 155309901', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (179, 38165, 8822599, '89381030000 155309919', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (180, 38165, 8822623, '89381030000 155474200', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (181, 38165, 8822631, '89381030000 155474267', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (182, 38165, 8822632, '89381030000 155474275', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (183, 38165, 8822633, '89381030000 155474283', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (184, 38165, 8822634, '89381030000 191595778', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (185, 38165, 8822635, '89381030000 155474309', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (186, 38165, 8822636, '89381030000 155474317', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (187, 38165, 8822638, '89381030000 155474333', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (188, 38165, 8822641, '89381030000 155474358', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (189, 38165, 8822642, '89381030000 155474366', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (190, 38165, 8822643, '89381030000 155474374', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (191, 38165, 8822644, '89381030000 155474382', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (192, 38165, 8822645, '89381030000 155474390', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (193, 38165, 8822646, '89381030000 155474408', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (194, 38165, 8822647, '89381030000 230657902', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (195, 38165, 8822649, '89381030000 155474432', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (196, 38165, 8822654, '89381030000 155474465', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (197, 38165, 8822656, '89381030000 155474481', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (198, 38165, 8822658, '89381030000 155474499', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (199, 38165, 8822671, '89381030000 155474531', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (200, 38165, 8822672, '89381030000 155474549', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (201, 38165, 8822673, '89381030000 155474556', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (202, 38165, 8822676, '89381030000 158168387', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (203, 38165, 8822677, '89381030000 158168395', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (204, 38165, 8822678, '89381030000 158168403', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (205, 38165, 8822683, '89381030000 158168452', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (206, 38165, 8822689, '89381030000 158168494', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (207, 38165, 8822690, '89381030000 158168502', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (208, 38165, 8822695, '89381030000 158168551', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (209, 38165, 8822696, '89381030000 158168569', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (210, 38165, 8822697, '89381030000 158168577', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (211, 38165, 8822699, '89381030000 158198582', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (212, 38165, 8822702, '89381030000 158198590', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (213, 38165, 8822705, '89381030000 158198616', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (214, 38165, 8822707, '89381030000 158198632', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (215, 38165, 8822708, '89381030000 158198640', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (216, 38165, 8822711, '89381030000 158198673', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (217, 38165, 8822712, '89381030000 158198681', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (218, 38165, 8822713, '89381030000 158198699', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (219, 38165, 8822716, '89381030000 158198723', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (220, 38165, 8822717, '89381030000 158198731', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (221, 38165, 8822720, '89381030000 158198764', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (222, 38165, 8822726, '89381030000 158198814', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (223, 38165, 8822728, '89381030000 158198830', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (224, 38165, 8822729, '89381030000 158198848', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (225, 38165, 8822730, '89381030000 158198855', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (226, 38165, 8822735, '89381030000 158198897', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (227, 38165, 8822736, '89381030000 158198905', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (228, 38165, 8822738, '89381030000 231621121', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (229, 38165, 8822739, '89381030000 158198921', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (230, 38165, 8822740, '89381030000 158198939', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (231, 38165, 8822744, '89381030000 158468258', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (232, 38165, 8822746, '89381030000 158198988', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (233, 38165, 8822747, '89381030000 158198996', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (234, 38165, 8822749, '89381030000 158199010', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (235, 38165, 8822750, '89381030000 158199028', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (236, 38165, 8822754, '89381030000 158199044', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (237, 38165, 8822756, '89381030000 158199069', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (238, 38165, 8822760, '89381030000 158199101', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (239, 38165, 8822761, '89381030000 158199119', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (240, 38165, 8822764, '89381030000 158199135', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (241, 38165, 8822765, '89381030000 158199143', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (242, 38165, 8822769, '89381030000 158199168', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (243, 38165, 8822770, '89381030000 158199192', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (244, 38165, 8822771, '89381030000 158199200', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (245, 38165, 8822776, '89381030000 158199226', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (246, 38165, 8822779, '89381030000 158199234', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (247, 38165, 8822781, '89381030000 158199259', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (248, 38165, 8822783, '89381030000 158199267', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (249, 38165, 8822786, '89381030000 158199291', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (250, 38165, 8822790, '89381030000 158199325', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (251, 38165, 8822791, '89381030000 158199333', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (252, 38165, 8822795, '89381030000 158199366', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (253, 38165, 8822796, '89381030000 158199374', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (254, 38165, 8822797, '89381030000 158199382', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (255, 38165, 8822804, '89381030000 158199416', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (256, 38165, 8822805, '89381030000 158199424', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (257, 38165, 8822807, '89381030000 158199440', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (258, 38165, 8822809, '89381030000 158199457', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (259, 38165, 8822812, '89381030000 158199473', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (260, 38165, 8822815, '89381030000 158199481', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (261, 38165, 8822816, '89381030000 158199499', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (262, 38165, 8822817, '89381030000 158199507', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (263, 38165, 8822819, '89381030000 158199515', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (264, 38165, 8822829, '89381030000 158199556', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (265, 38165, 8822830, '89381030000 158199564', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (266, 38165, 8822837, '89381030000 158199614', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (267, 38165, 8822848, '89381030000 231620743', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (268, 38165, 8822850, '89381030000 158199697', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (269, 38165, 8822853, '89381030000 158199713', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (270, 38165, 8822854, '89381030000 231345457', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (271, 38165, 8822855, '89381030000 158199739', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (272, 38165, 8822859, '89381030000 158199762', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (273, 38165, 8822864, '89381030000 158199812', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (274, 38165, 8822865, '89381030000 158199820', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (275, 38165, 8822869, '89381030000 158199846', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (276, 38165, 8822870, '89381030000 158199853', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (277, 38165, 8822872, '89381030000 158199879', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (278, 38165, 8822876, '89381030000 158199911', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (279, 38165, 8822877, '89381030000 158199929', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (280, 38165, 8822879, '89381030000 158199937', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (281, 38165, 8822890, '89381030000 158199952', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (282, 38165, 8822893, '89381030000 158199978', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (283, 38165, 8822894, '89381030000 158199986', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (284, 38165, 8822915, '89381030000 20964651', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (285, 38165, 8822916, '89381030000 20964652', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (286, 38165, 8822917, '89381030000 20964653', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (287, 38165, 8822920, '89381030000 20964654', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (288, 38165, 8822921, '89381030000 20964655', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (289, 38165, 8822924, '89381030000 20964656', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (290, 38165, 8822925, '89381030000 20964657', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (291, 38165, 8822926, '89381030000 20964658', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (292, 38165, 8822927, '89381030000 20964659', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (293, 38165, 8822928, '89381030000 20964660', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (294, 38165, 8822930, '89381030000 20964661', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (295, 38165, 8822932, '89381030000 20964662', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (296, 38165, 8822933, '89381030000 20964663', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (297, 38165, 8822934, '89381030000 20964664', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (298, 38165, 8822935, '89381030000 20964665', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (299, 38165, 8822936, '89381030000 20964666', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (300, 38165, 8822937, '89381030000 20964667', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (301, 38165, 8822938, '89381030000 20964668', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (302, 38165, 8822939, '89381030000 20964669', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (303, 38165, 8822940, '89381030000 260104585', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (304, 38165, 8822942, '89381030000 20964671', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (305, 38165, 8822943, '89381030000 20964672', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (306, 38165, 8822944, '89381030000 20964673', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (307, 38165, 8822945, '89381030000 20964674', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (308, 38165, 8822946, '89381030000 20964675', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (309, 38165, 8822947, '89381030000 20964676', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (310, 38165, 8822948, '89381030000 20964677', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (311, 38165, 8822949, '89381030000 20964678', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (312, 38165, 8822951, '89381030000 20964679', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (313, 38165, 8822953, '89381030000 20964680', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (314, 38165, 8822954, '89381030000 20964681', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (315, 38165, 8822956, '89381030000 20964683', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (316, 38165, 8822957, '89381030000 20964684', 'kontrola');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (317, 38165, 5966262, '89381030000 23241497', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (318, 38165, 5966263, '89381030000 23241498', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (319, 38165, 5966264, '89381030000 23241499', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (320, 38165, 5966265, '89381030000 23241500', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (321, 38165, 5966266, '89381030000 23241501', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (322, 38165, 5966267, '89381030000 23241502', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (323, 38165, 5966268, '89381030000 23241503', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (324, 38165, 5966269, '89381030000 23241504', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (325, 38165, 5966270, '89381030000 23241505', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (326, 38165, 5966271, '89381030000 23241506', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (327, 38165, 5966272, '89381030000 23241507', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (328, 38165, 5966273, '89381030000 23241508', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (329, 38165, 5966274, '89381030000 23241509', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (330, 38165, 5966275, '89381030000 23241510', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (331, 38165, 5966276, '89381030000 23241511', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (332, 38165, 5966277, '89381030000 23241512', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (333, 38165, 5966278, '89381030000 23241513', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (334, 38165, 5966279, '89381030000 23241514', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (335, 38165, 5966280, '89381030000 23241515', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (336, 38165, 5966281, '89381030000 23241516', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (337, 38165, 5966628, '89381030000 23241572', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (338, 38165, 5966629, '89381030000 23241573', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (339, 38165, 5966630, '89381030000 23241574', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (340, 38165, 5966631, '89381030000 23241575', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (341, 38165, 5966632, '89381030000 23241576', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (342, 38165, 5966633, '89381030000 23241577', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (343, 38165, 5966634, '89381030000 23241578', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (344, 38165, 5966635, '89381030000 23241579', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (345, 38165, 5966636, '89381030000 23241580', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (346, 38165, 5966637, '89381030000 23241581', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (347, 38165, 5966638, '89381030000 23241582', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (348, 38165, 5966639, '89381030000 23241583', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (349, 38165, 5966640, '89381030000 23241584', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (350, 38165, 5966641, '89381030000 23241585', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (351, 38165, 5966642, '89381030000 23241586', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (352, 38165, 5966643, '89381030000 23241587', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (353, 38165, 5966644, '89381030000 23241588', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (354, 38165, 5966645, '89381030000 23241589', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (355, 38165, 5966646, '89381030000 23241590', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (356, 38165, 5966647, '89381030000 232393266', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (357, 38165, 5966648, '89381030000 23241592', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (358, 38165, 5966649, '89381030000 23241593', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (359, 38165, 5966650, '89381030000 23241594', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (360, 38165, 5966651, '89381030000 23241595', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (361, 38165, 5966652, '89381030000 23241596', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (362, 38165, 5966653, '89381030000 23241597', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (363, 38165, 5966654, '89381030000 23241598', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (364, 38165, 5966655, '89381030000 23241599', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (365, 38165, 5966656, '89381030000 23241600', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (366, 38165, 5966657, '89381030000 23241601', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (367, 38165, 5966658, '89381030000 23241602', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (368, 38165, 5966659, '89381030000 23241603', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (369, 38165, 5966660, '89381030000 23241604', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (370, 38165, 5966661, '89381030000 23241605', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (371, 38165, 5966662, '89381030000 23241606', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (372, 38165, 5966663, '89381030000 23241607', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (373, 38165, 5966664, '89381030000 23241608', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (374, 38165, 5966665, '89381030000 23241609', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (375, 38165, 5966667, '89381030000 23241610', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (376, 38165, 5966668, '89381030000 23241611', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (377, 38165, 5966669, '89381030000 23241612', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (378, 38165, 5966670, '89381030000 23241613', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (379, 38165, 5966671, '89381030000 23241614', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (380, 38165, 5966672, '89381030000 23241615', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (381, 38165, 5966673, '89381030000 23241616', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (382, 38165, 5966674, '89381030000 23241617', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (383, 38165, 5966675, '89381030000 23241618', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (384, 38165, 5966676, '89381030000 23241619', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (385, 38165, 5966677, '89381030000 23241620', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (386, 38165, 5966678, '89381030000 23241621', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (387, 38165, 5966759, '89381030000 23241676', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (388, 38165, 5966760, '89381030000 23241677', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (389, 38165, 5966761, '89381030000 23241678', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (390, 38165, 5966762, '89381030000 23241679', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (391, 38165, 5966763, '89381030000 23241680', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (392, 38165, 5966764, '89381030000 23241681', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (393, 38165, 5966765, '89381030000 23241682', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (394, 38165, 5966766, '89381030000 23241683', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (395, 38165, 5966767, '89381030000 23241684', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (396, 38165, 5966768, '89381030000 23241685', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (397, 38165, 5966769, '89381030000 23241686', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (398, 38165, 5966770, '89381030000 23241687', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (399, 38165, 5966771, '89381030000 23241688', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (400, 38165, 5966772, '89381030000 23241689', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (401, 38165, 5966773, '89381030000 23241690', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (402, 38165, 5966774, '89381030000 23241691', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (403, 38165, 5966775, '89381030000 23241692', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (404, 38165, 5966776, '89381030000 23241693', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (405, 38165, 5966777, '89381030000 23241694', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (406, 38165, 5966778, '89381030000 23241695', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (407, 38165, 5966779, '89381030000 23241696', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (408, 38165, 5966780, '89381030000 23241697', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (409, 38165, 5966781, '89381030000 23241698', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (410, 38165, 5966782, '89381030000 23241699', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (411, 38165, 5966783, '89381030000 23241700', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (412, 38165, 5966784, '89381030000 23241701', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (413, 38165, 5966785, '89381030000 23241702', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (414, 38165, 5966786, '89381030000 23241703', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (415, 38165, 5966787, '89381030000 23241704', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (416, 38165, 5966788, '89381030000 23241705', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (417, 38165, 5966789, '89381030000 23241706', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (418, 38165, 5966790, '89381030000 23241707', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (419, 38165, 5966791, '89381030000 23241708', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (420, 38165, 5966792, '89381030000 23241709', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (421, 38165, 5966793, '89381030000 232393951', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (422, 38165, 5966794, '89381030000 23241711', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (423, 38165, 5966795, '89381030000 23241712', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (424, 38165, 5966796, '89381030000 23241713', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (425, 38165, 5966797, '89381030000 23241714', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (426, 38165, 5966798, '89381030000 23241715', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (427, 38165, 5966799, '89381030000 23241716', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (428, 38165, 5966800, '89381030000 23241717', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (429, 38165, 5966801, '89381030000 23241718', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (430, 38165, 5966802, '89381030000 23241719', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (431, 38165, 5966803, '89381030000 23241720', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (432, 38165, 5966804, '89381030000 23241721', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (433, 38165, 5966805, '89381030000 23241722', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (434, 38165, 5966806, '89381030000 23241723', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (435, 38165, 5966807, '89381030000 23241724', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (436, 38165, 5966808, '89381030000 23241725', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (437, 38165, 5966809, '89381030000 23241726', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (438, 38165, 5966810, '89381030000 23241727', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (439, 38165, 5966811, '89381030000 23241728', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (440, 38165, 5966812, '89381030000 23241729', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (441, 38165, 5966813, '89381030000 23241730', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (442, 38165, 5966814, '89381030000 23241731', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (443, 38165, 5966815, '89381030000 23241732', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (444, 38165, 5966816, '89381030000 23241733', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (445, 38165, 5966817, '89381030000 23241734', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (446, 38165, 5966818, '89381030000 23241735', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (447, 38165, 5966819, '89381030000 23241736', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (448, 38165, 5966820, '89381030000 23241737', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (449, 38165, 5966821, '89381030000 23241738', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (450, 38165, 5966822, '89381030000 23241739', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (451, 38165, 5966823, '89381030000 23241740', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (452, 38165, 5966824, '89381030000 23241741', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (453, 38165, 5966825, '89381030000 23241742', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (454, 38165, 5966826, '89381030000 23241743', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (455, 38165, 5966827, '89381030000 23241744', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (456, 38165, 5966828, '89381030000 23241745', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (457, 38165, 5966829, '89381030000 23241746', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (458, 38165, 5966830, '89381030000 23241747', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (459, 38165, 5966831, '89381030000 23241748', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (460, 38165, 5966832, '89381030000 23241749', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (461, 38165, 5966833, '89381030000 23241750', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (462, 38165, 5966834, '89381030000 23241751', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (463, 38165, 5966835, '89381030000 23241752', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (464, 38165, 5966836, '89381030000 23241753', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (465, 38165, 5966837, '89381030000 23241754', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (466, 38165, 5966838, '89381030000 23241755', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (467, 38165, 5966839, '89381030000 23241756', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (468, 38165, 5966840, '89381030000 23241757', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (469, 38165, 5966841, '89381030000 232393985', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (470, 38165, 5966842, '89381030000 23241759', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (471, 38165, 5966843, '89381030000 23241760', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (472, 38165, 5966844, '89381030000 23241761', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (473, 38165, 5966845, '89381030000 23241762', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (474, 38165, 5966846, '89381030000 23241763', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (475, 38165, 5966847, '89381030000 23239343', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (476, 38165, 5966848, '89381030000 23241765', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (477, 38165, 5966849, '89381030000 23241766', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (478, 38165, 5966850, '89381030000 23241767', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (479, 38165, 5966851, '89381030000 23241768', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (480, 38165, 5966852, '89381030000 23241769', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (481, 38165, 5966853, '89381030000 23241770', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (482, 38165, 5966854, '89381030000 23241771', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (483, 38165, 5966855, '89381030000 23241772', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (484, 38165, 5966856, '89381030000 23241773', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (485, 38165, 5966857, '89381030000 23241774', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (486, 38165, 5966858, '89381030000 23241775', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (487, 38165, 5967085, '89381030000 23241785', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (488, 38165, 5967086, '89381030000 23241786', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (489, 38165, 5967087, '89381030000 23241787', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (490, 38165, 5967088, '89381030000 23241788', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (491, 38165, 5967089, '89381030000 23241789', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (492, 38165, 5967090, '89381030000 23241790', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (493, 38165, 5967091, '89381030000 23241791', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (494, 38165, 5967092, '89381030000 23241792', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (495, 38165, 5967093, '89381030000 23241793', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (496, 38165, 5967094, '89381030000 23241794', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (497, 38165, 5967095, '89381030000 23241795', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (498, 38165, 5967096, '89381030000 23241796', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (499, 38165, 5967097, '89381030000 23241797', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (500, 38165, 5967098, '89381030000 23241798', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (501, 38165, 5967099, '89381030000 23241799', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (502, 38165, 5967100, '89381030000 23241800', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (503, 38165, 5967101, '89381030000 23241801', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (504, 38165, 5967102, '89381030000 23241802', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (505, 38165, 5967103, '89381030000 23241803', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (506, 38165, 5967104, '89381030000 23241804', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (507, 38165, 5967105, '89381030000 23241805', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (508, 38165, 5967106, '89381030000 23241806', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (509, 38165, 5967107, '89381030000 23241807', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (510, 38165, 5967108, '89381030000 23241808', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (511, 38165, 5967109, '89381030000 23241809', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (512, 38165, 5967110, '89381030000 23241810', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (513, 38165, 5967111, '89381030000 23241811', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (514, 38165, 5967112, '89381030000 23241812', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (515, 38165, 5967113, '89381030000 23241813', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (516, 38165, 5967114, '89381030000 23241814', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (517, 38165, 5967115, '89381030000 23241815', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (518, 38165, 5967116, '89381030000 23241816', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (519, 38165, 5967117, '89381030000 23241817', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (520, 38165, 5967118, '89381030000 23241818', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (521, 38165, 5967119, '89381030000 23241819', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (522, 38165, 5967120, '89381030000 23241820', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (523, 38165, 5967121, '89381030000 23241821', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (524, 38165, 5967122, '89381030000 23241822', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (525, 38165, 5967123, '89381030000 23241823', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (526, 38165, 5967124, '89381030000 23241824', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (527, 38165, 5967125, '89381030000 23241825', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (528, 38165, 5967126, '89381030000 23241826', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (529, 38165, 5967127, '89381030000 23241827', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (530, 38165, 5967128, '89381030000 23241828', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (531, 38165, 5967129, '89381030000 23241829', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (532, 38165, 5967130, '89381030000 23241830', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (533, 38165, 5967131, '89381030000 23241831', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (534, 38165, 5967132, '89381030000 23241832', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (535, 38165, 5967133, '89381030000 23241833', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (536, 38165, 5967134, '89381030000 23241834', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (537, 38165, 5967135, '89381030000 23241835', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (538, 38165, 5967136, '89381030000 23241836', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (539, 38165, 5967137, '89381030000 23241837', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (540, 38165, 5967138, '89381030000 23241838', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (541, 38165, 5967139, '89381030000 23241839', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (542, 38165, 5967140, '89381030000 23241840', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (543, 38165, 5967141, '89381030000 23241841', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (544, 38165, 5967142, '89381030000 23241842', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (545, 38165, 5967143, '89381030000 23241843', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (546, 38165, 5967144, '89381030000 23241844', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (547, 38165, 5967145, '89381030000 23241845', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (548, 38165, 5967146, '89381030000 23241846', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (549, 38165, 5967147, '89381030000 23241847', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (550, 38165, 5967148, '89381030000 23241848', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (551, 38165, 5967149, '89381030000 23241849', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (552, 38165, 5967150, '89381030000 23241850', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (553, 38165, 5967151, '89381030000 23241851', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (554, 38165, 5967152, '89381030000 23241852', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (555, 38165, 5967153, '89381030000 23241853', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (556, 38165, 5967154, '89381030000 23241854', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (557, 38165, 5967155, '89381030000 23241855', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (558, 38165, 5967156, '89381030000 23241856', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (559, 38165, 5967157, '89381030000 23241857', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (560, 38165, 5967158, '89381030000 23241858', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (561, 38165, 5967159, '89381030000 23241859', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (562, 38165, 5967160, '89381030000 23241860', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (563, 38165, 5967161, '89381030000 23241861', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (564, 38165, 5967162, '89381030000 23241862', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (565, 38165, 5967163, '89381030000 23241863', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (566, 38165, 5967164, '89381030000 23241864', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (567, 38165, 5967165, '89381030000 23241865', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (568, 38165, 5967166, '89381030000 23241866', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (569, 38165, 5967167, '89381030000 23241867', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (570, 38165, 5967168, '89381030000 23241868', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (571, 38165, 5967169, '89381030000 23241869', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (572, 38165, 5967170, '89381030000 23241870', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (573, 38165, 5967171, '89381030000 23241871', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (574, 38165, 5967172, '89381030000 23241872', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (575, 38165, 5967173, '89381030000 23241873', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (576, 38165, 5967174, '89381030000 23241874', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (577, 38165, 5967175, '89381030000 23241875', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (578, 38165, 5967176, '89381030000 23241876', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (579, 38165, 5967177, '89381030000 23241877', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (580, 38165, 5967178, '89381030000 23241878', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (581, 38165, 5967179, '89381030000 23241879', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (582, 38165, 5967180, '89381030000 23241880', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (583, 38165, 5967181, '89381030000 23241881', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (584, 38165, 5967182, '89381030000 232393241', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (585, 38165, 5967183, '89381030000 23241883', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (586, 38165, 5967184, '89381030000 23241884', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (587, 38165, 5979387, '89381030000 23203444', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (588, 38165, 5979388, '89381030000 23203445', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (589, 38165, 5979389, '89381030000 23203446', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (590, 38165, 5979390, '89381030000 23203447', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (591, 38165, 5979391, '89381030000 23203448', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (592, 38165, 5979392, '89381030000 23203449', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (593, 38165, 5979393, '89381030000 23203450', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (594, 38165, 5979394, '89381030000 23203451', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (595, 38165, 5979395, '89381030000 23203452', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (596, 38165, 5979396, '89381030000 23203453', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (597, 38165, 5982696, '89381030000 23203569', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (598, 38165, 5982697, '89381030000 23203570', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (599, 38165, 5982698, '89381030000 23203571', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (600, 38165, 5982699, '89381030000 23203572', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (601, 38165, 5982700, '89381030000 23203573', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (602, 38165, 5982701, '89381030000 23203574', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (603, 38165, 5982702, '89381030000 23203575', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (604, 38165, 5982703, '89381030000 23203576', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (605, 38165, 5982704, '89381030000 23203577', 'pda');
INSERT INTO public.sim_cards (id, network, num, iccid, purpose) VALUES (606, 38165, 5982705, '89381030000 23203578', 'pda');


                                                                                                                                                                                                                                                                                                                        3069.dat                                                                                            0000600 0004000 0002000 00000000002 13367436530 0014255 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        

                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              3071.dat                                                                                            0000600 0004000 0002000 00000000002 13367436530 0014246 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        

                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              3077.dat                                                                                            0000600 0004000 0002000 00000000277 13367436530 0014272 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        INSERT INTO public.software_v (id, software) VALUES (1, 1222);
INSERT INTO public.software_v (id, software) VALUES (2, 1234);
INSERT INTO public.software_v (id, software) VALUES (3, 1235);


                                                                                                                                                                                                                                                                                                                                 3044.dat                                                                                            0000600 0004000 0002000 00000001543 13367436530 0014261 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        INSERT INTO public.terminals (id, terminals_num_id, pda_id, printer_id, sim_cards_id, date_assembled, user_id) VALUES (1, 1, 9, 338, 330, '2018-10-31 09:36:15.202681', 1);
INSERT INTO public.terminals (id, terminals_num_id, pda_id, printer_id, sim_cards_id, date_assembled, user_id) VALUES (2, 2, 7, 382, 514, '2018-10-31 09:36:15.202681', 1);
INSERT INTO public.terminals (id, terminals_num_id, pda_id, printer_id, sim_cards_id, date_assembled, user_id) VALUES (8, 3, 8, 383, 335, '2018-10-31 09:36:15.202681', 1);
INSERT INTO public.terminals (id, terminals_num_id, pda_id, printer_id, sim_cards_id, date_assembled, user_id) VALUES (20, 4, 231, 342, 353, '2018-11-03 12:29:26.830991', 1);
INSERT INTO public.terminals (id, terminals_num_id, pda_id, printer_id, sim_cards_id, date_assembled, user_id) VALUES (21, 4, 56, 417, 466, '2018-11-03 12:34:54.428665', 1);


                                                                                                                                                             3056.dat                                                                                            0000600 0004000 0002000 00000000420 13367436530 0014255 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        INSERT INTO public.terminals_charges (id, terminal_id, agent_id, user_id, date) VALUES (110, 20, 33, 1, '2018-11-03 12:30:49.799333');
INSERT INTO public.terminals_charges (id, terminal_id, agent_id, user_id, date) VALUES (112, 21, 129, 1, '2018-11-03 12:38:35.77232');


                                                                                                                                                                                                                                                3058.dat                                                                                            0000600 0004000 0002000 00000000207 13367436530 0014262 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        INSERT INTO public.terminals_charges_off (id, terminal_charge_id, users_id, date) VALUES (70, 110, 1, '2018-11-03 12:32:39.370082');


                                                                                                                                                                                                                                                                                                                                                                                         3073.dat                                                                                            0000600 0004000 0002000 00000000213 13367436530 0014254 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        INSERT INTO public.terminals_disassembled (id, terminal_id, date_disassembled, user_id) VALUES (6, 20, '2018-11-03 12:33:29.574954', 1);


                                                                                                                                                                                                                                                                                                                                                                                     3042.dat                                                                                            0000600 0004000 0002000 00000055326 13367436530 0014267 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        INSERT INTO public.terminals_num (id, terminal_num) VALUES (1, 44001);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (2, 44002);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (3, 44003);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (4, 44004);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (5, 44005);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (6, 44006);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (7, 44007);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (8, 44008);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (9, 44009);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (10, 44010);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (11, 44011);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (12, 44012);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (13, 44013);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (14, 44014);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (15, 44015);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (16, 44016);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (17, 44017);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (18, 44018);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (19, 44019);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (20, 44020);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (21, 44021);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (22, 44022);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (23, 44023);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (24, 44024);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (25, 44025);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (26, 44026);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (27, 44027);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (28, 44028);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (29, 44029);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (30, 44030);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (31, 44031);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (32, 44032);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (33, 44033);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (34, 44034);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (35, 44035);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (36, 44036);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (37, 44037);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (38, 44038);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (39, 44039);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (40, 44040);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (41, 44041);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (42, 44042);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (43, 44043);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (44, 44044);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (45, 44045);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (46, 44046);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (47, 44047);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (48, 44048);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (49, 44049);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (50, 44050);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (51, 44051);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (52, 44052);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (53, 44053);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (54, 44054);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (55, 44055);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (56, 44056);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (57, 44057);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (58, 44058);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (59, 44059);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (60, 44060);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (61, 44061);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (62, 44062);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (63, 44063);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (64, 44064);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (65, 44065);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (66, 44066);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (67, 44067);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (68, 44068);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (69, 44069);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (70, 44070);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (71, 44071);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (72, 44072);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (73, 44073);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (74, 44074);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (75, 44075);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (76, 44076);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (77, 44077);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (78, 44078);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (79, 44079);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (80, 44080);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (81, 44081);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (82, 44082);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (83, 44083);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (84, 44084);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (85, 44085);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (86, 44086);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (87, 44087);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (88, 44088);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (89, 44089);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (90, 44090);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (91, 44091);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (92, 44092);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (93, 44093);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (94, 44094);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (95, 44095);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (96, 44096);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (97, 44097);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (98, 44098);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (99, 44099);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (100, 44100);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (101, 44101);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (102, 44102);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (103, 44103);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (104, 44104);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (105, 44105);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (106, 44106);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (107, 44107);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (108, 44108);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (109, 44109);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (110, 44110);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (111, 44111);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (112, 44112);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (113, 44113);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (114, 44114);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (115, 44115);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (116, 44116);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (117, 44117);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (118, 44118);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (119, 44119);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (120, 44120);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (121, 44121);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (122, 44122);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (123, 44123);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (124, 44124);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (125, 44125);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (126, 44126);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (127, 44127);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (128, 44128);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (129, 44129);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (130, 44130);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (131, 44131);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (132, 44132);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (133, 44133);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (134, 44134);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (135, 44135);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (136, 44136);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (137, 44137);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (138, 44138);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (139, 44139);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (140, 44140);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (141, 44141);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (142, 44142);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (143, 44143);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (144, 44144);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (145, 44145);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (146, 44146);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (147, 44147);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (148, 44148);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (149, 44149);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (150, 44150);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (151, 44151);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (152, 44152);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (153, 44153);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (154, 44154);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (155, 44155);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (156, 44156);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (157, 44157);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (158, 44158);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (159, 44159);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (160, 44160);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (161, 44161);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (162, 44162);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (163, 44163);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (164, 44164);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (165, 44165);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (166, 44166);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (167, 44167);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (168, 44168);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (169, 44169);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (170, 44170);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (171, 44171);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (172, 44172);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (173, 44173);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (174, 44174);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (175, 44175);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (176, 44176);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (177, 44177);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (178, 44178);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (179, 44179);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (180, 44180);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (181, 44181);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (182, 44182);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (183, 44183);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (184, 44184);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (185, 44185);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (186, 44186);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (187, 44187);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (188, 44188);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (189, 44189);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (190, 44190);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (191, 44191);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (192, 44192);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (193, 44193);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (194, 44194);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (195, 44195);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (196, 44196);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (197, 44197);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (198, 44198);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (199, 44199);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (200, 44200);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (201, 44201);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (202, 44202);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (203, 44203);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (204, 44204);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (205, 44205);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (206, 44206);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (207, 44207);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (208, 44208);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (209, 44209);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (210, 44210);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (211, 44211);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (212, 44212);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (213, 44213);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (214, 44214);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (215, 44215);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (216, 44216);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (217, 44217);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (218, 44218);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (219, 44219);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (220, 44220);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (221, 44221);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (222, 44222);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (223, 44223);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (224, 44224);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (225, 44225);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (226, 44226);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (227, 44227);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (228, 44228);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (229, 44229);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (230, 44230);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (231, 44231);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (232, 44232);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (233, 44233);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (234, 44234);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (235, 44235);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (236, 44236);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (237, 44237);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (238, 44238);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (239, 44239);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (240, 44240);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (241, 44241);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (242, 44242);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (243, 44243);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (244, 44244);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (245, 44245);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (246, 44246);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (247, 44247);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (248, 44248);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (249, 44249);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (250, 44250);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (251, 44251);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (252, 44252);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (253, 44253);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (254, 44254);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (255, 44255);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (256, 44256);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (257, 44257);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (258, 44258);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (259, 44259);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (260, 44260);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (261, 44261);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (262, 44262);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (263, 44263);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (264, 44264);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (265, 44265);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (266, 44266);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (267, 44267);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (268, 44268);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (269, 44269);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (270, 44270);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (271, 44271);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (272, 44272);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (273, 44273);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (274, 44274);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (275, 44275);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (276, 44276);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (277, 44277);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (278, 44278);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (279, 44279);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (280, 44280);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (281, 44281);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (282, 44282);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (283, 44283);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (284, 44284);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (285, 44285);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (286, 44286);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (287, 44287);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (288, 44288);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (289, 44289);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (290, 44290);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (291, 44291);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (292, 44292);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (293, 44293);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (294, 44294);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (295, 44295);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (296, 44296);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (297, 44297);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (298, 44298);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (299, 44299);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (300, 44300);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (301, 44301);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (302, 44302);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (303, 44303);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (304, 44304);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (305, 44305);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (306, 44306);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (307, 44307);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (308, 44308);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (309, 44309);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (310, 44310);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (311, 44311);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (312, 44312);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (313, 44313);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (314, 44314);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (315, 44315);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (316, 44316);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (317, 44317);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (318, 44318);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (319, 44319);
INSERT INTO public.terminals_num (id, terminal_num) VALUES (320, 44320);


                                                                                                                                                                                                                                                                                                          3046.dat                                                                                            0000600 0004000 0002000 00000000154 13367436530 0014260 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        INSERT INTO public.users (id, username, password, priviledge_id) VALUES (1, 'marko.nikolic', '12345', 2);


                                                                                                                                                                                                                                                                                                                                                                                                                    restore.sql                                                                                         0000600 0004000 0002000 00000136447 13367436530 0015415 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        --
-- NOTE:
--
-- File paths need to be edited. Search for $$PATH$$ and
-- replace it with the path to the directory containing
-- the extracted data files.
--
--
-- PostgreSQL database dump
--

-- Dumped from database version 10.1
-- Dumped by pg_dump version 10.4

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

DROP DATABASE terminals;
--
-- Name: terminals; Type: DATABASE; Schema: -; Owner: postgres
--

CREATE DATABASE terminals WITH TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'Serbian (Latin)_Serbia.1250' LC_CTYPE = 'Serbian (Latin)_Serbia.1250';


ALTER DATABASE terminals OWNER TO postgres;

\connect terminals

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
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
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
-- Name: agents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.agents_id_seq OWNED BY public.agents.id;


--
-- Name: cellphones; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cellphones (
    id integer NOT NULL,
    model_id integer NOT NULL,
    imei character varying(30) NOT NULL
);


ALTER TABLE public.cellphones OWNER TO postgres;

--
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
-- Name: cellphones_charges_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.cellphones_charges_id_seq OWNED BY public.cellphones_charges.id;


--
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
-- Name: cellphones_charges_off_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.cellphones_charges_off_id_seq OWNED BY public.cellphones_charges_off.id;


--
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
-- Name: cellphones_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.cellphones_id_seq OWNED BY public.cellphones.id;


--
-- Name: models; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.models (
    id integer NOT NULL,
    title character varying(45) NOT NULL
);


ALTER TABLE public.models OWNER TO postgres;

--
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
-- Name: cellphones_models_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.cellphones_models_id_seq OWNED BY public.models.id;


--
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
-- Name: devices_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.devices_id_seq OWNED BY public.devices.id;


--
-- Name: devices_locations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.devices_locations (
    id integer NOT NULL,
    device_id integer NOT NULL,
    location_id integer NOT NULL
);


ALTER TABLE public.devices_locations OWNER TO postgres;

--
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
-- Name: devices_locations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.devices_locations_id_seq OWNED BY public.devices_locations.id;


--
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
-- Name: devices_softwares_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.devices_softwares_id_seq OWNED BY public.devices_softwares.id;


--
-- Name: devices_types; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.devices_types (
    id bigint NOT NULL,
    title character varying(45) NOT NULL
);


ALTER TABLE public.devices_types OWNER TO postgres;

--
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
-- Name: devices_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.devices_types_id_seq OWNED BY public.devices_types.id;


--
-- Name: devices_writes_off; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.devices_writes_off (
    id integer NOT NULL,
    device_id integer NOT NULL,
    date timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.devices_writes_off OWNER TO postgres;

--
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
-- Name: devices_writes_off_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.devices_writes_off_id_seq OWNED BY public.devices_writes_off.id;


--
-- Name: locations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.locations (
    id integer NOT NULL,
    title character varying(45) NOT NULL
);


ALTER TABLE public.locations OWNER TO postgres;

--
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
-- Name: locations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.locations_id_seq OWNED BY public.locations.id;


--
-- Name: num; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.num (
    "position" integer
);


ALTER TABLE public.num OWNER TO postgres;

--
-- Name: priviledges; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.priviledges (
    id integer NOT NULL,
    title character varying(45) NOT NULL
);


ALTER TABLE public.priviledges OWNER TO postgres;

--
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
-- Name: priviledges_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.priviledges_id_seq OWNED BY public.priviledges.id;


--
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
-- Name: sim_cards_charges_off_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sim_cards_charges_off_id_seq OWNED BY public.sim_cards_charges_off.id;


--
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
-- Name: sim_cards_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sim_cards_id_seq OWNED BY public.sim_cards.id;


--
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
-- Name: sims_charges_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sims_charges_id_seq OWNED BY public.sim_cards_charges.id;


--
-- Name: software_v; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.software_v (
    id integer NOT NULL,
    software bigint NOT NULL
);


ALTER TABLE public.software_v OWNER TO postgres;

--
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
-- Name: software_v_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.software_v_id_seq OWNED BY public.software_v.id;


--
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
-- Name: terminals_charges_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.terminals_charges_id_seq OWNED BY public.terminals_charges.id;


--
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
-- Name: terminals_charges_off_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.terminals_charges_off_id_seq OWNED BY public.terminals_charges_off.id;


--
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
-- Name: terminals_disassembled_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.terminals_disassembled_id_seq OWNED BY public.terminals_disassembled.id;


--
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
-- Name: terminals_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.terminals_id_seq OWNED BY public.terminals.id;


--
-- Name: terminals_num; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.terminals_num (
    id integer NOT NULL,
    terminal_num integer NOT NULL
);


ALTER TABLE public.terminals_num OWNER TO postgres;

--
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
-- Name: terminals_num_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.terminals_num_id_seq OWNED BY public.terminals_num.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id integer NOT NULL,
    username character varying(45) NOT NULL,
    password character varying(45) NOT NULL,
    priviledge_id integer NOT NULL
);


ALTER TABLE public.users OWNER TO postgres;

--
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
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: agents id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.agents ALTER COLUMN id SET DEFAULT nextval('public.agents_id_seq'::regclass);


--
-- Name: cellphones id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cellphones ALTER COLUMN id SET DEFAULT nextval('public.cellphones_id_seq'::regclass);


--
-- Name: cellphones_charges id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cellphones_charges ALTER COLUMN id SET DEFAULT nextval('public.cellphones_charges_id_seq'::regclass);


--
-- Name: cellphones_charges_off id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cellphones_charges_off ALTER COLUMN id SET DEFAULT nextval('public.cellphones_charges_off_id_seq'::regclass);


--
-- Name: devices id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.devices ALTER COLUMN id SET DEFAULT nextval('public.devices_id_seq'::regclass);


--
-- Name: devices_locations id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.devices_locations ALTER COLUMN id SET DEFAULT nextval('public.devices_locations_id_seq'::regclass);


--
-- Name: devices_softwares id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.devices_softwares ALTER COLUMN id SET DEFAULT nextval('public.devices_softwares_id_seq'::regclass);


--
-- Name: devices_types id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.devices_types ALTER COLUMN id SET DEFAULT nextval('public.devices_types_id_seq'::regclass);


--
-- Name: devices_writes_off id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.devices_writes_off ALTER COLUMN id SET DEFAULT nextval('public.devices_writes_off_id_seq'::regclass);


--
-- Name: locations id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.locations ALTER COLUMN id SET DEFAULT nextval('public.locations_id_seq'::regclass);


--
-- Name: models id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.models ALTER COLUMN id SET DEFAULT nextval('public.cellphones_models_id_seq'::regclass);


--
-- Name: priviledges id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.priviledges ALTER COLUMN id SET DEFAULT nextval('public.priviledges_id_seq'::regclass);


--
-- Name: sim_cards id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sim_cards ALTER COLUMN id SET DEFAULT nextval('public.sim_cards_id_seq'::regclass);


--
-- Name: sim_cards_charges id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sim_cards_charges ALTER COLUMN id SET DEFAULT nextval('public.sims_charges_id_seq'::regclass);


--
-- Name: sim_cards_charges_off id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sim_cards_charges_off ALTER COLUMN id SET DEFAULT nextval('public.sim_cards_charges_off_id_seq'::regclass);


--
-- Name: software_v id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.software_v ALTER COLUMN id SET DEFAULT nextval('public.software_v_id_seq'::regclass);


--
-- Name: terminals id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.terminals ALTER COLUMN id SET DEFAULT nextval('public.terminals_id_seq'::regclass);


--
-- Name: terminals_charges id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.terminals_charges ALTER COLUMN id SET DEFAULT nextval('public.terminals_charges_id_seq'::regclass);


--
-- Name: terminals_charges_off id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.terminals_charges_off ALTER COLUMN id SET DEFAULT nextval('public.terminals_charges_off_id_seq'::regclass);


--
-- Name: terminals_disassembled id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.terminals_disassembled ALTER COLUMN id SET DEFAULT nextval('public.terminals_disassembled_id_seq'::regclass);


--
-- Name: terminals_num id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.terminals_num ALTER COLUMN id SET DEFAULT nextval('public.terminals_num_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Data for Name: agents; Type: TABLE DATA; Schema: public; Owner: postgres
--

\i $$PATH$$/3054.dat

--
-- Data for Name: cellphones; Type: TABLE DATA; Schema: public; Owner: postgres
--

\i $$PATH$$/3060.dat

--
-- Data for Name: cellphones_charges; Type: TABLE DATA; Schema: public; Owner: postgres
--

\i $$PATH$$/3064.dat

--
-- Data for Name: cellphones_charges_off; Type: TABLE DATA; Schema: public; Owner: postgres
--

\i $$PATH$$/3066.dat

--
-- Data for Name: devices; Type: TABLE DATA; Schema: public; Owner: postgres
--

\i $$PATH$$/3038.dat

--
-- Data for Name: devices_locations; Type: TABLE DATA; Schema: public; Owner: postgres
--

\i $$PATH$$/3052.dat

--
-- Data for Name: devices_softwares; Type: TABLE DATA; Schema: public; Owner: postgres
--

\i $$PATH$$/3079.dat

--
-- Data for Name: devices_types; Type: TABLE DATA; Schema: public; Owner: postgres
--

\i $$PATH$$/3075.dat

--
-- Data for Name: devices_writes_off; Type: TABLE DATA; Schema: public; Owner: postgres
--

\i $$PATH$$/3081.dat

--
-- Data for Name: locations; Type: TABLE DATA; Schema: public; Owner: postgres
--

\i $$PATH$$/3050.dat

--
-- Data for Name: models; Type: TABLE DATA; Schema: public; Owner: postgres
--

\i $$PATH$$/3062.dat

--
-- Data for Name: num; Type: TABLE DATA; Schema: public; Owner: postgres
--

\i $$PATH$$/3067.dat

--
-- Data for Name: priviledges; Type: TABLE DATA; Schema: public; Owner: postgres
--

\i $$PATH$$/3048.dat

--
-- Data for Name: sim_cards; Type: TABLE DATA; Schema: public; Owner: postgres
--

\i $$PATH$$/3040.dat

--
-- Data for Name: sim_cards_charges; Type: TABLE DATA; Schema: public; Owner: postgres
--

\i $$PATH$$/3069.dat

--
-- Data for Name: sim_cards_charges_off; Type: TABLE DATA; Schema: public; Owner: postgres
--

\i $$PATH$$/3071.dat

--
-- Data for Name: software_v; Type: TABLE DATA; Schema: public; Owner: postgres
--

\i $$PATH$$/3077.dat

--
-- Data for Name: terminals; Type: TABLE DATA; Schema: public; Owner: postgres
--

\i $$PATH$$/3044.dat

--
-- Data for Name: terminals_charges; Type: TABLE DATA; Schema: public; Owner: postgres
--

\i $$PATH$$/3056.dat

--
-- Data for Name: terminals_charges_off; Type: TABLE DATA; Schema: public; Owner: postgres
--

\i $$PATH$$/3058.dat

--
-- Data for Name: terminals_disassembled; Type: TABLE DATA; Schema: public; Owner: postgres
--

\i $$PATH$$/3073.dat

--
-- Data for Name: terminals_num; Type: TABLE DATA; Schema: public; Owner: postgres
--

\i $$PATH$$/3042.dat

--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

\i $$PATH$$/3046.dat

--
-- Name: agents_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.agents_id_seq', 287, true);


--
-- Name: cellphones_charges_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.cellphones_charges_id_seq', 27, true);


--
-- Name: cellphones_charges_off_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.cellphones_charges_off_id_seq', 13, true);


--
-- Name: cellphones_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.cellphones_id_seq', 6, true);


--
-- Name: cellphones_models_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.cellphones_models_id_seq', 4, true);


--
-- Name: devices_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.devices_id_seq', 621, true);


--
-- Name: devices_locations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.devices_locations_id_seq', 629, true);


--
-- Name: devices_softwares_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.devices_softwares_id_seq', 320, true);


--
-- Name: devices_types_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.devices_types_id_seq', 2, true);


--
-- Name: devices_writes_off_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.devices_writes_off_id_seq', 1, false);


--
-- Name: locations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.locations_id_seq', 3, true);


--
-- Name: priviledges_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.priviledges_id_seq', 3, true);


--
-- Name: sim_cards_charges_off_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sim_cards_charges_off_id_seq', 13, true);


--
-- Name: sim_cards_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sim_cards_id_seq', 606, true);


--
-- Name: sims_charges_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sims_charges_id_seq', 42, true);


--
-- Name: software_v_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.software_v_id_seq', 3, true);


--
-- Name: terminals_charges_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.terminals_charges_id_seq', 112, true);


--
-- Name: terminals_charges_off_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.terminals_charges_off_id_seq', 70, true);


--
-- Name: terminals_disassembled_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.terminals_disassembled_id_seq', 6, true);


--
-- Name: terminals_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.terminals_id_seq', 21, true);


--
-- Name: terminals_num_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.terminals_num_id_seq', 320, true);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_id_seq', 1, true);


--
-- Name: agents agents_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.agents
    ADD CONSTRAINT agents_pkey PRIMARY KEY (id);


--
-- Name: cellphones_charges_off cellphones_charges_off_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cellphones_charges_off
    ADD CONSTRAINT cellphones_charges_off_pkey PRIMARY KEY (id);


--
-- Name: cellphones_charges cellphones_charges_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cellphones_charges
    ADD CONSTRAINT cellphones_charges_pkey PRIMARY KEY (id);


--
-- Name: models cellphones_models_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.models
    ADD CONSTRAINT cellphones_models_pkey PRIMARY KEY (id);


--
-- Name: cellphones cellphones_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cellphones
    ADD CONSTRAINT cellphones_pkey PRIMARY KEY (id);


--
-- Name: devices_locations devices_locations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.devices_locations
    ADD CONSTRAINT devices_locations_pkey PRIMARY KEY (id);


--
-- Name: devices devices_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.devices
    ADD CONSTRAINT devices_pkey PRIMARY KEY (id);


--
-- Name: devices_softwares devices_softwares_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.devices_softwares
    ADD CONSTRAINT devices_softwares_pkey PRIMARY KEY (id);


--
-- Name: devices_types devices_types_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.devices_types
    ADD CONSTRAINT devices_types_pkey PRIMARY KEY (id);


--
-- Name: devices devices_ukey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.devices
    ADD CONSTRAINT devices_ukey UNIQUE (sn);


--
-- Name: devices_writes_off devices_writes_off_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.devices_writes_off
    ADD CONSTRAINT devices_writes_off_pkey PRIMARY KEY (id);


--
-- Name: locations locations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.locations
    ADD CONSTRAINT locations_pkey PRIMARY KEY (id);


--
-- Name: agents off_num_uk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.agents
    ADD CONSTRAINT off_num_uk UNIQUE (off_num);


--
-- Name: priviledges priviledges_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.priviledges
    ADD CONSTRAINT priviledges_pkey PRIMARY KEY (id);


--
-- Name: sim_cards_charges_off sim_cards_charges_off_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sim_cards_charges_off
    ADD CONSTRAINT sim_cards_charges_off_pkey PRIMARY KEY (id);


--
-- Name: sim_cards sim_cards_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sim_cards
    ADD CONSTRAINT sim_cards_pkey PRIMARY KEY (id);


--
-- Name: sim_cards_charges sims_charges_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sim_cards_charges
    ADD CONSTRAINT sims_charges_pkey PRIMARY KEY (id);


--
-- Name: software_v software_v_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.software_v
    ADD CONSTRAINT software_v_pkey PRIMARY KEY (id);


--
-- Name: terminals_charges_off terminals_charges_off_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.terminals_charges_off
    ADD CONSTRAINT terminals_charges_off_pkey PRIMARY KEY (id, users_id);


--
-- Name: terminals_charges terminals_charges_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.terminals_charges
    ADD CONSTRAINT terminals_charges_pkey PRIMARY KEY (id);


--
-- Name: terminals_disassembled terminals_disassembled_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.terminals_disassembled
    ADD CONSTRAINT terminals_disassembled_pkey PRIMARY KEY (id);


--
-- Name: terminals_num terminals_num_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.terminals_num
    ADD CONSTRAINT terminals_num_pkey PRIMARY KEY (id);


--
-- Name: terminals_num terminals_num_ukey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.terminals_num
    ADD CONSTRAINT terminals_num_ukey UNIQUE (terminal_num);


--
-- Name: terminals terminals_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.terminals
    ADD CONSTRAINT terminals_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: sim_cards_charges agents_sc_charges_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sim_cards_charges
    ADD CONSTRAINT agents_sc_charges_id_fk FOREIGN KEY (agent_id) REFERENCES public.agents(id);


--
-- Name: cellphones cellphones_cp_models_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cellphones
    ADD CONSTRAINT cellphones_cp_models_fk FOREIGN KEY (model_id) REFERENCES public.models(id);


--
-- Name: cellphones_charges cpc_agents_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cellphones_charges
    ADD CONSTRAINT cpc_agents_fk FOREIGN KEY (agent_id) REFERENCES public.agents(id);


--
-- Name: cellphones_charges cpc_cellphones_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cellphones_charges
    ADD CONSTRAINT cpc_cellphones_fk FOREIGN KEY (cellphone_id) REFERENCES public.cellphones(id);


--
-- Name: cellphones_charges cpc_users_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cellphones_charges
    ADD CONSTRAINT cpc_users_fk FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: cellphones_charges_off cpco_cpc_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cellphones_charges_off
    ADD CONSTRAINT cpco_cpc_fk FOREIGN KEY (cellphone_charge_id) REFERENCES public.cellphones_charges(id);


--
-- Name: cellphones_charges_off cpco_users_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cellphones_charges_off
    ADD CONSTRAINT cpco_users_fk FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: devices devices_device_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.devices
    ADD CONSTRAINT devices_device_type_id_fkey FOREIGN KEY (device_type_id) REFERENCES public.devices_types(id);


--
-- Name: devices devices_model_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.devices
    ADD CONSTRAINT devices_model_id_fkey FOREIGN KEY (model_id) REFERENCES public.models(id);


--
-- Name: devices_softwares devices_softwares_device_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.devices_softwares
    ADD CONSTRAINT devices_softwares_device_id_fkey FOREIGN KEY (device_id) REFERENCES public.devices(id);


--
-- Name: devices_softwares devices_softwares_software_v_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.devices_softwares
    ADD CONSTRAINT devices_softwares_software_v_id_fkey FOREIGN KEY (software_v_id) REFERENCES public.software_v(id);


--
-- Name: devices_writes_off devices_writes_off_device_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.devices_writes_off
    ADD CONSTRAINT devices_writes_off_device_id_fkey FOREIGN KEY (device_id) REFERENCES public.devices(id);


--
-- Name: devices_locations dl_devices_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.devices_locations
    ADD CONSTRAINT dl_devices_fk FOREIGN KEY (device_id) REFERENCES public.devices(id);


--
-- Name: devices_locations dl_locations_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.devices_locations
    ADD CONSTRAINT dl_locations_fk FOREIGN KEY (location_id) REFERENCES public.locations(id);


--
-- Name: sim_cards_charges_off sc_charges_scco_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sim_cards_charges_off
    ADD CONSTRAINT sc_charges_scco_fk FOREIGN KEY (sim_card_charge_id) REFERENCES public.sim_cards_charges(id);


--
-- Name: sim_cards_charges sim_cards_sc_charges_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sim_cards_charges
    ADD CONSTRAINT sim_cards_sc_charges_fk FOREIGN KEY (sim_id) REFERENCES public.sim_cards(id);


--
-- Name: terminals_charges tc_agents_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.terminals_charges
    ADD CONSTRAINT tc_agents_fk FOREIGN KEY (agent_id) REFERENCES public.agents(id);


--
-- Name: terminals_charges tc_terminals_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.terminals_charges
    ADD CONSTRAINT tc_terminals_fk FOREIGN KEY (terminal_id) REFERENCES public.terminals(id);


--
-- Name: terminals_charges tc_users; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.terminals_charges
    ADD CONSTRAINT tc_users FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: terminals_charges_off tco_tc_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.terminals_charges_off
    ADD CONSTRAINT tco_tc_fk FOREIGN KEY (terminal_charge_id) REFERENCES public.terminals_charges(id);


--
-- Name: terminals_charges_off tco_users_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.terminals_charges_off
    ADD CONSTRAINT tco_users_fk FOREIGN KEY (users_id) REFERENCES public.users(id);


--
-- Name: terminals terminals_devices_fk1; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.terminals
    ADD CONSTRAINT terminals_devices_fk1 FOREIGN KEY (pda_id) REFERENCES public.devices(id);


--
-- Name: terminals terminals_devices_fk2; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.terminals
    ADD CONSTRAINT terminals_devices_fk2 FOREIGN KEY (printer_id) REFERENCES public.devices(id);


--
-- Name: terminals_disassembled terminals_disassembled_terminals_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.terminals_disassembled
    ADD CONSTRAINT terminals_disassembled_terminals_fk FOREIGN KEY (terminal_id) REFERENCES public.terminals(id);


--
-- Name: terminals terminals_sim_cards_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.terminals
    ADD CONSTRAINT terminals_sim_cards_fk FOREIGN KEY (sim_cards_id) REFERENCES public.sim_cards(id);


--
-- Name: terminals terminals_terminals_num_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.terminals
    ADD CONSTRAINT terminals_terminals_num_fk FOREIGN KEY (terminals_num_id) REFERENCES public.terminals_num(id);


--
-- Name: users users_priviledges_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_priviledges_fk FOREIGN KEY (priviledge_id) REFERENCES public.priviledges(id);


--
-- Name: sim_cards_charges users_sc_charges_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sim_cards_charges
    ADD CONSTRAINT users_sc_charges_fk FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: sim_cards_charges_off users_scco_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sim_cards_charges_off
    ADD CONSTRAINT users_scco_fk FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- PostgreSQL database dump complete
--

                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         