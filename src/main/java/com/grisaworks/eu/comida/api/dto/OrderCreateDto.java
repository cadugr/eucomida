package com.grisaworks.eu.comida.api.dto;

import com.grisaworks.eu.comida.domain.model.Order;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.PositiveOrZero;
import lombok.Data;

import java.math.BigDecimal;

@Data
public class OrderCreateDto {

    @NotNull
    @DecimalMin(value = "0.01")
    private BigDecimal subtotal;

    @NotNull
    @PositiveOrZero
    private BigDecimal freightRate;

    @NotNull
    @DecimalMin(value = "0.01")
    private BigDecimal totalValue;

    /**
     * Converte este DTO em uma entidade Order.
     */
    public Order toEntity() {
        return Order.builder()
                .subtotal(this.subtotal)
                .freightRate(this.freightRate)
                .totalValue(this.totalValue)
                // status já vem como CREATED no modelo
                .build();
    }

}
