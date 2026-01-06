import { useEffect, useState } from 'react';
import { useParams, Link } from 'react-router-dom';
import { supabase } from '../lib/supabase';
import { useCart } from '../context/CartContext';
import './ProductPage.css';

interface Product {
  id: string;
  name: string;
  description: string;
  price: number;
  image_url: string;
  category: string;
  stock: number;
}

export default function ProductPage() {
  const { id } = useParams<{ id: string }>();
  const [product, setProduct] = useState<Product | null>(null);
  const [loading, setLoading] = useState(true);
  const [quantity, setQuantity] = useState(1);
  const { addToCart } = useCart();

  useEffect(() => {
    async function fetchProduct() {
      if (!id) return;

      const { data, error } = await supabase
        .from('products')
        .select('*')
        .eq('id', id)
        .maybeSingle();

      if (!error && data) {
        setProduct(data);
      }
      setLoading(false);
    }

    fetchProduct();
  }, [id]);

  const handleAddToCart = () => {
    if (product) {
      addToCart(product.id, quantity);
    }
  };

  if (loading) {
    return <div className="loading-page">Loading...</div>;
  }

  if (!product) {
    return (
      <div className="error-page">
        <h2>Product not found</h2>
        <Link to="/shop" className="back-link">← Back to Shop</Link>
      </div>
    );
  }

  return (
    <div className="product-page">
      <div className="product-container">
        <Link to="/shop" className="back-link">← Back to Shop</Link>

        <div className="product-layout">
          <div className="product-image-section">
            <img src={product.image_url} alt={product.name} className="product-detail-image" />
          </div>

          <div className="product-detail-section">
            <div className="product-category-badge">{product.category}</div>
            <h1 className="product-detail-title">{product.name}</h1>
            <p className="product-detail-description">{product.description}</p>

            <div className="product-detail-price">${product.price.toFixed(2)}</div>

            <div className="product-stock">
              {product.stock > 0 ? (
                <span className="in-stock">✓ In Stock ({product.stock} available)</span>
              ) : (
                <span className="out-of-stock">Out of Stock</span>
              )}
            </div>

            <div className="product-actions">
              <div className="quantity-selector">
                <button
                  onClick={() => setQuantity(Math.max(1, quantity - 1))}
                  className="quantity-button"
                  disabled={quantity <= 1}
                >
                  -
                </button>
                <span className="quantity-value">{quantity}</span>
                <button
                  onClick={() => setQuantity(Math.min(product.stock, quantity + 1))}
                  className="quantity-button"
                  disabled={quantity >= product.stock}
                >
                  +
                </button>
              </div>

              <button
                onClick={handleAddToCart}
                className="add-to-cart-large"
                disabled={product.stock === 0}
              >
                Add to Cart
              </button>
            </div>

            <div className="product-info-grid">
              <div className="info-item">
                <div className="info-label">Category</div>
                <div className="info-value">{product.category}</div>
              </div>
              <div className="info-item">
                <div className="info-label">Availability</div>
                <div className="info-value">{product.stock > 0 ? 'In Stock' : 'Out of Stock'}</div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
