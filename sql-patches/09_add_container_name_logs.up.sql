ALTER TABLE public.log_url
    ADD COLUMN container_name text NOT NULL,
    ADD COLUMN created_at timestamp without time zone DEFAULT now() NOT NULL,
    ADD COLUMN updated_at timestamp without time zone DEFAULT now() NOT NULL;

CREATE TRIGGER set_timestamp BEFORE UPDATE ON public.log_url
    FOR EACH ROW EXECUTE FUNCTION public.trigger_set_timestamp();
