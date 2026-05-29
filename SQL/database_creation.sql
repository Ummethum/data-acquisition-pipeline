-- Create the database
CREATE DATABASE gans;

-- Use the database
USE gans;

-- Create the 'cities' table
CREATE TABLE cities (
    city_id INT AUTO_INCREMENT, -- Automatically generated ID for each city
    city VARCHAR(255) NOT NULL UNIQUE, -- Name of the city
    country VARCHAR(255) NOT NULL, -- Name of the country
    latitude DECIMAL(8,5) NOT NULL,
    longitude DECIMAL(8,5) NOT NULL,
    area DECIMAL(7,2) NOT NULL,
    PRIMARY KEY (city_id) -- Primary key to uniquely identify each city
);

-- create the "city_populations" table

CREATE TABLE city_populations (
    city_id INT,
    `population` INT NOT NULL,
    timestamp_population DATE NOT NULL, -- timestamp year
    FOREIGN KEY (city_id) REFERENCES cities(city_id), -- foreign key to connect each population to its city
    UNIQUE (city_id, timestamp_population) -- prevents the same timestamp being uploaded again
);

-- create the "city_weather_forecast" table

CREATE TABLE city_weather_forecast (
    id INT AUTO_INCREMENT,
    city_id INT,
    timestamp_interval DATETIME,  -- timestamp of 3 h interval
    temperature DECIMAL(10,2),
    weather_keyword VARCHAR(255),
    rain_probability DECIMAL(10,2),
    rain_volume_mm DECIMAL(10,2),
    snow_volume_mm DECIMAL(10,2),
    wind_speed_m_s DECIMAL(10,2),
    data_retrieval_time DATETIME,
    PRIMARY KEY (id), -- Primary key to uniquely identify timestamp
    FOREIGN KEY (city_id) REFERENCES cities(city_id) -- foreign key to connect each population to its city
);