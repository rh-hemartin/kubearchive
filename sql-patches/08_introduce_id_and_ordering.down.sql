ALTER TABLE ONLY public.log_url RENAME TO log_url_old;
ALTER TABLE ONLY public.resource RENAME TO resource_old;

CREATE TABLE public.resource (
    uuid uuid PRIMARY KEY,
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
CREATE TRIGGER set_timestamp BEFORE UPDATE ON public.resource FOR EACH ROW EXECUTE FUNCTION public.trigger_set_timestamp();

INSERT INTO public.resource(uuid, api_version, kind, name, namespace, resource_version, created_at, updated_at, cluster_deleted_ts, data)
    SELECT uuid, api_version, kind, name, namespace, resource_version, created_at, updated_at, cluster_deleted_ts, data
    FROM public.resource_old ORDER BY data->'metadata'->>'creationTimestamp';


CREATE TABLE public.log_url (
    uuid uuid NOT NULL,
    url text NOT NULL
);

ALTER TABLE public.log_url OWNER TO kubearchive;

ALTER TABLE ONLY public.log_url
    ADD CONSTRAINT fk_uuid_resource FOREIGN KEY (uuid) REFERENCES public.resource(uuid);

DROP TABLE public.log_url_old;
DROP TABLE public.resource_old;

CREATE INDEX resource_kind_idx ON public.resource
    USING btree (kind, api_version);
CREATE INDEX resource_kind_namespace_idx ON public.resource
    USING btree (kind, api_version, namespace);
CREATE INDEX idx_json_annotations ON public.resource
    USING gin ((((data -> 'metadata'::text) -> 'annotations'::text)) jsonb_path_ops);
CREATE INDEX idx_json_labels ON public.resource
    USING gin ((((data -> 'metadata'::text) -> 'labels'::text)) jsonb_path_ops);
CREATE INDEX idx_json_owners ON public.resource
    USING gin ((((data -> 'metadata'::text) -> 'ownerReferences'::text)) jsonb_path_ops);
CREATE INDEX idx_creation_timestamp ON public.resource
    USING btree ((((data -> 'metadata'::text) ->> 'creationTimestamp'::text)) DESC);
