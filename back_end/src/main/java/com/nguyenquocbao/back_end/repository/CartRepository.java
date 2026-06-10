package com.nguyenquocbao.back_end.repository;

import com.nguyenquocbao.back_end.entity.Cart;
import com.nguyenquocbao.back_end.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface CartRepository extends JpaRepository<Cart, UUID> {
    Optional<Cart> findByUser(User user);
}
