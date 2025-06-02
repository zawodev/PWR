-- schemat
CREATE SCHEMA IF NOT EXISTS Stepaniuk;

-- tabela pomocnicza dla miesięcy
CREATE TABLE Stepaniuk.MonthDim (
    month_key    SMALLINT    PRIMARY KEY,  -- 1–12
    month_name   VARCHAR(20) NOT NULL
);

INSERT INTO Stepaniuk.MonthDim VALUES
(1,'January'),  (2,'February'), (3,'March'),    (4,'April'),
(5,'May'),      (6,'June'),     (7,'July'),     (8,'August'),
(9,'September'),(10,'October'), (11,'November'),(12,'December');

-- tabela pomocnicza dla dni tygodnia
CREATE TABLE Stepaniuk.WeekdayDim (
    weekday_key  SMALLINT    PRIMARY KEY,  -- 1–7
    weekday_name VARCHAR(20) NOT NULL
);

INSERT INTO Stepaniuk.WeekdayDim VALUES
(1,'Monday'), (2,'Tuesday'), (3,'Wednesday'), (4,'Thursday'),
(5,'Friday'), (6,'Saturday'), (7,'Sunday');

-- wymiar czasu
CREATE TABLE Stepaniuk.TimeDim (
    time_key      INT          PRIMARY KEY,      -- YYYYMMDDHHMMSS
    full_datetime TIMESTAMP    NOT NULL,
    year_n        SMALLINT     NOT NULL,
    quarter_n     SMALLINT     NOT NULL,
    month_key     SMALLINT     NOT NULL       REFERENCES Stepaniuk.MonthDim(month_key),
    day_n         SMALLINT     NOT NULL,
    weekday_key   SMALLINT     NOT NULL       REFERENCES Stepaniuk.WeekdayDim(weekday_key),
    hour_n        SMALLINT     NOT NULL,
    minute_n      SMALLINT     NOT NULL,
    second_n      SMALLINT     NOT NULL
);

-- wymiar klienta
CREATE TABLE Stepaniuk.CustomerDim (
    customer_id     VARCHAR(50)  PRIMARY KEY,
    customer_state  CHAR(2)      NOT NULL,
    customer_city   VARCHAR(100) NOT NULL,
    city_population INT,
    city_area_km2   DECIMAL(10,2),
    city_density    DECIMAL(10,2),
    city_gdp        DECIMAL(18,2)
);

-- wymiar sprzedawcy
CREATE TABLE Stepaniuk.SellerDim (
    seller_id       VARCHAR(50)  PRIMARY KEY,
    seller_state    CHAR(2)      NOT NULL,
    seller_city     VARCHAR(100) NOT NULL,
    city_population INT,
    city_area_km2   DECIMAL(10,2),
    city_density    DECIMAL(10,2),
    city_gdp        DECIMAL(18,2)
);

-- wymiar produktu
CREATE TABLE Stepaniuk.ProductDim (
    product_id     VARCHAR(50)  PRIMARY KEY,
    category       VARCHAR(100) NOT NULL,
    sub_category   VARCHAR(100)
);

-- wymiar płatności
CREATE TABLE Stepaniuk.PaymentDim (
    payment_id     VARCHAR(50)  PRIMARY KEY,
    payment_type   VARCHAR(30)  NOT NULL,
    installments   SMALLINT     NOT NULL
);

-- wymiar opinii
CREATE TABLE Stepaniuk.ReviewDim (
    review_id       VARCHAR(50) PRIMARY KEY,
    review_score    SMALLINT    NOT NULL,
    review_comment  TEXT,
    review_date     DATE        NOT NULL
);

-- tabela faktów
CREATE TABLE Stepaniuk.FactOrders (
    order_id               VARCHAR(50)  PRIMARY KEY,
    order_time_key         INT          NOT NULL            REFERENCES Stepaniuk.TimeDim(time_key),
    customer_id            VARCHAR(50)  NOT NULL            REFERENCES Stepaniuk.CustomerDim(customer_id),
    seller_id              VARCHAR(50)  NOT NULL            REFERENCES Stepaniuk.SellerDim(seller_id),
    product_id             VARCHAR(50)  NOT NULL            REFERENCES Stepaniuk.ProductDim(product_id),
    payment_id             VARCHAR(50)  NOT NULL            REFERENCES Stepaniuk.PaymentDim(payment_id),
    review_id              VARCHAR(50)                      REFERENCES Stepaniuk.ReviewDim(review_id),
    order_count            INT          NOT NULL DEFAULT 1,
    total_revenue          DECIMAL(18,2)NOT NULL,
    total_items            INT          NOT NULL,
    average_review_score   DECIMAL(3,2),
    average_delivery_time  DECIMAL(10,2) -- dni
);
