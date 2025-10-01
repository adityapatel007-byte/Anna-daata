-- Create users table
CREATE TABLE users (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    email TEXT UNIQUE NOT NULL,
    name TEXT NOT NULL,
    phone TEXT NOT NULL,
    password TEXT NOT NULL,
    role TEXT NOT NULL CHECK (role IN ('volunteer', 'ngo')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create food_posts table
CREATE TABLE food_posts (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    volunteer_id UUID REFERENCES users(id) ON DELETE CASCADE,
    description TEXT NOT NULL,
    location TEXT NOT NULL,
    pickup_time TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    is_claimed BOOLEAN DEFAULT FALSE,
    claimed_by UUID REFERENCES users(id) ON DELETE SET NULL
);

-- Enable Row Level Security (RLS)
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE food_posts ENABLE ROW LEVEL SECURITY;

-- Create policies for users table
CREATE POLICY "Users can read their own data" ON users
    FOR SELECT USING (auth.uid() = id OR auth.role() = 'anon');

CREATE POLICY "Anyone can insert users" ON users
    FOR INSERT WITH CHECK (true);

-- Create policies for food_posts table
CREATE POLICY "Anyone can read food posts" ON food_posts
    FOR SELECT USING (true);

CREATE POLICY "Volunteers can insert their own posts" ON food_posts
    FOR INSERT WITH CHECK (true);

CREATE POLICY "NGOs can update food posts to claim them" ON food_posts
    FOR UPDATE USING (true);