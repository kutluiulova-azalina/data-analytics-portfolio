--Ознакомление
SELECT *
FROM public.parcing_table
LIMIT 10;

--Определите диапазон заработных плат в общем, а 
--именно средние значения, минимумы и максимумы нижних и верхних порогов зарплаты.

SELECT ROUND(AVG(salary_from),2) AS salary_from_avg, ROUND(AVG(salary_to),2) AS salary_to_avg, 
	MIN(salary_from) AS salary_from_min, MIN(salary_to) AS salary_to_avg, 
	MAX(salary_from) AS salary_from_max, MAX(salary_to) AS salary_to_max
FROM public.parcing_table; 

-- КОММЕНТАРИЙ: Основной рыночный диапазон для 
-- большинства вакансий находится в интервале от 50 000 до 200 000 ₽, 
-- а средняя предлагаемая зарплата оценивается на уровне ~131 700 ₽. Наблюдаются выбросы - 
-- высокие зарплаты топ-менеджмента, а также 50 рублей в качестве минимальной, вероятно, ошибка 
-- в объявлении.



--Выявите регионы и компании, в которых сосредоточено 
--наибольшее количество вакансий.

SELECT area, COUNT(*) AS vacancies_count_by_area_employer
FROM public.parcing_table
GROUP BY area
ORDER BY vacancies_count_by_area_employer DESC
LIMIT 10;

SELECT employer, COUNT(*) AS vacancies_count_by_area_employer
FROM public.parcing_table
GROUP BY employer
ORDER BY vacancies_count_by_area_employer DESC
LIMIT 10;

--Основная масса вакансий сосредоточена в трёх регионах-лидерах. Безусловным центром притяжения 
-- является Москва, на которую приходится 1 247 вакансий, что значительно превышает показатели 
-- других регионов. Второе место занимает Санкт-Петербург с 181 вакансией, а замыкает тройку лидеров 
-- Екатеринбург — 51 вакансия. Такое распределение ожидаемо, поскольку в крупнейших городах сосредоточено 
-- большинство IT-компаний, финансовых учреждений и крупных работодателей.

-- Среди компаний наибольшее количество вакансий предлагает СБЕР — 243 предложения, что подтверждает его
-- статус одного из крупнейших работодателей в сфере IT и аналитики. Далее следуют WILDBERRIES (43 вакансии), 
-- Ozon (34), Банк ВТБ (ПАО) (28) и Т1 (26). Интересно, что в топе представлены как государственные 
-- корпорации (СБЕР, ВТБ), так и крупные частные компании из сферы 
-- e-commerce и технологий (Wildberries, Ozon, Т1).

-- Таким образом, рынок вакансий сильно централизован: более 80 % всех предложений 
-- приходится на Москву, а основными драйверами спроса выступают крупные финансовые и технологические компании.


--Проанализируйте, какие преобладают типы занятости, 
-- а также графики работы.

SELECT employment, COUNT(employer) AS vacancies_count_by_employment
FROM public.parcing_table
GROUP BY employment
ORDER BY vacancies_count_by_employment DESC
LIMIT 4;

SELECT schedule, COUNT(id) AS vacancies_count_by_schedule
FROM public.parcing_table
GROUP BY schedule 
ORDER BY vacancies_count_by_schedule DESC
LIMIT 4;

-- подавляющее большинство вакансий предлагает полную занятость — 1 764 предложения, 
-- что составляет около 98 % от общего числа. На этом фоне остальные форматы занятости представлены 
-- незначительно. Рынок ориентирован преимущественно на специалистов, готовых работать 
-- на постоянной основе в штате компании. Что касается графиков работы, здесь также 
-- наблюдается выраженное доминирование одного формата. Полный день указан в 1 441 вакансии, 
-- что составляет около 80 % от всех предложений. 

--Изучите распределение грейдов (Junior, Middle, Senior) среди аналитиков данных
-- и системных аналитиков.
SELECT experience, COUNT(*) AS vacancies_count_by_grade
FROM public.parcing_table
GROUP BY experience
ORDER BY vacancies_count_by_grade DESC;


SELECT COUNT(*) AS vacancies_count_by_data_sys
FROM public.parcing_table
WHERE name LIKE '%Дата аналитик%' 
OR name LIKE '%дата аналитик%' 
OR name LIKE '%Аналитик данных%'
OR name LIKE '%аналитик данных%'
OR name LIKE '%Data analyst%'
OR name LIKE '%data analyst%'
OR name LIKE '%Дата-аналитик%'
OR name LIKE'%дата-аналитик%'
OR name LIKE '%Системный аналитик%'
OR name LIKE '%cистемный аналитик%'
OR name LIKE '%System analyst%'
OR name LIKE '%system analyst%';

