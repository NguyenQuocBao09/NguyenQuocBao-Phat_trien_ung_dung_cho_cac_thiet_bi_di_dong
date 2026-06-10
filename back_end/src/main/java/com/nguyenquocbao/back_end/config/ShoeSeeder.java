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
import com.nguyenquocbao.back_end.repository.TagRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;
import org.springframework.core.annotation.Order;

import java.util.UUID;
import java.util.Set;
import java.util.List;

@Component
@RequiredArgsConstructor
@Order(2)
public class ShoeSeeder implements CommandLineRunner {

    private final ProductRepository productRepository;
    private final TagRepository tagRepository;
    private final GalleryRepository galleryRepository;
    private final CategoryRepository categoryRepository;
    private final ProductCategoryRepository productCategoryRepository;

    @Override
    public void run(String... args) throws Exception {
        List<Product> allProducts = productRepository.findAll();
        boolean hasShoes = allProducts.stream().anyMatch(p -> p.getSku() != null && p.getSku().startsWith("SHOE-"));
        if (hasShoes) {
            System.out.println("Shoes already seeded");
            return;
        }

        Category shoesCategory = categoryRepository.findByCategoryName("Shoes").orElseGet(() -> 
            categoryRepository.save(Category.builder().categoryName("Shoes").build())
        );

        Tag newTag = tagRepository.findByName("NEW").orElseGet(() -> 
            tagRepository.save(Tag.builder().name("NEW").build())
        );
        Tag saleTag = tagRepository.findByName("SALE").orElseGet(() -> 
            tagRepository.save(Tag.builder().name("SALE").build())
        );

        String[][] shoesData = {
            {"Nike Air Max", "Comfortable running shoes", "assets/sale_shoes_1.png", "120.0", "150.0"},
            {"Adidas Ultraboost", "Premium athletic sneakers", "assets/sale_shoes_2.png", "140.0", "180.0"},
            {"Classic Leather Oxfords", "Elegant formal shoes", "assets/shoescte.jpg", "85.0", "110.0"},
            {"Summer Sandals", "Breathable and light for the beach", "assets/sale_shoes_1.png", "45.0", "60.0"},
            {"High Heels Elegant", "Perfect for parties and events", "assets/sale_shoes_2.png", "90.0", "120.0"}
        };

        for (int i = 0; i < shoesData.length; i++) {
            String[] data = shoesData[i];
            String name = data[0];
            String desc = data[1];
            String image = data[2];
            double salePrice = Double.parseDouble(data[3]);
            double comparePrice = Double.parseDouble(data[4]);

            Product p = Product.builder()
                .slug("shoe-" + UUID.randomUUID().toString().substring(0, 8))
                .name(name)
                .sku("SHOE-" + String.format("%03d", i + 1))
                .salePrice(salePrice)
                .comparePrice(comparePrice)
                .buyingPrice(salePrice * 0.6)
                .quantity(50)
                .shortDescription(desc)
                .description("Detailed description for " + name + ". Premium quality.")
                .productType("Footwear")
                .published(true)
                .disableOutOfStock(false)
                .rating(4.5 + (i % 5) * 0.1)
                .reviewCount(15 + i * 5)
                .tags(Set.of(i % 2 == 0 ? newTag : saleTag))
                .build();
            
            productRepository.save(p);

            Gallery g = Gallery.builder()
                .product(p)
                .image(image)
                .placeholder(image)
                .isThumbnail(true)
                .build();
            
            galleryRepository.save(g);

            ProductCategory pc = ProductCategory.builder()
                .product(p)
                .category(shoesCategory)
                .build();
            
            productCategoryRepository.save(pc);
        }

        System.out.println("Seeded 5 new shoe products.");
    }
}
