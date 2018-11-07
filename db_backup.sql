PGDMP                     
    v         	   terminals    10.1    10.4 �               0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                       false                       0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                       false                       0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                       false                       1262    24707 	   terminals    DATABASE     �   CREATE DATABASE terminals WITH TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'Serbian (Latin)_Serbia.1250' LC_CTYPE = 'Serbian (Latin)_Serbia.1250';
    DROP DATABASE terminals;
             postgres    false                        2615    2200    public    SCHEMA        CREATE SCHEMA public;
    DROP SCHEMA public;
             postgres    false                       0    0    SCHEMA public    COMMENT     6   COMMENT ON SCHEMA public IS 'standard public schema';
                  postgres    false    3                        3079    12924    plpgsql 	   EXTENSION     ?   CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;
    DROP EXTENSION plpgsql;
                  false                       0    0    EXTENSION plpgsql    COMMENT     @   COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';
                       false    1            �            1255    33409 ?   discharge(integer, integer, integer, integer, integer, integer)    FUNCTION     ;  CREATE FUNCTION public.discharge(_agent_id integer, _terminal integer, _sim integer, _phone integer, _inactiv integer, _user integer) RETURNS void
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
       public       postgres    false    3    1            �            1255    33283 U   insert_new_terminal(integer, character varying, character varying, character varying)    FUNCTION     �  CREATE FUNCTION public.insert_new_terminal(_terminal_num integer, _pda character varying, _printer character varying, _iccid character varying) RETURNS void
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
       public       postgres    false    1    3            �            1255    34003 ^   insert_new_terminal(integer, character varying, character varying, character varying, integer)    FUNCTION     �  CREATE FUNCTION public.insert_new_terminal(_terminal_num integer, _pda character varying, _printer character varying, _iccid character varying, _user_id integer) RETURNS void
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
       public       postgres    false    3    1            �            1255    33358 Y   make_new_charge(character varying, integer, integer, integer, character varying, integer)    FUNCTION     f  CREATE FUNCTION public.make_new_charge(_agent character varying, _off_num integer, _terminal_num integer, _sim integer, _imei character varying, _user integer) RETURNS void
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
       public       postgres    false    3    1            �            1259    33207    agents    TABLE     �   CREATE TABLE public.agents (
    id integer NOT NULL,
    first_name character varying(45) NOT NULL,
    last_name character varying(45) NOT NULL,
    off_num integer,
    active smallint DEFAULT 1
);
    DROP TABLE public.agents;
       public         postgres    false    3            �            1259    33205    agents_id_seq    SEQUENCE     �   CREATE SEQUENCE public.agents_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 $   DROP SEQUENCE public.agents_id_seq;
       public       postgres    false    213    3                       0    0    agents_id_seq    SEQUENCE OWNED BY     ?   ALTER SEQUENCE public.agents_id_seq OWNED BY public.agents.id;
            public       postgres    false    212            �            1259    33286 
   cellphones    TABLE     �   CREATE TABLE public.cellphones (
    id integer NOT NULL,
    model_id integer NOT NULL,
    imei character varying(30) NOT NULL
);
    DROP TABLE public.cellphones;
       public         postgres    false    3            �            1259    33307    cellphones_charges    TABLE     �   CREATE TABLE public.cellphones_charges (
    id integer NOT NULL,
    cellphone_id integer NOT NULL,
    agent_id integer NOT NULL,
    user_id integer NOT NULL,
    date timestamp without time zone DEFAULT now()
);
 &   DROP TABLE public.cellphones_charges;
       public         postgres    false    3            �            1259    33305    cellphones_charges_id_seq    SEQUENCE     �   CREATE SEQUENCE public.cellphones_charges_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 0   DROP SEQUENCE public.cellphones_charges_id_seq;
       public       postgres    false    223    3                       0    0    cellphones_charges_id_seq    SEQUENCE OWNED BY     W   ALTER SEQUENCE public.cellphones_charges_id_seq OWNED BY public.cellphones_charges.id;
            public       postgres    false    222            �            1259    33315    cellphones_charges_off    TABLE     �   CREATE TABLE public.cellphones_charges_off (
    id integer NOT NULL,
    cellphone_charge_id integer NOT NULL,
    user_id integer NOT NULL,
    date timestamp without time zone DEFAULT now() NOT NULL
);
 *   DROP TABLE public.cellphones_charges_off;
       public         postgres    false    3            �            1259    33313    cellphones_charges_off_id_seq    SEQUENCE     �   CREATE SEQUENCE public.cellphones_charges_off_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 4   DROP SEQUENCE public.cellphones_charges_off_id_seq;
       public       postgres    false    225    3                       0    0    cellphones_charges_off_id_seq    SEQUENCE OWNED BY     _   ALTER SEQUENCE public.cellphones_charges_off_id_seq OWNED BY public.cellphones_charges_off.id;
            public       postgres    false    224            �            1259    33284    cellphones_id_seq    SEQUENCE     �   CREATE SEQUENCE public.cellphones_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 (   DROP SEQUENCE public.cellphones_id_seq;
       public       postgres    false    3    219                       0    0    cellphones_id_seq    SEQUENCE OWNED BY     G   ALTER SEQUENCE public.cellphones_id_seq OWNED BY public.cellphones.id;
            public       postgres    false    218            �            1259    33294    models    TABLE     �   CREATE TABLE public.models (
    id integer NOT NULL,
    title character varying(45) NOT NULL,
    purpose character varying(45) NOT NULL
);
    DROP TABLE public.models;
       public         postgres    false    3            �            1259    33292    cellphones_models_id_seq    SEQUENCE     �   CREATE SEQUENCE public.cellphones_models_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 /   DROP SEQUENCE public.cellphones_models_id_seq;
       public       postgres    false    221    3                       0    0    cellphones_models_id_seq    SEQUENCE OWNED BY     J   ALTER SEQUENCE public.cellphones_models_id_seq OWNED BY public.models.id;
            public       postgres    false    220            �            1259    24870    devices    TABLE     �   CREATE TABLE public.devices (
    id integer NOT NULL,
    sn character varying(13) NOT NULL,
    nav_num character varying(20) NOT NULL,
    model_id integer,
    device_type_id integer
);
    DROP TABLE public.devices;
       public         postgres    false    3            �            1259    24868    devices_id_seq    SEQUENCE     �   CREATE SEQUENCE public.devices_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 %   DROP SEQUENCE public.devices_id_seq;
       public       postgres    false    3    197                       0    0    devices_id_seq    SEQUENCE OWNED BY     A   ALTER SEQUENCE public.devices_id_seq OWNED BY public.devices.id;
            public       postgres    false    196            �            1259    33189    devices_locations    TABLE     �   CREATE TABLE public.devices_locations (
    id integer NOT NULL,
    device_id integer NOT NULL,
    location_id integer NOT NULL
);
 %   DROP TABLE public.devices_locations;
       public         postgres    false    3            �            1259    33187    devices_locations_id_seq    SEQUENCE     �   CREATE SEQUENCE public.devices_locations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 /   DROP SEQUENCE public.devices_locations_id_seq;
       public       postgres    false    3    211                       0    0    devices_locations_id_seq    SEQUENCE OWNED BY     U   ALTER SEQUENCE public.devices_locations_id_seq OWNED BY public.devices_locations.id;
            public       postgres    false    210            �            1259    34066    devices_softwares    TABLE     �   CREATE TABLE public.devices_softwares (
    id integer NOT NULL,
    device_id integer NOT NULL,
    software_v_id integer NOT NULL,
    date timestamp without time zone DEFAULT now() NOT NULL
);
 %   DROP TABLE public.devices_softwares;
       public         postgres    false    3            �            1259    34064    devices_softwares_id_seq    SEQUENCE     �   CREATE SEQUENCE public.devices_softwares_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 /   DROP SEQUENCE public.devices_softwares_id_seq;
       public       postgres    false    238    3                       0    0    devices_softwares_id_seq    SEQUENCE OWNED BY     U   ALTER SEQUENCE public.devices_softwares_id_seq OWNED BY public.devices_softwares.id;
            public       postgres    false    237            �            1259    34006    devices_types    TABLE     h   CREATE TABLE public.devices_types (
    id bigint NOT NULL,
    title character varying(45) NOT NULL
);
 !   DROP TABLE public.devices_types;
       public         postgres    false    3            �            1259    34004    devices_types_id_seq    SEQUENCE     }   CREATE SEQUENCE public.devices_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 +   DROP SEQUENCE public.devices_types_id_seq;
       public       postgres    false    3    234                       0    0    devices_types_id_seq    SEQUENCE OWNED BY     M   ALTER SEQUENCE public.devices_types_id_seq OWNED BY public.devices_types.id;
            public       postgres    false    233            �            1259    34085    devices_writes_off    TABLE     �   CREATE TABLE public.devices_writes_off (
    id integer NOT NULL,
    device_id integer NOT NULL,
    date timestamp without time zone DEFAULT now() NOT NULL
);
 &   DROP TABLE public.devices_writes_off;
       public         postgres    false    3            �            1259    34083    devices_writes_off_id_seq    SEQUENCE     �   CREATE SEQUENCE public.devices_writes_off_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 0   DROP SEQUENCE public.devices_writes_off_id_seq;
       public       postgres    false    3    240                       0    0    devices_writes_off_id_seq    SEQUENCE OWNED BY     W   ALTER SEQUENCE public.devices_writes_off_id_seq OWNED BY public.devices_writes_off.id;
            public       postgres    false    239            �            1259    33181 	   locations    TABLE     e   CREATE TABLE public.locations (
    id integer NOT NULL,
    title character varying(45) NOT NULL
);
    DROP TABLE public.locations;
       public         postgres    false    3            �            1259    33179    locations_id_seq    SEQUENCE     �   CREATE SEQUENCE public.locations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 '   DROP SEQUENCE public.locations_id_seq;
       public       postgres    false    3    209                       0    0    locations_id_seq    SEQUENCE OWNED BY     E   ALTER SEQUENCE public.locations_id_seq OWNED BY public.locations.id;
            public       postgres    false    208            �            1259    33355    num    TABLE     4   CREATE TABLE public.num (
    "position" integer
);
    DROP TABLE public.num;
       public         postgres    false    3            �            1259    33168    priviledges    TABLE     g   CREATE TABLE public.priviledges (
    id integer NOT NULL,
    title character varying(45) NOT NULL
);
    DROP TABLE public.priviledges;
       public         postgres    false    3            �            1259    33166    priviledges_id_seq    SEQUENCE     �   CREATE SEQUENCE public.priviledges_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 )   DROP SEQUENCE public.priviledges_id_seq;
       public       postgres    false    3    207                       0    0    priviledges_id_seq    SEQUENCE OWNED BY     I   ALTER SEQUENCE public.priviledges_id_seq OWNED BY public.priviledges.id;
            public       postgres    false    206            �            1259    24883 	   sim_cards    TABLE     �   CREATE TABLE public.sim_cards (
    id integer NOT NULL,
    network integer NOT NULL,
    num bigint NOT NULL,
    iccid character varying(21) NOT NULL,
    purpose character varying(20) NOT NULL
);
    DROP TABLE public.sim_cards;
       public         postgres    false    3            �            1259    33367    sim_cards_charges    TABLE     �   CREATE TABLE public.sim_cards_charges (
    id integer NOT NULL,
    sim_id integer NOT NULL,
    agent_id integer NOT NULL,
    user_id integer NOT NULL,
    date timestamp without time zone DEFAULT now() NOT NULL
);
 %   DROP TABLE public.sim_cards_charges;
       public         postgres    false    3            �            1259    33390    sim_cards_charges_off    TABLE     �   CREATE TABLE public.sim_cards_charges_off (
    id integer NOT NULL,
    sim_card_charge_id integer NOT NULL,
    user_id integer NOT NULL,
    date timestamp without time zone DEFAULT now() NOT NULL
);
 )   DROP TABLE public.sim_cards_charges_off;
       public         postgres    false    3            �            1259    33388    sim_cards_charges_off_id_seq    SEQUENCE     �   CREATE SEQUENCE public.sim_cards_charges_off_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 3   DROP SEQUENCE public.sim_cards_charges_off_id_seq;
       public       postgres    false    230    3                       0    0    sim_cards_charges_off_id_seq    SEQUENCE OWNED BY     ]   ALTER SEQUENCE public.sim_cards_charges_off_id_seq OWNED BY public.sim_cards_charges_off.id;
            public       postgres    false    229            �            1259    24881    sim_cards_id_seq    SEQUENCE     �   CREATE SEQUENCE public.sim_cards_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 '   DROP SEQUENCE public.sim_cards_id_seq;
       public       postgres    false    3    199                       0    0    sim_cards_id_seq    SEQUENCE OWNED BY     E   ALTER SEQUENCE public.sim_cards_id_seq OWNED BY public.sim_cards.id;
            public       postgres    false    198            �            1259    33365    sims_charges_id_seq    SEQUENCE     �   CREATE SEQUENCE public.sims_charges_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 *   DROP SEQUENCE public.sims_charges_id_seq;
       public       postgres    false    3    228                        0    0    sims_charges_id_seq    SEQUENCE OWNED BY     P   ALTER SEQUENCE public.sims_charges_id_seq OWNED BY public.sim_cards_charges.id;
            public       postgres    false    227            �            1259    34014 
   software_v    TABLE     Z   CREATE TABLE public.software_v (
    id integer NOT NULL,
    software bigint NOT NULL
);
    DROP TABLE public.software_v;
       public         postgres    false    3            �            1259    34012    software_v_id_seq    SEQUENCE     �   CREATE SEQUENCE public.software_v_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 (   DROP SEQUENCE public.software_v_id_seq;
       public       postgres    false    236    3            !           0    0    software_v_id_seq    SEQUENCE OWNED BY     G   ALTER SEQUENCE public.software_v_id_seq OWNED BY public.software_v.id;
            public       postgres    false    235            �            1259    24940 	   terminals    TABLE     '  CREATE TABLE public.terminals (
    id bigint NOT NULL,
    terminals_num_id integer NOT NULL,
    pda_id integer NOT NULL,
    printer_id integer NOT NULL,
    sim_cards_id integer NOT NULL,
    date_assembled timestamp without time zone DEFAULT now() NOT NULL,
    user_id integer NOT NULL
);
    DROP TABLE public.terminals;
       public         postgres    false    3            �            1259    33225    terminals_charges    TABLE     �   CREATE TABLE public.terminals_charges (
    id integer NOT NULL,
    terminal_id integer NOT NULL,
    agent_id integer NOT NULL,
    user_id integer NOT NULL,
    date timestamp without time zone DEFAULT now() NOT NULL
);
 %   DROP TABLE public.terminals_charges;
       public         postgres    false    3            �            1259    33223    terminals_charges_id_seq    SEQUENCE     �   CREATE SEQUENCE public.terminals_charges_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 /   DROP SEQUENCE public.terminals_charges_id_seq;
       public       postgres    false    3    215            "           0    0    terminals_charges_id_seq    SEQUENCE OWNED BY     U   ALTER SEQUENCE public.terminals_charges_id_seq OWNED BY public.terminals_charges.id;
            public       postgres    false    214            �            1259    33244    terminals_charges_off    TABLE     �   CREATE TABLE public.terminals_charges_off (
    id integer NOT NULL,
    terminal_charge_id integer NOT NULL,
    users_id integer NOT NULL,
    date timestamp without time zone DEFAULT now() NOT NULL
);
 )   DROP TABLE public.terminals_charges_off;
       public         postgres    false    3            �            1259    33242    terminals_charges_off_id_seq    SEQUENCE     �   CREATE SEQUENCE public.terminals_charges_off_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 3   DROP SEQUENCE public.terminals_charges_off_id_seq;
       public       postgres    false    217    3            #           0    0    terminals_charges_off_id_seq    SEQUENCE OWNED BY     ]   ALTER SEQUENCE public.terminals_charges_off_id_seq OWNED BY public.terminals_charges_off.id;
            public       postgres    false    216            �            1259    33975    terminals_disassembled    TABLE     �   CREATE TABLE public.terminals_disassembled (
    id bigint NOT NULL,
    terminal_id bigint NOT NULL,
    date_disassembled timestamp without time zone DEFAULT now() NOT NULL,
    user_id integer NOT NULL
);
 *   DROP TABLE public.terminals_disassembled;
       public         postgres    false    3            �            1259    33973    terminals_disassembled_id_seq    SEQUENCE     �   CREATE SEQUENCE public.terminals_disassembled_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 4   DROP SEQUENCE public.terminals_disassembled_id_seq;
       public       postgres    false    3    232            $           0    0    terminals_disassembled_id_seq    SEQUENCE OWNED BY     _   ALTER SEQUENCE public.terminals_disassembled_id_seq OWNED BY public.terminals_disassembled.id;
            public       postgres    false    231            �            1259    24938    terminals_id_seq    SEQUENCE     �   CREATE SEQUENCE public.terminals_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 '   DROP SEQUENCE public.terminals_id_seq;
       public       postgres    false    3    203            %           0    0    terminals_id_seq    SEQUENCE OWNED BY     E   ALTER SEQUENCE public.terminals_id_seq OWNED BY public.terminals.id;
            public       postgres    false    202            �            1259    24930    terminals_num    TABLE     b   CREATE TABLE public.terminals_num (
    id integer NOT NULL,
    terminal_num integer NOT NULL
);
 !   DROP TABLE public.terminals_num;
       public         postgres    false    3            �            1259    24928    terminals_num_id_seq    SEQUENCE     �   CREATE SEQUENCE public.terminals_num_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 +   DROP SEQUENCE public.terminals_num_id_seq;
       public       postgres    false    201    3            &           0    0    terminals_num_id_seq    SEQUENCE OWNED BY     M   ALTER SEQUENCE public.terminals_num_id_seq OWNED BY public.terminals_num.id;
            public       postgres    false    200            �            1259    33160    users    TABLE     �   CREATE TABLE public.users (
    id integer NOT NULL,
    username character varying(45) NOT NULL,
    password character varying(45) NOT NULL,
    priviledge_id integer NOT NULL
);
    DROP TABLE public.users;
       public         postgres    false    3            �            1259    33158    users_id_seq    SEQUENCE     �   CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 #   DROP SEQUENCE public.users_id_seq;
       public       postgres    false    205    3            '           0    0    users_id_seq    SEQUENCE OWNED BY     =   ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;
            public       postgres    false    204            �
           2604    33210 	   agents id    DEFAULT     f   ALTER TABLE ONLY public.agents ALTER COLUMN id SET DEFAULT nextval('public.agents_id_seq'::regclass);
 8   ALTER TABLE public.agents ALTER COLUMN id DROP DEFAULT;
       public       postgres    false    212    213    213                       2604    33289    cellphones id    DEFAULT     n   ALTER TABLE ONLY public.cellphones ALTER COLUMN id SET DEFAULT nextval('public.cellphones_id_seq'::regclass);
 <   ALTER TABLE public.cellphones ALTER COLUMN id DROP DEFAULT;
       public       postgres    false    219    218    219                       2604    33310    cellphones_charges id    DEFAULT     ~   ALTER TABLE ONLY public.cellphones_charges ALTER COLUMN id SET DEFAULT nextval('public.cellphones_charges_id_seq'::regclass);
 D   ALTER TABLE public.cellphones_charges ALTER COLUMN id DROP DEFAULT;
       public       postgres    false    222    223    223                       2604    33318    cellphones_charges_off id    DEFAULT     �   ALTER TABLE ONLY public.cellphones_charges_off ALTER COLUMN id SET DEFAULT nextval('public.cellphones_charges_off_id_seq'::regclass);
 H   ALTER TABLE public.cellphones_charges_off ALTER COLUMN id DROP DEFAULT;
       public       postgres    false    224    225    225            �
           2604    24873 
   devices id    DEFAULT     h   ALTER TABLE ONLY public.devices ALTER COLUMN id SET DEFAULT nextval('public.devices_id_seq'::regclass);
 9   ALTER TABLE public.devices ALTER COLUMN id DROP DEFAULT;
       public       postgres    false    197    196    197            �
           2604    33192    devices_locations id    DEFAULT     |   ALTER TABLE ONLY public.devices_locations ALTER COLUMN id SET DEFAULT nextval('public.devices_locations_id_seq'::regclass);
 C   ALTER TABLE public.devices_locations ALTER COLUMN id DROP DEFAULT;
       public       postgres    false    210    211    211                       2604    34069    devices_softwares id    DEFAULT     |   ALTER TABLE ONLY public.devices_softwares ALTER COLUMN id SET DEFAULT nextval('public.devices_softwares_id_seq'::regclass);
 C   ALTER TABLE public.devices_softwares ALTER COLUMN id DROP DEFAULT;
       public       postgres    false    237    238    238                       2604    34009    devices_types id    DEFAULT     t   ALTER TABLE ONLY public.devices_types ALTER COLUMN id SET DEFAULT nextval('public.devices_types_id_seq'::regclass);
 ?   ALTER TABLE public.devices_types ALTER COLUMN id DROP DEFAULT;
       public       postgres    false    233    234    234                       2604    34088    devices_writes_off id    DEFAULT     ~   ALTER TABLE ONLY public.devices_writes_off ALTER COLUMN id SET DEFAULT nextval('public.devices_writes_off_id_seq'::regclass);
 D   ALTER TABLE public.devices_writes_off ALTER COLUMN id DROP DEFAULT;
       public       postgres    false    239    240    240            �
           2604    33184    locations id    DEFAULT     l   ALTER TABLE ONLY public.locations ALTER COLUMN id SET DEFAULT nextval('public.locations_id_seq'::regclass);
 ;   ALTER TABLE public.locations ALTER COLUMN id DROP DEFAULT;
       public       postgres    false    209    208    209                       2604    33297 	   models id    DEFAULT     q   ALTER TABLE ONLY public.models ALTER COLUMN id SET DEFAULT nextval('public.cellphones_models_id_seq'::regclass);
 8   ALTER TABLE public.models ALTER COLUMN id DROP DEFAULT;
       public       postgres    false    221    220    221            �
           2604    33171    priviledges id    DEFAULT     p   ALTER TABLE ONLY public.priviledges ALTER COLUMN id SET DEFAULT nextval('public.priviledges_id_seq'::regclass);
 =   ALTER TABLE public.priviledges ALTER COLUMN id DROP DEFAULT;
       public       postgres    false    207    206    207            �
           2604    24886    sim_cards id    DEFAULT     l   ALTER TABLE ONLY public.sim_cards ALTER COLUMN id SET DEFAULT nextval('public.sim_cards_id_seq'::regclass);
 ;   ALTER TABLE public.sim_cards ALTER COLUMN id DROP DEFAULT;
       public       postgres    false    198    199    199            	           2604    33370    sim_cards_charges id    DEFAULT     w   ALTER TABLE ONLY public.sim_cards_charges ALTER COLUMN id SET DEFAULT nextval('public.sims_charges_id_seq'::regclass);
 C   ALTER TABLE public.sim_cards_charges ALTER COLUMN id DROP DEFAULT;
       public       postgres    false    227    228    228                       2604    33393    sim_cards_charges_off id    DEFAULT     �   ALTER TABLE ONLY public.sim_cards_charges_off ALTER COLUMN id SET DEFAULT nextval('public.sim_cards_charges_off_id_seq'::regclass);
 G   ALTER TABLE public.sim_cards_charges_off ALTER COLUMN id DROP DEFAULT;
       public       postgres    false    229    230    230                       2604    34017    software_v id    DEFAULT     n   ALTER TABLE ONLY public.software_v ALTER COLUMN id SET DEFAULT nextval('public.software_v_id_seq'::regclass);
 <   ALTER TABLE public.software_v ALTER COLUMN id DROP DEFAULT;
       public       postgres    false    235    236    236            �
           2604    33956    terminals id    DEFAULT     l   ALTER TABLE ONLY public.terminals ALTER COLUMN id SET DEFAULT nextval('public.terminals_id_seq'::regclass);
 ;   ALTER TABLE public.terminals ALTER COLUMN id DROP DEFAULT;
       public       postgres    false    202    203    203            �
           2604    33228    terminals_charges id    DEFAULT     |   ALTER TABLE ONLY public.terminals_charges ALTER COLUMN id SET DEFAULT nextval('public.terminals_charges_id_seq'::regclass);
 C   ALTER TABLE public.terminals_charges ALTER COLUMN id DROP DEFAULT;
       public       postgres    false    215    214    215                       2604    33247    terminals_charges_off id    DEFAULT     �   ALTER TABLE ONLY public.terminals_charges_off ALTER COLUMN id SET DEFAULT nextval('public.terminals_charges_off_id_seq'::regclass);
 G   ALTER TABLE public.terminals_charges_off ALTER COLUMN id DROP DEFAULT;
       public       postgres    false    217    216    217                       2604    33978    terminals_disassembled id    DEFAULT     �   ALTER TABLE ONLY public.terminals_disassembled ALTER COLUMN id SET DEFAULT nextval('public.terminals_disassembled_id_seq'::regclass);
 H   ALTER TABLE public.terminals_disassembled ALTER COLUMN id DROP DEFAULT;
       public       postgres    false    232    231    232            �
           2604    24933    terminals_num id    DEFAULT     t   ALTER TABLE ONLY public.terminals_num ALTER COLUMN id SET DEFAULT nextval('public.terminals_num_id_seq'::regclass);
 ?   ALTER TABLE public.terminals_num ALTER COLUMN id DROP DEFAULT;
       public       postgres    false    200    201    201            �
           2604    33163    users id    DEFAULT     d   ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);
 7   ALTER TABLE public.users ALTER COLUMN id DROP DEFAULT;
       public       postgres    false    204    205    205            �          0    33207    agents 
   TABLE DATA                     public       postgres    false    213   ��       �          0    33286 
   cellphones 
   TABLE DATA                     public       postgres    false    219   Y
      �          0    33307    cellphones_charges 
   TABLE DATA                     public       postgres    false    223   �
      �          0    33315    cellphones_charges_off 
   TABLE DATA                     public       postgres    false    225         �          0    24870    devices 
   TABLE DATA                     public       postgres    false    197   0      �          0    33189    devices_locations 
   TABLE DATA                     public       postgres    false    211   a!                0    34066    devices_softwares 
   TABLE DATA                     public       postgres    false    238   T/                0    34006    devices_types 
   TABLE DATA                     public       postgres    false    234   :      	          0    34085    devices_writes_off 
   TABLE DATA                     public       postgres    false    240   ~:      �          0    33181 	   locations 
   TABLE DATA                     public       postgres    false    209   �:      �          0    33294    models 
   TABLE DATA                     public       postgres    false    221   �;      �          0    33355    num 
   TABLE DATA                     public       postgres    false    226   f<      �          0    33168    priviledges 
   TABLE DATA                     public       postgres    false    207   �<      �          0    24883 	   sim_cards 
   TABLE DATA                     public       postgres    false    199   "=      �          0    33367    sim_cards_charges 
   TABLE DATA                     public       postgres    false    228   �T      �          0    33390    sim_cards_charges_off 
   TABLE DATA                     public       postgres    false    230   U                0    34014 
   software_v 
   TABLE DATA                     public       postgres    false    236    U      �          0    24940 	   terminals 
   TABLE DATA                     public       postgres    false    203   �U      �          0    33225    terminals_charges 
   TABLE DATA                     public       postgres    false    215   Cd      �          0    33244    terminals_charges_off 
   TABLE DATA                     public       postgres    false    217   ]d                0    33975    terminals_disassembled 
   TABLE DATA                     public       postgres    false    232   wd      �          0    24930    terminals_num 
   TABLE DATA                     public       postgres    false    201   �d      �          0    33160    users 
   TABLE DATA                     public       postgres    false    205   �j      (           0    0    agents_id_seq    SEQUENCE SET     =   SELECT pg_catalog.setval('public.agents_id_seq', 287, true);
            public       postgres    false    212            )           0    0    cellphones_charges_id_seq    SEQUENCE SET     H   SELECT pg_catalog.setval('public.cellphones_charges_id_seq', 27, true);
            public       postgres    false    222            *           0    0    cellphones_charges_off_id_seq    SEQUENCE SET     L   SELECT pg_catalog.setval('public.cellphones_charges_off_id_seq', 13, true);
            public       postgres    false    224            +           0    0    cellphones_id_seq    SEQUENCE SET     ?   SELECT pg_catalog.setval('public.cellphones_id_seq', 6, true);
            public       postgres    false    218            ,           0    0    cellphones_models_id_seq    SEQUENCE SET     F   SELECT pg_catalog.setval('public.cellphones_models_id_seq', 8, true);
            public       postgres    false    220            -           0    0    devices_id_seq    SEQUENCE SET     >   SELECT pg_catalog.setval('public.devices_id_seq', 621, true);
            public       postgres    false    196            .           0    0    devices_locations_id_seq    SEQUENCE SET     H   SELECT pg_catalog.setval('public.devices_locations_id_seq', 629, true);
            public       postgres    false    210            /           0    0    devices_softwares_id_seq    SEQUENCE SET     H   SELECT pg_catalog.setval('public.devices_softwares_id_seq', 320, true);
            public       postgres    false    237            0           0    0    devices_types_id_seq    SEQUENCE SET     B   SELECT pg_catalog.setval('public.devices_types_id_seq', 2, true);
            public       postgres    false    233            1           0    0    devices_writes_off_id_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public.devices_writes_off_id_seq', 1, true);
            public       postgres    false    239            2           0    0    locations_id_seq    SEQUENCE SET     >   SELECT pg_catalog.setval('public.locations_id_seq', 6, true);
            public       postgres    false    208            3           0    0    priviledges_id_seq    SEQUENCE SET     @   SELECT pg_catalog.setval('public.priviledges_id_seq', 3, true);
            public       postgres    false    206            4           0    0    sim_cards_charges_off_id_seq    SEQUENCE SET     K   SELECT pg_catalog.setval('public.sim_cards_charges_off_id_seq', 13, true);
            public       postgres    false    229            5           0    0    sim_cards_id_seq    SEQUENCE SET     @   SELECT pg_catalog.setval('public.sim_cards_id_seq', 609, true);
            public       postgres    false    198            6           0    0    sims_charges_id_seq    SEQUENCE SET     B   SELECT pg_catalog.setval('public.sims_charges_id_seq', 42, true);
            public       postgres    false    227            7           0    0    software_v_id_seq    SEQUENCE SET     ?   SELECT pg_catalog.setval('public.software_v_id_seq', 3, true);
            public       postgres    false    235            8           0    0    terminals_charges_id_seq    SEQUENCE SET     H   SELECT pg_catalog.setval('public.terminals_charges_id_seq', 117, true);
            public       postgres    false    214            9           0    0    terminals_charges_off_id_seq    SEQUENCE SET     K   SELECT pg_catalog.setval('public.terminals_charges_off_id_seq', 75, true);
            public       postgres    false    216            :           0    0    terminals_disassembled_id_seq    SEQUENCE SET     K   SELECT pg_catalog.setval('public.terminals_disassembled_id_seq', 6, true);
            public       postgres    false    231            ;           0    0    terminals_id_seq    SEQUENCE SET     @   SELECT pg_catalog.setval('public.terminals_id_seq', 366, true);
            public       postgres    false    202            <           0    0    terminals_num_id_seq    SEQUENCE SET     D   SELECT pg_catalog.setval('public.terminals_num_id_seq', 320, true);
            public       postgres    false    200            =           0    0    users_id_seq    SEQUENCE SET     :   SELECT pg_catalog.setval('public.users_id_seq', 5, true);
            public       postgres    false    204            *           2606    33213    agents agents_pkey 
   CONSTRAINT     P   ALTER TABLE ONLY public.agents
    ADD CONSTRAINT agents_pkey PRIMARY KEY (id);
 <   ALTER TABLE ONLY public.agents DROP CONSTRAINT agents_pkey;
       public         postgres    false    213            8           2606    33321 2   cellphones_charges_off cellphones_charges_off_pkey 
   CONSTRAINT     p   ALTER TABLE ONLY public.cellphones_charges_off
    ADD CONSTRAINT cellphones_charges_off_pkey PRIMARY KEY (id);
 \   ALTER TABLE ONLY public.cellphones_charges_off DROP CONSTRAINT cellphones_charges_off_pkey;
       public         postgres    false    225            6           2606    33312 *   cellphones_charges cellphones_charges_pkey 
   CONSTRAINT     h   ALTER TABLE ONLY public.cellphones_charges
    ADD CONSTRAINT cellphones_charges_pkey PRIMARY KEY (id);
 T   ALTER TABLE ONLY public.cellphones_charges DROP CONSTRAINT cellphones_charges_pkey;
       public         postgres    false    223            4           2606    33299    models cellphones_models_pkey 
   CONSTRAINT     [   ALTER TABLE ONLY public.models
    ADD CONSTRAINT cellphones_models_pkey PRIMARY KEY (id);
 G   ALTER TABLE ONLY public.models DROP CONSTRAINT cellphones_models_pkey;
       public         postgres    false    221            2           2606    33291    cellphones cellphones_pkey 
   CONSTRAINT     X   ALTER TABLE ONLY public.cellphones
    ADD CONSTRAINT cellphones_pkey PRIMARY KEY (id);
 D   ALTER TABLE ONLY public.cellphones DROP CONSTRAINT cellphones_pkey;
       public         postgres    false    219            (           2606    33194 (   devices_locations devices_locations_pkey 
   CONSTRAINT     f   ALTER TABLE ONLY public.devices_locations
    ADD CONSTRAINT devices_locations_pkey PRIMARY KEY (id);
 R   ALTER TABLE ONLY public.devices_locations DROP CONSTRAINT devices_locations_pkey;
       public         postgres    false    211                       2606    24876    devices devices_pkey 
   CONSTRAINT     R   ALTER TABLE ONLY public.devices
    ADD CONSTRAINT devices_pkey PRIMARY KEY (id);
 >   ALTER TABLE ONLY public.devices DROP CONSTRAINT devices_pkey;
       public         postgres    false    197            D           2606    34072 (   devices_softwares devices_softwares_pkey 
   CONSTRAINT     f   ALTER TABLE ONLY public.devices_softwares
    ADD CONSTRAINT devices_softwares_pkey PRIMARY KEY (id);
 R   ALTER TABLE ONLY public.devices_softwares DROP CONSTRAINT devices_softwares_pkey;
       public         postgres    false    238            @           2606    34011     devices_types devices_types_pkey 
   CONSTRAINT     ^   ALTER TABLE ONLY public.devices_types
    ADD CONSTRAINT devices_types_pkey PRIMARY KEY (id);
 J   ALTER TABLE ONLY public.devices_types DROP CONSTRAINT devices_types_pkey;
       public         postgres    false    234                       2606    24987    devices devices_ukey 
   CONSTRAINT     M   ALTER TABLE ONLY public.devices
    ADD CONSTRAINT devices_ukey UNIQUE (sn);
 >   ALTER TABLE ONLY public.devices DROP CONSTRAINT devices_ukey;
       public         postgres    false    197            F           2606    34091 *   devices_writes_off devices_writes_off_pkey 
   CONSTRAINT     h   ALTER TABLE ONLY public.devices_writes_off
    ADD CONSTRAINT devices_writes_off_pkey PRIMARY KEY (id);
 T   ALTER TABLE ONLY public.devices_writes_off DROP CONSTRAINT devices_writes_off_pkey;
       public         postgres    false    240            &           2606    33186    locations locations_pkey 
   CONSTRAINT     V   ALTER TABLE ONLY public.locations
    ADD CONSTRAINT locations_pkey PRIMARY KEY (id);
 B   ALTER TABLE ONLY public.locations DROP CONSTRAINT locations_pkey;
       public         postgres    false    209            ,           2606    33360    agents off_num_uk 
   CONSTRAINT     O   ALTER TABLE ONLY public.agents
    ADD CONSTRAINT off_num_uk UNIQUE (off_num);
 ;   ALTER TABLE ONLY public.agents DROP CONSTRAINT off_num_uk;
       public         postgres    false    213            $           2606    33173    priviledges priviledges_pkey 
   CONSTRAINT     Z   ALTER TABLE ONLY public.priviledges
    ADD CONSTRAINT priviledges_pkey PRIMARY KEY (id);
 F   ALTER TABLE ONLY public.priviledges DROP CONSTRAINT priviledges_pkey;
       public         postgres    false    207            <           2606    33395 0   sim_cards_charges_off sim_cards_charges_off_pkey 
   CONSTRAINT     n   ALTER TABLE ONLY public.sim_cards_charges_off
    ADD CONSTRAINT sim_cards_charges_off_pkey PRIMARY KEY (id);
 Z   ALTER TABLE ONLY public.sim_cards_charges_off DROP CONSTRAINT sim_cards_charges_off_pkey;
       public         postgres    false    230                       2606    24888    sim_cards sim_cards_pkey 
   CONSTRAINT     V   ALTER TABLE ONLY public.sim_cards
    ADD CONSTRAINT sim_cards_pkey PRIMARY KEY (id);
 B   ALTER TABLE ONLY public.sim_cards DROP CONSTRAINT sim_cards_pkey;
       public         postgres    false    199            :           2606    33372 #   sim_cards_charges sims_charges_pkey 
   CONSTRAINT     a   ALTER TABLE ONLY public.sim_cards_charges
    ADD CONSTRAINT sims_charges_pkey PRIMARY KEY (id);
 M   ALTER TABLE ONLY public.sim_cards_charges DROP CONSTRAINT sims_charges_pkey;
       public         postgres    false    228            B           2606    34019    software_v software_v_pkey 
   CONSTRAINT     X   ALTER TABLE ONLY public.software_v
    ADD CONSTRAINT software_v_pkey PRIMARY KEY (id);
 D   ALTER TABLE ONLY public.software_v DROP CONSTRAINT software_v_pkey;
       public         postgres    false    236            0           2606    33249 0   terminals_charges_off terminals_charges_off_pkey 
   CONSTRAINT     x   ALTER TABLE ONLY public.terminals_charges_off
    ADD CONSTRAINT terminals_charges_off_pkey PRIMARY KEY (id, users_id);
 Z   ALTER TABLE ONLY public.terminals_charges_off DROP CONSTRAINT terminals_charges_off_pkey;
       public         postgres    false    217    217            .           2606    33231 (   terminals_charges terminals_charges_pkey 
   CONSTRAINT     f   ALTER TABLE ONLY public.terminals_charges
    ADD CONSTRAINT terminals_charges_pkey PRIMARY KEY (id);
 R   ALTER TABLE ONLY public.terminals_charges DROP CONSTRAINT terminals_charges_pkey;
       public         postgres    false    215            >           2606    33981 2   terminals_disassembled terminals_disassembled_pkey 
   CONSTRAINT     p   ALTER TABLE ONLY public.terminals_disassembled
    ADD CONSTRAINT terminals_disassembled_pkey PRIMARY KEY (id);
 \   ALTER TABLE ONLY public.terminals_disassembled DROP CONSTRAINT terminals_disassembled_pkey;
       public         postgres    false    232                       2606    24935     terminals_num terminals_num_pkey 
   CONSTRAINT     ^   ALTER TABLE ONLY public.terminals_num
    ADD CONSTRAINT terminals_num_pkey PRIMARY KEY (id);
 J   ALTER TABLE ONLY public.terminals_num DROP CONSTRAINT terminals_num_pkey;
       public         postgres    false    201                       2606    24937     terminals_num terminals_num_ukey 
   CONSTRAINT     c   ALTER TABLE ONLY public.terminals_num
    ADD CONSTRAINT terminals_num_ukey UNIQUE (terminal_num);
 J   ALTER TABLE ONLY public.terminals_num DROP CONSTRAINT terminals_num_ukey;
       public         postgres    false    201                        2606    33958    terminals terminals_pkey 
   CONSTRAINT     V   ALTER TABLE ONLY public.terminals
    ADD CONSTRAINT terminals_pkey PRIMARY KEY (id);
 B   ALTER TABLE ONLY public.terminals DROP CONSTRAINT terminals_pkey;
       public         postgres    false    203            "           2606    33165    users users_pkey 
   CONSTRAINT     N   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);
 :   ALTER TABLE ONLY public.users DROP CONSTRAINT users_pkey;
       public         postgres    false    205            \           2606    33378 )   sim_cards_charges agents_sc_charges_id_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.sim_cards_charges
    ADD CONSTRAINT agents_sc_charges_id_fk FOREIGN KEY (agent_id) REFERENCES public.agents(id);
 S   ALTER TABLE ONLY public.sim_cards_charges DROP CONSTRAINT agents_sc_charges_id_fk;
       public       postgres    false    2858    228    213            U           2606    33300 "   cellphones cellphones_cp_models_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.cellphones
    ADD CONSTRAINT cellphones_cp_models_fk FOREIGN KEY (model_id) REFERENCES public.models(id);
 L   ALTER TABLE ONLY public.cellphones DROP CONSTRAINT cellphones_cp_models_fk;
       public       postgres    false    221    219    2868            W           2606    33335     cellphones_charges cpc_agents_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.cellphones_charges
    ADD CONSTRAINT cpc_agents_fk FOREIGN KEY (agent_id) REFERENCES public.agents(id);
 J   ALTER TABLE ONLY public.cellphones_charges DROP CONSTRAINT cpc_agents_fk;
       public       postgres    false    213    223    2858            V           2606    33330 $   cellphones_charges cpc_cellphones_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.cellphones_charges
    ADD CONSTRAINT cpc_cellphones_fk FOREIGN KEY (cellphone_id) REFERENCES public.cellphones(id);
 N   ALTER TABLE ONLY public.cellphones_charges DROP CONSTRAINT cpc_cellphones_fk;
       public       postgres    false    219    2866    223            X           2606    33340    cellphones_charges cpc_users_fk    FK CONSTRAINT     ~   ALTER TABLE ONLY public.cellphones_charges
    ADD CONSTRAINT cpc_users_fk FOREIGN KEY (user_id) REFERENCES public.users(id);
 I   ALTER TABLE ONLY public.cellphones_charges DROP CONSTRAINT cpc_users_fk;
       public       postgres    false    205    2850    223            Y           2606    33345 "   cellphones_charges_off cpco_cpc_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.cellphones_charges_off
    ADD CONSTRAINT cpco_cpc_fk FOREIGN KEY (cellphone_charge_id) REFERENCES public.cellphones_charges(id);
 L   ALTER TABLE ONLY public.cellphones_charges_off DROP CONSTRAINT cpco_cpc_fk;
       public       postgres    false    225    2870    223            Z           2606    33350 $   cellphones_charges_off cpco_users_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.cellphones_charges_off
    ADD CONSTRAINT cpco_users_fk FOREIGN KEY (user_id) REFERENCES public.users(id);
 N   ALTER TABLE ONLY public.cellphones_charges_off DROP CONSTRAINT cpco_users_fk;
       public       postgres    false    2850    225    205            H           2606    34031 #   devices devices_device_type_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.devices
    ADD CONSTRAINT devices_device_type_id_fkey FOREIGN KEY (device_type_id) REFERENCES public.devices_types(id);
 M   ALTER TABLE ONLY public.devices DROP CONSTRAINT devices_device_type_id_fkey;
       public       postgres    false    2880    234    197            G           2606    34026    devices devices_model_id_fkey    FK CONSTRAINT     ~   ALTER TABLE ONLY public.devices
    ADD CONSTRAINT devices_model_id_fkey FOREIGN KEY (model_id) REFERENCES public.models(id);
 G   ALTER TABLE ONLY public.devices DROP CONSTRAINT devices_model_id_fkey;
       public       postgres    false    221    197    2868            a           2606    34073 2   devices_softwares devices_softwares_device_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.devices_softwares
    ADD CONSTRAINT devices_softwares_device_id_fkey FOREIGN KEY (device_id) REFERENCES public.devices(id);
 \   ALTER TABLE ONLY public.devices_softwares DROP CONSTRAINT devices_softwares_device_id_fkey;
       public       postgres    false    2838    197    238            b           2606    34078 6   devices_softwares devices_softwares_software_v_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.devices_softwares
    ADD CONSTRAINT devices_softwares_software_v_id_fkey FOREIGN KEY (software_v_id) REFERENCES public.software_v(id);
 `   ALTER TABLE ONLY public.devices_softwares DROP CONSTRAINT devices_softwares_software_v_id_fkey;
       public       postgres    false    236    2882    238            c           2606    34092 4   devices_writes_off devices_writes_off_device_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.devices_writes_off
    ADD CONSTRAINT devices_writes_off_device_id_fkey FOREIGN KEY (device_id) REFERENCES public.devices(id);
 ^   ALTER TABLE ONLY public.devices_writes_off DROP CONSTRAINT devices_writes_off_device_id_fkey;
       public       postgres    false    2838    240    197            N           2606    33195    devices_locations dl_devices_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.devices_locations
    ADD CONSTRAINT dl_devices_fk FOREIGN KEY (device_id) REFERENCES public.devices(id);
 I   ALTER TABLE ONLY public.devices_locations DROP CONSTRAINT dl_devices_fk;
       public       postgres    false    2838    211    197            O           2606    33200 !   devices_locations dl_locations_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.devices_locations
    ADD CONSTRAINT dl_locations_fk FOREIGN KEY (location_id) REFERENCES public.locations(id);
 K   ALTER TABLE ONLY public.devices_locations DROP CONSTRAINT dl_locations_fk;
       public       postgres    false    209    2854    211            ^           2606    33396 (   sim_cards_charges_off sc_charges_scco_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.sim_cards_charges_off
    ADD CONSTRAINT sc_charges_scco_fk FOREIGN KEY (sim_card_charge_id) REFERENCES public.sim_cards_charges(id);
 R   ALTER TABLE ONLY public.sim_cards_charges_off DROP CONSTRAINT sc_charges_scco_fk;
       public       postgres    false    228    2874    230            [           2606    33373 )   sim_cards_charges sim_cards_sc_charges_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.sim_cards_charges
    ADD CONSTRAINT sim_cards_sc_charges_fk FOREIGN KEY (sim_id) REFERENCES public.sim_cards(id);
 S   ALTER TABLE ONLY public.sim_cards_charges DROP CONSTRAINT sim_cards_sc_charges_fk;
       public       postgres    false    228    2842    199            P           2606    33237    terminals_charges tc_agents_fk    FK CONSTRAINT        ALTER TABLE ONLY public.terminals_charges
    ADD CONSTRAINT tc_agents_fk FOREIGN KEY (agent_id) REFERENCES public.agents(id);
 H   ALTER TABLE ONLY public.terminals_charges DROP CONSTRAINT tc_agents_fk;
       public       postgres    false    215    2858    213            R           2606    33959 !   terminals_charges tc_terminals_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.terminals_charges
    ADD CONSTRAINT tc_terminals_fk FOREIGN KEY (terminal_id) REFERENCES public.terminals(id);
 K   ALTER TABLE ONLY public.terminals_charges DROP CONSTRAINT tc_terminals_fk;
       public       postgres    false    215    2848    203            Q           2606    33250    terminals_charges tc_users    FK CONSTRAINT     y   ALTER TABLE ONLY public.terminals_charges
    ADD CONSTRAINT tc_users FOREIGN KEY (user_id) REFERENCES public.users(id);
 D   ALTER TABLE ONLY public.terminals_charges DROP CONSTRAINT tc_users;
       public       postgres    false    205    2850    215            T           2606    33260    terminals_charges_off tco_tc_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.terminals_charges_off
    ADD CONSTRAINT tco_tc_fk FOREIGN KEY (terminal_charge_id) REFERENCES public.terminals_charges(id);
 I   ALTER TABLE ONLY public.terminals_charges_off DROP CONSTRAINT tco_tc_fk;
       public       postgres    false    2862    215    217            S           2606    33255 "   terminals_charges_off tco_users_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.terminals_charges_off
    ADD CONSTRAINT tco_users_fk FOREIGN KEY (users_id) REFERENCES public.users(id);
 L   ALTER TABLE ONLY public.terminals_charges_off DROP CONSTRAINT tco_users_fk;
       public       postgres    false    2850    217    205            J           2606    24951    terminals terminals_devices_fk1    FK CONSTRAINT        ALTER TABLE ONLY public.terminals
    ADD CONSTRAINT terminals_devices_fk1 FOREIGN KEY (pda_id) REFERENCES public.devices(id);
 I   ALTER TABLE ONLY public.terminals DROP CONSTRAINT terminals_devices_fk1;
       public       postgres    false    2838    197    203            K           2606    24956    terminals terminals_devices_fk2    FK CONSTRAINT     �   ALTER TABLE ONLY public.terminals
    ADD CONSTRAINT terminals_devices_fk2 FOREIGN KEY (printer_id) REFERENCES public.devices(id);
 I   ALTER TABLE ONLY public.terminals DROP CONSTRAINT terminals_devices_fk2;
       public       postgres    false    203    2838    197            `           2606    33983 :   terminals_disassembled terminals_disassembled_terminals_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.terminals_disassembled
    ADD CONSTRAINT terminals_disassembled_terminals_fk FOREIGN KEY (terminal_id) REFERENCES public.terminals(id);
 d   ALTER TABLE ONLY public.terminals_disassembled DROP CONSTRAINT terminals_disassembled_terminals_fk;
       public       postgres    false    203    232    2848            L           2606    24961     terminals terminals_sim_cards_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.terminals
    ADD CONSTRAINT terminals_sim_cards_fk FOREIGN KEY (sim_cards_id) REFERENCES public.sim_cards(id);
 J   ALTER TABLE ONLY public.terminals DROP CONSTRAINT terminals_sim_cards_fk;
       public       postgres    false    203    2842    199            I           2606    24946 $   terminals terminals_terminals_num_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.terminals
    ADD CONSTRAINT terminals_terminals_num_fk FOREIGN KEY (terminals_num_id) REFERENCES public.terminals_num(id);
 N   ALTER TABLE ONLY public.terminals DROP CONSTRAINT terminals_terminals_num_fk;
       public       postgres    false    203    201    2844            M           2606    33174    users users_priviledges_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_priviledges_fk FOREIGN KEY (priviledge_id) REFERENCES public.priviledges(id);
 D   ALTER TABLE ONLY public.users DROP CONSTRAINT users_priviledges_fk;
       public       postgres    false    2852    207    205            ]           2606    33383 %   sim_cards_charges users_sc_charges_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.sim_cards_charges
    ADD CONSTRAINT users_sc_charges_fk FOREIGN KEY (user_id) REFERENCES public.users(id);
 O   ALTER TABLE ONLY public.sim_cards_charges DROP CONSTRAINT users_sc_charges_fk;
       public       postgres    false    2850    228    205            _           2606    33401 #   sim_cards_charges_off users_scco_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.sim_cards_charges_off
    ADD CONSTRAINT users_scco_fk FOREIGN KEY (user_id) REFERENCES public.users(id);
 M   ALTER TABLE ONLY public.sim_cards_charges_off DROP CONSTRAINT users_scco_fk;
       public       postgres    false    2850    205    230            �   Z  x��]�n�8��+���%�Al��,f���M�%W���
*���D�'�G:��k�K��ហw�c��y�!��o����?~��=\�͠�~��n\n?����Yͷ��Q^�ǇA����?����A>-j�~z��?���_~��=>���k/��~V�������>���������i��,�m�c?���/��!�z%9t�M����/�dv� s��rT�`P�A��s�2jaV(�~��:v�;S���Ҭr�'9���_�
+����ʑ�h��/��h�aN�lxꖀ' x�����Nx��˥k�,d�1U����-����G޾�Q��V]`Nո����|�~�k��F����(�lY�݅ ���(�6�x��g�{#�-ؗ�5�h�F�����O+�"M(j��ZP�f�
��L�Ӌl���+�[�t��I�\��L���Ǭ3����	�~�A��֘�f���m��$��F�+���#6)���ϝ� �lC�!)�c�I Y�K �.�(�a3N�f[y�!)����Τtn��;��`���e���ڂ���c�A�<�gS;E�J��N����4�}��@'+��U��p�f�,`����f�s���9J�pn�Iy�Ʈ��"�7/0��]�8&L嶑T3Ͷu��m�@mU^lU��=�J3�c�^�XC����,r��i8�.�sr����.��T�AA�V.(�mux?=�Uw�|r����c�u���،cb"gqL�-S��3�qn���֬_�:Ę�5��uL�Y`��پâKq{�O�rK��-�p��N .����� ��P�β}�p1qߘK ~�{{�C0���&*��Y�u�Bq�m�ȢDܮ?�-N@1�Z���EǨ5�d��~
�3�����	q���9��(��hwUSb���v�}��Q�w�@LɘTHe���w�y�X��>D4�z&hom�$���M��)�����q��ez
���PR�ԝm�_u�U�2]-h�)��{XU��9��C��>�N1*��*s����1mM�S�%as��
�m��m��d�G-@;\��1Su�!^l2'j����d��FeM϶�o�:?a�K��R���i��!1Rutz����Q̯�i{ߵ�qF���>2w9��0c���&&_n��9��0;����'KF01q�*lC�n4�^w�Ǡ΢21�Y.�B�ﯲI�
�[�8"*����9���j��J�p���.ˏ��
߾����#Cw�nr��\�7q��ɬ5���a>< �����&�<�oNbf�Ƃg�$^1�q�W"C뒘��E����1�9��$�c�Ү^��IM:����jP�S��"5ݾ{qx�5�i˿�X�]EK�ԁ�YJ}3������q�u2��'C�xNr��8ua��ٱV�l�s�rPe2��:w�g�cMH$�1!I)�u�}����l�ž
��M�Q�z���t��MՎ�!�m
&0���+����5Nq�x��$G�L���t	T /Q�NW�8��z��"T�J�H�]R�
�5n3x�	R�ԹQ���S3�e�@Q��u6mUj�%H�zL��&P����%ʚ��!U'��K��
e�&Lg5lQYj��V��w����-�\�L���!4�'9L%��(�t�v�������/��J��m;w� ڇ�[g��r��=�>�t�^��b��s�l�t�1կ���=�`c��D4�����6{�sDN��1^c�HR9Rv�}�c @�aF�u�a����j�0�֤�K���K3jn|WE��,s����sE� �=ɴW5nB9yid`� �,ߊe�9S�  �!��ir:����u��E��iw[i\�(�N�!	U�N�a�Ӟu
�����E�� ��d�Ѧ�议8m�CE9����r�ж��9�(8 �=�핶�[��XA��۾�O�Ҥ8�<�}���*@J#F�ؒOQ,.@r#ҹ���A�*�2�2ɱ�'qJ�EYTJ���l����m��NU5s�D]���a�R�����3�
t���҄g��P@��I���~��D�
r H����)����H�mR���Uk�tтQ>��]������.ht�xr�m��c��e����m�t�# E�1l{q��P��k��������H{��]�H��F�VuN�A�V�]M�u˂Y�v$76ݪdŠPU�I����1H����.B�^ԍv�o��ۘ����Y��Kzw��g.�,"��+��G��+���Z�싑z���\��ɓ��(p��b����]{9��M�ܺ�
��].YR[L��&���{��[�k֨�u���Ng3Y��Q�ꦩ�jM�`�@]`��&�v���Y�|�$���m�����;�4��n��@�vYDu��z��C��AnT��b�����#�u�~��r�ݓՂ����)OӒ����I��!L�Q�N��LW�l2Ȝ+�}"��[����U?O$^+P�"XU���D�~Ө���I��e��
T�U� QiP�����G:WÂ�O�k���xL�t�v�L�^�j<LJ��(C�,�K�&N�[;#�=|�����e��t�'�u���c�L�W�DU\)�B��f0u� 	�%�.*0�{Ҡ�̻QS�Q�	�}��?�;46h�I KÒ�rG��"��s�q��Ǧ�S�ڜ[בL���8��B1�b�܈aW*�x#����a����kt������&��u�wl��#�7U4�PM��H�H��Nͬw}��8��2����N�!PwE2��I�z��|:�eP����]M����BAvt�ɳ��BA�@F�oL�i�/r	��gI���uVMA�o���S[�ۍ�A2��X��Ǧ�ށ���
ܫt����:Е��(�Hq��o_mCP�����G�޿w��q��dFV�M��_���bAAB��1l;���2�Oo�����m5$(2��?�'2s��2%w��������bڏ�T�q%��q5.ʤ��痢E�� �Q���))T��f��)Qd��^3i����T�bALIF�h2�N1(�� �w���0A�D����%4;%��!P����
��^I����[���Yf8M������@��)<$��hD�5ջ<;!e�R��b��л��b	��ҋ������܍q�^�ȯ�t���-9.��f����� *���If�O�B���6σqm�J5��D5��};ɥ��L����"���Ҧ}�%˭B��X�W/̝�������V(WJ>����� A�zs[o����n��3�t�,���ǖ�@Q�>�`��S Rº��3�=�F�B������I7���:?m�@���ʽ���r��@U���F���FEYT�z����b'*���q���dU��DB��ɟݻ0�]V����W4*To[|�(��_f"e�
4����o�ћ'!7����w����T֐�;����4]�����H�����.� 	�%+�6��ٷ@� ��I���C�3 s&���=8��DE���[Wʟ�{!@�Lڡ�9���o�M6����h��w:w�Ҙ���X�1���o������/�#����X��S��S�XP�X�Wa��(+����N*�cI�廑�^E�I��Tҥ�~�ǚ�      �   �   x���=�0��=��n*��x�q�S�@�Pm�B5` V����tk�3=��u}{�u���3��0��y}�7�aⰬ���}�Ň
��������D���(�����h��M�Z�LSTa.��|I(�LT�O���D����e�e���      �   
   x���          �   
   x���          �      x���M�m�qE���'�f}���A,��rW$�[186��g�^�ZU���j�ɂ�s��kW�5ꫯ����������������?������������/~���������O����~��_�x��}��_������|�����?���O_�۷�����_�},L9C����Ͽ����|���◿���皳����x5W�9����ܵ�E�ëyJͽ?�\�Vs��s"j�W��QSx5���'j*��֚5�W�JM[Q�y5+�,����Ь�x>�C�r�����Ь��s�84+�48�yZ�C�W6�C�rH�Y�<��!�6�C�rH�{�yZ�CzN�V��6�C�rH���ǡU9��s�8�^8��7�C�rH�|{xڕC��v�и5y�/�s��qhW!����Ю����Ю�{��Ю���ǡ]9t�lrxڕC'�wxڕC�ӳ"�ǡS9tV��q�T��<�ʡ�Q�ǡS9tN��q�T�5y:�Cǣ&�C�r�{���y9��-�C��<t?O�N��Y�CD(x ¨$� .x$¨(Ey(¨,�"�X�Qa$�(F/��xJ��F�јQ��#��(��F�؃$�"�##D"�i�H$���oQ"�P�4�9"�P�4�"���.�GF�DB%ҊߧB$*��}d�DB%Ҽ?)�H�D�qr"�P���J$�T"����$A$���s��$R��/q%I��o��$V��s�D"�ע��K$��Z4��D"ɪEJ$��Z4^ڔH$9�h�7"�t���jD"i%R��ňD�J���oD"i%�}7"�����H$�D����HZ�.1"���v��H$�D�q��HZ�3hq"��)��D"Y%��#9�HV��vq"��)f��D"Y%R�SĉD�J�����d�H-'�*�n�ՉD�J���v"���6$'�H^�t{�H$�D� �$�+�4�4�D�J$"M"��I�H�H$�D� 1��D� 1��D�Ĝ���J��#
1��D����������w_>/���ۯ?���������}>u!����Ђ��8fe��9p����
1�YYh�Bb��0"�B��cVF�W�Yp����1�YYI{!��1+-XH��cVZ���ǪD� 1�U��a��ǪD�k"B��cU"��1!f±*��R�C�X�HqcM��p�J���&�X8V%����p�J$"��X�Hq�K��p�J���&�h8v%����ؕH3�D�cW"�51�]�t���x8v%�"��ؕH7�A�cW"� 1!�]�4�HĈ8v%RDu��ǩDZ#��t*�"�Ĕ8N%Ғ(J$ҩD�|�s�8�Hˢ(�H�)R3JL��T"�E�D:�HkEQ"�N%��Q�H�S���HĴ��J�D"��eT"� 1-.�i��iq�H;�DL�˨D�A$bZ����x�h�~1W,uX�+qX,uX�+qX,uX�+qX,uX�+qX,uX�+qX,uX�+qX,uX�+qX,uX�+qX,uX�+qX,uX�+qX,uX�+qX,uX�+qX,uX�+qX,uX�+qX,uX�+qX,uX�+qX,uX�+qX,uX�+qX,uX�+qX,ud��*qd+5���m+1�-5���m+1�-5���m+1�-5���m+1�-5���m+1�-5���m+1�-5���m+1�-5���m+1�-5���m+1�-5���m+1�-5���m+1�-5���m+1�-5���m+1�-5���m+1�-����*����*����*����*����*�������������������������������)�^F4f�D�A$�1CG%�"�:*�B�lDc��J�D"v��H'�D4f(*�fDc��)fF4f(*��afDc��)�{F4f(*��(fDc��)�F4f(*�beDc��)$q�4f�I���9;��D�_����D�_����D�_����D�_����D�_����D�_��E��H#*fTʯ���GQ�{xEC�]���Z2��ĳ�Ւ!G'�콖?0�\?k��wO�+���e�~ג!��:���l��6�R3��`��*�w���� �7`��*��<�7�k�wb^��5����ЭZ3~�05t�ּ�[f����OR9c&0/R��tR��zk2����t�bČ�-�?w�sKx�@��ɋ�>+�	H�a��y Նy��1�,r����Vf��@�0h�P�@L0h�P�ك`��!�?'���¡8�Z9��@L/��b�8��Z9���Il2�p���ĩǋ�7�C�䂽8y��
1�`�C1������ߌ����~��f�.������S�Ϧ�9^M5�}V��ș͑3x�}?�}�,��+{����+�T�Ze�7l���*Ob�*�Vy+�Ty�ʛW������n��2R��Z�=�ê���@d�&���0��a�1D�ib�j�a���@d�&���0��a�1D�ib�j�a���@d�%���0!2��vc�f�a�1L��İ��D�yb�iS"�<1�4�)�a�vÔ�0O;�aJd�'���0%2l&���0%2l&���0#2l^���fD�MM�ÌȰi�rc�6=Un3"��L�ÌȰ�R��0#2l�T�1̈�'Un3"��H�ÌȰ�T�1̉[�ahs"�VbÜȰ���0'2l%��1̉[�ahs"�VbÜȰ���0'2l%��1̉ۉahs"�vb�&�a;1L�&�a;1L�&�a;1L�&�a;1L�&�a;1L�&�a;1L�&�a;1L�&�a;1L�&�a'1L�&�a'1L��a'1L��a'1L��a'1L��a'1L��a'1L��a'1L��a'1L��a'1L��a6ô1l�f#1L�6�a6ì1l�f#1��6�a6ì1l�f#1��6�a6ì1l�f#1��6�a6ì1l�f#1��6�aH�ư�c�[|����y!~�H��F�C�'=����D���=��H��F�C�'=����DOo�<Dz"��=�J��F�C�'=����)����y�'@I�W�av�Rs��Y)�ʡ�!%^M���R��d�ʡ�!%^O���R�e�ʡ�!e���rh�rH�ע�*�F(��x/Z�rh�rH���*�F(��x3Z�rh�rH�W��*�F(��x7Z�rh�rH����*�F(��x;Z�rh��A�ף�TFx�y?�T
e^��j:
��RoHW�Q(M�yEZ��(�&ʼ#-�t�e^��E�H�[�2k� �t]q�Xq���RW#V+qű�ǈ�J\q,u�1bűWK]q�Xq���RW#V+qű�ǈ�J\q,u�1bűWK]q�Xq���RW#V+qű�ǈ[�J\q,u�1bűWK]q�Xq���RW#V+qű�ǈ�J\q,u�1B���RW#V+qű�ǈ�J\q,u�1����RW#V+qű�ǈ�J\q,u�1B����RW#Vqű���WK]q�Xql��RW#�DF\q,u�1f��v/���b� ^ȵ{!���:@�B���O��
�r�F����a���~��O���Y�Qf�Q����,�(��(�S��sb��o����:(b��o����:(b��o�y�y�1��;E+N�V��~��O��a���~��O��a���~���g!F��$����B�2�Ikן�e��֮?1��'1�]b��ObX��,�(��(������~��O��0b��o����F�2��2?�ÈQ�y��O��0b�y�(�S�1�e�2��c~}�A��ؕ�<�[x�(��+�y�`��3�2�2������Ʈ���<�(�1�T��y�pӳ*��V���a�gUN���
ʇ��U9�?�+(`�-�?�+(�zV�İv��\O��a�
ʇ��U91�]A��س*'��+(.{V�İv��hϪ�֮��(�2OkWP@Z�'��+( 
�����V�a�

�B+�İvD���İvD���İvD���İvD���İvD���İvD���İv   D���İvD���İvD���İvD���İvD���İ~�(����4� 
�l%�5�:�B+[�aM����VbXӬ�(����4� 
�l%�5�:�B+[�aM����VbXӬ�(����4� 
�,M�GӬ�8�4M����x4�:�S`KS��4� N�-M�GӬ�8�4M����x4�:�S`KS��4� N�-M�GӬ�8�4M����x4�:�S`KS��4� N�-M�GӬ�8�4�1�8�4�1�8�4-+���x���S`KS�ѲR N�-M�G�J�8�4-+��J���t� .�2I�s����8�$=�M���,��<7]/���L���t� .�2I�s����8�$=�M���,��<7]/���Lә��zA\�e��$M���,�İ��qq�ibX����8�41��zA\������Y�]fO]fo��B�2{�2{{b��S������̞���ޟ��e��e���,�.��.���g!v�=u���?�������Y�]fO]fo��B�2{�2{{b��S������̞���ޟ��e��e���,�.���9ۺ!�k�U�>���LT�Ϋ�}*�癨��W]�Tn�3Q];��vζ�F���9Rf��?Q];Gʬ��g!�k�H����,Du�Dʬ��g!�k'Rf��?Q ;��ޟ�(��Hk��B�N$���g!
d'������a��Y�ىİ��,D��DbX{�@v"1��?Q ;%1��T�(�����+S *����K�'i�G��u��ִ�I4	X���&Omb^k��9y5g��nM���V�y�w��5�]�n5j�&vj�����YM|��!��Ȥ�j"���_~�QH5+����<y�P��>(���C~�ny�t�t4���I=�'ͺ �}RO��Ѭ �<�F�.��_��_ͺ b�Sa4���O��Ѭ �<�F�.��_��_ͺ b�Sa4���O��Ѭ`��I�4���O�4���O�4���O�4���O�4���O�4���O��.<��O��.<��O��.<��O��.<��O��.<���)��ͣ'����7��Sl�Rl�\&BL�yJ�ys�1��)���e"����7��Sl�Rl�\&BL�yJ�ys�1��)���e"����7��Sl�Rl�\&BL�yJ�ys�1��)���e"�[Zi��e"ĕf�l��\&B��z��zs��K�Yo.a�f��˛�D��/O�/o.!�<���L�h��d���2��˓�˛�D��/O�/o.!�<���L�h��d���2��˓w˛QD��-O�-oF!z�<y��E�������f�w˓w˛QD��-O�-oF!z�<y��E�������f�w˓w˛QD��-O�-oF!z�<y��E�������f�w˓w˛QD��-O�-oF!z�<y��E�������f�w˓w˛QD��-��0�-�>��0�簧r[:O<��=�=���y�9L�y��ܖ�ͫzO�O�t�x�{|*�������S�-�'� �� �ʯ'�A<�=�n���<&��77�d��g��/�W��      �   �  x���ͪl�F�>�iF�����H+B0M����&y��1�o0vËWaq���]s�9��_��W����o���ǿ��?������~�����������?����?}��?Ͽ����|��?��_}��>����_�ዯ�uYV_�y���W}]���U�תo{�y|��yոV}ռVM}պV-}վVm}չV}�+���_��f=�_���{��O���)0��9��z�'�џ���}��	p��������չ� G
��	p�� �������+G��+WG�ֹru�l=�\=�l=�\=�l=�\=�l�����+WO=[�+WO=[�+WO=[�+WO=[�+WO=[�+WO=[�+W/=[�+W/=[�+W/=[�+W/=[�+W/=[�+W/=[�+W/=[�+W/=[�+W/=[�+W/=[�+Wo=[�+Wo=[�+Wo=[�+Wo��q��g�}��g�}��g�}��g�}��g���P�V<���.�?��O��`���p8��0�?#��O	�a�s�pH��0�?+��O��#x�C<���>���9l�Wa���g���ק����羱��'�1��������U���"U���BU���bU��ƂU��ƢU����U��ƖP~[B�uTl	��Q�%�_GŖP~[B�uTl	��Q�%�_GŖP~[B�PG-r��k,t��k,v��k,x��k,z��k,|�	l,~�l,��)l,��9l,��Il,��Yl,2��i,4��i,6��i,8��i,:��i,<�	j,>�j,@�)j,B�9j,D�Ij,F�Yj,H�ij,J�yj�R������ ���Q����F	2J��cXW�[>��y�Ǔu����źz���f]?oA���[�����-��y?oA���[�����-��y?oA���[�����-��%yK?oI���[�����-��%yK?oI���[�����-��%yK?oE���[��߿��-�����[����o��߿��-����������o�}���E�}���E��������5yk?o\�K��\ry.�t������%�ҿE�\�K�]r�.��t�R��W�(�{�R��W�(�{�R��W�(�{�R��W�(�{�R��W�(�{�R��W�(�{�R��W�(�{�R��W�(�{�R��W�(�{�R��W�(�{�R��W�(�{�R��W�(�{�R��W�(�{�R��W�(�{�R��W�(�{�R��W�(�{�R��W�(��{ЉR��W�(�{�R��W�(�{�R��W�(�{�R��W�(�{�R��W�(�{�R��W�(�{�R��WQ(�{�RQ�WQ(�{�RQ�WQ(�{�RQ�WQ(�{�RQ�WQ(�{�RQ�WQ(�{�RQ�WQ(�{�RQ�W���g%þ�Qh���Q��Qh���Q��Qh���Q��Qh���Q��Qh���Q��Qh���Q��Qh���Q��Qh���Q��QE���[����VR�[Rh%�%�VR�[Rh%�%�VR�[R���x����ZI�nI�����G�H����G�H����G�H����G�H����G�H����G�H����G�H����G�H����G�H����G�H����G�H����G�H����G�H����G�H����F��F�S��T:E�NE�S��T:E�NE�S��T:E�NE�S��T:E�NE�'��(cʟ�Ph���P��Ph���P��Ph���P��Ph���P��Ph���P��Ph���P��Ph���P���h����о��h����о��h����о��h����о��h����о��h����о��h����о��(
�{
��о��(
�{
�JоOШ����[l�}6l���ٰ���g��*��>̰u�߿�֝�/*��>̠��L�k&�����*��>̠��*��>̠��*��>̠��*��>̠��*��>�Ծ���*��>̠��*��>̠��cVƟ�2�B��Ⱥ�d���Cks�������9�6��o�����Cksn�����g��>���uZ�?����䵴��K���dʟ��n�'3�������~s�xû8�ox3����ϯo��|�x�,fF���`X}�S���C��Uw䘾�N�W�1��{Y]_u�����{qV_u���� }ս����ҵ��*�������1�1������fi��(P>����$�{D���G�?D{ȯ޶�~Û�ҷ����o���&��`D����|'~����M�F�����j�K���~Z�p|C!VN��Xdp7Xp����7��7ЃE7���7��70�����",B��#,D�IB,F�YB,H�iB,J�yB,L��B,N�Bl��W��§�������'���g��§�������'���g��§�������'���g� ç�����'��g��L���2|�3|��3n`;����;����;����;����;����;�ᆷt���f���fS��_�7�z��z���>�_�7�z��zS��_�7�z��zS��_�7�z��zS��_�7�z��z��i���<r���Nm;���z��zS��_�7�z��zS��_�7�z��zS��}�m<��y�����m>��}�����m@�y��_�7�z��zS��_�7�z��zS��_�7�z��zS��_�7��ڟ��Sk�Z3L���j=����F��>d�8n�{�\6h��As٠��e��o4�ڿq�\6h��As٠��e��o4��ڟ��=k�Y3����g�г�'�5C�ڟ|��m�o3L���j͋���ݠ>�����f�[����o�O�k���?�����f�[����o�O�k���?�y�^�o�k^���[��au�O�kt̾��dX]��au�O�k�յ?��V��ĺfX]��au�O�k�յ?��V��ĺfX]��au�O�k�յ?��V��ĺfX]��au�O��Ս?�n���w�au�O��Ս?�nV7�ĺA0�2��-�A0�,sT��}�A�T��}�u1~�bh]�߿Z��/�������u1~�bh]�߿Z��/�������u1~�bh]�߿Z��/�������u1~�bh]�߿Z��/�������u1~�b@F�s��ύd4>7����h@F�s��ύd4>7����h@F�s��ύd4>7����h@F�s��o:ء7LjE�ϣ5>�P��<j@Q��E�ϣ5>�P��<j@Q��E�ϣ5>�P��<ꀢ�ϣ(��<ꀢ�ϣ(��<ꀢ�ϣ(��<ꀢ�ϣ(��<ꀢ�ϣ(��<ꀢ�ϣ������	�?��0����	�	�?��0����	�	�?��0����	�	�?��0����	W����p������#a����v�[���Y�/��w�         �
  x�ŝM�DE��w��U�T�9��{� �@c��=j"ZLԿ��'8t��o���V��^u_}��˯�}����?~�������7o}����������}�����O߽y>>��k�������o?{������7�O�����||2����>�a������p���x���gc����	��z>!�������?��SF��#�r>��KF>��!�pא��q���CC�Q*��tlh�xl�ֱj�d�:vy̘�2t�2�1�e���2c>ˣc�͌-��]>3�3t�2�1�ӱ�iƼvt^�p���ym�i�kG�	�1���&�Ƽ�d�i�kG�	�1���&�Ƽ�d�i�k:�N8�y�SSĆӘ׮�ث�����Ա�i�y�.���y�nO=��n���żvS�.�-�=�������4����פ�r�"^�s���E��璱w9m���u�r�&^۳�\���xm�б�i�xmϣc�E5⵽L�.�m�5u�r�f^[K�.�m浵u�r�f^[�3VN��kKwƼ���k+u�r�3�)�u浥s��Ӝy�����4g^�C����k[�T/�9�{��
z)͙֊�B�ќY�S�.�9��:�g���W�.�S�]�`F�!z�5�f��S�.�3Z,�l�h�ul�ʌ�c�΂)��&c�ς9-R�.��Z\;�hɬ��󝥴dZKӱ��k�sK�Ӓy-un�rZ2�)��d^K�ײ���k��Zb����:�e9-�ײ�S�.�%�Z^�����:v9�0�ӱz���Ա�i�y�,��v�ה�r�a^;[�.���:v9�0��s1�5浣��)��sd�[N��k:��r�e^�:�ނ^浫s�-�]�5%��v�׮�緜v�׮Ω��v�׮Ω��v������i�y����A.��=2����2��+�c�;��|!��A��Äts�)�c�;��|l!��A�Åt�s������ ���Lt1���l`�;��|]���|]�1@`�3��:A`���u!�
��ӈJ��un[H��X���B:\�Z���ױ�-�t���nGH��X��vut�ƚ�CH��X��s
�p�|
m�(�X��Shd	�����0�X���Չ�FC�`�O�eB:\�
_SH��X��k	�p�|m���N���p+�K�c���#�w\�\׹��ױ^���6�����A�`�Y�-��cՂ�ױn���u������C�`�]�~[[E��X���"��ױ~����c��S)�Sz�:�B:\�*�%��u�cp�B:\�Jw��א1k.��u�fp�)����1;���:V4�]���X��!t�cU��ױ��ChZ�C��B�:d����P6�p�B�
`C�`�ph���p�{`���������:�:86�2:\�j�*XF��X������p+�\�c̓��G_��\�����X����u�|p,�et���~��A�`�~�#��c��c�*���±Z���:�@8v�2:\�*�~8/��u��plWet�������ޗ�1�a�*��u�����:�C8��*:bcE�c�*��u��p�Xet��U~��Ea���+4-�ceD�x ��u���+t�cu�_��F�#�
ms�
L���Ut/�!�0�H�*:	c�D`�*��u�����t����=��ױV"�h���:VK�2:\�z���UF��X1X���pk&�V�c�D��u�/�e�3��f'����fv2���0�mf'����fv2���~s@F��X7�,Oul,��z�%�Cr�����ǱhB
��X3s��0K&���%X1s��}�9���:8��z�����n,���!�C	VK���;	KH�k%b�$ӕK%b���RB
��X(K'�N$X'K'�.$X&�$��p�������=et�e�RH��X&���$b]!�c���űL"���8�I�6!�c�D쩣w!�2��KH��X&{���$������j���u]H�L"��u]H�L"��6]H�L"\x޻�`�Dx�w�u*�	�I���ͱL"���]H�L"b���$�th�e&�Cs,��R��ޟ��\.�Cs,�����ͱL��B:4�2��+�Cs,���'��bv!�2��/FG�B�e��.�Cs,�(��ͱLBK��X&��th�e�.���2�a�*�Cs,��L!�c�D�m��`�D�m�9�I���.$X&Gx⺐`�D��B�eq�'�	�Iĩ'�Xdv!�2�8GH��X&��~��{v!�2�)�Cs,��q�th�e9��ͱLBJ�B�eiCH��X&�6�th�eiKH��X&���th�eiB�t!�2�.eth�eiB�u!�2�4�뺐`�D��6��$r
mӅ�$r��ͱLBK��X&�X��>��c�Db�#�Cs,�Hl|dth�e����ͱL��g�c�Dbi#�Cs,��y�th�e����ޅ�$c�c�D.�m��`�D.�m��`�D.�y�B�e}π�ͱL"��w!�2���FF��X&�Kh�.$X&��Cs,�H�mD��Bb�L"����t�:�md�	:s�62���{}��\�]HwЙ밷��t�:�md���{���\�J�\Й�\ht�����Pb�Z"]x�QJ,�K��;R��z���HF��X0��Y���Xb�b"�����:�L�_!�c�Dbg%��u,�H�dt��UKGG1�X6�Xy5�ŋ�_�$�         X   x���v
Q���W((M��L�KI-�LN-�/�,H-V��L�Q(�,�I�Ts�	uV�0�QP/HIT״��$G�HQf^Ij�.. G�)o      	   l   x���v
Q���W((M��L�KI-�LN-�//�,R�ii
�):
�x03�$US!��'�5XA�PG���DGA����B��P��L��������H������P]Ӛ�� i}      �   �   x���=�0 ��S�H�����&MA�
>�hM[�����`���|+��Z+�3<�;a� �p�ZYH����#�B}8���e��;ޠ��}���+�0� ��\j�&l|p1�5��#��p~E[��[���ex��V�z���=��(� 8���      �   �   x���A�@໿bn*X��"t��D%���������o�vM/sy��ޤy�\kH�a���/٢����+��N�ANhCe���u��.��C'{4퓑�'���'����-�`�H0�P@�#�rf����<���\��X�d�e��|r��#��+�p�Q�g�a�d�E      �   :   x���v
Q���W((M��L��+�U�P*�/�,���S�Ts�	uV�0Ӵ��� ��g      �   b   x���v
Q���W((M��L�+(�,��IMIO-V��L�Q(�,�I�Ts�	uV�0�QP/-N-R״��$]�P{bJnf������KR���pq x=�      �      x���I��F����. ]!�p�+YDB 1m$,"�D�����W�w)݋t�n?n��:��w�����w���w?��_�|�����_����_���o�������o����?~����o��j��w?}�ݷ?����o���?~Q>}�,n�>2k-����y��v���(��Q���/���~������_���/&�)�4.�5��:ЋJ@�X�xY�P	�J/A��.��.A>4.�;TH.���r��
��s�`a?��2 �^���h�)���C�) ���8\� x��J���* �A����M�T.@D�H�]w ��\�ɐX���yPCF�
LtrZd+2*W`����TPu�0��:�
�����HS�ɘX��Q����*01ȓi*����^2*W`b�{��u L~/��[�� թ���A&�{�=�01��`*貕؀�IviS�˨܀����2*7`b�h���؀��ׁ�U &Nek�}b&����) &��dLl�����2&v`���;0qp*ې=�����{$��ߠ�~7zѭ�
�u`}x������ڹ�7H����~n���E� A�C����gc����dbm���]�P�w(�2&0q���Ƀ��>�YW����n YWw*(��YOu*h�u L�۽���:&0��T�o`��&���x;_�uD&ߡ�P���Wb5;_&K���80����o0t
��Ʃ<���L4~/�&���:�S�p ��*�s�����;�)�yWwUw�L�=�q�Ny�Ȼy��$;�&&��1d<`bn�����@�) &�~�(�s� &�n�	e�)������;c	`��<(�3� &�~�� [��D�KUw��D��Uw�O&��S��?��H(x�
��|2�~76]w?+(�LlU�ƒ�u�t��저������M��L�M�[�'[}�t��LP��~�0�YD�]o} 7��A���o +}o�eD���Wb�0���
���u
����;�Э`"�+�u L�|�j��L�;����� &2��T��`��Ѽ�Σy yKs�@ŭ�yKХ�X�M��C��H���W� 0�!\w�Q #��µ h��ẃ�r �ߔ�{F��輑ຣ��d{H�\87l�<	Б۷��;
dZwO�Нv�4��QukR-�9Bw�Q �҂s!tM����r��{F@��q���=# �҂s!R���hK{9v	��W�lK�N�n9B��q+����$ _N�ο�I :&o��������8t���Aւ�|�Ixұo��S��w]��@ĥ�������Z��?)��.\O:v�9%�C�l,�r鄎K���X ��	����@Υo'��\	]��*t�����+�Z��.���/	��g��K'�^t��Y�N�秄�\@G�Ytm�i�NN�]ױ@ܥ��͒��R ����� l�A॓C�)�
;n�x��_�*�5A�ňQ`I�� �b�ƅ�y,'��C��ʾq��B� �b�+�$��b/F�K����#g�K��� �+�1Մ�H��,	��D_��o�a�/F�맄ބ�БuZ�CT �b����:4A��ȑ���:.@����	��1[�å c�7�$�KAƈq`Iw���	WK�p��`�s4�r��qs/�o�Q#��B@�:_��t���ؖ	[��=��0���Wsʕp�$a��S������8t�)��I�,	�B�0����%A���4���%A�/�12�fIЍY*��1�șR7g�@ ƒ?�R7�@"�^�~��2T c[�����	�$ _:n��3T c/�L�0F�#�q�$�!c/��d����h:v�`�#����Ux6��з�Dc�:N	�#��8{��tsf
�c�m7�8_w,tq��od�v�
Mx*�go�S��T�1NfW/	�S�81�/	�SH�8{���np��8t�$� #���~J���)���rS
鐒q�����xb2�����n�!'�d�����t�8I,	B+6$e�$���2N�K��Y'��)�t't�2N��K�BV�Y�cJЙ�+de�X�ο͖�qސ�qb�Zt�
Y'��)��:n�2N|MK�p�9de�8z��Ho��8��1%�p�7de��i�ݸ�
Y'�c�ݼ�
Y'�%A�詐�q�_��Yf��c��L��K�n�X!+d�ǔ�y��2���.	��[��LЧ���BV&ʾeYt�
Y� ֪%A�w���	b�Zt{�
Y� ��)A`���	�kZ��W���B�$��]�2Q��&�*de�8z����BV&��%A���
Y� ��%Ag����	��\t��
Y� ��)A��������9'&���BV&��h�
B	��	2�yIй�*de���{V]�BV&H�o�
)� t$��%A��	��;%�C��$���˲$���2A��K��<P!+��$�)!+dǔPtg��2Afq,	�3�
Y� S(���
Y� �%A�����	l]t驐�	2bI��񫐕	�����
Y���S�.�Z!+��$4!+$غ$��@G� >%�$�2A<nK�.�Z!+�<FӍ����	�q[t��
Y��=�S��<P!+�}JЙ*de���O	�0de�D:��.�BV&yxt�(�
Y���х�W�����]�����I�}]� ��L��K��Y����!4T��$�;tk�2I"�K�n�[��L��P� +���8L؃��L�ߔ��4der�<��~Gߦ +�/-v_!+�d��E�+@V&��X+���Y�4��>!+�d�꒠K�V���K�C�����ɗG�>�T!+�/-��}ͩBV&_Z���^��L�ݒ���T��L��8�.�X!+���6櫵Lde��"�fW!+�//�C�q��L��ؒ�K�T��$I�-	�Ti�����#�1����Q���F�
�+�A�房��A��Y8n��+�dF�>�q)н�@Lfl�in�{R2���:,BHfl>�[�I����t.��Dd�f���W!!3���[����[��V�c"�c���񘱥8o:&B:flN�[�������V cb�l�غ*�Dc�Ș� 36#խ@���������覛t� 3���#��7�Ō-�z+�A�A,fl^�[��R1c���
dPl����K�p%� �@E�Č��{)�A1c��u)�A1c��ح@E�Ì��|)Ѝ�l�{��R�c"�a����a�a�nL��/c��o���%-�:���럹xB�m^�SR|@���c����|��o��Y�.���^�@�}N�*^$�+�'(��UR�A���qo����!W�.)n����]�$��]�]R�����%��@�m4�]\B�
��>�u�����\ŋ�p�U��%�k@���..!\�m#���5 �v6v����w}Vq	�n3>��%�kO����]�C����k��$���櫸d����k���O��,�^�8�����O��<R{�����Gj7(Οj)y�v������Gj@�*.!\��쫸�p�7����n��x�΀p{��*.!���v�U\B8��򫸄p�ۛ�Wq	�G� 1�	�Gf;�6ΗY͊�����Kg�8�͊U\�8�m�뻸q��;�Wq	��}��..Yp��O ���9 �x�Wq	�������9 n?t��]��u@�~�p�l���K��K�@����΁p�Ć���p��f5��%� ?^rM�7�p�x�5�� ���%�t~Ǐ�\�� ?�qM�7�p���5�� ���t~�Ox\�� ?�qM�7�p���5�����t~�Ox�H�@8~��EB���/�%���x�.�p��ǫ�p�$\�l�4m�|n|u׬��9�4m�q@qN8M�y(�	�i;�
�9�4m�Ѡ8'���<:�Ӵ��AqN8M�y �  8�Ӵ��e�i; ��N�v@��=���� ��N�v��e'i;����
������t���{��I��� ½��$]�~ �^�p��s?�pܥ㒮s?�pܥ㒮s?�pܥ㒮s/@���wq	�
n��������.)�B�u���p!�:���&A��%�+@8��U\B��KJ��t�;�b��]\B85�7���A�a�y�B1(�B�u�j�m"�uz?LBH5�6����K��R��ӻ�q�j����%��T�>��..A�b�v�]\�8H5��U���q�jȃ#N�v�jȃ#N�v�j��Kfwq	� Ր��I��R�߻��p�j؇���%��TC�pUB8H5�3����A�!�����%��T�>��..!��p�U	� Ր�'����A�a�|�R�}�*�$��TCN�&!����wq	� Ր�����p�j��P��%��TCN�&!����wq	� Ր�Լ���p�j�}`�U\B8H5d�k�A�!+'\�R�O	��K���^�%��TC����A�!���Wq	� Ր<]B85������A�a��B�á�%��PC�pht	� Ԑ<&!���CC��PC�ph��pjH�B��#���A�!y84LB85$��I�����0	� Ԑ,:��N�TC�th�q�jH�� R�ӡ��A�!y:��(��^�ӡ��A�!_ҡ�$�طqֿ\s��x84$������<wq	� Ր<.��A�!y84\B8H5�!����p�j` Z�%��T��须��p�jH�0�����А��jH�0��L5�����d����8���q�����K���j8��k�1?Sgq�T�����8^<B��3�p�O5����j8���p�L5���SMc8~������1 ܋EHc8@����p<�p/!��� ܋EHb8��b���j��-B)1�3�p��K��؞���8%\J��L5��)�Rb8�g��,N	�ñ=SgqJ����j8�S¥�pl�T�Y�.%�c{���p)1�3�p��K���
�[�R2��
�[�R�7�������� �E(%~c+@8nJ���
�[�R�7�������� �E(%~c�@8nJ���*�[�R�7�
��������E(%~c�@8nJ���*�[�R�7�
��������E(%~c�@8nJ���*�[�R�7���������E(%~ck@8nJ����[�R�7���������E(%~ck@8nJ����[�R�7���������E(%~c�@8nJ���:�[�R�7�����������������C(%~c�@8�J�[�:�;�R�7���������C(%~c�@8���%�3 w��ol������̀p�!����;�R�76�q�PJ��f@8�J����B)���C(%~c3 w��ol������́p�!�&!����Ӕ؍́p|�iJ���@8>�4%vcs �{���9��=M����瞦K�@8焓؍́p|�iJ���@8>�4%vc �{�����=M����瞦�nl��sOSb7� ��)�[ ���Ӕ؍-�p|�iJ��@8>�4%vc �{��!�@8>�4%C�-�p|�iJ��[���ӔQ���)�n	��sOS2D������i��	��OS2E����d��=B1���k���P�,Nn�Y\��G�a'7�,.��#�pg��Y\��G�a'7�,.��#�0��}���j���}~�t��Y��糸�p�P�,N�2��d�5��d+3�K��5du^�4�,�P�,N�j�W�G�a�x5�+�?B�8ūI^Y�j�,W0�+�?B�8ūI^Y�j��)^M���P�,N�j�W�fq�W����#�0�S����������      �   
   x���          �   
   x���             S   x���v
Q���W((M��L�+�O+)O,J�/S��L�Q��5�}B]�4u���4��<��n�nlB�vc�vS�v.. T�9p      �   �  x��]M�]���+��Wg����\VY�@��H���^X����g������Z�~N�R�tWW����?���ۏ?��۟_~���o�����᏷��}�����￾����7�O�|�v������ϟ?||���O�>�o�������ϟ�������_>�������??�|�������_n���3�}]�2�+�㼕����ݭe~���~�Տ�� �|��X�Z�.�x�����[)۱��_n��f6���
����Vk����7�/�e6֟^�+��>���a��'�]v����Q��e_hB`כ�����r*�D�p�Y���V��~_�ͬ?�����i��ʀ���G�Kx�k��n��~��p[�~ي���f�b]� 
%������j���bG9��4/�P���qL.H ��5�ą��]�Z���IxЁ��x1|j<ae��
&��6psk�gЁ�\nT�.���������*��-��[SvdH��l.BpKB��e�"C[S� `�!"�2k�g�G��:Vy2���*�0�2a�I]���`�#hn?�2\��c�3si�0��C��*<	:pauCn�p�0���΂J��_G&���E��?�ot������G�'օ�E�`d�xb]��C�Q�nK�	�m�JN�*�.\�l$��<!�:p�fcuD��)��l�$�s�w��(�@v�O�Eα�4&@����w�<t�1�������Ӑ 5���Ձ[�ϝ-؍��@�����NF=Zn�1*�P��'Rn�1J���'~W.�؂{��c=�t�v$=/����DW��������K�]��\|e��Oi���Q�Fog�we��C�e��ީ���v�<�2;�/�T�B��bΩL!~{����v*�2��n��Bvn��3C��[�9���P�f�X(�1sGb����, Zd�0�/��-�x�,2��O����g��[(�U�`�Uo��s���
�e.ɇc������2��5+�-�I��9�zu�/_�<#�L�Ձ�|�ͼq˴^��P�<"�L�Ձ�^��.R�I%��\�3
W�w�V��\a�mO��iY/�^�B"���l�cKC�^d@#*m6����M�2X�|��4_�H+؝�!����A�mɡ�L�����-��6�qe���ތ������]o;�ͨ�@��*�:x�-�ң�4_io6��~�P�Z^T�;w���X��+�"pQ�����֔}/���N|jyeP.�5.	��Ӆk;�ag����ׅ�vv	��nQ҅�;w�]E��K��[a����S��-q�Z��d#��~��Z2r)�w�tJS8��)�2;B���TPvfVB�G�1'��t�t�Fب9d�:x{��N�9�y�-��{d@�<Bѡ��<�xM}� 3i��Q��Ҏ�Y0g��e��7ƌCzk4i���0=qRsS\CE�����Vl!���
��sJ�[(g�`�;��Z��7w���=�U�H���[8K��`D:��rl{'��n��r��ߞ'�J���t�o�ܒ�B���3رs*�H�	���d��� a�w�DɊ��dIJ��#��o�����ު4��V
���锓�*J��n�	j��)QB���-lL>�'��b�	�acj�:m2׭�n�{�h����췦R���:��J��kJ{���	a�p�*X���O �+�u�ܟn¸�J�W���?�<%�d�T	1��4XU����SB7����yFET1���B>�#��) p����S�*� pT�c}S:��e� g9٧�A)� (�sO��LQr���7���Ij̘��9�)%S�J�[ж��჋8\���p��و=ҏ2��F�#�.��$?N敕��FW�t�_uaĔ����_E�dX	1�Ҏϫ�����L�ٝs �L���)^���3^!���HX�+�9�0+!��+�����Cڻ�it%?�&tj#���$bD�dL\	1b�Fe�D�3VBL9�b�1�W�Qq%Ĕ����)�'��J��:�����tA�ةDdg�)WB̽�5ʐΦ�!A`�;u�vPv�%C�J����!�&�LwB�L�*y>?�(ƶS'ȅ�ȳF7!� �ԩ1ۅ�c��N����)"k{7�e�T����X!���(�9�N��T�A\���ԉ�I듓	J�)`1�����Mَ+j�$ɕW4�)�q�{�$W.���ܒ�J���M�	�Z��{����Y��?�K!�!vW�~��kY�W��qe�7ŷd`P	�ri�2����+F>H�+'+�d�Uyu��Q��#�4i~\�ը����eU^!�,�0��X�Ѥ�X��M���߲*�bļɛL-��eU^!Ĉy�1���Ȫ�B�a�o��x^���
!mI�}�����c�����Y�وy1�c{%qA�Ä�h�p�u�� F�#I�,(��%��BI�{޸Ĉ�0b�0�D���<�D!�0aP����IV>(!�	�rV�@H�=�JBL���A^�Y��D����=��B|F�Q�r6Vy��x�T�&XpJ�k(!�A4랹�1KGi��+��� �3�J�K$LL��ñ%�#�� �$ɜ;��� ��Br+�0�i#����7e1�&��C�*{��\�0��1��l2V�%ϓ5�ȒS�J�)�{PNz�]	1/HS�����A=�!��\�R(�1�t�`�c��t�g�f$�\*�Yg�b86�!���u�	!�c#b�LezB���H������Y=O1A�4��Cz�Q���CVc�gݼB���H��ה�X#�x�z�k.��+]�a�|h��YG����x�fi��FǶ�s����0b��5�:{4o
#�A����6��5	!�c�th�:[O�G*!�c�3�3���6��C-v�y6�'�����A7��g3�B���H���9HrW1�a7b�Kބñ��k�Ƴ�c!�5����!ݳ	o!�E��sf㈶i]�l�#�ং�c(���G�{[���وk�K��z���%���:��d�_e&z�v�'�`7�1 �ɍ%�lT@��18O�)!�M.(k�W$D1[+A����\�RB<� ��uB*{7��y���-�<����D���R��g{
��hu3J��ݒ�J�-Ǭ\&��G%�Ws���z���TB��dʟ|�N��؜�sA,(���UB|Fml_a.�\)VB��}�vs{c��W�G�pVғ;�B��NB\A4���l�P1b�+ӄ+o�I�<��g���
��N�M�+�F܂S���膴wc}�89�`Y.�6�}nO��e&�8{�X+��&�d޳�<X�x?����d���4�E�8VV�BL���\�+5Ʊ�Ä����A Y��
!梴K,�V��i7!���{riH���W!��q�Fg�fv�H1H�^m�c����
86�6Az���%�^�ŕ\�֏�a#���s�T�̒���A�	����R!a�ȕ(m^#�*7B�)2�Ў��-� 	�G���ğGB$Ȳ�M!��1��h�gwǄ�((�HH/|cm_A!��
J���bSa�#�y	��?.�F<C$���������1.
i=ڻ-ۋ%��D	��H�,�*���y\a?y6]!�آ�ԸՄ���D�bhWo���"�>����7��F�C�dY�B�%�������⯾��p�#      �   
   x���          �   
   x���             
   x���          �   M  x��ܽ�\uE�>W1eA����|ae�" L���� j�_��+X����b�9?�y������=^�y���O����������ǟ�����Oϟ~{������y���ox���</km[^|�쵘)3�3��ș�̒3;3��9�9����)g.f.9s3s˙l�w��:��8�r(9��rlʡ�ؖC̱1��ck9��z����\�s��s��k{.=��\z����\�s鹶��smϥ�ڞKϵ==��y�yl�Cϣ�h��؞����<�<���==��y�yl�C�c{^��lϋ���y��=/z^��3=/���e{^��lϋ���y��=/z^�睞w��Nϻ�y�������n{��y�?�y�=���۞wz�m�;=�睞w��Aχ������|��a{>���=�|؞z>��z>l�=�烞��Aχ������|��i{>���=��|ڞOz>m�'=��瓞O����O��Iϧ������|��e{����=_�|ٞ/z�l�=_�狞/��Eϗ����K?}����|��e{����=��|۞oz�m�7=߶盞o��MϷ������|��m{���֜BϷ���A������iRن!m*�bH�ʶ3�Ue;Ҭ��iW�.�4�l7C�l�0_�
)�[!X��ha��\��{!`��a�B��d�F�a@�h4j�����0�a�8��� ��r�0��F�a��h<z�����0�a�@�� �т1��!Fb@�hD�����18b�#H��� �ђ(1��%F[b��hL�����91xb�'P�� �ѢH1��)F�b@�hT�����Y1�b�+X��� �Ѳh1��-F�b��h\�����y1�b�/`�� ����1��1Fc@�hd������18c�3h��� ����1��5F[c��hl������1xc�7p�� ����1��9F�c@�ht������1�c�;x��� ����1��=F�c��h|������1�c�?��� ��2� �AFd1�j�,Y��AVd1�j�,Ym�� ��d�A��6�b��Y�� �AVd1�j�,Ym�� ��d�A��6�b��Y�� �AVd1���E��p���\�l��A��.b��ǋd��"Y��A��/b���d�A��6�b��Y�� �AVd1�j�,Ym�� ��d�A��6�b��Y�� �AVd1�j�,Ym�� ��d�A��6�b��Y�� �AVd1�j�,Ym�� ��d�A��6�b��Y�� �AVd1�j�,Ym�� ��d�A��6�b��Y�� �AVd1�j�,Ym�� ��d�A��6�b��Y�� �AVd1�j�,Ym�� ��d�A��6�b��Y�� �AVd1�j�,Ym�� ��d�A��6�b��Y�� �AVd1�j�,Ym�� ��d�A��6�b��Y�� �AVd1�j�,Ym��A�6�� G�`���#�m��A�6�� G�`��r0��9�h�r�A9� �m��A�6�� G�`��r0��9�h�r�A9� �m��A�g�|����1s      �   �   x����
�0 �|���B($m''��`��D�ٴ	��������Nc�@��vsx��dc��/�z��N��#�1���a�h*���~�Rp(g_�8{�$�lڎ@V;��u���=i�+��{um#��c��Co     