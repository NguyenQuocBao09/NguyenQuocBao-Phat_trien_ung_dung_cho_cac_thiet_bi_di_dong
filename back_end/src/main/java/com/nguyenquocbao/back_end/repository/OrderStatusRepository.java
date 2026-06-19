package com.nguyenquocbao.back_end.repository;

import com.nguyenquocbao.back_end.entity.OrderStatus;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;
import java.util.UUID;

public interface OrderStatusRepository extends JpaRepository<OrderStatus, UUID> {
    Optional<OrderStatus> findByStatusName(String statusName);
}
