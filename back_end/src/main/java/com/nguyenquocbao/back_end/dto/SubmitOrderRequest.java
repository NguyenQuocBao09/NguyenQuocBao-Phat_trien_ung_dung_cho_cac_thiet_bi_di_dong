package com.nguyenquocbao.back_end.dto;

import lombok.Data;
import java.util.UUID;

@Data
public class SubmitOrderRequest {
    private UUID deliveryMethodId;
    private Double orderTotal;
}
