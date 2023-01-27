/*
 Source Server Type    : PostgreSQL
 
 Source Host           : localhost:5432

 Source Schema         : netatmo_weather

 Target Server Type    : PostgreSQL


 Date: 27/01/2023 09:17:53
*/


-- ----------------------------
-- Sequence structure for weather_time_utc_seq
-- ----------------------------
DROP SEQUENCE IF EXISTS "netatmo_weather"."weather_time_utc_seq";
CREATE SEQUENCE "netatmo_weather"."weather_time_utc_seq" 
INCREMENT 1
MINVALUE  1
MAXVALUE 2147483647
START 1
CACHE 1;

-- ----------------------------
-- Table structure for anemometer
-- ----------------------------
DROP TABLE IF EXISTS "netatmo_weather"."anemometer";
CREATE TABLE "netatmo_weather"."anemometer" (
  "time_utc" int4 NOT NULL DEFAULT nextval('"netatmo_weather".weather_time_utc_seq'::regclass),
  "windstrength" int2,
  "windangle" int2,
  "guststrength" int2,
  "gustangle" int2,
  "max_wind_str" int2,
  "max_wind_angle" int2,
  "date_max_wind_str" int4,
  "timestamp" timestamp(6) DEFAULT now()
)
;

-- ----------------------------
-- Table structure for indoor
-- ----------------------------
DROP TABLE IF EXISTS "netatmo_weather"."indoor";
CREATE TABLE "netatmo_weather"."indoor" (
  "time_utc" int4 NOT NULL,
  "temperature" float4,
  "co2" int4,
  "humidity" int2,
  "noise" int2,
  "pressure" float4,
  "absolutepressure" float4,
  "min_temp" float4,
  "max_temp" float4,
  "date_max_temp" int4,
  "date_min_temp" int4,
  "temp_trend" varchar(20) COLLATE "pg_catalog"."default",
  "pressure_trend" varchar(20) COLLATE "pg_catalog"."default",
  "timestamp" timestamp(6) DEFAULT now()
)
;

-- ----------------------------
-- Table structure for outdoor
-- ----------------------------
DROP TABLE IF EXISTS "netatmo_weather"."outdoor";
CREATE TABLE "netatmo_weather"."outdoor" (
  "time_utc" int4 NOT NULL DEFAULT nextval('"netatmo_weather".weather_time_utc_seq'::regclass),
  "temperature" float4,
  "humidity" int2,
  "min_temp" float4,
  "max_temp" float4,
  "date_max_temp" int4,
  "date_min_temp" int4,
  "temp_trend" varchar(20) COLLATE "pg_catalog"."default",
  "timestamp" timestamp(6) DEFAULT now()
)
;

-- ----------------------------
-- Table structure for rain
-- ----------------------------
DROP TABLE IF EXISTS "netatmo_weather"."rain";
CREATE TABLE "netatmo_weather"."rain" (
  "time_utc" int4 NOT NULL DEFAULT nextval('"netatmo_weather".weather_time_utc_seq'::regclass),
  "rain" float4,
  "sum_rain_1" float4,
  "sum_rain_24" float4,
  "timestamp" timestamp(6) DEFAULT now()
)
;

-- ----------------------------
-- View structure for vw_indoor
-- ----------------------------
DROP VIEW IF EXISTS "netatmo_weather"."vw_indoor";
CREATE VIEW "netatmo_weather"."vw_indoor" AS  SELECT to_timestamp(indoor.time_utc::double precision)::timestamp without time zone AS down_time,
    indoor.temperature,
    indoor.co2,
    indoor.humidity,
    indoor.noise,
    indoor.pressure,
    indoor.absolutepressure,
    indoor.min_temp,
    indoor.max_temp,
    to_timestamp(indoor.date_max_temp::double precision)::timestamp without time zone AS date_max_temp,
    to_timestamp(indoor.date_min_temp::double precision)::timestamp without time zone AS date_min_temp,
    indoor.temp_trend,
    indoor.pressure_trend,
    indoor."timestamp" AS down_time_tmst
   FROM netatmo_weather.indoor
  ORDER BY indoor.time_utc DESC;

-- ----------------------------
-- View structure for vw_rain
-- ----------------------------
DROP VIEW IF EXISTS "netatmo_weather"."vw_rain";
CREATE VIEW "netatmo_weather"."vw_rain" AS  SELECT to_timestamp(rain.time_utc::double precision)::timestamp without time zone AS down_time,
    rain.rain,
    rain.sum_rain_1,
    rain.sum_rain_24
   FROM netatmo_weather.rain
  ORDER BY rain.time_utc DESC;



-- ----------------------------
-- View structure for vw_weather
-- ----------------------------
DROP VIEW IF EXISTS "netatmo_weather"."vw_weather";
CREATE VIEW "netatmo_weather"."vw_weather" AS  SELECT to_timestamp(outdoor.time_utc::double precision)::timestamp without time zone AS down_time,
    outdoor.temperature AS temperature,
    outdoor.humidity AS humidity,
    outdoor.min_temp,
    outdoor.max_temp,
    to_timestamp(outdoor.date_max_temp::double precision)::timestamp without time zone AS date_max_temp,
    to_timestamp(outdoor.date_min_temp::double precision)::timestamp without time zone AS date_min_temp,
    outdoor."timestamp" AS down_time_tmst
   FROM netatmo_weather.outdoor
  ORDER BY outdoor.time_utc DESC;

-- ----------------------------
-- Alter sequences owned by
-- ----------------------------
SELECT setval('"netatmo_weather"."weather_time_utc_seq"', 1, false);

-- ----------------------------
-- Primary Key structure for table anemometer
-- ----------------------------
ALTER TABLE "netatmo_weather"."anemometer" ADD CONSTRAINT "anemometer_pkey" PRIMARY KEY ("time_utc");

-- ----------------------------
-- Primary Key structure for table indoor
-- ----------------------------
ALTER TABLE "netatmo_weather"."indoor" ADD CONSTRAINT "indoor_pkey" PRIMARY KEY ("time_utc");

-- ----------------------------
-- Indexes structure for table outdoor
-- ----------------------------
CREATE UNIQUE INDEX "idx_weather_tm_utc_copy1" ON "netatmo_weather"."outdoor" USING btree (
  "time_utc" "pg_catalog"."int4_ops" ASC NULLS LAST
);

-- ----------------------------
-- Primary Key structure for table outdoor
-- ----------------------------
ALTER TABLE "netatmo_weather"."outdoor" ADD CONSTRAINT "weather_copy1_pkey" PRIMARY KEY ("time_utc");

-- ----------------------------
-- Primary Key structure for table rain
-- ----------------------------
ALTER TABLE "netatmo_weather"."rain" ADD CONSTRAINT "rain_pkey" PRIMARY KEY ("time_utc");
