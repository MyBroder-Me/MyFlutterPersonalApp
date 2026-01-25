-- =====================================================
-- Add disabled_at column to profiles table
-- =====================================================
-- Allows soft-disabling accounts instead of hard-deleting,
-- preserving user data and purchases.

ALTER TABLE public.profiles
ADD COLUMN disabled_at TIMESTAMPTZ DEFAULT NULL;

COMMENT ON COLUMN public.profiles.disabled_at IS
  'When account was disabled. NULL = active account.';

-- Index for querying disabled accounts efficiently
CREATE INDEX idx_profiles_disabled_at ON public.profiles(disabled_at)
WHERE disabled_at IS NOT NULL;
