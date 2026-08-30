package com.grisaworks.eu.comida.infrastructure.rabbitmq;

import jakarta.annotation.PostConstruct;
import lombok.RequiredArgsConstructor;
import org.springframework.amqp.rabbit.core.RabbitAdmin;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;

// Desativado no perfil "test" (ver src/test/resources/application.yml) para
// que os testes não dependam de um broker RabbitMQ real.
@Profile("!test")
@Configuration
@RequiredArgsConstructor
public class RabbitMQInitializer {

    private final RabbitAdmin rabbitAdmin;

    @PostConstruct
    public void init() {
        rabbitAdmin.initialize();
    }
}
