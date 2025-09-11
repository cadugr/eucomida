package com.grisaworks.eu.comida.domain.repository;

import com.grisaworks.eu.comida.domain.model.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByUsername(String username);
}
