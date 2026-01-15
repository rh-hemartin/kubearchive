ALTER TABLE public.resource
ADD COLUMN IF NOT EXISTS cluster_id uuid;

