-- Desafío
-- Creación de un informe de resumen del cliente
-- En este ejercicio, creará un informe de resumen de clientes que resuma la información clave sobre los clientes en la base de datos de Sakila, 
--incluido su historial de alquiler y detalles de pago. El informe se generará utilizando una combinación de vistas, CTE y tablas temporales.
-- Paso 1: Crear una vista
-- En primer lugar, cree una vista que resuma la información de alquiler de cada cliente. La vista debe incluir el ID del cliente, el nombre, 
--la dirección de correo electrónico y la cantidad total de alquileres (rental_count).

CREATE VIEW customer_rental_summary AS
SELECT 
        customer_id, 
        CONCAT (c.first_name, ' ', c.last_name) AS customer_name,
        email, 
        COUNT(*) AS rental_count
FROM customer AS c
JOIN rental AS r ON c.customer_id = r.customer_id
GROUP BY c.customer_id 

-- Paso 2: Crear una tabla temporal
-- A continuación, cree una tabla temporal que calcule el importe total pagado por cada cliente (total_paid). La tabla temporal debe utilizar 
-- la vista de resumen de alquiler creada en el paso 1 para unirse con la tabla de pagos y calcular el importe total pagado por cada cliente.

CREATE TEMPORARY TABLE customer_payment_summary_temp AS (
SELECT 
        crs.customer_id,  
        SUM(amount) AS total_paid
FROM customer_rental_summary AS crs
JOIN rental AS r ON crs.customer_id = r.customer_id
JOIN payment AS p ON r.rental_id = p.rental_id
GROUP BY crs.customer_id
);


-- Paso 3: Crear un CTE y el Informe de resumen del cliente
-- Cree un CTE que una la Vista de resumen de alquiler con la Tabla temporal de resumen de pago del cliente creada en el Paso 2. 
-- El CTE debe incluir el nombre del cliente, la dirección de correo electrónico, el recuento de alquileres y el monto total pagado.
-- A continuación, utilizando el CTE, cree la consulta para generar el informe de resumen final del cliente, el cual debe incluir: 
--nombre del cliente, correo electrónico, rental_count, total_paid y Average_payment_per_rental, esta última columna es una columna 
--derivada de total_paid y rental_count

CREATE VIEW customer_summary AS
WITH customer_sumary_report AS (
    SELECT 
            crs.customer_name,
            crs.email,
            crs.rental_count,
            cps.total_paid,
FROM customer_rental_summary AS crs
JOIN customer_payment_summary AS cps ON crs.customer_id = cps.customer_id
)
SELECT 
        customer_name,
        email,
        rental_count,
        total_paid,
        total_paid / rental_count AS average_payment_per_rental
FROM customer_sumary_report; 