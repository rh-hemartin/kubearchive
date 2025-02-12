DROP INDEX idx_creation_timestamp_id;
CREATE INDEX idx_creation_timestamp ON public.resource
    USING btree ((((data -> 'metadata'::text) ->> 'creationTimestamp'::text)) DESC);

ALTER TABLE ONLY public.log_url
    DROP CONSTRAINT log_url_uuid_fkey;

ALTER TABLE ONLY public.resource
    DROP CONSTRAINT resource_uuid_key;

ALTER TABLE ONLY public.resource
    DROP CONSTRAINT resource_pkey;

ALTER TABLE ONLY public.resource
    ADD CONSTRAINT resource_pkey PRIMARY KEY (uuid);

ALTER TABLE ONLY public.log_url
    DROP CONSTRAINT log_url_pkey;

ALTER TABLE ONLY public.resource
    DROP COLUMN id;

ALTER TABLE ONLY public.log_url
    DROP COLUMN id;

ALTER TABLE ONLY public.log_url
    ADD CONSTRAINT fk_uuid_resource FOREIGN KEY (uuid) REFERENCES public.resource(uuid);
