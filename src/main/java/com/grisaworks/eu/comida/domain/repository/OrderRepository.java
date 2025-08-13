package com.grisaworks.eu.comida.domain.repository;

import com.grisaworks.eu.comida.domain.model.Order;
import org.springframework.data.jpa.repository.JpaRepository;

public interface OrderRepository extends JpaRepository<Order, Long> {
}
