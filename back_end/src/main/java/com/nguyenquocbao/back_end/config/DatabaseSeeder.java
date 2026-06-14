package com.nguyenquocbao.back_end.config;

import com.nguyenquocbao.back_end.entity.Category;
import com.nguyenquocbao.back_end.entity.Gallery;
import com.nguyenquocbao.back_end.entity.Product;
import com.nguyenquocbao.back_end.entity.ProductCategory;
import com.nguyenquocbao.back_end.entity.Tag;
import com.nguyenquocbao.back_end.repository.CategoryRepository;
import com.nguyenquocbao.back_end.repository.GalleryRepository;
import com.nguyenquocbao.back_end.repository.ProductCategoryRepository;
import com.nguyenquocbao.back_end.repository.ProductRepository;
import com.nguyenquocbao.back_end.repository.ProductReviewRepository;
import com.nguyenquocbao.back_end.repository.ReviewGalleryRepository;
import com.nguyenquocbao.back_end.repository.TagRepository;
import com.nguyenquocbao.back_end.repository.UserRepository;
import com.nguyenquocbao.back_end.entity.User;
import com.nguyenquocbao.back_end.entity.ProductReview;
import com.nguyenquocbao.back_end.entity.ReviewGallery;
import com.nguyenquocbao.back_end.entity.Provider;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;
import org.springframework.core.annotation.Order;

import java.util.UUID;
import java.util.Set;
import java.util.List;
import java.util.Random;
import java.util.ArrayList;
import java.time.ZonedDateTime;

@Component
@RequiredArgsConstructor
@Order(1)
public class DatabaseSeeder implements CommandLineRunner {

    private final ProductRepository productRepository;
    private final TagRepository tagRepository;
    private final GalleryRepository galleryRepository;
    private final CategoryRepository categoryRepository;
    private final ProductCategoryRepository productCategoryRepository;
    private final UserRepository userRepository;
    private final ProductReviewRepository productReviewRepository;
    private final ReviewGalleryRepository reviewGalleryRepository;

    @Override
    public void run(String... args) throws Exception {
        if (productRepository.count() > 0) {
            System.out.println("Database already seeded");
            return;
        }

        Tag newTag = tagRepository.save(Tag.builder().name("NEW").build());
        Tag saleTag = tagRepository.save(Tag.builder().name("SALE").build());

        Category tops = categoryRepository.save(Category.builder().categoryName("Tops").build());
        Category clothes = categoryRepository.save(Category.builder().categoryName("Clothes").build());
        Category shoes = categoryRepository.save(Category.builder().categoryName("Shoes").build());
        Category accessories = categoryRepository.save(Category.builder().categoryName("Accessories").build());
        Category shirts = categoryRepository.save(Category.builder().categoryName("Shirts & Blouses").build());
        List<Category> categories = List.of(tops, clothes, shoes, accessories, shirts);

        String[] images = {
            "wc1.jpg", "wc2.jpg", "wc3.jpg", "wc4.jpg", "wc5.jpg", "wc6.jpg", 
            "blouse4.jpg", "blouse5.jpg", "blouse6.jpg", "blouses1.jpg", "blouses2.jpg", "blouses3.jpg", "blouses7.jpg", 
            "wc15.jpg", "wc16.jpg", "wc17.jpg", "wc18.jpg", "wc19.jpg", "wc20.jpg", 
            "dress1.jpg", "dress2.jpg", "dress3.jpg", "dress4.jpg", "dress5.jpg", "dress6.jpg", "blazer6.jpg", 
            "blazer7.jpg", "blazer8.jpg", "blazer9.jpg", "wc7.jpg", "new_dress_1.png", "new_dress_2.png", 
            "womens_fashion_1.png", "womens_fashion_2.png", "womens_fashion_3.png", "womens_fashion_4.png", "new_skirt_1.png", 
            "new_skirt_2.png", "knitwear6.jpg", "pants1.jpg", "womens_fashion_5.png", "womens_fashion_6.png", "womens_fashion_7.png", 
            "womens_fashion_8.png", "womens_fashion_9.png", "red_blouse.png", "sale_bag_1.png", "outerwear6.jpg", "womens_fashion_10.png", 
            "knitwear7.jpg", "knitwear8.jpg", "knitwear9.jpg", "dress7.jpg", "dress8.jpg", 
            "outerwear7.jpg", "outerwear8.jpg", "wc8.jpg", "wc9.jpg", "wc10.jpg", "wc11.jpg", 
            "skirt1.jpg", "skirt2.jpg", "skirt3.jpg", "skirt4.jpg", "skirt5.jpg", "sportdress.jpg", "blazer10.jpg", 
            "wc12.jpg", "wc13.jpg", "wc14.jpg", "womens_top_casual.png", "womens_top_floral.png", 
            "womens_top_silk.png"
        };

        if (productRepository.count() == 0) {
            for (int i = 0; i < images.length; i++) {
                String img = images[i];
                String name = formatProductName(img);
                
                Product p = Product.builder()
                    .slug(img.replace(".jpg", "").replace(".png", "") + "-" + UUID.randomUUID().toString().substring(0, 8))
                    .name(name)
                    .sku("SKU-" + i)
                    .salePrice(50.0 + (i % 50))
                    .comparePrice(i % 2 == 0 ? null : 60.0 + (i % 50))
                    .buyingPrice(30.0)
                    .quantity(100)
                    .shortDescription("This is " + name)
                    .description("Detailed description for " + name)
                    .productType("Apparel")
                    .published(true)
                    .disableOutOfStock(false)
                    .rating(4.5)
                    .reviewCount(10 + i)
                    .tags(Set.of(i % 2 == 0 ? newTag : saleTag))
                    .build();
                
                productRepository.save(p);

                Gallery g = Gallery.builder()
                    .product(p)
                    .image("assets/" + img)
                    .placeholder("assets/" + img)
                    .isThumbnail(true)
                    .build();
                
                galleryRepository.save(g);

                ProductCategory pc = ProductCategory.builder()
                    .product(p)
                    .category(categories.get(i % categories.size()))
                    .build();
                
                productCategoryRepository.save(pc);
            }
        }

        // Seed Users
        List<User> users = new ArrayList<>();
        String[] userNames = {"Helene Moore", "Kate Doe", "Kim Shine", "Matilda Brown", "John Smith", "Jane Austen"};
        String[] avatars = {
            "https://i.pravatar.cc/150?img=1", "https://i.pravatar.cc/150?img=2", 
            "https://i.pravatar.cc/150?img=3", "https://i.pravatar.cc/150?img=4",
            "https://i.pravatar.cc/150?img=5", "https://i.pravatar.cc/150?img=6"
        };
        for (int i = 0; i < userNames.length; i++) {
            User u = new User();
            u.setName(userNames[i]);
            u.setEmail("user" + i + "@example.com");
            u.setPassword("password");
            u.setFirstName(userNames[i].split(" ")[0]);
            u.setLastName(userNames[i].split(" ")[1]);
            u.setImage(avatars[i]);
            u.setProvider(Provider.LOCAL);
            userRepository.save(u);
            users.add(u);
        }

        // Seed Reviews
        List<Product> products = productRepository.findAll();
        Random rand = new Random(42);
        for (Product p : products) {
            int numReviews = 3 + rand.nextInt(10); // 3 to 12 reviews
            double totalRating = 0;
            for (int i = 0; i < numReviews; i++) {
                User u = users.get(rand.nextInt(users.size()));
                double rating = 3.0 + rand.nextInt(3); // 3, 4, 5
                totalRating += rating;
                
                ProductReview review = ProductReview.builder()
                    .product(p)
                    .user(u)
                    .rating(rating)
                    .content("I loved this product so much as soon as I tried it on I knew I had to buy it in another color. Highly recommended!")
                    .build();
                productReviewRepository.save(review);

                // Add 2 photos to about 30% of reviews
                if (rand.nextDouble() < 0.3) {
                    reviewGalleryRepository.save(ReviewGallery.builder()
                        .review(review)
                        .imageUrl("https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?ixlib=rb-4.0.3&auto=format&fit=crop&w=400&q=80")
                        .build());
                    reviewGalleryRepository.save(ReviewGallery.builder()
                        .review(review)
                        .imageUrl("https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?ixlib=rb-4.0.3&auto=format&fit=crop&w=400&q=80")
                        .build());
                }
            }
            p.setReviewCount(numReviews);
            p.setRating(Math.round((totalRating / numReviews) * 10.0) / 10.0);
            productRepository.save(p);
        }

        System.out.println("Seeded " + images.length + " products, categories, users, and reviews.");
    }

