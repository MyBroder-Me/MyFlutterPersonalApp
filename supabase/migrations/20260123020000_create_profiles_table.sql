-- =====================================================
-- Create profiles table with auto-creation trigger
-- =====================================================

-- Create profiles table
CREATE TABLE public.profiles (
  -- Primary key references auth.users
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,

  -- Timestamps
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,

  -- Identity
  display_name TEXT,
  avatar_url TEXT,

  -- Subscription
  is_premium BOOLEAN DEFAULT FALSE NOT NULL,
  premium_until TIMESTAMPTZ,

  -- App Settings
  theme TEXT DEFAULT 'system' CHECK (theme IN ('light', 'dark', 'system')),
  enabled_spaces TEXT[] DEFAULT ARRAY['books']::TEXT[],

  -- Catch-all for future settings
  preferences JSONB DEFAULT '{}'::JSONB
);

-- Add comment for documentation
COMMENT ON TABLE public.profiles IS 'User profiles with app settings and preferences';
COMMENT ON COLUMN public.profiles.enabled_spaces IS 'Array of space identifiers the user has enabled';
COMMENT ON COLUMN public.profiles.preferences IS 'JSONB for misc settings (notifications, language, currency, etc.)';

-- =====================================================
-- Auto-update updated_at timestamp
-- =====================================================

CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER on_profiles_updated
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- =====================================================
-- Auto-create profile on user signup
-- =====================================================

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, display_name, avatar_url)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.raw_user_meta_data->>'name'),
    NEW.raw_user_meta_data->>'avatar_url'
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- =====================================================
-- Row Level Security
-- =====================================================

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Users can view their own profile
CREATE POLICY "Users can view own profile"
  ON public.profiles
  FOR SELECT
  USING (auth.uid() = id);

-- Users can update their own profile
CREATE POLICY "Users can update own profile"
  ON public.profiles
  FOR UPDATE
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

-- Note: No INSERT policy needed - trigger handles creation
-- Note: No DELETE policy - profiles deleted via CASCADE when auth.users deleted

-- =====================================================
-- Indexes
-- =====================================================

CREATE INDEX idx_profiles_is_premium ON public.profiles(is_premium) WHERE is_premium = TRUE;

-- =====================================================
-- Grants
-- =====================================================

GRANT SELECT, UPDATE ON public.profiles TO authenticated;
