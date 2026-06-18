package com.nguyenquocbao.back_end.repository;

import com.nguyenquocbao.back_end.entity.OrderItem;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.UUID;

import java.util.List;
import com.nguyenquocbao.back_end.entity.Order;

@Repository
public interface OrderItemRepository extends JpaRepository<OrderItem, UUID> {
    List<OrderItem> findByOrder(Order order);
}
