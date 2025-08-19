package com.grisaworks.eu.comida.api.controller;

import com.grisaworks.eu.comida.api.controller.openapi.OrderControllerOpenApi;
import com.grisaworks.eu.comida.api.dto.OrderCreateDto;
import com.grisaworks.eu.comida.api.dto.OrderResponseDto;
import com.grisaworks.eu.comida.domain.model.Order;
import com.grisaworks.eu.comida.domain.service.OrderService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

@RequiredArgsConstructor
@RestController
@RequestMapping("/orders")
public class OrderController implements OrderControllerOpenApi {

    private final OrderService orderService;

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public OrderResponseDto create(@RequestBody OrderCreateDto orderDto) {
       Order toSave = orderDto.toEntity();
       return OrderResponseDto.fromEntity(orderService.save(toSave));
    }

    @GetMapping("{orderId}/status")
    public String getOrderStatus(@PathVariable Long orderId) {
        return orderService.getOrderStatus(orderId);
    }
}
