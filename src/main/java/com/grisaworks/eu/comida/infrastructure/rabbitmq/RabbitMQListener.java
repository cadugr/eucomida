package com.grisaworks.eu.comida.infrastructure.rabbitmq;

import com.grisaworks.eu.comida.domain.model.Order;
import lombok.extern.slf4j.Slf4j;
import org.springframework.amqp.rabbit.annotation.RabbitListener;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.stereotype.Component;

import static com.grisaworks.eu.comida.infrastructure.rabbitmq.RabbitMQConfig.QUEUE;

@Slf4j
@Component
public class RabbitMQListener {

    @RabbitListener(queues = QUEUE)
    public void handleMessage(@Payload Order order) {
        log.info("Order with id {} and value of {} has been processed.",
                order.getId(), order.getTotalValue());
    }
}
