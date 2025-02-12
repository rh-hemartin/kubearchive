CREATE INDEX resource_kind_idx ON public.resource USING btree (kind, api_version);
CREATE INDEX resource_kind_namespace_idx ON public.resource USING btree (kind, api_version, namespace);
