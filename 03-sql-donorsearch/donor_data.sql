-- Определить регионы с наибольшим количеством зарегистрированных доноров.
SELECT region, COUNT(id) AS donation_count_region
FROM donorsearch.user_anon_data
WHERE region IS NOT NULL
GROUP BY region 
ORDER BY donation_count_region DESC
LIMIT 10;

донорская активность сконцентрирована в москве и санкт-петербурге. казань — третий по объёму город. остальные регионы демонстрируют средние, близкие друг к другу значения. киев — единственный иностранный город в списке.

--Изучить динамику общего количества донаций в месяц за 2022 и 2023 годы.
SELECT DATE_TRUNC('month', donation_date::timestamptz)::date AS date, COUNT(*) AS donation_count_per_month
FROM donorsearch.donation_anon
WHERE DATE_TRUNC('month', donation_date::timestamptz)::date BETWEEN '2021-01-01'::date AND '2022-12-01'::date
GROUP BY date
ORDER BY date;

За два года наблюдается устойчивый рост количества донаций. Так, динамика положительная: 2022 год показывает значительный прирост донаций по сравнению с 2021-м, с выходом на плато около 3 000 донаций в месяц во второй половине года. Пик активности — осенью и в декабре.

--Определить наиболее активных доноров в системе, учитывая только данные о зарегистрированных и подтвержденных донациях.
SELECT user_id, COUNT(id) AS donation_count_per_user
FROM donorsearch.donation_anon
WHERE confirmation IS TRUE
GROUP BY user_id 
ORDER BY COUNT(id) DESC
LIMIT 10;

Максимальное число донаций у одного донора — 361. Остальные участники топ-10 имеют от 204 до 236 донаций, что также является высоким показателем донорской активности.

--Оценить, как система бонусов влияет на зарегистрированные в системе донации.
WITH donor_activity AS (
	SELECT u.id, 
		u.confirmed_donations, 
		COALESCE(b.user_bonus_count, 0) AS bonus_count, 
		CASE 
			WHEN b.user_bonus_count > 0 THEN 'Получили бонус'
			ELSE 'Не получили бонус'
		END AS bonus_status
	FROM donorsearch.user_anon_data AS u
	LEFT JOIN donorsearch.user_anon_bonus AS b ON b.user_id = u.id)
	
SELECT bonus_status, COUNT(id), AVG(bonus_count) AS avg_bonuses, AVG(confirmed_donations) AS avg_donations
FROM donor_activity
GROUP BY bonus_status ;

Программа лояльности эффективна: доноры с бонусами сдают кровь в 26 раз чаще. Однако она охватывает лишь 7.6% донорской базы, оставляя более 250 тысяч доноров без мотивации. Расширение бонусной программы на неактивных доноров может значительно увеличить общее количество донаций.

--Исследовать вовлечение новых доноров через социальные сети. Узнать, сколько по каким каналам пришло доноров, и среднее количество донаций по каждому каналу.

SELECT CASE
	WHEN  autho_vk THEN 'VK'
	WHEN autho_ok THEN 'Одноклассники'
	WHEN autho_tg THEN 'Телеграм'
	WHEN autho_yandex THEN 'Яндекс'
	WHEN autho_google THEN 'Google'
	ELSE 'Не через соцсеть'
END AS platform, 
	COUNT(id) AS users_count, AVG(confirmed_donations)
FROM donorsearch.user_anon_data
GROUP BY platform
ORDER BY users_count;

VK привлекает наибольшее число доноров, но Яндекс показывает лучшую активность (1.73 донаций). Рекомендуется увеличить инвестиции в Яндекс и Телеграм, а также усилить работу с донорами, пришедшими не через соцсети, чтобы повысить их лояльность.

--Сравнить активность однократных доноров со средней активностью повторных доноров.

WITH donor_activity AS (
	SELECT user_id, 
	COUNT(*) AS total_donations,
	(MAX(donation_date) - MIN(donation_date)) AS activity_duration_days,
	(MAX(donation_date) - MIN(donation_date))/NULLIF(COUNT(*) - 1, 0) AS avg_days_between_donations,
	EXTRACT(YEAR FROM MIN(donation_date)) AS first_donation_year,
	EXTRACT(YEAR FROM AGE(CURRENT_DATE, MIN(donation_date))) AS years_since_first_donation,
	CASE 
		WHEN COUNT(*) = 1 THEN 'Однократные'
		WHEN COUNT(*) > 1 THEN 'Повторные'		
	END AS donor_status
	FROM donorsearch.donation_anon
	GROUP BY user_id
	HAVING COUNT(*) > 1)
	
