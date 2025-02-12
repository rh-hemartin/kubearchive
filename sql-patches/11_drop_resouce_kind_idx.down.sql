CREATE INDEX resource_kind_idx ON public.resource USING btree (kind, api_version);
