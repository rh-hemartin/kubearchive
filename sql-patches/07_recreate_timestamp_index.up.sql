DROP INDEX idx_creation_timestamp;
CREATE INDEX idx_creation_timestamp ON public.resource
    USING btree ((((data -> 'metadata'::text) ->> 'creationTimestamp'::text)) DESC);
