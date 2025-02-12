CREATE FUNCTION public.trigger_set_timestamp() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
	  NEW.updated_at = NOW();
RETURN NEW;
END;
	$$;

SET default_tablespace = '';
SET default_table_access_method = heap;

CREATE TABLE public.resource (
    uuid uuid NOT NULL,
    api_version character varying NOT NULL,
    kind character varying NOT NULL,
    name character varying NOT NULL,
    namespace character varying NOT NULL,
    resource_version character varying,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    cluster_deleted_ts timestamp without time zone,
    data jsonb NOT NULL
);

ALTER TABLE public.resource OWNER TO kubearchive;

ALTER TABLE ONLY public.resource
    ADD CONSTRAINT resource_pkey PRIMARY KEY (uuid);

CREATE TRIGGER set_timestamp BEFORE UPDATE ON public.resource FOR EACH ROW EXECUTE FUNCTION public.trigger_set_timestamp();
