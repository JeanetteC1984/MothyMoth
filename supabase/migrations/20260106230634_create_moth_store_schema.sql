/*
  # Create Moth Store Schema
  
  1. New Tables
    - `products`
      - `id` (uuid, primary key)
      - `name` (text) - Product name
      - `description` (text) - Product description
      - `price` (numeric) - Product price in dollars
      - `image_url` (text) - URL to product image
      - `category` (text) - Product category (live moth, preserved moth, moth art)
      - `stock` (integer) - Available stock quantity
      - `featured` (boolean) - Whether product is featured
      - `created_at` (timestamp)
    
    - `cart_items`
      - `id` (uuid, primary key)
      - `user_id` (uuid, references auth.users)
      - `product_id` (uuid, references products)
      - `quantity` (integer) - Quantity in cart
      - `created_at` (timestamp)
    
    - `orders`
      - `id` (uuid, primary key)
      - `user_id` (uuid, references auth.users)
      - `total` (numeric) - Order total amount
      - `status` (text) - Order status (pending, completed, cancelled)
      - `customer_name` (text) - Customer name
      - `customer_email` (text) - Customer email
      - `customer_address` (text) - Delivery address
      - `created_at` (timestamp)
    
    - `order_items`
      - `id` (uuid, primary key)
      - `order_id` (uuid, references orders)
      - `product_id` (uuid, references products)
      - `quantity` (integer) - Quantity ordered
      - `price` (numeric) - Price at time of order
      - `created_at` (timestamp)
  
  2. Security
    - Enable RLS on all tables
    - Products: Public read access, no write access
    - Cart items: Users can manage their own cart items
    - Orders: Users can view their own orders
    - Order items: Users can view items from their own orders
*/

-- Create products table
CREATE TABLE IF NOT EXISTS products (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  description text NOT NULL,
  price numeric(10, 2) NOT NULL,
  image_url text NOT NULL,
  category text NOT NULL,
  stock integer NOT NULL DEFAULT 0,
  featured boolean DEFAULT false,
  created_at timestamptz DEFAULT now()
);

-- Create cart_items table
CREATE TABLE IF NOT EXISTS cart_items (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
  product_id uuid REFERENCES products(id) ON DELETE CASCADE,
  quantity integer NOT NULL DEFAULT 1,
  created_at timestamptz DEFAULT now(),
  UNIQUE(user_id, product_id)
);

-- Create orders table
CREATE TABLE IF NOT EXISTS orders (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) ON DELETE SET NULL,
  total numeric(10, 2) NOT NULL,
  status text NOT NULL DEFAULT 'pending',
  customer_name text NOT NULL,
  customer_email text NOT NULL,
  customer_address text NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- Create order_items table
CREATE TABLE IF NOT EXISTS order_items (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id uuid REFERENCES orders(id) ON DELETE CASCADE,
  product_id uuid REFERENCES products(id) ON DELETE SET NULL,
  quantity integer NOT NULL,
  price numeric(10, 2) NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- Enable RLS
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE cart_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_items ENABLE ROW LEVEL SECURITY;

-- Products policies (public read)
CREATE POLICY "Anyone can view products"
  ON products FOR SELECT
  TO public
  USING (true);

-- Cart items policies
CREATE POLICY "Users can view own cart items"
  ON cart_items FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own cart items"
  ON cart_items FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own cart items"
  ON cart_items FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own cart items"
  ON cart_items FOR DELETE
  TO authenticated
  USING (auth.uid() = user_id);

-- Orders policies
CREATE POLICY "Users can view own orders"
  ON orders FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can create orders"
  ON orders FOR INSERT
  TO authenticated
  WITH CHECK (true);

-- Order items policies
CREATE POLICY "Users can view own order items"
  ON order_items FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM orders
      WHERE orders.id = order_items.order_id
      AND orders.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can create order items"
  ON order_items FOR INSERT
  TO authenticated
  WITH CHECK (true);

-- Insert sample moth products
INSERT INTO products (name, description, price, image_url, category, stock, featured) VALUES
  ('Luna Moth', 'Beautiful green luna moth with elegant long tails. Native to North America, these gentle creatures are a stunning addition to any collection.', 49.99, 'https://images.pexels.com/photos/3889855/pexels-photo-3889855.jpeg', 'live', 12, true),
  ('Atlas Moth', 'One of the largest moth species in the world. Their wingspan can reach up to 12 inches, displaying gorgeous russet and cream patterns.', 89.99, 'https://images.pexels.com/photos/6641495/pexels-photo-6641495.jpeg', 'live', 8, true),
  ('Rosy Maple Moth', 'Adorable pink and yellow fuzzy moth. Their soft pastel colors make them look like little pieces of candy with wings.', 34.99, 'https://images.pexels.com/photos/4899139/pexels-photo-4899139.jpeg', 'live', 15, true),
  ('Death''s-head Hawkmoth', 'Famous for the skull-like pattern on their thorax. These fascinating moths have been featured in popular culture for decades.', 79.99, 'https://images.pexels.com/photos/7368291/pexels-photo-7368291.jpeg', 'live', 6, false),
  ('Cecropia Moth', 'North America''s largest native moth with striking red and white markings. A magnificent specimen for any enthusiast.', 64.99, 'https://images.pexels.com/photos/4781930/pexels-photo-4781930.jpeg', 'live', 10, false),
  ('Emperor Moth', 'Beautiful European moth with prominent eye spots on all four wings. Their subtle earth tones create a mesmerizing pattern.', 54.99, 'https://images.pexels.com/photos/5680054/pexels-photo-5680054.jpeg', 'live', 9, false),
  ('Framed Luna Moth Display', 'Professionally preserved luna moth in a shadow box frame. Perfect for display in your home or office.', 129.99, 'https://images.pexels.com/photos/4666751/pexels-photo-4666751.jpeg', 'preserved', 20, true),
  ('Atlas Moth Wing Art', 'Stunning artistic piece featuring genuine atlas moth wings. Each piece is unique and comes with certificate of authenticity.', 199.99, 'https://images.pexels.com/photos/5836716/pexels-photo-5836716.jpeg', 'art', 5, false),
  ('Moth Study Collection', 'Curated collection of 6 different preserved moth species in a beautiful display case. Educational and decorative.', 249.99, 'https://images.pexels.com/photos/6992094/pexels-photo-6992094.jpeg', 'preserved', 7, true),
  ('Vintage Moth Illustration Print', 'High-quality reproduction of Victorian-era moth scientific illustrations. Printed on archival paper.', 39.99, 'https://images.pexels.com/photos/6077144/pexels-photo-6077144.jpeg', 'art', 50, false),
  ('Polyphemus Moth', 'Large silk moth with beautiful eye spots. Their wingspan reaches up to 6 inches with stunning pink and yellow accents.', 59.99, 'https://images.pexels.com/photos/5582923/pexels-photo-5582923.jpeg', 'live', 11, false),
  ('Io Moth', 'Striking yellow moth with large eye spots that flash when threatened. A favorite among collectors.', 44.99, 'https://images.pexels.com/photos/6012302/pexels-photo-6012302.jpeg', 'live', 13, false);
