package com.grisaworks.eu.comida.api.controller.openapi;

import com.grisaworks.eu.comida.domain.model.Order;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;

@Tag(name = "Orders")
public interface OrderControllerOpenApi {

    @Operation(summary = "Create a new order.")
    Order create(@RequestBody Order order);

    @Operation(summary = "Get a status from an Order.")
    String getOrderStatus(@PathVariable Long orderId);
}
