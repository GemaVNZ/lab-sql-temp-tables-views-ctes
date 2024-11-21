-- Desafío
-- Creación de un informe de resumen del cliente
-- En este ejercicio, creará un informe de resumen de clientes que resuma la información clave sobre los clientes en la base de datos de Sakila, 
--incluido su historial de alquiler y detalles de pago. El informe se generará utilizando una combinación de vistas, CTE y tablas temporales.
-- Paso 1: Crear una vista
-- En primer lugar, cree una vista que resuma la información de alquiler de cada cliente. La vista debe incluir el ID del cliente, el nombre, 
--la dirección de correo electrónico y la cantidad total de alquileres (rental_count).

CREATE VIEW payment_summary AS
SELECT customer_id, first_name, email, COUNT(*) AS rental_count
FROM customer
JOIN rental ON customer.customer_id = rental.customer_id
GROUP BY customer_id, first_name, email;

-- Paso 2: Crear una tabla temporal
-- A continuación, cree una tabla temporal que calcule el importe total pagado por cada cliente (total_paid). La tabla temporal debe utilizar 
-- la vista de resumen de alquiler creada en el paso 1 para unirse con la tabla de pagos y calcular el importe total pagado por cada cliente.

CREATE TEMPORARY TABLE payment_summary_temp AS
SELECT customer_id, rental_count, SUM(amount) AS total_paid
FROM payment_summary
JOIN payment ON payment.customer_id = payment_summary.customer_id
GROUP BY customer_id, rental_count;

-- Paso 3: Crear un CTE y el Informe de resumen del cliente
-- Cree un CTE que una la Vista de resumen de alquiler con la Tabla temporal de resumen de pago del cliente creada en el Paso 2. 
-- El CTE debe incluir el nombre del cliente, la dirección de correo electrónico, el recuento de alquileres y el monto total pagado.
-- A continuación, utilizando el CTE, cree la consulta para generar el informe de resumen final del cliente, el cual debe incluir: 
--nombre del cliente, correo electrónico, rental_count, total_paid y Average_payment_per_rental, esta última columna es una columna 
--derivada de total_paid y rental_count

CREATE VIEW customer_summary AS
WITH rental_payment_summary AS (
    SELECT ps.customer_id, ps.first_name, ps.email, ps.rental_count, 
    SUM(p.amount) AS total_paid
    FROM payment_summary ps
    JOIN payment p ON ps.customer_id = p.customer_id
    GROUP BY ps.customer_id, ps.first_name, ps.email, ps.rental_count
)
SELECT customer_id, first_name, email, rental_count, total_paid, 
       ROUND(total_paid / rental_count, 2) AS average_payment_per_rental
FROM rental_payment_summary;