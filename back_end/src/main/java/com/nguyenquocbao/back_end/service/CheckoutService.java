package com.nguyenquocbao.back_end.service;

import com.nguyenquocbao.back_end.entity.DeliveryMethod;
import com.nguyenquocbao.back_end.entity.PaymentCard;
import com.nguyenquocbao.back_end.entity.User;
import com.nguyenquocbao.back_end.entity.UserAddress;
import com.nguyenquocbao.back_end.entity.Cart;
import com.nguyenquocbao.back_end.entity.CartItem;
import com.nguyenquocbao.back_end.entity.Order;
import com.nguyenquocbao.back_end.entity.OrderItem;
import com.nguyenquocbao.back_end.repository.*;
import com.nguyenquocbao.back_end.dto.SubmitOrderRequest;
import jakarta.annotation.PostConstruct;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class CheckoutService {

    private final UserAddressRepository userAddressRepository;
    private final PaymentCardRepository paymentCardRepository;
    private final DeliveryMethodRepository deliveryMethodRepository;
    private final OrderRepository orderRepository;
    private final OrderItemRepository orderItemRepository;
    private final CartRepository cartRepository;
    private final CartItemRepository cartItemRepository;

    @PostConstruct
    @Transactional
    public void initMockData() {
        if (deliveryMethodRepository.count() == 0) {
            deliveryMethodRepository.save(DeliveryMethod.builder().name("FedEx").duration("2-3 days").price(15.0).logoUrl("fedex.png").build());
            deliveryMethodRepository.save(DeliveryMethod.builder().name("USPS.COM").duration("2-3 days").price(10.0).logoUrl("usps.png").build());
            deliveryMethodRepository.save(DeliveryMethod.builder().name("DHL").duration("2-3 days").price(20.0).logoUrl("dhl.png").build());
        }
    }

    @Transactional
    public synchronized void initUserMockDataIfNeeded(User user) {
        if (userAddressRepository.findByUser(user).isEmpty()) {
            userAddressRepository.save(UserAddress.builder()
                    .user(user)
                    .fullName("Jane Doe")
                    .address("3 Newbridge Court")
                    .city("Chino Hills")
                    .state("CA")
                    .zipCode("91709")
                    .country("United States")
                    .isDefault(true)
                    .build());
        }

        if (paymentCardRepository.findByUser(user).isEmpty()) {
            paymentCardRepository.save(PaymentCard.builder()
                    .user(user)
                    .cardHolderName("Jennyfer Doe")
                    .cardNumber("**** **** **** 3947")
                    .expiryDate("05/23")
                    .brand("Mastercard")
                    .isDefault(true)
                    .build());
            paymentCardRepository.save(PaymentCard.builder()
                    .user(user)
                    .cardHolderName("Jennyfer Doe")
                    .cardNumber("**** **** **** 4546")
                    .expiryDate("11/22")
                    .brand("Visa")
                    .isDefault(false)
                    .build());
        }
    }

    @Transactional
    public List<UserAddress> getUserAddresses(User user) {
        initUserMockDataIfNeeded(user);
        return userAddressRepository.findByUser(user);
    }

    @Transactional
    public List<PaymentCard> getPaymentCards(User user) {
        initUserMockDataIfNeeded(user);
        return paymentCardRepository.findByUser(user);
    }

    public List<DeliveryMethod> getDeliveryMethods() {
        return deliveryMethodRepository.findAll();
    }

    @Transactional
    public PaymentCard addPaymentCard(User user, PaymentCard card) {
        if (card.getIsDefault() != null && card.getIsDefault()) {
            clearDefaultPaymentCard(user);
        } else if (paymentCardRepository.findByUser(user).isEmpty()) {
            card.setIsDefault(true);
        } else {
            card.setIsDefault(false);
        }
        card.setUser(user);
        return paymentCardRepository.save(card);
    }

    @Transactional
    public void setDefaultPaymentCard(User user, UUID cardId) {
        clearDefaultPaymentCard(user);
        PaymentCard card = paymentCardRepository.findById(cardId)
                .orElseThrow(() -> new RuntimeException("Card not found"));
        if (card.getUser().getId().equals(user.getId())) {
            card.setIsDefault(true);
            paymentCardRepository.save(card);
        }
    }

    @Transactional
    public void deletePaymentCard(User user, UUID cardId) {
        PaymentCard card = paymentCardRepository.findById(cardId)
                .orElseThrow(() -> new RuntimeException("Card not found"));
        if (!card.getUser().getId().equals(user.getId())) {
            throw new RuntimeException("Unauthorized");
        }
        paymentCardRepository.delete(card);
    }

    private void clearDefaultPaymentCard(User user) {
        List<PaymentCard> cards = paymentCardRepository.findByUser(user);
        for (PaymentCard c : cards) {
            if (c.getIsDefault() != null && c.getIsDefault()) {
                c.setIsDefault(false);
                paymentCardRepository.save(c);
            }
        }
    }

    @Transactional
    public UserAddress addUserAddress(User user, UserAddress address) {
        if (address.getIsDefault() != null && address.getIsDefault()) {
            clearDefaultAddress(user);
        } else if (userAddressRepository.findByUser(user).isEmpty()) {
            address.setIsDefault(true);
        } else {
            address.setIsDefault(false);
        }
        address.setUser(user);
        return userAddressRepository.save(address);
    }

    @Transactional
    public UserAddress updateUserAddress(User user, UUID addressId, UserAddress updatedAddress) {
        UserAddress existing = userAddressRepository.findById(addressId)
                .orElseThrow(() -> new RuntimeException("Address not found"));
        if (!existing.getUser().getId().equals(user.getId())) {
            throw new RuntimeException("Unauthorized");
        }
        
        existing.setFullName(updatedAddress.getFullName());
        existing.setAddress(updatedAddress.getAddress());
        existing.setCity(updatedAddress.getCity());
        existing.setState(updatedAddress.getState());
        existing.setZipCode(updatedAddress.getZipCode());
        existing.setCountry(updatedAddress.getCountry());
        
        if (updatedAddress.getIsDefault() != null && updatedAddress.getIsDefault() && (existing.getIsDefault() == null || !existing.getIsDefault())) {
            clearDefaultAddress(user);
            existing.setIsDefault(true);
        }
        
        return userAddressRepository.save(existing);
    }

    @Transactional
    public void setDefaultUserAddress(User user, UUID addressId) {
        clearDefaultAddress(user);
        UserAddress address = userAddressRepository.findById(addressId)
                .orElseThrow(() -> new RuntimeException("Address not found"));
        if (address.getUser().getId().equals(user.getId())) {
            address.setIsDefault(true);
            userAddressRepository.save(address);
        }
    }

    private void clearDefaultAddress(User user) {
        List<UserAddress> addresses = userAddressRepository.findByUser(user);
        for (UserAddress a : addresses) {
            if (a.getIsDefault() != null && a.getIsDefault()) {
                a.setIsDefault(false);
                userAddressRepository.save(a);
            }
        }
    }

    @Transactional
    public void deleteUserAddress(User user, UUID addressId) {
        UserAddress existing = userAddressRepository.findById(addressId)
                .orElseThrow(() -> new RuntimeException("Address not found"));
        if (!existing.getUser().getId().equals(user.getId())) {
            throw new RuntimeException("Unauthorized");
        }
        userAddressRepository.delete(existing);
    }

    @Transactional
    public void submitOrder(User user, SubmitOrderRequest request) {
        UserAddress address = userAddressRepository.findByUser(user).stream()
                .filter(a -> a.getIsDefault() != null && a.getIsDefault())
                .findFirst()
                .orElseThrow(() -> new RuntimeException("No default shipping address found"));

        PaymentCard card = paymentCardRepository.findByUser(user).stream()
                .filter(c -> c.getIsDefault() != null && c.getIsDefault())
                .findFirst()
                .orElseThrow(() -> new RuntimeException("No default payment method found"));

        DeliveryMethod deliveryMethod = deliveryMethodRepository.findById(request.getDeliveryMethodId())
                .orElseThrow(() -> new RuntimeException("Delivery method not found"));

        Cart cart = cartRepository.findByUser(user).orElseThrow(() -> new RuntimeException("Cart not found"));
        List<CartItem> cartItems = cartItemRepository.findByCart(cart);

        if (cartItems.isEmpty()) {
            throw new RuntimeException("Cart is empty");
        }

        Order order = Order.builder()
                .id(UUID.randomUUID().toString())
                .user(user)
                .shippingAddress(address.getFullName() + ", " + address.getAddress() + ", " + address.getCity() + ", " + address.getState() + " " + address.getZipCode() + ", " + address.getCountry())
                .paymentMethod(card.getBrand() + " ending in " + card.getCardNumber().substring(card.getCardNumber().length() - 4))
                .deliveryMethod(deliveryMethod.getName())
                .totalAmount(request.getOrderTotal())
                .build();

        order = orderRepository.save(order);

        for (CartItem item : cartItems) {
            OrderItem orderItem = OrderItem.builder()
                    .order(order)
                    .product(item.getProduct())
                    .price(item.getProduct().getSalePrice())
                    .quantity(item.getQuantity())
                    .build();
            orderItemRepository.save(orderItem);
        }

        cartItemRepository.deleteByCart(cart);
    }

    @Transactional
    public List<com.nguyenquocbao.back_end.dto.OrderDto> getUserOrders(User user) {
        List<Order> orders = orderRepository.findByUserOrderByCreatedAtDesc(user);
        return orders.stream().map(order -> {
            List<OrderItem> items = orderItemRepository.findByOrder(order);
            int quantity = items.stream().mapToInt(OrderItem::getQuantity).sum();
            
            String statusName = "Processing";
            if (order.getOrderStatus() != null) {
                statusName = order.getOrderStatus().getStatusName();
            }
            
            java.time.format.DateTimeFormatter formatter = java.time.format.DateTimeFormatter.ofPattern("dd-MM-yyyy");
            String dateStr = order.getCreatedAt() != null ? order.getCreatedAt().format(formatter) : "";
            
            return com.nguyenquocbao.back_end.dto.OrderDto.builder()
                    .id(order.getId().length() > 8 ? order.getId().substring(0, 8) : order.getId())
                    .trackingNumber("IW" + order.getId().substring(0, Math.min(order.getId().length(), 10)).toUpperCase())
                    .quantity(quantity)
                    .totalAmount(order.getTotalAmount())
                    .date(dateStr)
                    .status(statusName)
                    .build();
        }).toList();
    }
}
