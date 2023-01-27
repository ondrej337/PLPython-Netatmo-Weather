CREATE OR REPLACE FUNCTION "mycron"."py_netatmo"()
  RETURNS "pg_catalog"."void" AS $BODY$
import lnetatmo

try:
  # 1 : Authenticate
  authorization = lnetatmo.ClientAuth()
  # 2 : Get devices list
  weatherData = lnetatmo.WeatherStationData(authorization)
	
  # 3 : Access most fresh data directly
  ir = weatherData.lastData()['Indoor']
  ot = weatherData.lastData()['Outdoor']
  am = weatherData.lastData()['Anemometer']
  rg = weatherData.lastData()['Rain Gauge']
  # 4 : Insert to postgres database
  ir_plan = plpy.prepare("INSERT INTO netatmo_weather.indoor(time_utc,temperature,co2,humidity,noise,pressure,absolutepressure,min_temp,max_temp,date_max_temp,date_min_temp,temp_trend,pressure_trend) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13) ON CONFLICT (time_utc) DO NOTHING",["int","float","int","int","int","float","float","float","float","int","int","VARCHAR","VARCHAR"])
  plpy.execute(ir_plan, [ir['When'], ir['Temperature'], ir['CO2'], ir['Humidity'], ir['Noise'], ir['Pressure'], ir['AbsolutePressure'], ir['min_temp'], ir['max_temp'], ir['date_max_temp'], ir['date_min_temp'], ir.get('temp_trend'), ir['pressure_trend']])
	
  ot_plan = plpy.prepare("INSERT INTO netatmo_weather.outdoor(time_utc,temperature,humidity,min_temp,max_temp,date_max_temp,date_min_temp,temp_trend) VALUES ($1,$2,$3,$4,$5,$6,$7,$8) ON CONFLICT (time_utc) DO NOTHING",["int","float","int","float","float","int","int","VARCHAR"])
  plpy.execute(ot_plan, [ot['When'], ot['Temperature'], ot['Humidity'], ot['min_temp'], ot['max_temp'], ot['date_max_temp'], ot['date_min_temp'], ot.get('temp_trend')])
		
  am_plan = plpy.prepare("INSERT INTO netatmo_weather.anemometer(time_utc, windstrength, windangle, guststrength, gustangle, max_wind_str, max_wind_angle, date_max_wind_str) VALUES ($1,$2,$3,$4,$5,$6,$7,$8) ON CONFLICT (time_utc) DO NOTHING",["int","int","int","int","int","int","int","int"])
  plpy.execute(am_plan, [am['When'], am['WindStrength'], am['WindAngle'], am['GustStrength'], am['GustAngle'], am['max_wind_str'], am['max_wind_angle'], am['date_max_wind_str']])
	
  rg_plan = plpy.prepare("INSERT INTO netatmo_weather.rain(time_utc,rain,sum_rain_1,sum_rain_24) VALUES ($1,$2,$3,$4) ON CONFLICT (time_utc) DO NOTHING",["int","float","float","float"])
  plpy.execute(rg_plan, [rg['When'], rg['Rain'], rg['sum_rain_1'], rg['sum_rain_24']])
	

except Exception as ex:
  plpy.error('ERROR',ex)
	
$BODY$
  LANGUAGE plpython3u VOLATILE
  COST 100

