ALTER TABLE public.log_url
    ADD id BIGSERIAL;

ALTER TABLE public.resource
    ADD id BIGSERIAL;

ALTER TABLE ONLY public.log_url
    ADD CONSTRAINT log_url_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.resource
    RENAME CONSTRAINT resource_pkey TO resource_pkey_old;

ALTER TABLE ONLY public.resource
    ADD CONSTRAINT resource_uuid_key UNIQUE (uuid);

ALTER TABLE ONLY public.log_url
    DROP CONSTRAINT fk_uuid_resource;

ALTER TABLE ONLY public.resource
    DROP CONSTRAINT resource_pkey_old;

ALTER TABLE ONLY public.resource
    ADD CONSTRAINT resource_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.log_url
    ADD CONSTRAINT log_url_uuid_fkey FOREIGN KEY (uuid) REFERENCES public.resource(uuid);

DROP INDEX idx_creation_timestamp;
CREATE INDEX idx_creation_timestamp_id ON public.resource
    USING btree ((((data -> 'metadata'::text) ->> 'creationTimestamp'::text)) DESC, id DESC);
