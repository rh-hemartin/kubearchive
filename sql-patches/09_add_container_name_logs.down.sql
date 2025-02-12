DROP TRIGGER set_timestamp ON public.log_url;

ALTER TABLE public.log_url
    DROP COLUMN container_name,
    DROP COLUMN created_at,
    DROP COLUMN updated_at;
