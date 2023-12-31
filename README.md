# Проектная работа по модулю “DWH”

## fw_dwh-27_script.sql

SQL-cкрипт выполнняется в БД, к которой осуществляется подключение в рамках ETL-процедур.
При выполнении скрипта: 
* Производится последовательное удаление (если существуют) и создание следующих сущностей:
  * Table:
    *  fact_flights - таблица фактов по совершенным перелётам;
    *  reject_fact_flights - таблица отбраковки для некачественных строк, загружаемых в fact_flights;
    *  dim_calendar - справочник дат с 01-01-2016 по 01-01-2030;
    *  dim_passengers - справочник пассажиров;
    *  reject_dim_passengers - таблица отбраковки для некачественных строк, загружаемых в dim_passengers;
    *  dim_aircrafts - справочник самолетов;
    *  reject_dim_aircrafts - таблица отбраковки для некачественных строк, загружаемых в dim_aircrafts;
    *  dim_airports - справочник аэропортов;
    *  reject_dim_airports - таблица отбраковки для некачественных строк, загружаемых в dim_airports;
    *  dim_tariff - справочник тарифов (классов обслуживания);
    *  reject_dim_tariff - таблица отбраковки для некачественных строк, загружаемых в dim_tariff;
  *  Schema:
     *  dwh - схема для таблицы фактов и справочников.

## fw_dwh-27_1_dim_passengers.ktr

ETL-процедура для наполнения справочника пассажиров.
* Table tickets - выгрузка данных из исходной таблицы tickets;
* phone and email - преобразование JSON в отдельные столбцы phone и email:
* Select values - приведение исходных данных к виду, соответствующему справочнику;
* Проверка данных на качество. Строки, не прошедшие проверку, загружаются в таблицу отбраковки reject_dim_passengers:
  * Проверка на null - проверка на отсутствие пустых значений, полноту данных;
  * Проверка phone - проверка на валидность, в частности, значения в phone должны начинаться с + и иметь длину 12 символов;
  * Проверка passenger_id - проверка на уникальность значений в passenger_id;
* Table dim_passengers - загрузка проверенных исходных данных в таблицу dim_passengers.

## fw_dwh-27_2_dim_aircrafts_tarif
ETL-процедура для наполнения справочников самолётов и тарифов.
* Table seats - выгрузка данных из исходной таблицы seats;
* Sort rows - сортировка сначала по aircraft_code, затем по fare_conditions;
* count_seats - подсчёт общего количества мест по каждому самолёту;
* seats - подсчёт количества места в разрезе класса обслуживания (тарифа) по каждому самолёту;
* Row denormaliser - преобразование и переименование строк Economy, Comfort и Business в столбцы economy_seats, comfort_seats и business_seats;
* service_class - приведение исходных данных к виду, соответствующему справочнику;
* Проверка данных на качество. Строки, не прошедшие проверку, загружаются в таблицу отбраковки reject_dim_tariff:
  * Проверка на null 2 - проверка на отсутствие пустых значений, полноту данных;
  * Проверка service_class - проверка на уникальность значений в service_class без учёта регистра;
* Table dim_tariff - загрузка проверенных исходных данных в таблицу dim_tariff;
* Table aircrafts - выгрузка данных из исходной таблицы aircrafts;
* Stream lookup - обогащение исходных данных количеством мест по каждому самолёту;
* Stream lookup 2 - обогащение данных количеством мест в разрезе класса обслуживания (тарифа) по каждому самолёту;
* Проверка данных на качество. Строки, не прошедшие проверку, загружаются в таблицу отбраковки reject_dim_aircrafts:
  * Проверка на null - проверка на отсутствие пустых значений, полноту данных;
  * Проверка range - проверка на достоверность, в частности, значения в range должны быть > 0;
  * Проверка aircraft_code - проверка на уникальность значений в aircraft_code без учёта регистра;
* Table dim_aircrafts - загрузка проверенных исходных данных в таблицу dim_aircrafts.

## fw_dwh-27_3_dim_airport.ktr
ETL-процедура для наполнения справочника аэропортов.
* Table airports - выгрузка данных из исходной таблицы airports;
* Select values - приведение исходных данных к виду, соответствующему справочнику;
* Проверка данных на качество. Строки, не прошедшие проверку, загружаются в таблицу отбраковки reject_dim_airports:
  * Проверка на null - проверка на отсутствие пустых значений, полноту данных;
  * Проверка longitude и latitude - проверка на валидность, в частности, значения в longitude и latitude должны быть в типе данных Number;
  * Проверка airport_code - проверка на валидность, в частности, значения в airport_code должны иметь длину 3 символа;
  * Проверка airport_code 2 - проверка на уникальность значений в airport_code без учёта регистра;
* Table dim_airports - загрузка проверенных исходных данных в таблицу dim_airports.

## fw_dwh-27_4_fact_flights
ETL-процедура для наполнения таблицы фактов по совершённым перелётам.
* Table ticket_flights - выгрузка данных из исходной таблицы ticket_flights;
* Table tickets - выгрузка данных из исходной таблицы tickets;
* Stream lookup - обогащение данных таблицы ticket_flights данными таблицы tickets;
* Table flights - выгрузка данных из исходной таблицы flights;
* Stream lookup 2 - обогащение данными таблицы flights;
* Arrived - выборка всех перелётов в статусе Arrived;
* Проверка данных на качество. Строки, не прошедшие проверку, загружаются в таблицу отбраковки reject_fact_flights:
  * Проверка на null - проверка на отсутствие пустых значений, полноту данных;
  * Проверка actual_departure - проверка на достоверность, значения в actual_departure должны быть >= scheduled_departure;
  * Проверка airport - проверка на достоверность, значения в departure_airport и arrival_airport не должны быть равны;
  * Проверка amount - проверка на валидность, значения в amount должны быть в типе данных Number;
* Delay - высчитывание разницы в секундах между actual_departure и scheduled_departure, и actual_arrival и scheduled_arrival;
* Select values - выбор столбцов необходимых для дальнейшего формирования таблицы;
* Table dim_passengers - выгрузка id и passenger_id из справочника dim_passengers;
* Stream lookup 3 - обогащение данных столбцом passenger_key (id);
* Table dim_aircrafts - выгрузка id и aircraft_code из справочника dim_aircrafts;
* Stream lookup 4 - обогащение данных столбцом aircraft_key (id);
* Table dim_airports - выгрузка id и airport_code из справочника dim_airports;
* Stream lookup 5 - обогащение данных столбцом departure_airport_key (id);
* Stream lookup 6 - обогащение данных столбцом arrival_airport_key (id);
* Table dim_tariff - выгрузка id и service_class из справочника dim_tariff;
* Stream lookup 7 - обогащение данных столбцом service_class_key (id);
* Select values 2 - приведение данных к виду, соответствующему таблице фактов;
* Table fact_flights - загрузка подготовленных данных в таблицу fact_flights.
