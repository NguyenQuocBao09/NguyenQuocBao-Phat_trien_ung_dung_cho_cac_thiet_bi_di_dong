package com.nguyenquocbao.back_end.repository;

import com.nguyenquocbao.back_end.entity.Cart;
import com.nguyenquocbao.back_end.entity.CartItem;
import com.nguyenquocbao.back_end.entity.Product;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface CartItemRepository extends JpaRepository<CartItem, UUID> {
    List<CartItem> findByCart(Cart cart);
    Optional<CartItem> findByCartAndProductAndColorAndSize(Cart cart, Product product, String color, String size);
    void deleteByCart(Cart cart);
}
