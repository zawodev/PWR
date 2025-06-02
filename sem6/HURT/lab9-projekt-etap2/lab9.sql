SELECT
    i.order_item_id         AS fact_id,
    i.order_id,
    t.time_key,
    t.customer_id,
    i.seller_id,
    i.product_id,

    p.payment_id            AS payment_id,

    p.payment_sequential,
    p.payment_installments,
    p.payment_value,

    r.review_id,
    i.price + i.freight_value AS total_revenue,
    1                        AS total_items,
    r.review_score           AS average_review_score,

    DATEDIFF(
        DAY,
            t.order_purchase_timestamp,
            t.order_delivered_customer_date
    )                        AS average_delivery_time

FROM Stage.OrderItems AS i

         JOIN Stage.Orders_Time AS t
              ON i.order_id = t.order_id

         JOIN Stage.Customers_Clean AS c
              ON t.customer_id = c.customer_id

         JOIN Stage.Payments AS p
              ON i.order_id = p.order_id

         LEFT JOIN Stage.Reviews AS r
                   ON i.order_id = r.order_id;










































SELECT DISTINCT(order_id) FROM Stepaniuk.FactOrders;

TRUNCATE TABLE Stepaniuk.FactOrders;

SELECT * FROM Stepaniuk.FactOrders
ORDER BY 3, 2;

SELECT * FROM Stage.OrderItems
ORDER BY 1, 2;


SELECT COUNT(DISTINCT CONCAT(order_id, '-')) AS liczba_unikalnych
FROM Stage.OrderItems;


SELECT
    order_id,
    fact_id,
    COUNT(*) AS wystapienia
FROM Stepaniuk.FactOrders
GROUP BY order_id, fact_id
HAVING COUNT(*) > 1
ORDER BY order_id, fact_id;








INSERT INTO Stepaniuk.FactOrders (
    order_item_id, order_id, time_key, customer_id, seller_id,
    product_id, payment_type_key, payment_sequential,
    payment_installments, payment_value, review_key,
    total_revenue, total_items, average_review_score, average_delivery_time
)
SELECT DISTINCT
    i.order_item_id,
    i.order_id,
    t.time_key,
    t.customer_id,
    i.seller_id,
    i.product_id,
    pay.payment_type_key,
    p.payment_sequential,
    p.payment_installments,
    p.payment_value,
    rd.review_key,
    i.price + i.freight_value,
    1,
    rd.review_score,
    DATEDIFF(
        DAY,
            t.order_purchase_timestamp,
            t.order_delivered_customer_date
    )
FROM Stage.OrderItems AS i
         JOIN Stage.OrdersClean AS t
              ON i.order_id = t.order_id
         JOIN (
    SELECT order_id, payment_type, payment_sequential, payment_installments, payment_value
    FROM Stage.Payments
) AS p
              ON i.order_id = p.order_id
         JOIN Stepaniuk.PaymentDim AS pay
              ON p.payment_type = pay.payment_type
         LEFT JOIN Stage.Reviews AS r
                   ON i.order_id = r.order_id
         LEFT JOIN Stepaniuk.ReviewDim AS rd
                   ON rd.review_id = r.review_id
WHERE NOT EXISTS (
    SELECT 1
    FROM Stepaniuk.FactOrders F
    WHERE F.order_id = i.order_id
      AND F.order_item_id = i.order_item_id
);