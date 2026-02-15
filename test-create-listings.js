// Test Script to Create Sample Listings for Testing
// Run this in MongoDB Compass or MongoDB Shell

// First, get a valid user ID (seller)
// Replace with your actual user ID from the database
const sellerId = "YOUR_USER_ID_HERE";

// Sample listings to create
db.listings.insertMany([
  {
    title: "Calculus Early Transcendentals 8th Edition",
    description: "Excellent condition. Barely used. Perfect for MATH 141 students. Includes access code.",
    price: 85.00,
    priceType: "sell",
    category: "books",
    condition: "like-new",
    images: [
      {
        url: "https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=400",
        publicId: "sample_calculus_book",
        imageUrl: "https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=400"
      }
    ],
    seller: ObjectId(sellerId),
    status: "pending",
    location: "Main Campus Library",
    contactPreference: "chat",
    views: 0,
    isFeatured: false,
    createdAt: new Date(),
    updatedAt: new Date()
  },
  {
    title: "MacBook Pro 2020 M1 - 16GB RAM",
    description: "Perfect for CS students. Includes charger, case, and original box. Battery health 95%.",
    price: 1200.00,
    priceType: "sell",
    category: "electronics",
    condition: "good",
    images: [
      {
        url: "https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=400",
        publicId: "sample_macbook",
        imageUrl: "https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=400"
      }
    ],
    seller: ObjectId(sellerId),
    status: "pending",
    location: "Engineering Building",
    contactPreference: "chat",
    views: 0,
    isFeatured: false,
    createdAt: new Date(),
    updatedAt: new Date()
  },
  {
    title: "Studio Apartment - Summer Sublet",
    description: "Fully furnished studio near campus. Available May-August. Utilities included, parking available.",
    price: 750.00,
    priceType: "rent",
    category: "housing",
    condition: "good",
    images: [
      {
        url: "https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=400",
        publicId: "sample_apartment",
        imageUrl: "https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=400"
      }
    ],
    seller: ObjectId(sellerId),
    status: "pending",
    location: "University Village",
    contactPreference: "phone",
    views: 0,
    isFeatured: false,
    createdAt: new Date(),
    updatedAt: new Date()
  },
  {
    title: "Tutoring Services - Math & Physics",
    description: "Graduate student offering tutoring. $25/hr. Flexible schedule, can meet on campus or online.",
    price: 25.00,
    priceType: "sell",
    category: "services",
    condition: "new",
    images: [
      {
        url: "https://images.unsplash.com/photo-1503676260728-1c00da094a0b?w=400",
        publicId: "sample_tutoring",
        imageUrl: "https://images.unsplash.com/photo-1503676260728-1c00da094a0b?w=400"
      }
    ],
    seller: ObjectId(sellerId),
    status: "pending",
    location: "Online/Campus",
    contactPreference: "chat",
    views: 0,
    isFeatured: false,
    createdAt: new Date(),
    updatedAt: new Date()
  },
  {
    title: "Organic Chemistry Lab Manual",
    description: "CHEM 226 lab manual. Great condition with notes. $30 or best offer.",
    price: 30.00,
    priceType: "sell",
    category: "books",
    condition: "good",
    images: [
      {
        url: "https://images.unsplash.com/photo-1532012197267-da84d127e765?w=400",
        publicId: "sample_chem_manual",
        imageUrl: "https://images.unsplash.com/photo-1532012197267-da84d127e765?w=400"
      }
    ],
    seller: ObjectId(sellerId),
    status: "pending",
    location: "Science Building",
    contactPreference: "chat",
    views: 0,
    isFeatured: false,
    createdAt: new Date(),
    updatedAt: new Date()
  }
]);

print("Sample listings created successfully!");
