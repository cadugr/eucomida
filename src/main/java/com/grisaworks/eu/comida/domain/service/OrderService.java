package com.grisaworks.eu.comida.domain.service;

import com.grisaworks.eu.comida.domain.exception.EntityNotFoundException;
import com.grisaworks.eu.comida.domain.model.Order;
import com.grisaworks.eu.comida.domain.repository.OrderRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class OrderService {

    @Autowired
    private OrderRepository orderRepository;

    public Order save(Order order) {
        return orderRepository.save(order);
    }

    public String getOrderStatus(Long orderId) {
        return orderRepository.findById(orderId).orElseThrow(
                () -> new EntityNotFoundException(String.format("order with id %d not found.", orderId))
        ).getStatus().toString();
    }


}
