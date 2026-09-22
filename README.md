[README.md](https://github.com/user-attachments/files/32504743/README.md)[Uploading README.# SQL a Power BI projekt – Engeto Datová akademie

**Autor:** Liliana Chundelová

## Zadání projektu

Cílem projektu bylo analyzovat vývoj mezd, cen vybraných potravin a hrubého domácího produktu (HDP) v České republice v letech 2006–2018. Součástí projektu bylo vytvoření primární a sekundární tabulky, zodpovězení pěti výzkumných otázek pomocí SQL a následná vizualizace výsledků v Power BI.

---

# Příprava dat

## Primární tabulka

Pro vytvoření primární tabulky byla využita data z následujících tabulek:

- `czechia_payroll`
- `czechia_payroll_industry_branch`
- `czechia_price`
- `czechia_price_category`
- `economies`

### Mzdy

Z tabulky `czechia_payroll` byly použity pouze záznamy s `value_type_code = 5958`, protože představují průměrnou hrubou mzdu. Současně byl použit `calculation_code = 200`, který odpovídá přepočtenému počtu zaměstnanců a poskytuje vhodnější podklad pro porovnání mezd mezi jednotlivými odvětvími.

Pro jednotlivá odvětví a roky byla vypočtena průměrná hodnota mezd pomocí funkce `AVG()`.

### Ceny potravin

Z tabulky `czechia_price` byly pro jednotlivé roky vypočteny průměrné ceny jednotlivých kategorií potravin. Rok byl získán z atributu `date_from`.

### HDP

Z tabulky `economies` byla připojena hodnota HDP pouze pro stát **Czech Republic**.

### Spojení dat

Data byla spojena pomocí příslušných primárních a cizích klíčů mezi jednotlivými tabulkami.

Po vytvoření tabulky byla provedena kontrola:

- počtu let,
- hodnot `NULL`,
- prázdných textových řetězců.

---

## Sekundární tabulka

Sekundární tabulka byla vytvořena z tabulky `economies`.

Obsahuje údaje za evropské státy v období **2006–2018**:

- country
- GDP
- population
- GINI
- year

Před vytvořením tabulky byly nejprve vyhledány všechny unikátní názvy států a následně byly vybrány pouze evropské země.

---

# Výzkumné otázky

## 1. Rostly mzdy ve všech odvětvích, nebo v některých docházelo k poklesu?

Pro porovnání mezd mezi jednotlivými roky byla využita analytická funkce `LAG()`, která umožnila porovnat mzdu s předchozím rokem v rámci každého odvětví.

### Výsledek

V analyzovaném období skutečně docházelo v některých odvětvích k meziročnímu poklesu mezd. Nejvýrazněji se tento trend projevil v odvětví **Těžba a dobývání**, kde se pokles objevil opakovaně. V ostatních odvětvích šlo většinou pouze o jednorázové poklesy.

![alt text](Power_BI_projekt_engeto/screenshots/Růst_mezd.png)
---

## 2. Kolik bylo možné koupit litrů mléka a kilogramů chleba za průměrnou mzdu v prvním a posledním sledovaném období?

Byla porovnána průměrná mzda s průměrnou cenou:

- konzumního chleba,
- polotučného pasterovaného mléka.

Pro výpočet byla použita průměrná hodnota mezd napříč jednotlivými odvětvími.

### Výsledek

V roce **2006** bylo možné za průměrnou mzdu koupit přibližně:

- **1313 kg chleba**
- **1466 litrů mléka**

V roce **2018** bylo možné koupit přibližně:

- **1365 kg chleba**
- **1670 litrů mléka**

Kupní síla průměrné mzdy se tedy během sledovaného období zvýšila.

![alt text](Power_BI_projekt_engeto/screenshots/Kupní_síla_mléko_chléb.png)

---

## 3. Která kategorie potravin zdražovala nejpomaleji?

Pomocí funkce `LAG()` byl vypočten meziroční procentní růst cen jednotlivých potravin a následně byl spočten jejich průměrný růst.

### Výsledek

Nejpomaleji rostoucí cenu měl **cukr krystal**, který vykázal nejnižší průměrný meziroční růst cen.

![alt text](Power_BI_projekt_engeto/screenshots/Meziroční_růst_cen.png)

---

## 4. Existoval rok, kdy ceny potravin rostly výrazně rychleji než mzdy (o více než 10 %)?

Byl vypočten průměrný meziroční růst cen potravin i mezd a následně byl porovnán jejich rozdíl.

### Výsledek

V analyzovaném období nebyl nalezen žádný rok, ve kterém by růst cen potravin převýšil růst mezd o více než **10 procent**.

![alt text](image.png)

---

## 5. Má růst HDP vliv na růst mezd a cen potravin?

Byl vypočten meziroční růst HDP a následně porovnán s meziročním růstem mezd a cen potravin.

### Výsledek

Na základě provedené analýzy nelze v tomto datasetu pozorovat jednoznačnou přímou souvislost mezi růstem HDP a růstem mezd nebo cen potravin. V některých letech se ukazatele vyvíjely podobně, v jiných naopak odlišně.

![alt text](image-1.png)

---

# Použité SQL techniky

Při řešení projektu byly využity zejména následující SQL techniky:

- Common Table Expressions (`WITH`)
- `JOIN`
- `GROUP BY`
- agregační funkce (`AVG`, `ROUND`)
- analytická funkce `LAG()`
- výpočty meziročních procentních změn
- filtrování dat pomocí `WHERE`
- převody datových typů (`CAST`, `EXTRACT`)

---

# Závěr

V rámci projektu byly vytvořeny dvě výsledné tabulky, které sloužily jako podklad pro analytické dotazy. Pomocí SQL byly zodpovězeny všechny požadované výzkumné otázky zaměřené na vývoj mezd, cen potravin a HDP v České republice. Data byla následně dále transformována pomocí Power Query a výsledky analýzy byly vizualizovány v Microsoft Power BI.

Analýza ukázala, že kupní síla průměrné mzdy se během sledovaného období zvýšila, nejpomaleji zdražoval cukr krystal a neexistoval rok, kdy by růst cen potravin převýšil růst mezd o více než 10 procentních bodů. Současně nebyla prokázána jednoznačná přímá souvislost mezi růstem HDP a vývojem mezd či cen potravin.
md…]()