    private String formatProductName(String filename) {
        String baseName = filename.replace(".jpg", "").replace(".png", "").replace("_", " ");
        baseName = baseName.replaceAll("[0-9]", "").trim(); // remove numbers
        String[] words = baseName.split(" ");
        StringBuilder sb = new StringBuilder();
        for (String word : words) {
            if (word.length() > 0) {
                sb.append(Character.toUpperCase(word.charAt(0)));
                if (word.length() > 1) {
                    sb.append(word.substring(1).toLowerCase());
                }
                sb.append(" ");
            }
        }
        String formatted = sb.toString().trim();
        
        if (formatted.equalsIgnoreCase("Sale Item") || formatted.equalsIgnoreCase("Clothes") || formatted.equalsIgnoreCase("Streetcloth")) {
            formatted = "Trendy Fashion Apparel";
        }
        if (formatted.equalsIgnoreCase("Wc")) {
            formatted = "Women's Collection Exclusive";
        }

        // Add e-commerce flair based on keywords
        String lower = formatted.toLowerCase();
        if (lower.contains("blazer")) {
            return "Premium Women's " + formatted + " - Elegant Office Wear";
        } else if (lower.contains("blouse") || lower.contains("top")) {
            return "Casual " + formatted + " - Summer Collection 2024";
        } else if (lower.contains("dress") || lower.contains("skirt")) {
            return "Vintage " + formatted + " - Perfect for Parties";
        } else if (lower.contains("knitwear") || lower.contains("sweater") || lower.contains("pullover")) {
            return "Cozy Winter " + formatted + " - Warm & Soft";
        } else if (lower.contains("shirt") || lower.contains("tshirt")) {
            return "Classic 100% Cotton " + formatted + " - Regular Fit";
        } else if (lower.contains("bag")) {
            return "Luxury Designer " + formatted + " - Premium Leather";
        } else if (lower.contains("shoes")) {
            return "Comfortable " + formatted + " - Breathable Sneakers";
        } else if (lower.contains("outerwear") || lower.contains("jacket")) {
            return "Stylish " + formatted + " - Windproof Coat";
        } else if (lower.contains("pants")) {
            return "High-Waisted Straight " + formatted + " - Casual Fit";
        } else {
            return "Fashionable " + formatted + " - New Arrival";
        }
    }
}