SELECT experience, COUNT(*) AS vacancies_count_sys_data, 
	ROUND(COUNT(*) * 100 / 1448, 2) AS percent_vacancies
FROM public.parcing_table
GROUP BY experience 
ORDER BY vacancies_count_sys_data DESC;

-- что основная доля предложений приходится на категорию Junior+ (1–3 года опыта) 
-- — 1 091 вакансия, что составляет 75 % от общего числа. Это свидетельствует о высоком спросе 
-- на специалистов начального уровня, уже имеющих небольшой практический опыт, но ещё не достигших 
-- среднего уровня. Большинство работодателей ориентированы на специалистов начального и среднего уровня,
-- что создаёт возможности для карьерного старта, но ограничивает выбор для опытных кандидатов. 
-- Вероятно, рынок сеньоров перенасыщен или же основной канал подбора не призодится на сайты с вакансиями.

--Выявите основных работодателей, предлагаемые зарплаты 
--и условия труда для аналитиков.

SELECT employer, AVG(salary_from) AS salary_from_avg, 
AVG(salary_to) AS salary_to_avg, COUNT(*) AS vacancies_by_conditions, employment, schedule
FROM public.parcing_table

WHERE name LIKE '%Дата аналитик%' 
OR name LIKE '%дата аналитик%' 
OR name LIKE '%Аналитик данных%'
OR name LIKE '%аналитик данных%'
OR name LIKE '%Data analyst%'
OR name LIKE '%data analyst%'
OR name LIKE '%Дата-аналитик%'
OR name LIKE'%дата-аналитик%'
OR name LIKE '%Системный аналитик%'
OR name LIKE '%cистемный аналитик%'
OR name LIKE '%System analyst%'
OR name LIKE '%system analyst%'

GROUP BY employer, employment, schedule
ORDER BY vacancies_by_conditions DESC;

--Среди ключевых работодателей для аналитиков лидирует СБЕР (136 вакансий) со средней 
-- зарплатой ~110 000 ₽. Наиболее высокие зарплаты предлагают ANCOR (до 300 000 ₽), INGURU.RU (200 000–300 000 ₽)
-- и Займиго МФК (~197 000 ₽). Основной формат занятости — полная занятость и полный день, однако з
-- начительная доля вакансий предусматривает удалённую работу (Ростелеком, Ozon, Wildberries, X5 Tech и др.). 
-- Рынок консолидирован вокруг крупных корпораций, а наиболее высокооплачиваемые предложения исходят 
-- от узкоспециализированных и консалтинговых компаний.

--Определите наиболее востребованные навыки (как жёсткие, так и мягкие) 
--для различных грейдов и позиций.

SELECT experience, key_skills_1,COUNT(*) AS ment_freq
FROM public.parcing_table
GROUP BY experience, key_skills_1  
ORDER BY ment_freq DESC;

SELECT experience, key_skills_2,COUNT(*) AS ment_freq
FROM public.parcing_table
GROUP BY experience, key_skills_2  
ORDER BY ment_freq DESC;

SELECT experience, key_skills_3,COUNT(*) AS ment_freq
FROM public.parcing_table
GROUP BY experience, key_skills_3  
ORDER BY ment_freq DESC;

SELECT experience, key_skills_4,COUNT(*) AS ment_freq
FROM public.parcing_table
GROUP BY experience, key_skills_4  
ORDER BY ment_freq DESC;



SELECT experience, soft_skills_1,COUNT(*) AS ment_freq
FROM public.parcing_table
GROUP BY experience, soft_skills_1  
ORDER BY ment_freq DESC;

SELECT experience, soft_skills_2,COUNT(*) AS ment_freq
FROM public.parcing_table
GROUP BY experience, soft_skills_2  
ORDER BY ment_freq DESC;

SELECT experience, soft_skills_3,COUNT(*) AS ment_freq
FROM public.parcing_table
GROUP BY experience, soft_skills_3  
ORDER BY ment_freq DESC;

SELECT experience, soft_skills_4,COUNT(*) AS ment_freq
FROM public.parcing_table
GROUP BY experience, soft_skills_4
ORDER BY ment_freq DESC;

-- Рынок аналитиков предъявляет устойчивый спрос на SQL, Python, навыки визуализации данных, 
-- а также на коммуникативные навыки и умение работать с документацией. Набор требований 
-- ожидаемо расширяется с ростом грейда, а для кандидатов без опыта ключевым является базовое владение
-- аналитическими инструментами и готовность к обучению.










	
	

