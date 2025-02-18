DROP INDEX idx_creation_timestamp;
CREATE INDEX idx_creation_timestamp ON public.resource
    USING gin ((((data -> 'metadata'::text) -> 'creationTimestamp'::text)) jsonb_path_ops);
