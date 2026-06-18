package com.nguyenquocbao.back_end.repository;

import com.nguyenquocbao.back_end.entity.Order;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import com.nguyenquocbao.back_end.entity.User;

@Repository
public interface OrderRepository extends JpaRepository<Order, String> {
    List<Order> findByUserOrderByCreatedAtDesc(User user);
}
