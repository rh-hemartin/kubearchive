CREATE TABLE public.log_url (
    uuid uuid NOT NULL,
    url text NOT NULL
);

ALTER TABLE ONLY public.log_url
    ADD CONSTRAINT fk_uuid_resource FOREIGN KEY (uuid) REFERENCES public.resource(uuid);

ALTER TABLE public.log_url OWNER TO kubearchive;
