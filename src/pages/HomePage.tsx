import { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import { supabase } from '../lib/supabase';
import ProductCard from '../components/ProductCard';
import './HomePage.css';

interface Product {
  id: string;
  name: string;
  price: number;
  image_url: string;
  category: string;
}

export default function HomePage() {
  const [featuredProducts, setFeaturedProducts] = useState<Product[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    async function fetchFeaturedProducts() {
      const { data, error } = await supabase
        .from('products')
        .select('*')
        .eq('featured', true)
        .limit(6);

      if (!error && data) {
        setFeaturedProducts(data);
      }
      setLoading(false);
    }

    fetchFeaturedProducts();
  }, []);

  return (
    <div className="home-page">
      <section className="hero">
        <div className="hero-content">
          <h1 className="hero-title">
            Welcome to the
            <br />
            <span className="hero-highlight">Moth Emporium</span>
          </h1>
          <p className="hero-subtitle">
            Discover rare and beautiful moths from around the world.
            <br />
            From living specimens to preserved collections and artwork.
          </p>
          <Link to="/shop" className="hero-button">
            Explore Collection
          </Link>
        </div>
        <div className="hero-decoration">
          <div className="moth-float">🦋</div>
        </div>
      </section>

      <section className="featured-section">
        <div className="section-header">
          <h2 className="section-title">Featured Moths</h2>
          <Link to="/shop" className="view-all-link">
            View All →
          </Link>
        </div>

        {loading ? (
          <div className="loading">Loading...</div>
        ) : (
          <div className="products-grid">
            {featuredProducts.map(product => (
              <ProductCard key={product.id} {...product} />
            ))}
          </div>
        )}
      </section>

      <section className="info-section">
        <div className="info-grid">
          <div className="info-card">
            <div className="info-icon">🌙</div>
            <h3 className="info-title">Nocturnal Beauty</h3>
            <p className="info-description">
              Each moth is carefully selected for its unique patterns and characteristics
            </p>
          </div>
          <div className="info-card">
            <div className="info-icon">🌿</div>
            <h3 className="info-title">Ethically Sourced</h3>
            <p className="info-description">
              All our moths are ethically sourced and sustainably collected
            </p>
          </div>
          <div className="info-card">
            <div className="info-icon">📦</div>
            <h3 className="info-title">Safe Delivery</h3>
            <p className="info-description">
              Secure packaging ensures your moths arrive in perfect condition
            </p>
          </div>
        </div>
      </section>
    </div>
  );
}
