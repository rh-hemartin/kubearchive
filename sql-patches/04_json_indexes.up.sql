CREATE INDEX idx_json_annotations ON public.resource USING gin ((((data -> 'metadata'::text) -> 'annotations'::text)) jsonb_path_ops);
CREATE INDEX idx_json_labels ON public.resource USING gin ((((data -> 'metadata'::text) -> 'labels'::text)) jsonb_path_ops);
CREATE INDEX idx_json_owners ON public.resource USING gin ((((data -> 'metadata'::text) -> 'ownerReferences'::text)) jsonb_path_ops);
