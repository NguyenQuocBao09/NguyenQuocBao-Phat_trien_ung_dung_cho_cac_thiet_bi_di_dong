package com.nguyenquocbao.back_end.repository;

import com.nguyenquocbao.back_end.entity.PaymentCard;
import com.nguyenquocbao.back_end.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface PaymentCardRepository extends JpaRepository<PaymentCard, UUID> {
    List<PaymentCard> findByUser(User user);
}
