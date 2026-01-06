import { Link } from 'react-router-dom';
import { useCart } from '../context/CartContext';
import './ProductCard.css';

interface ProductCardProps {
  id: string;
  name: string;
  price: number;
  image_url: string;
  category: string;
}

export default function ProductCard({ id, name, price, image_url, category }: ProductCardProps) {
  const { addToCart } = useCart();

  const handleAddToCart = (e: React.MouseEvent) => {
    e.preventDefault();
    addToCart(id);
  };

  return (
    <Link to={`/product/${id}`} className="product-card">
      <div className="product-image-container">
        <img src={image_url} alt={name} className="product-image" />
        <div className="product-category">{category}</div>
      </div>
      <div className="product-info">
        <h3 className="product-name">{name}</h3>
        <div className="product-footer">
          <span className="product-price">${price.toFixed(2)}</span>
          <button onClick={handleAddToCart} className="add-to-cart-button">
            Add to Cart
          </button>
        </div>
      </div>
    </Link>
  );
}
