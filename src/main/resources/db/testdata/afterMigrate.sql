set foreign_key_checks = 0;

DELETE FROM user_roles;
DELETE FROM users;
DELETE FROM roles_permissions;
DELETE FROM roles;
DELETE FROM permissions;

alter table user_roles auto_increment = 1;
alter table users auto_increment = 1;
alter table roles_permissions auto_increment = 1;
alter table roles auto_increment = 1;
alter table permissions auto_increment = 1;

-- Permissões
INSERT INTO permissions (name) VALUES ('CREATE_ORDER');
INSERT INTO permissions (name) VALUES ('CONSULT_ORDER_STATUS');

-- Roles
INSERT INTO roles (name) VALUES ('USER'); -- ID 1
INSERT INTO roles (name) VALUES ('DELIVERY_MAN'); -- ID 2

-- Relacionar permissões às roles
INSERT INTO roles_permissions (role_id, permission_id) VALUES (1, 1); -- USER -> CREATE_ORDER
INSERT INTO roles_permissions (role_id, permission_id) VALUES (2, 1); -- DELIVERY_MAN -> CREATE_ORDER
INSERT INTO roles_permissions (role_id, permission_id) VALUES (2, 2); -- DELIVERY_MAN -> CONSULT_ORDER_STATUS

-- Usuários com senha encriptada (BCrypt)
INSERT INTO users (username, password, enabled) VALUES ('joao', '$2a$12$Afvj6vjn0NVxbmpSw0lJW.HrRkqEk5Ced6Ba2XuNwp54VaNiEbfgu', true);
INSERT INTO users (username, password, enabled) VALUES ('maria', '$2a$12$Afvj6vjn0NVxbmpSw0lJW.HrRkqEk5Ced6Ba2XuNwp54VaNiEbfgu', true);

-- Relacionar roles aos usuários
INSERT INTO user_roles (user_id, role_id) VALUES (1, 1); -- joao é USER
INSERT INTO user_roles (user_id, role_id) VALUES (2, 2); -- maria é DELIVERY_MAN