SELECT first_donation_year, donor_status,
	CASE
		WHEN total_donations BETWEEN 2 AND 3 THEN '2-3 донации'
		WHEN total_donations BETWEEN 4 AND 5 THEN '4-5 донации'
		WHEN total_donations > 6 THEN '6+ донаций'
		WHEN total_donations = 1 THEN '1 донация'
	END AS donation_frequency_group, 
	COUNT(user_id) AS donor_count, 
	ROUND(AVG(total_donations)::numeric, 2) AS avg_donations_per_donor,
	ROUND(AVG(activity_duration_days)::NUMERIC, 2) AS avg_activity_duration_days,
	ROUND(AVG(avg_days_between_donations)::numeric, 2)  AS avg_days_between_donations,
	ROUND(AVG(years_since_first_donation)::NUMERIC, 2) AS avg_years_since_first_donation
FROM donor_activity
GROUP BY first_donation_year, donor_status, donation_frequency_group
ORDER BY first_donation_year,donor_status, donation_frequency_group;
	
Анализ по повторным донорам показывает устойчивый рост их числа, особенно с 2014 года, с пиковым значением в 2022 году, когда было зафиксировано 3414 повторных доноров. Основная масса повторных доноров (около 64%) относится к группе с 2–3 донациями, что указывает на потенциал для их дальнейшего удержания и перевода в более активные категории. Наиболее ценными являются доноры с 6 и более донациями — они сдают кровь чаще (средний интервал между донациями у них составляет около 52 дней против 125 дней у группы 2–3 донации) и остаются активными значительно дольше (в среднем 442 дня против 161 дня). Прослеживается чёткая закономерность: чем выше частота донаций, тем короче интервал между ними и тем длительнее период активности донора в системе. При этом наблюдается снижение активности у новых доноров — если у доноров 2013 года в группе 6+ было в среднем 24 донации, интервал 134 дня и активность 2360 дней, то у доноров 2022 года в той же группе — всего 10,8 донаций, интервал 52 дня и активность 442 дня. Это объясняется тем, что новые доноры ещё не успели накопить стаж, но при этом они сдают кровь чаще, чем старожилы в начале их донорского пути. Самые активные годы по сумме донаций — 2013–2015 годы, когда группа 6+ донаций давала более 14 000 донаций в год. В данных присутствуют артефакты — записи с 1970 по 2000 год, которые являются аномальными и не должны учитываться в анализе. Таким образом, повторные доноры составляют ядро донорской программы, причём основная масса сосредоточена в группе 2–3 донации, а самая ценная группа — доноры с 6 и более донациями, которые сдают чаще и остаются активными дольше. Рекомендуется фокусироваться на удержании доноров с 2–3 донациями и поощрении их перехода в более активные группы, а также на информировании новых доноров о возможности стать постоянными участниками донорского движения.	

--Сравнить данные о планируемых донациях с фактическими данными, чтобы оценить эффективность планирования.
WITH planned_donations AS (
	SELECT DISTINCT user_id, donation_date, donation_type
	FROM donorsearch.donation_plan), 
	
actual_donations AS (
	SELECT DISTINCT user_id, donation_date
	FROM donorsearch.donation_anon), 
	
planned_vs_actual AS (
	SELECT pd.user_id, 
		   pd.donation_date, 
		   pd.donation_type,
		CASE 
			WHEN ad.user_id IS NOT NULL THEN 1 ELSE 0
		END AS completed
	FROM planned_donations AS pd
	LEFT JOIN actual_donations AS ad ON (ad.user_id = pd.user_id) AND (ad.donation_date = pd.donation_date)
)

SELECT donation_type, count(*) AS total_planned_donations, 
sum(completed) AS completed_donations,
round(SUM(completed) * 100.0/count(*), 2) AS completion_rate 
FROM planned_vs_actual
GROUP BY donation_type;

Планирование донаций неэффективно: из 26 205 запланированных донаций выполнено лишь 5 382 (20.5%).

Особенно низкая эффективность у платных донаций — выполняется только 13% планов (1 из 8), что на 8.5 п.п. ниже, чем у безвозмездных (21.6%, 1 из 5).

Текущая система планирования теряет ~80% потенциальных донаций. Фокус на удержании и мотивации платных доноров может дать наибольший прирост.

	
