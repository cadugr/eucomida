package com.grisaworks.eu.comida.api.controller;

import com.grisaworks.eu.comida.api.controller.openapi.OrderControllerOpenApi;
import com.grisaworks.eu.comida.api.dto.OrderCreateDto;
import com.grisaworks.eu.comida.api.dto.OrderResponseDto;
import com.grisaworks.eu.comida.domain.model.Order;
import com.grisaworks.eu.comida.domain.service.OrderService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.hateoas.EntityModel;
import org.springframework.hateoas.server.mvc.WebMvcLinkBuilder;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RequiredArgsConstructor
@RestController
@RequestMapping("/orders")
public class OrderController implements OrderControllerOpenApi {

    private final OrderService orderService;

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public EntityModel<OrderResponseDto> create(@Valid @RequestBody OrderCreateDto orderDto) {
       Order toSave = orderDto.toEntity();
       OrderResponseDto response = OrderResponseDto.fromEntity(orderService.save(toSave));

        EntityModel<OrderResponseDto> orderResponseModel = EntityModel.of(response);
        orderResponseModel.add(
                WebMvcLinkBuilder.linkTo(
                        WebMvcLinkBuilder.methodOn(OrderController.class)
                                .getOrderStatus(response.getId())
                ).withRel("order-status")
        );
        return orderResponseModel;
    }

    @GetMapping("{orderId}/status")
    public ResponseEntity<String> getOrderStatus(@PathVariable Long orderId) {
        return ResponseEntity.ok(orderService.getOrderStatus(orderId));
    }
}
