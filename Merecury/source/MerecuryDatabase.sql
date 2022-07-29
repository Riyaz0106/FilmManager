--
-- PostgreSQL database dump
--

-- Dumped from database version 14.1
-- Dumped by pg_dump version 14.1

-- Started on 2022-02-04 02:24:59

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

DROP DATABASE "FilmManager";
--
-- TOC entry 3440 (class 1262 OID 16413)
-- Name: FilmManager; Type: DATABASE; Schema: -; Owner: postgres
--

CREATE DATABASE "FilmManager" WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE = 'English_United States.1252';


ALTER DATABASE "FilmManager" OWNER TO postgres;

\connect "FilmManager"

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 3 (class 2615 OID 2200)
-- Name: public; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA public;


ALTER SCHEMA public OWNER TO postgres;

--
-- TOC entry 3441 (class 0 OID 0)
-- Dependencies: 3
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA public IS 'standard public schema';


--
-- TOC entry 271 (class 1255 OID 49698)
-- Name: calculateaveragerating(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.calculateaveragerating(film text, OUT _out numeric) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
	BEGIN
		_out = (SELECT AVG(rating)::NUMERIC(10,1) FROM getFilmratings() WHERE filmname = film);
	END;
$$;


ALTER FUNCTION public.calculateaveragerating(film text, OUT _out numeric) OWNER TO postgres;

--
-- TOC entry 251 (class 1255 OID 26624)
-- Name: cleanarraytotext(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.cleanarraytotext(_value text, OUT output text) RETURNS text
    LANGUAGE plpgsql
    AS $$
	BEGIN
		SELECT REPLACE (_value, '"', '') INTO _value;
		SELECT REPLACE (_value, '[', '') INTO _value;
		SELECT REPLACE (_value, ']', '') INTO _value;
		output = _value;
	END;
$$;


ALTER FUNCTION public.cleanarraytotext(_value text, OUT output text) OWNER TO postgres;

--
-- TOC entry 263 (class 1255 OID 42129)
-- Name: createsubfilmlink(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.createsubfilmlink(_superid integer, _subid integer) RETURNS text
    LANGUAGE plpgsql
    AS $_$
	DECLARE _out text;
	BEGIN
		IF _superid != 0 THEN
			EXECUTE
			   format ('INSERT INTO subFilmLinks (superfilm_id,subfilm_id) VALUES($1,$2) RETURNING ''Inserted''') 
			   USING _superid,_subid
			   INTO _out;
		END IF;
		RETURN _out;
	END;
$_$;


ALTER FUNCTION public.createsubfilmlink(_superid integer, _subid integer) OWNER TO postgres;

--
-- TOC entry 253 (class 1255 OID 84608)
-- Name: createuser(text, text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.createuser(username text, pswd text, repswd text, OUT output text) RETURNS text
    LANGUAGE plpgsql
    AS $_$
	BEGIN
		IF pswd = repswd THEN
			BEGIN
				EXECUTE
				   format ('INSERT INTO useraccount(username, password) VALUES($1, $2) RETURNING username;') 
				   USING username, pswd
				   INTO output;
				EXCEPTION WHEN unique_violation THEN
					output = 'Username already taken.';
			END;
			IF output = username THEN
				output = 'created';
			END IF;
		ELSE
			output = 'Entered password and repassword did not match.';
		END IF;
	END;
$_$;


ALTER FUNCTION public.createuser(username text, pswd text, repswd text, OUT output text) OWNER TO postgres;

--
-- TOC entry 259 (class 1255 OID 87785)
-- Name: deletefilmbyid(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.deletefilmbyid(_id integer, OUT output text) RETURNS text
    LANGUAGE plpgsql
    AS $_$
	DECLARE _value text;
	BEGIN
		EXECUTE format ('DELETE FROM films WHERE id IN (SELECT subfilm_id FROM subfilmlinks WHERE superfilm_id = $1)') USING _id;
		EXECUTE format ('DELETE FROM films WHERE id = $1 RETURNING name') USING _id INTO _value;
		output = _value || ' has been deleted sucessfully.';
	END;
$_$;


ALTER FUNCTION public.deletefilmbyid(_id integer, OUT output text) OWNER TO postgres;

--
-- TOC entry 266 (class 1255 OID 44677)
-- Name: deletefilmpersonfilmroles(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.deletefilmpersonfilmroles(_filmname text, OUT output text) RETURNS text
    LANGUAGE plpgsql
    AS $_$
	DECLARE _value text;
	BEGIN
		EXECUTE format ('DELETE FROM filmPersonsRoles WHERE filmname = $1 RETURNING filmname') USING _filmname INTO _value;
		output = 'deleted';
	END;
$_$;


ALTER FUNCTION public.deletefilmpersonfilmroles(_filmname text, OUT output text) OWNER TO postgres;

--
-- TOC entry 278 (class 1255 OID 34541)
-- Name: deletefilmpersonsbyid(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.deletefilmpersonsbyid(_id integer) RETURNS text
    LANGUAGE plpgsql
    AS $_$
	DECLARE _personname text;
			_filmname text;
			_filmid int;
			_flag int;
	BEGIN
		EXECUTE format('SELECT name FROM getfilmpersonsbyId($1)') USING _id INTO _personname;
		EXECUTE format('SELECT filmname FROM getfilmPersonsRolesbyName($1)') USING _personname INTO _filmname;
		EXECUTE format('SELECT id FROM getfilmbyName($1)') USING _filmname INTO _filmid;
		EXECUTE format('SELECT FROM deleteFilmbyId($1)') USING _filmid;
		EXECUTE format('DELETE FROM filmPersons WHERE id = $1 RETURNING id') USING _id INTO _flag;
		IF _flag = _id THEN
			RETURN 'deleted';
		ELSE
			RETURN 'failed';
		END IF;
	END;
$_$;


ALTER FUNCTION public.deletefilmpersonsbyid(_id integer) OWNER TO postgres;

--
-- TOC entry 258 (class 1255 OID 83417)
-- Name: deletefilmratings(text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.deletefilmratings(username text, _filmname text, OUT _out text) RETURNS text
    LANGUAGE plpgsql
    AS $_$
	BEGIN
		EXECUTE format('DELETE FROM user_ratings WHERE user_id = $1 and film_name = $2') USING username,_filmname;
		_out = 'deleted';
	END;
$_$;


ALTER FUNCTION public.deletefilmratings(username text, _filmname text, OUT _out text) OWNER TO postgres;

--
-- TOC entry 262 (class 1255 OID 83614)
-- Name: getallsubfilmlink(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getallsubfilmlink() RETURNS TABLE(superid integer, subid integer)
    LANGUAGE plpgsql
    AS $$
	BEGIN
		RETURN QUERY EXECUTE
		   format ('SELECT * FROM subfilmlinks');
	END;
$$;


ALTER FUNCTION public.getallsubfilmlink() OWNER TO postgres;

--
-- TOC entry 256 (class 1255 OID 87612)
-- Name: getallsuperfilms(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getallsuperfilms() RETURNS TABLE(id integer, name text, releaseyear integer, description text, audiencetype text, genere text, duration text, persons text[], roles text[], selectedpersons text[], selectedroles text[], dropdown text[])
    LANGUAGE plpgsql
    AS $$
	BEGIN
		RETURN QUERY EXECUTE 
			format('SELECT myfilms.*,dropdown.dropdown FROM getFilmswithPersonsRoles() AS myfilms 
					INNER JOIN getdropdown() as dropdown ON myfilms.id = dropdown.filmid 
					WHERE myfilms.id NOT IN (select subid FROM getallsubfilmlink())');
	END;
$$;


ALTER FUNCTION public.getallsuperfilms() OWNER TO postgres;

--
-- TOC entry 280 (class 1255 OID 83756)
-- Name: getdropdown(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getdropdown() RETURNS TABLE(filmid integer, dropdown text[])
    LANGUAGE plpgsql
    AS $$
 	DECLARE _filmid int[];
 			_dropdown text [];
			l_value int;
	BEGIN
		CREATE TEMP TABLE temp_table(
			filmid integer NOT NULL,
			dropdownvalues text[] NOT NULL
		);
		_filmid = ARRAY(SELECT id FROM getfilms());
		FOREACH l_value IN ARRAY _filmid                             
    	LOOP
			_dropdown = ARRAY(SELECT name FROM getFilms() WHERE id NOT IN 
							  (SELECT subfilm_id from subfilmlinks where superfilm_id = l_value) AND id <> l_value);
			INSERT INTO temp_table(filmid,dropdownvalues) VALUES(l_value,_dropdown);
		END LOOP;
		RETURN QUERY EXECUTE format('SELECT * FROM temp_table');
		DROP TABLE temp_table;
	END;
$$;


ALTER FUNCTION public.getdropdown() OWNER TO postgres;

--
-- TOC entry 252 (class 1255 OID 34993)
-- Name: getfilmbyid(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getfilmbyid(_id integer) RETURNS TABLE(id integer, name text, releaseyear integer, description text, audiencetype text, genere text, duration text)
    LANGUAGE plpgsql
    AS $_$
	BEGIN
		RETURN QUERY EXECUTE
		   format ('SELECT * FROM films WHERE id = $1') USING _id;
	END;
$_$;


ALTER FUNCTION public.getfilmbyid(_id integer) OWNER TO postgres;

--
-- TOC entry 279 (class 1255 OID 34542)
-- Name: getfilmbyname(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getfilmbyname(_name text) RETURNS TABLE(id integer, name text, releaseyear integer, description text, audiencetype text, genere text, duration text)
    LANGUAGE plpgsql
    AS $_$
	BEGIN
		RETURN QUERY EXECUTE
		   format ('SELECT * FROM films WHERE name = $1') USING _name;
	END;
$_$;


ALTER FUNCTION public.getfilmbyname(_name text) OWNER TO postgres;

--
-- TOC entry 264 (class 1255 OID 25758)
-- Name: getfilmpersons(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getfilmpersons() RETURNS TABLE(id integer, name text, age integer, sex character, experience integer)
    LANGUAGE plpgsql
    AS $$
	BEGIN
		RETURN QUERY EXECUTE
		   format('SELECT * FROM filmPersons');
	END;
$$;


ALTER FUNCTION public.getfilmpersons() OWNER TO postgres;

--
-- TOC entry 276 (class 1255 OID 34539)
-- Name: getfilmpersonsbyid(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getfilmpersonsbyid(_id integer) RETURNS TABLE(id integer, name text, age integer, sex character, experience integer)
    LANGUAGE plpgsql
    AS $_$
	BEGIN
		RETURN QUERY EXECUTE
		   format('SELECT * FROM filmPersons WHERE id = $1') USING _id;
	END;
$_$;


ALTER FUNCTION public.getfilmpersonsbyid(_id integer) OWNER TO postgres;

--
-- TOC entry 277 (class 1255 OID 34540)
-- Name: getfilmpersonsrolesbyname(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getfilmpersonsrolesbyname(_name text) RETURNS TABLE(id integer, personname text, rolename text, filmname text)
    LANGUAGE plpgsql
    AS $_$
	BEGIN
		RETURN QUERY EXECUTE
		   format('SELECT * FROM filmPersonsroles WHERE personname = $1') USING _name;
	END;
$_$;


ALTER FUNCTION public.getfilmpersonsrolesbyname(_name text) OWNER TO postgres;

--
-- TOC entry 270 (class 1255 OID 49380)
-- Name: getfilmratings(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getfilmratings() RETURNS TABLE(username text, filmname text, rating integer, review text)
    LANGUAGE plpgsql
    AS $$
	BEGIN
		RETURN QUERY EXECUTE format('SELECT * FROM user_ratings;');
	END;
$$;


ALTER FUNCTION public.getfilmratings() OWNER TO postgres;

--
-- TOC entry 265 (class 1255 OID 25815)
-- Name: getfilms(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getfilms() RETURNS TABLE(id integer, name text, releaseyear integer, description text, audiencetype text, genere text, duration text)
    LANGUAGE plpgsql
    AS $$
	BEGIN
		RETURN QUERY EXECUTE
		   format ('SELECT * FROM films');
	END;
$$;


ALTER FUNCTION public.getfilms() OWNER TO postgres;

--
-- TOC entry 255 (class 1255 OID 84720)
-- Name: getfilmsuggestions(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getfilmsuggestions(uname text) RETURNS TABLE(id integer, name text, releaseyear integer, duration text)
    LANGUAGE plpgsql
    AS $_$
	BEGIN
	IF EXISTS(SELECT * FROM getFilmratings() WHERE username = uname) THEN
		RETURN QUERY EXECUTE format('SELECT id, name, releaseyear, duration FROM getFilms() WHERE name IN (SELECT DISTINCT filmname FROM filmpersonsroles WHERE personname NOT IN
 									(SELECT personname FROM filmpersonsroles WHERE filmname IN (SELECT filmname FROM getFilmratings() WHERE rating IN 
									(SELECT MIN (rating) FROM getFilmratings() WHERE username = $1 ) and username = $1))
   									AND filmname NOT IN (SELECT filmname FROM getFilmratings() WHERE username = $1))') 
						USING uname;
	END IF;
	END;
$_$;


ALTER FUNCTION public.getfilmsuggestions(uname text) OWNER TO postgres;

--
-- TOC entry 272 (class 1255 OID 33903)
-- Name: getfilmswithpersonsroles(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getfilmswithpersonsroles() RETURNS TABLE(id integer, name text, releaseyear integer, description text, audiencetype text, genere text, duration text, persons text[], roles text[], selectedpersons text[], selectedroles text[])
    LANGUAGE plpgsql
    AS $$
	BEGIN
		CREATE TEMP TABLE temp_table(
			filmid integer NOT NULL,
			filmname text NOT NULL,
			releaseyear integer NOT NULL,
			description text NOT NULL,
			audiencetype text NOT NULL,
			genere text NOT NULL,
			duartion text NOT NULL,
			persons text[],
			roles text[],
			selectedpersons text[],
			selectedroles text[]
		);
		
		CREATE TRIGGER trig_insert_members_username
		BEFORE INSERT
		on temp_table
		for each row
		execute procedure temp_insert_persons_roles();
		
		RETURN QUERY INSERT INTO temp_table(SELECT * FROM getFilms()) RETURNING *;
		DROP TRIGGER trig_insert_members_username ON temp_table;
		DROP TABLE temp_table;
		
	END;
$$;


ALTER FUNCTION public.getfilmswithpersonsroles() OWNER TO postgres;

--
-- TOC entry 260 (class 1255 OID 17470)
-- Name: getrolebyname(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getrolebyname(_name text) RETURNS TABLE(id integer, name text)
    LANGUAGE plpgsql
    AS $_$
	BEGIN
		RETURN QUERY EXECUTE
			format ('SELECT * FROM roles WHERE rolename = $1') USING _name;
	END;
$_$;


ALTER FUNCTION public.getrolebyname(_name text) OWNER TO postgres;

--
-- TOC entry 250 (class 1255 OID 16661)
-- Name: getroles(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getroles() RETURNS TABLE(id integer, name text)
    LANGUAGE plpgsql
    AS $$
	BEGIN
		RETURN QUERY EXECUTE
		   format ('SELECT * FROM roles');
	END;
$$;


ALTER FUNCTION public.getroles() OWNER TO postgres;

--
-- TOC entry 281 (class 1255 OID 83796)
-- Name: getsubfilmlink(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getsubfilmlink(_superid integer) RETURNS TABLE(id integer, name text, releaseyear integer, description text, audiencetype text, genere text, duration text, persons text[], roles text[], selectedpersons text[], selectedroles text[], dropdown text[])
    LANGUAGE plpgsql
    AS $_$
	DECLARE _out text;
	BEGIN
		IF _superid != 0 THEN
			RETURN QUERY EXECUTE
			   format ('SELECT superfilms.*,dropdown.dropdown FROM getFilmswithPersonsRoles() AS superfilms 
						INNER JOIN getallsubfilmlink() as subfilim ON subfilim.subid = superfilms.id 
					   	INNER JOIN getdropdown() as dropdown ON superfilms.id = dropdown.filmid WHERE subfilim.superid = $1') USING _superid;
		END IF;
	END;
$_$;


ALTER FUNCTION public.getsubfilmlink(_superid integer) OWNER TO postgres;

--
-- TOC entry 254 (class 1255 OID 84620)
-- Name: getuser(text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getuser(username text, pswd text, OUT output text) RETURNS text
    LANGUAGE plpgsql
    AS $_$
	BEGIN
		EXECUTE
		   format ('SELECT user_id FROM useraccount WHERE username = $1 and password = $2 LIMIT 1;') 
		   USING username, pswd
		   INTO output;
				
		IF output IS NOT NULL THEN
			output = 'Found';
		ELSE
			output = 'User Not Found.';
		END IF;
	END;
$_$;


ALTER FUNCTION public.getuser(username text, pswd text, OUT output text) OWNER TO postgres;

--
-- TOC entry 282 (class 1255 OID 88056)
-- Name: insertfilm(text, integer, text, text, text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.insertfilm(_name text, _ryear integer, _description text, _audtype text, _genere text, _duration text) RETURNS integer
    LANGUAGE plpgsql
    AS $_$
	DECLARE _id INTEGER;
			_temp text[];
			_genere_arr text[] = '{"Fantasy", "Romance", "Drama", "Crime & Mystery", "Horrer", "Documentry", "Sci-Fi", "Comedy", "Historical", "Action", "Thriller", "Animation", "Adventure", "Strategy"}';
	BEGIN
		_genere = (SELECT BTRIM(_genere,'{}'));
		_genere = (SELECT cleanarraytotext(_genere));
		_temp = (SELECT string_to_array(_genere, ','));
		IF (SELECT _temp <@ _genere_arr) THEN		
			EXECUTE format ('INSERT INTO films (name, releaseyear, description, audiencetype, genere, duration)
							VALUES($1, $2, $3, $4, $5, $6) RETURNING id')
					USING _name, _ryear::INTEGER, _description, _audtype, _genere, _duration
					INTO _id;
		END IF;
		RETURN _id;
	END;
$_$;


ALTER FUNCTION public.insertfilm(_name text, _ryear integer, _description text, _audtype text, _genere text, _duration text) OWNER TO postgres;

--
-- TOC entry 274 (class 1255 OID 34455)
-- Name: insertfilmpersons(text, integer, text, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.insertfilmpersons(_name text, _age integer, _gender text, _experience integer) RETURNS text
    LANGUAGE plpgsql
    AS $_$
	BEGIN
		EXECUTE format('INSERT INTO filmPersons(name,age,sex,experience) VALUES($1,$2,$3,$4)') 
			USING _name, _age,_gender,_experience;
		RETURN 'added';
	END;
$_$;


ALTER FUNCTION public.insertfilmpersons(_name text, _age integer, _gender text, _experience integer) OWNER TO postgres;

--
-- TOC entry 269 (class 1255 OID 49379)
-- Name: insertfilmratings(integer, text, integer, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.insertfilmratings(_filmid integer, _username text, _star integer, _review text) RETURNS text
    LANGUAGE plpgsql
    AS $_$
	BEGIN
		EXECUTE format('INSERT INTO user_ratings(user_id,film_name,rating,review) VALUES($1,$2,$3,$4)')
		USING _username,(SELECT name FROM getFilmbyId(_filmid)),_star,_review;
		RETURN 'added';
	END;
$_$;


ALTER FUNCTION public.insertfilmratings(_filmid integer, _username text, _star integer, _review text) OWNER TO postgres;

--
-- TOC entry 273 (class 1255 OID 34448)
-- Name: insertpersonfilmroles(json); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.insertpersonfilmroles(body json) RETURNS text
    LANGUAGE plpgsql
    AS $_$
	DECLARE _key   text;
   			_value text;
			_filmName text;
			_filmPersonName text;
			_roles text[];
			l_value text;
			j int;
	BEGIN
		j = 0;
		FOR _key, _value IN SELECT * FROM json_each_text($1)
		LOOP
			IF _key LIKE '%moviename' THEN
		   		_filmName = _value;
			ELSEIF _key LIKE ('%movieperson' || j::CHAR) THEN
				_filmPersonName = _value;
			ELSEIF _key LIKE ('%movierole' || j::CHAR) THEN
				_roles = (SELECT string_to_array((SELECT * FROM cleanArraytoText(_value)), ','));
				FOREACH l_value IN ARRAY _roles                             
				LOOP
					BEGIN
						EXECUTE format('INSERT INTO filmPersonsRoles(personname,rolename,filmname) VALUES($1,$2,$3)') 
								USING _filmPersonName,l_value,_filmName;
					EXCEPTION WHEN unique_violation THEN
					END;
				END LOOP;
				j=j+1;
			END IF;
		END LOOP;
		RETURN 'added';
	END;
$_$;


ALTER FUNCTION public.insertpersonfilmroles(body json) OWNER TO postgres;

--
-- TOC entry 267 (class 1255 OID 25959)
-- Name: temp_insert_persons_roles(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.temp_insert_persons_roles() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
	
	DECLARE _persons text[];
			_roles text[];
			l_value text;
			i int;
	BEGIN
		_persons = ARRAY(SELECT name FROM getFilmpersons());
		_roles = ARRAY(SELECT  name FROM getRoles());

		if NEW.persons is null then
			NEW.persons = _persons;
		end if;
		if NEW.roles is null then
			NEW.roles = _roles;
		end if;
		if NEW.selectedpersons is null then
			NEW.selectedpersons = ARRAY(SELECT DISTINCT personname FROM FilmPersonsRoles WHERE filmname = New.filmname);
		end if;
		if NEW.selectedroles is null then
			i=0;
			foreach l_value in ARRAY NEW.selectedpersons                             
				loop
				NEW.selectedroles[i] = ARRAY(SELECT rolename FROM FilmPersonsRoles WHERE filmname = New.filmname AND personname = l_value);
			i=i+1;
			end loop;
		end if;
		return NEW;
	END;
$$;


ALTER FUNCTION public.temp_insert_persons_roles() OWNER TO postgres;

--
-- TOC entry 261 (class 1255 OID 43363)
-- Name: updatefilmbyid(integer, text, integer, text, text, text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.updatefilmbyid(_id integer, _name text, _ryear integer, _description text, _genere text, _audtype text, _duration text) RETURNS text
    LANGUAGE plpgsql
    AS $_$
	BEGIN
		EXECUTE format ('UPDATE films 
						SET name = $2, 
							releaseyear = $3, 
							description = $4, 
							audiencetype = $5, 
							genere = $6,
							duration = $7 WHERE id = $1')
						USING _id, _name, _ryear, _description, _audtype, (SELECT cleanarraytotext(_genere)), _duration;
		RETURN 'updated';
	END;
$_$;


ALTER FUNCTION public.updatefilmbyid(_id integer, _name text, _ryear integer, _description text, _genere text, _audtype text, _duration text) OWNER TO postgres;

--
-- TOC entry 275 (class 1255 OID 34520)
-- Name: updatefilmpersonsbyid(integer, text, integer, text, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.updatefilmpersonsbyid(_id integer, _name text, _age integer, _gender text, _experience integer) RETURNS text
    LANGUAGE plpgsql
    AS $_$
	BEGIN
		EXECUTE format('UPDATE filmPersons SET 
					   name=$2,
					   age=$3,
					   sex=$4,
					   experience=$5 WHERE id = $1') 
			USING _id, _name, _age,_gender,_experience;
		RETURN 'updated';
	END;
$_$;


ALTER FUNCTION public.updatefilmpersonsbyid(_id integer, _name text, _age integer, _gender text, _experience integer) OWNER TO postgres;

--
-- TOC entry 257 (class 1255 OID 83414)
-- Name: updatefilmratings(text, text, integer, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.updatefilmratings(username text, _filmname text, _rating integer, _review text, OUT _out text) RETURNS text
    LANGUAGE plpgsql
    AS $_$
	BEGIN
		EXECUTE format('UPDATE user_ratings SET rating = $1, review = $2 
					   WHERE user_id = $3 and film_name = $4') USING _rating,_review,username,_filmname;
		_out = 'updated';
	END;
$_$;


ALTER FUNCTION public.updatefilmratings(username text, _filmname text, _rating integer, _review text, OUT _out text) OWNER TO postgres;

--
-- TOC entry 268 (class 1255 OID 44891)
-- Name: updatesubfilmlink(text, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.updatesubfilmlink(_superid text, _subid integer) RETURNS text
    LANGUAGE plpgsql
    AS $_$
	DECLARE _out text;
	BEGIN
		IF _superid <> '0' THEN
			IF (SELECT id FROM getfIlmbyName(_superid)) IS NOT NULL THEN
				_superid = (SELECT id FROM getfIlmbyName(_superid));
			END IF;
			RAISE NOTICE '%', _superid;
			IF EXISTS (SELECT 1 FROM subFilmLinks WHERE subfilm_id = _subid) THEN
				EXECUTE
				   format ('UPDATE subFilmLinks SET superfilm_id = $1 WHERE subfilm_id = $2 RETURNING ''Updated''') 
				   USING _superid::integer,_subid
				   INTO _out;
				RETURN _out;
			ELSE
				 PERFORM createsubfilmlink(_superid::integer,_subid);
				 RETURN 'created sublink';
			END IF;
		END IF;
		RETURN 'updated';
	END;
$_$;


ALTER FUNCTION public.updatesubfilmlink(_superid text, _subid integer) OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 232 (class 1259 OID 34411)
-- Name: filmpersons; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.filmpersons (
    id integer NOT NULL,
    name text NOT NULL,
    age integer,
    sex character(6),
    experience integer
);


ALTER TABLE public.filmpersons OWNER TO postgres;

--
-- TOC entry 231 (class 1259 OID 34410)
-- Name: filmpersons_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.filmpersons_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.filmpersons_id_seq OWNER TO postgres;

--
-- TOC entry 3442 (class 0 OID 0)
-- Dependencies: 231
-- Name: filmpersons_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.filmpersons_id_seq OWNED BY public.filmpersons.id;


--
-- TOC entry 234 (class 1259 OID 34422)
-- Name: filmpersonsroles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.filmpersonsroles (
    id integer NOT NULL,
    personname text NOT NULL,
    rolename text DEFAULT ''::text NOT NULL,
    filmname text DEFAULT ''::text NOT NULL
);


ALTER TABLE public.filmpersonsroles OWNER TO postgres;

--
-- TOC entry 233 (class 1259 OID 34421)
-- Name: filmpersonsroles_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.filmpersonsroles_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.filmpersonsroles_id_seq OWNER TO postgres;

--
-- TOC entry 3443 (class 0 OID 0)
-- Dependencies: 233
-- Name: filmpersonsroles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.filmpersonsroles_id_seq OWNED BY public.filmpersonsroles.id;


--
-- TOC entry 228 (class 1259 OID 16548)
-- Name: films; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.films (
    id integer NOT NULL,
    name text NOT NULL,
    releaseyear integer NOT NULL,
    description text NOT NULL,
    audiencetype text NOT NULL,
    genere text NOT NULL,
    duration text DEFAULT 'na'::text NOT NULL
);


ALTER TABLE public.films OWNER TO postgres;

--
-- TOC entry 227 (class 1259 OID 16547)
-- Name: films_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.films_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.films_id_seq OWNER TO postgres;

--
-- TOC entry 3444 (class 0 OID 0)
-- Dependencies: 227
-- Name: films_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.films_id_seq OWNED BY public.films.id;


--
-- TOC entry 230 (class 1259 OID 16632)
-- Name: roles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.roles (
    id integer NOT NULL,
    rolename text NOT NULL
);


ALTER TABLE public.roles OWNER TO postgres;

--
-- TOC entry 229 (class 1259 OID 16631)
-- Name: roles_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.roles_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.roles_id_seq OWNER TO postgres;

--
-- TOC entry 3445 (class 0 OID 0)
-- Dependencies: 229
-- Name: roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.roles_id_seq OWNED BY public.roles.id;


--
-- TOC entry 235 (class 1259 OID 41909)
-- Name: subfilmlinks; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.subfilmlinks (
    superfilm_id integer NOT NULL,
    subfilm_id integer NOT NULL
);


ALTER TABLE public.subfilmlinks OWNER TO postgres;

--
-- TOC entry 236 (class 1259 OID 44579)
-- Name: user_ratings; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_ratings (
    user_id text NOT NULL,
    film_name text NOT NULL,
    rating integer NOT NULL,
    review text NOT NULL
);


ALTER TABLE public.user_ratings OWNER TO postgres;

--
-- TOC entry 238 (class 1259 OID 84532)
-- Name: useraccount; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.useraccount (
    user_id integer NOT NULL,
    username text,
    password text
);


ALTER TABLE public.useraccount OWNER TO postgres;

--
-- TOC entry 237 (class 1259 OID 84531)
-- Name: useraccount_user_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.useraccount_user_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.useraccount_user_id_seq OWNER TO postgres;

--
-- TOC entry 3446 (class 0 OID 0)
-- Dependencies: 237
-- Name: useraccount_user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.useraccount_user_id_seq OWNED BY public.useraccount.user_id;


--
-- TOC entry 3246 (class 2604 OID 34414)
-- Name: filmpersons id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.filmpersons ALTER COLUMN id SET DEFAULT nextval('public.filmpersons_id_seq'::regclass);


--
-- TOC entry 3247 (class 2604 OID 34425)
-- Name: filmpersonsroles id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.filmpersonsroles ALTER COLUMN id SET DEFAULT nextval('public.filmpersonsroles_id_seq'::regclass);


--
-- TOC entry 3243 (class 2604 OID 16551)
-- Name: films id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.films ALTER COLUMN id SET DEFAULT nextval('public.films_id_seq'::regclass);


--
-- TOC entry 3245 (class 2604 OID 16635)
-- Name: roles id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles ALTER COLUMN id SET DEFAULT nextval('public.roles_id_seq'::regclass);


--
-- TOC entry 3250 (class 2604 OID 84535)
-- Name: useraccount user_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.useraccount ALTER COLUMN user_id SET DEFAULT nextval('public.useraccount_user_id_seq'::regclass);


--
-- TOC entry 3428 (class 0 OID 34411)
-- Dependencies: 232
-- Data for Name: filmpersons; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.filmpersons VALUES (1, 'Daniel Radcliffe', 32, 'Male  ', 20);
INSERT INTO public.filmpersons VALUES (2, 'Emma Watson', 31, 'Female', 20);
INSERT INTO public.filmpersons VALUES (4, 'Chris Columbus', 63, 'Male  ', 40);
INSERT INTO public.filmpersons VALUES (5, 'Alfonso Cuarón', 60, 'Male  ', 50);
INSERT INTO public.filmpersons VALUES (6, 'Tom Felton', 32, 'Male  ', 25);
INSERT INTO public.filmpersons VALUES (8, 'Helena Bonham Carter', 55, 'Female', 40);
INSERT INTO public.filmpersons VALUES (7, 'Evanna Lynch', 35, 'Male  ', 25);
INSERT INTO public.filmpersons VALUES (9, 'Harrison Ford', 79, 'Male  ', 50);
INSERT INTO public.filmpersons VALUES (11, 'Carrie Fisher', 65, 'Female', 50);
INSERT INTO public.filmpersons VALUES (12, 'Anthony Daniels', 75, 'Male  ', 65);
INSERT INTO public.filmpersons VALUES (13, 'James Earl Jones', 91, 'Male  ', 80);
INSERT INTO public.filmpersons VALUES (14, 'George Lucas', 77, 'Male  ', 60);
INSERT INTO public.filmpersons VALUES (15, 'JJ Abrams', 55, 'Male  ', 30);
INSERT INTO public.filmpersons VALUES (16, 'Natalie Portman', 40, 'Female', 25);
INSERT INTO public.filmpersons VALUES (17, 'Hayden Christensen', 40, 'Male  ', 20);
INSERT INTO public.filmpersons VALUES (18, 'James Wilks', 43, 'Male  ', 30);
INSERT INTO public.filmpersons VALUES (19, 'Arnold Schwarzenegger', 74, 'Male  ', 50);
INSERT INTO public.filmpersons VALUES (20, 'Daisy Ridley', 29, 'Female', 3);


--
-- TOC entry 3430 (class 0 OID 34422)
-- Dependencies: 234
-- Data for Name: filmpersonsroles; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.filmpersonsroles VALUES (62, 'Evanna Lynch', 'actor', 'Harry Potter film series');
INSERT INTO public.filmpersonsroles VALUES (63, 'Evanna Lynch', 'director', 'Harry Potter film series');
INSERT INTO public.filmpersonsroles VALUES (64, 'Daniel Radcliffe', 'actor', 'Harry Potter film series');
INSERT INTO public.filmpersonsroles VALUES (65, 'Emma Watson', 'actor', 'Harry Potter film series');
INSERT INTO public.filmpersonsroles VALUES (66, 'Alfonso Cuarón', 'director', 'Harry Potter film series');
INSERT INTO public.filmpersonsroles VALUES (67, 'Chris Columbus', 'associate director', 'Harry Potter film series');
INSERT INTO public.filmpersonsroles VALUES (73, 'Helena Bonham Carter', 'actor', 'Harry Potter and the Half-Blood Prince');
INSERT INTO public.filmpersonsroles VALUES (74, 'Tom Felton', 'actor', 'Harry Potter and the Deathly Hallows - Part 1');
INSERT INTO public.filmpersonsroles VALUES (75, 'Chris Columbus', 'director', 'Harry Potter and the Deathly Hallows - Part 2');
INSERT INTO public.filmpersonsroles VALUES (76, 'Emma Watson', 'actor', 'Harry Potter and the Deathly Hallows - Part 2');
INSERT INTO public.filmpersonsroles VALUES (77, 'Tom Felton', 'actor', 'Harry Potter and the Deathly Hallows - Part 2');
INSERT INTO public.filmpersonsroles VALUES (8, 'Emma Watson', 'actor', 'Harry Potter and the Goblet of Fire');
INSERT INTO public.filmpersonsroles VALUES (9, 'Evanna Lynch', 'actor', 'Harry Potter and the Goblet of Fire');
INSERT INTO public.filmpersonsroles VALUES (10, 'Evanna Lynch', 'associate director', 'Harry Potter and the Goblet of Fire');
INSERT INTO public.filmpersonsroles VALUES (11, 'Evanna Lynch', 'director', 'Harry Potter and the Goblet of Fire');
INSERT INTO public.filmpersonsroles VALUES (100, 'Arnold Schwarzenegger', 'actor', 'The Game Changers');
INSERT INTO public.filmpersonsroles VALUES (101, 'James Wilks', 'producer', 'The Game Changers');
INSERT INTO public.filmpersonsroles VALUES (35, 'Chris Columbus', 'director', 'Harry Potter and the Philosopher''s Stone');
INSERT INTO public.filmpersonsroles VALUES (36, 'Chris Columbus', 'producer', 'Harry Potter and the Philosopher''s Stone');
INSERT INTO public.filmpersonsroles VALUES (37, 'Daniel Radcliffe', 'actor', 'Harry Potter and the Philosopher''s Stone');
INSERT INTO public.filmpersonsroles VALUES (102, 'James Wilks', 'director', 'The Game Changers');
INSERT INTO public.filmpersonsroles VALUES (103, 'George Lucas', 'director', 'The Empire Strikes Back');
INSERT INTO public.filmpersonsroles VALUES (104, 'George Lucas', 'producer', 'The Empire Strikes Back');
INSERT INTO public.filmpersonsroles VALUES (105, 'JJ Abrams', 'associate director', 'The Empire Strikes Back');
INSERT INTO public.filmpersonsroles VALUES (106, 'Anthony Daniels', 'actor', 'Return of the Jedi');
INSERT INTO public.filmpersonsroles VALUES (107, 'Anthony Daniels', 'director', 'Return of the Jedi');
INSERT INTO public.filmpersonsroles VALUES (108, 'Harrison Ford', 'actor', 'Return of the Jedi');
INSERT INTO public.filmpersonsroles VALUES (109, 'Harrison Ford', 'actor', 'War of Stars');
INSERT INTO public.filmpersonsroles VALUES (110, 'George Lucas', 'director', 'War of Stars');
INSERT INTO public.filmpersonsroles VALUES (111, 'George Lucas', 'producer', 'War of Stars');
INSERT INTO public.filmpersonsroles VALUES (112, 'Hayden Christensen', 'actor', 'Star Wars: Episode II - Attack of the Clones');
INSERT INTO public.filmpersonsroles VALUES (113, 'George Lucas', 'director', 'Star Wars: Episode II - Attack of the Clones');
INSERT INTO public.filmpersonsroles VALUES (52, 'Chris Columbus', 'director', 'Harry Potter and the Order of the Phoenix');
INSERT INTO public.filmpersonsroles VALUES (53, 'Helena Bonham Carter', 'actor', 'Harry Potter and the Order of the Phoenix');
INSERT INTO public.filmpersonsroles VALUES (54, 'Daniel Radcliffe', 'actor', 'Harry Potter and the Order of the Phoenix');
INSERT INTO public.filmpersonsroles VALUES (55, 'Daniel Radcliffe', 'cinematographer', 'Harry Potter and the Order of the Phoenix');
INSERT INTO public.filmpersonsroles VALUES (56, 'Daniel Radcliffe', 'actor', 'Harry Potter and the Chamber of Secrets');
INSERT INTO public.filmpersonsroles VALUES (57, 'Emma Watson', 'actor', 'Harry Potter and the Chamber of Secrets');
INSERT INTO public.filmpersonsroles VALUES (58, 'Emma Watson', 'writer', 'Harry Potter and the Chamber of Secrets');
INSERT INTO public.filmpersonsroles VALUES (59, 'Daniel Radcliffe', 'actor', 'Harry Potter and the Prisoner of Azkaban');
INSERT INTO public.filmpersonsroles VALUES (60, 'Emma Watson', 'actor', 'Harry Potter and the Prisoner of Azkaban');
INSERT INTO public.filmpersonsroles VALUES (61, 'Alfonso Cuarón', 'director', 'Harry Potter and the Prisoner of Azkaban');
INSERT INTO public.filmpersonsroles VALUES (114, 'George Lucas', 'producer', 'Star Wars: Episode II - Attack of the Clones');
INSERT INTO public.filmpersonsroles VALUES (115, 'Natalie Portman', 'actor', 'Star Wars: Episode II - Attack of the Clones');
INSERT INTO public.filmpersonsroles VALUES (116, 'George Lucas', 'director', 'Star Wars: Episode I - The Phantom Menace');
INSERT INTO public.filmpersonsroles VALUES (117, 'George Lucas', 'producer', 'Star Wars: Episode I - The Phantom Menace');
INSERT INTO public.filmpersonsroles VALUES (121, 'George Lucas', 'director', 'Star Wars Series');
INSERT INTO public.filmpersonsroles VALUES (122, 'George Lucas', 'producer', 'Star Wars Series');
INSERT INTO public.filmpersonsroles VALUES (123, 'Natalie Portman', 'actor', 'Star Wars Series');
INSERT INTO public.filmpersonsroles VALUES (124, 'Daisy Ridley', 'actor', 'Star Wars Series');
INSERT INTO public.filmpersonsroles VALUES (125, 'Daisy Ridley', 'action director', 'Star Wars Series');
INSERT INTO public.filmpersonsroles VALUES (126, 'Evanna Lynch', 'associate director', 'Ice Age');
INSERT INTO public.filmpersonsroles VALUES (127, 'Evanna Lynch', 'edittor', 'Ice Age');
INSERT INTO public.filmpersonsroles VALUES (128, 'Harrison Ford', 'actor', 'Ice Age');
INSERT INTO public.filmpersonsroles VALUES (129, 'Harrison Ford', 'writer', 'Ice Age');


--
-- TOC entry 3424 (class 0 OID 16548)
-- Dependencies: 228
-- Data for Name: films; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.films VALUES (37, 'Harry Potter and the Prisoner of Azkaban', 2004, 'Harry wait for the end of the vacation, especially when Vernon sister announces her visit. Trouble is inevitable and eventually Harry runs away - much to the concern of the wizarding community as felon Sirius Black has escaped from prison and died probably looking for him. Back at Hogwarts, Harry discovers that Black is responsible for his parents deaths. And then Ron rat behaves even more than strange.', 'above 12', 'Fantasy,Drama,Documentry,Historical', '139 min');
INSERT INTO public.films VALUES (43, 'Harry Potter film series', 2001, 'Harry Potter is a film series based on the novels of the same name by JK Rowling. The series is distributed by Warner Bros. and consists of eight fantasy films, beginning with Harry Potter and the Philosopher Stone through Harry Potter and the Deathly Hallows - Part 2.', 'above 12', 'Fantasy,Comedy,Action,Adventure', '1172 min');
INSERT INTO public.films VALUES (44, 'Harry Potter and the Goblet of Fire', 2005, 'Harry Potter and his friends witness a historic event: This year, the Triwizard Tournament is taking place at Hogwarts. For inexplicable reasons, Harry becomes a participant and must face dangerous dragons, water demons and difficult puzzles - along with an accompanying to the prom. Harry soon realizes he has landed in a game of life and death and Voldemort is closer than he expected.', 'above 12', 'Fantasy,Drama,Documentry', '139 min');
INSERT INTO public.films VALUES (3, 'Harry Potter and the Philosopher''s Stone', 2001, 'The young orphan Harry Potter grows up with his aunt and uncle, who only exploit him. However, just before his eleventh birthday, his life changes when he receives an invitation to Hogwarts, a school of witchcraft and wizardry. Magical creatures, spells await him there potions class and the teacher Snape who doesn''t seem to like him. Harry finds friends in his classmates Ron and Hermione. And soon he has to deal with the most evil of magicians.', 'above 12', 'Fantasy,Drama', '130 min');
INSERT INTO public.films VALUES (46, 'Harry Potter and the Half-Blood Prince', 2009, 'The magic of love dominates the sixth year of Harry and his friends Hermione and Ron. Hormones and a love potion cause emotional confusion as Voldemort''s followers band together for an assault on the young heroes and their greatest magical ally. But as Harry y and Professor Dumbledore discover the secret to Voldemort''s eternal life, his influence behind the walls of Hogwarts grows. The Dark Lord has already sent Death to Hogwarts.', 'above 12', 'Fantasy,Drama,Adventure', '150 min');
INSERT INTO public.films VALUES (47, 'Harry Potter and the Deathly Hallows - Part 1', 2010, 'Dumbledore is dead and both Hogwarts and the Ministry of Magic are under Death Eater control. Harry, Ron, and Hermione set out on a quest to find the remaining Horcruxes, destroying which could defeat Voldemort once and for all. However, the Horcruxes will soon become e A stress test for the three friends. And when Harry learns of the legendary Deathly Hallows, he begins to doubt which path is right for him.', 'above 12', 'Fantasy,Drama', '146 min');
INSERT INTO public.films VALUES (45, 'Harry Potter and the Order of the Phoenix', 2007, 'Harry Potter is spending a lonely summer with the Dursleys when he and his cousin Dudley are suddenly attacked by dementors. Harry has a hard time driving them away, but he faces expulsion from school for performing magic in front of a muggle. But that''s just the beginning of the trouble, because w Every time they arrive at Hogwarts, few want to believe that Voldemort is back. And then there''s the new teacher who seems to be trying to prevent the students from learning magic.', 'above 12', 'Fantasy,Drama,Comedy', '129 min');
INSERT INTO public.films VALUES (24, 'Harry Potter and the Chamber of Secrets', 2002, 'Strange things are happening at Hogwarts in Harry''s second year. Gradually, students are found petrified in the corridors and everything points to a mysterious chamber that Hagrid is said to have something to do with. The new Defense Against the Dark Arts teacher, Gilderoy Lockhart, sh all but unqualified, and when Dumbledore is eventually suspended, Harry, Ron and Hermione set out to solve the mystery themselves.', 'above 12', 'Fantasy,Drama,Comedy', '160 min');
INSERT INTO public.films VALUES (48, 'Harry Potter and the Deathly Hallows - Part 2', 2011, 'Only two more Horcruxes are missing to finally be able to defeat Voldemort. Harry, Ron and Hermione find out that there must be one in Gringotts and plan to break into the wizarding bank with the help of the goblin Griphook. It doesn''t take long for them to be discovered - now Voldemort knows what d he three plan. The last Horcrux leads the friends back to Hogwarts, where soon wizards and Death Eaters face each other in an all-important battle.', 'above 12', 'Fantasy,Drama,Adventure', '130 min');
INSERT INTO public.films VALUES (56, 'Star Wars: Episode II - Attack of the Clones', 1993, 'As Obi-Wan Kenobi trains teenage Anakin Skywalker to become a Jedi Knight and has his hands full with the hot-headed young man, a new conflict brews. When Senator Amidala narrowly escapes an assassination, Obi-Wan and Anakin are called in to help. On a fe On their planet, they encounter the mysterious leader of the enemy Separatists and a massive army of cloned warriors. Meanwhile, Anakin develops deeper feelings for the beautiful ex-queen.', 'above 12', 'Drama,Sci-Fi,Action,Adventure', '144 min');
INSERT INTO public.films VALUES (54, 'Return of the Jedi', 1983, 'The second Death Star, meant to spell the doom of the rebels, is nearing completion. The rebels order their entire forces to the moon of Endor to fight the Empire from there. Meanwhile, Luke returns to Dagobah to complete his training as a Jedi Knight n. He learns from Yoda that he has to face his father, Darth Vader, one last time. A father-son duel erupts on the Death Star.', 'above 12', 'Drama,Sci-Fi,Action', '131 min');
INSERT INTO public.films VALUES (52, 'War of Stars', 1997, 'Young Luke Skywalker lives on his uncle''s farm on the desert planet of Tatooine. One day he finds a secret message in a robot. He sets out in search of the actual recipient of the message, a certain Obi-Wan, known as Ben Kenobi as a hermit on Ta tooine lives. He teaches Luke the basics of the Force and suddenly finds himself on the side of the rebels in the fight against the Empire and the sinister Darth Vader.', 'above 12', 'Drama,Sci-Fi', '121 min');
INSERT INTO public.films VALUES (55, 'Star Wars: Episode I - The Phantom Menace', 1999, 'The greedy Trade Federation besieges young Queen Amidala''s peaceful planet Naboo. Jedi Master Qui-Gon Jinn and his apprentice Obi-Wan Kenobi are sent by the Jedi High Council to negotiate peace. When their mission fails, the Jedi flee with Amidala to the desert pla net Tatooine. There they meet nine-year-old Anakin Skywalker, in whom Qui-Gon sees a strong predisposition to the Force. He takes the boy to train him to be a Jedi.', 'above 12', 'Drama,Sci-Fi,Action,Adventure', '136 min');
INSERT INTO public.films VALUES (57, 'Star Wars Series', 1977, 'Star Wars is an American epic space opera multimedia franchise created by George Lucas, which began with the eponymous 1977 film and quickly became a worldwide pop-culture phenomenon.', 'above 12', 'Fantasy,Drama,Sci-Fi,Action', '2000 min');
INSERT INTO public.films VALUES (59, 'The Game Changers', 2018, 'James Wilks travels the world on a quest for the truth about meat, protein, and strength. Showcasing elite athletes, special ops soldiers, and visionary scientists to change the way people eat and live.', 'above 12', 'Documentry,Adventure', '112 min');
INSERT INTO public.films VALUES (53, 'The Empire Strikes Back', 1980, 'The rebels are forced to evacuate their base on the ice planet Hoth after an attack by Darth Vader. Luke Skywalker goes to the wise Jedi Master Yoda to be trained by him in the Force. Meanwhile, Darth Vader succeeds in bringing Han Solo and Princess capture Leia. When Luke rushes to help his friends, he falls straight into Vader''s trap. Luke and Vader find themselves in a duel that leaves Luke in a nasty surprise.', 'above 12', 'Drama,Sci-Fi,Action', '124 min');
INSERT INTO public.films VALUES (58, 'Ice Age', 2002, 'Manny the mammoth, Sid the loquacious sloth, and Diego the sabre-toothed tiger go on a comical quest to return a human baby back to his father, across a world on the brink of an ice age.', 'above 2', 'Comedy,Animation', '81 min');


--
-- TOC entry 3426 (class 0 OID 16632)
-- Dependencies: 230
-- Data for Name: roles; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.roles VALUES (1, 'actor');
INSERT INTO public.roles VALUES (2, 'director');
INSERT INTO public.roles VALUES (3, 'producer');
INSERT INTO public.roles VALUES (4, 'associate director');
INSERT INTO public.roles VALUES (5, 'cinematographer');
INSERT INTO public.roles VALUES (6, 'writer');
INSERT INTO public.roles VALUES (7, 'edittor');
INSERT INTO public.roles VALUES (8, 'action director');


--
-- TOC entry 3431 (class 0 OID 41909)
-- Dependencies: 235
-- Data for Name: subfilmlinks; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.subfilmlinks VALUES (43, 3);
INSERT INTO public.subfilmlinks VALUES (43, 44);
INSERT INTO public.subfilmlinks VALUES (43, 45);
INSERT INTO public.subfilmlinks VALUES (43, 24);
INSERT INTO public.subfilmlinks VALUES (43, 37);
INSERT INTO public.subfilmlinks VALUES (43, 46);
INSERT INTO public.subfilmlinks VALUES (43, 47);
INSERT INTO public.subfilmlinks VALUES (43, 48);
INSERT INTO public.subfilmlinks VALUES (57, 53);
INSERT INTO public.subfilmlinks VALUES (57, 54);
INSERT INTO public.subfilmlinks VALUES (57, 52);
INSERT INTO public.subfilmlinks VALUES (57, 56);
INSERT INTO public.subfilmlinks VALUES (57, 55);


--
-- TOC entry 3432 (class 0 OID 44579)
-- Dependencies: 236
-- Data for Name: user_ratings; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.user_ratings VALUES ('shaikriyaz0106@gmail.com', 'Harry Potter film series', 5, 'Fantastic movie for the children''s to watch and enjoy.');
INSERT INTO public.user_ratings VALUES ('riyaz', 'Harry Potter and the Philosopher''s Stone', 3, 'Best movie ever made.');
INSERT INTO public.user_ratings VALUES ('riyaz', 'Harry Potter film series', 5, 'It is an awesome movie to watch.');
INSERT INTO public.user_ratings VALUES ('riyaz', 'Harry Potter and the Prisoner of Azkaban', 4, 'It is an average movie with less story and more drama.');


--
-- TOC entry 3434 (class 0 OID 84532)
-- Dependencies: 238
-- Data for Name: useraccount; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.useraccount VALUES (1, 'riyaz', 'riyaz123');
INSERT INTO public.useraccount VALUES (2, 'shaikriyaz0106@gmail.com', 'shaik123');
INSERT INTO public.useraccount VALUES (3, 'logic', 'logic1234');
INSERT INTO public.useraccount VALUES (5, 'marry', 'marry1234');


--
-- TOC entry 3447 (class 0 OID 0)
-- Dependencies: 231
-- Name: filmpersons_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.filmpersons_id_seq', 20, true);


--
-- TOC entry 3448 (class 0 OID 0)
-- Dependencies: 233
-- Name: filmpersonsroles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.filmpersonsroles_id_seq', 129, true);


--
-- TOC entry 3449 (class 0 OID 0)
-- Dependencies: 227
-- Name: films_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.films_id_seq', 59, true);


--
-- TOC entry 3450 (class 0 OID 0)
-- Dependencies: 229
-- Name: roles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.roles_id_seq', 8, true);


--
-- TOC entry 3451 (class 0 OID 0)
-- Dependencies: 237
-- Name: useraccount_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.useraccount_user_id_seq', 6, true);


--
-- TOC entry 3262 (class 2606 OID 34420)
-- Name: filmpersons filmpersons_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.filmpersons
    ADD CONSTRAINT filmpersons_name_key UNIQUE (name);


--
-- TOC entry 3264 (class 2606 OID 34418)
-- Name: filmpersons filmpersons_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.filmpersons
    ADD CONSTRAINT filmpersons_pkey PRIMARY KEY (id);


--
-- TOC entry 3266 (class 2606 OID 34431)
-- Name: filmpersonsroles filmpersonsroles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.filmpersonsroles
    ADD CONSTRAINT filmpersonsroles_pkey PRIMARY KEY (id);


--
-- TOC entry 3268 (class 2606 OID 34450)
-- Name: filmpersonsroles filmpersonsroles_uk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.filmpersonsroles
    ADD CONSTRAINT filmpersonsroles_uk UNIQUE (personname, rolename, filmname);


--
-- TOC entry 3252 (class 2606 OID 16559)
-- Name: films films_description_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.films
    ADD CONSTRAINT films_description_key UNIQUE (description);


--
-- TOC entry 3254 (class 2606 OID 16557)
-- Name: films films_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.films
    ADD CONSTRAINT films_name_key UNIQUE (name);


--
-- TOC entry 3256 (class 2606 OID 16555)
-- Name: films films_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.films
    ADD CONSTRAINT films_pkey PRIMARY KEY (id);


--
-- TOC entry 3258 (class 2606 OID 16639)
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- TOC entry 3260 (class 2606 OID 16641)
-- Name: roles roles_rolename_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_rolename_key UNIQUE (rolename);


--
-- TOC entry 3270 (class 2606 OID 41913)
-- Name: subfilmlinks subfilmlinks_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.subfilmlinks
    ADD CONSTRAINT subfilmlinks_pkey PRIMARY KEY (superfilm_id, subfilm_id);


--
-- TOC entry 3272 (class 2606 OID 44585)
-- Name: user_ratings user_ratings_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_ratings
    ADD CONSTRAINT user_ratings_pkey PRIMARY KEY (user_id, film_name);


--
-- TOC entry 3274 (class 2606 OID 84539)
-- Name: useraccount useraccount_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.useraccount
    ADD CONSTRAINT useraccount_pkey PRIMARY KEY (user_id);


--
-- TOC entry 3276 (class 2606 OID 84541)
-- Name: useraccount useraccount_username_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.useraccount
    ADD CONSTRAINT useraccount_username_key UNIQUE (username);


--
-- TOC entry 3277 (class 2606 OID 34524)
-- Name: filmpersonsroles filmpersonsroles_filmname_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.filmpersonsroles
    ADD CONSTRAINT filmpersonsroles_filmname_fkey FOREIGN KEY (filmname) REFERENCES public.films(name) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3279 (class 2606 OID 34534)
-- Name: filmpersonsroles filmpersonsroles_personname_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.filmpersonsroles
    ADD CONSTRAINT filmpersonsroles_personname_fkey FOREIGN KEY (personname) REFERENCES public.filmpersons(name) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3278 (class 2606 OID 34529)
-- Name: filmpersonsroles filmpersonsroles_rolename_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.filmpersonsroles
    ADD CONSTRAINT filmpersonsroles_rolename_fkey FOREIGN KEY (rolename) REFERENCES public.roles(rolename) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3281 (class 2606 OID 41919)
-- Name: subfilmlinks subfilmlinks_subfilm_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.subfilmlinks
    ADD CONSTRAINT subfilmlinks_subfilm_id_fkey FOREIGN KEY (subfilm_id) REFERENCES public.films(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3280 (class 2606 OID 41914)
-- Name: subfilmlinks subfilmlinks_superfilm_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.subfilmlinks
    ADD CONSTRAINT subfilmlinks_superfilm_id_fkey FOREIGN KEY (superfilm_id) REFERENCES public.films(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3282 (class 2606 OID 44586)
-- Name: user_ratings user_ratings_film_name_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_ratings
    ADD CONSTRAINT user_ratings_film_name_fkey FOREIGN KEY (film_name) REFERENCES public.films(name) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3283 (class 2606 OID 84542)
-- Name: user_ratings user_ratings_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_ratings
    ADD CONSTRAINT user_ratings_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.useraccount(username);


-- Completed on 2022-02-04 02:25:00

--
-- PostgreSQL database dump complete
--

