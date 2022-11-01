-- CASE - Fifa 2020
-- BASE DE DADOS: 
	-- Base de dados contendo caracteristicas dos jogadores registrados no jogo FIFA20
-- OBJETIVOS:
	-- Analisar as caracteristicas dos jogadores (Idade, Overall, Posições, Altura, Peso, Salário, Nacionalidade)
	-- Analisar caracteristicas dos clubes (folhas salariais, Overall)
	-- Identificar fatores que influemciam diretamente no Overall dos jogadores
	-- Analisar paises que possuem maior quantidade de jogadores e jogadores acima da média
	-- Analisar clubes com maiores folhas salariais
	-- Analisar jogadores com maiores salários
	-- Identificar melhores jogadores por posição "Seleção Fifa"
	-- Identificar as "promessas"

-- RESUMO DOS INSIGHTS:
	-- Aproximadamente 70% dos jogadores tem idades entre 20-30 anos.
	-- Nos temos 162 nacionalidade diferentes entre todos os jogadores, mas 50% deles então concentrado em apenas 10 nacionalidades.
	-- Analisando as variáves quantitativas, um ponto que chamou muito minha atenção foi a distribuição da variável Salário, onde existem poucos com salário altos e muitos com slários "Baixos".
	-- Analisando a média, desvio padrão do Overall por faixa etária, podemos presumir que os jogadores atingem seu auge em questão de desempenho na faixa etária 25-35 anos.
	-- Analisando a média, desvio padrão e a quantidade de jogadores por país podemos presumir que o brasil tem mais jogadores com Overall acima da média.
	-- Existe uma forte correlação entre Overall e o Salário (Coef=0,6).
	-- Existe uma grande desigualdade entre os clubes, se falando de infraestrutura e contratações, assim deixando campeonatos menos competitivos.	
	-- As folhas salarias dos 10 clubes com maiores folhas salariais (1,5% do total de clubes) corresondem a Aproximadamente 20% da soma das folhas salariais de todos os clubes (698)
	-- Dentro dos TOP 10 clubes com melhores médias de Overall, estão os 3 campeões das champions 2020-2022.
	-- Dos Títulos da Champions de 2010-2019 (10 disputas), só dois foram ganhos por clubes fora desse top 10 (Maiores médias de Overall), mostrado uma forte Hegemonia desses clubes.
	-- Dentro desses 10 clubes (Top 10 Overall), 7 deles se encntram no top 10 de maiores folas salariais.
	-- O país que apresenta a melhor relação quantidade absoluta e proposrção de jogadores "bons" é o Brasil, com isso seria interessante os clubes direcionarem os olhares para o Brasil na hora de contratar seus jogadores/Promessas.
	-- Dentro dos 5 melhores jogadores (Maiores Overais), 3 deles estão entro do TOP5 maiores salários
	-- Os 10 melhores jogadores com 20 anos ou menos (Dessas 10 promessas, 5 mudaram de clube até o ano 2022).

-- Conhecimentos aplicados
-- Estatística:
       -- Análise exploratoria das variáveis qualitativas (Tabela de Frequência/Histograma)
       -- Análise exploratoria das variáveis quantitativas (Medidas Resumo (Média, Soma e Contagem))
       -- Correlação entre variáveis (Coef Pearson e Coeficiente de Determinação)
-- SQL:
       -- Selecionar variáveis que quero visualizar de uma tabela (SELECT/FROM)
       -- Comandos para exiição de medidas resumo (COUNT, SUM, AVG)
       -- Criar relação entre tabelas (JOINS)
	   -- Criar Filtros (WHERE)
       -- Sintaxe condicionais (AND, OR, NOT) e comparação (<, >, !=)
	   -- Agrupar medidas resumos por categoria (GROUP BY)
       -- Ordenar DataFrame (ORDER BY)
       -- Comandos para análise de valores únicos (DISTINCT)
       -- Comandos de manipulação de Datas (DATEDIFF) 
       -- Criar colunas condicionais (CASE-WHEN-THEN-ELSE-END)
       -- Criar variável faixa de valores para variáveis quantitativas (CASE-WHEN-THEN-ELSE-END)
       -- Conversão de tipo de variável (CAST)
       -- Unir DataFrames com as mesmas variáveis "empilhar" (UNION)
       -- Criar tabelas dinâmicas (INTO), com finalidade de deixar o código mais "limpo"
	   -- Aplicação de SUBQUERYS


-- Corrigindo tipo da variáveis e renomeando colunas
-- E criando tabela temporária om as correções
DROP TABLE IF EXISTS #tabela_fifa_corrigida
SELECT
	sofifa_id AS 'ID_fifa',
	short_name AS 'Nome',
	nationality AS 'Nacionalidade',
	CAST([age] AS int) AS 'Idade',
	CAST([dob] AS date) AS 'Data_Nasc',
	CAST([height_cm] AS int) AS 'Altura',
	CAST([weight_kg] AS int) AS 'Peso',
	club AS 'Clube',
	CAST([overall] AS int) AS 'Overall',
	CAST([value_eur] AS int) AS 'Valor',
	CAST([wage_eur] AS int)*10 AS 'Salario',
	CAST([release_clause_eur] AS int) AS 'Recisao',
	CAST([joined] AS date) AS 'Contratado',
	team_position AS 'Posicao',
	preferred_foot AS 'Perna',
	contract_valid_until AS 'Validade_Contrato',
	team_jersey_number AS 'Num_Camisa'
INTO
	#tabela_fifa_corrigida
FROM
	Henrique.dbo.players_20



-- Criando Colunas Condicionais e Calculadas

DROP TABLE IF EXISTS #tabela_fifa_corrigida2
SELECT
	*,
	CASE WHEN Idade<16 THEN '0-15'  
		 WHEN Idade<20 THEN '16-19'
		 WHEN Idade<25 THEN '20-24'  
		 WHEN Idade<30 THEN '25-29'  
		 WHEN Idade<35 THEN '30-34'  
		 WHEN Idade<40 THEN '35-39'  
		 ELSE '40+'
	END AS 'Faixa_Etaria',
	ROUND(CAST(Peso AS float)/POWER(Altura,2)*10000,2) AS 'IMC',
	DATEDIFF(yy,Data_Nasc,Contratado) AS 'Idade_Contratado',
	Idade+CAST(Validade_Contrato AS int)-2019 AS 'Idade_Final_Contrato'
INTO
	#tabela_fifa_corrigida2
FROM
	#tabela_fifa_corrigida

-- Analise Explratória 
-- Variáveis Qualitativas

-- Quantidade de Clubes 
SELECT 
	COUNT (DISTINCT Clube) AS 'Quantidade de CLubes'
FROM
	#tabela_fifa_corrigida2
-- 698 Clubes


-- Quantidade de Jogadores
SELECT 
	COUNT (1) AS 'Quantidade de Jogadores'
FROM
	#tabela_fifa_corrigida2
-- 18.278 Jogadores


-- Quantidade de Jogadores por Faixa Etária
SELECT
	Faixa_Etaria,
	COUNT(ID_fifa) AS 'Jogadores_ABS',
	ROUND(CAST(COUNT(ID_fifa) AS FLOAT)/(SELECT COUNT(ID_fifa) FROM #tabela_fifa_corrigida2),2) AS 'Jogadores_REL'
FROM
	#tabela_fifa_corrigida2
GROUP BY
	Faixa_Etaria
ORDER BY
	Faixa_Etaria ASC
-- Aproximadamente 70% dos jogadores tem idades entre 20-30 anos


-- Quantidade de Jogadores por Nacionalidade
SELECT COUNT(DISTINCT Nacionalidade) FROM #tabela_fifa_corrigida2

SELECT
	Nacionalidade,
	COUNT(ID_fifa) AS 'Jogadores_ABS',
	ROUND(CAST(COUNT(ID_fifa) AS FLOAT)/(SELECT COUNT(ID_fifa) FROM #tabela_fifa_corrigida2),2) AS 'Jogadores_REL'
FROM
	#tabela_fifa_corrigida2
GROUP BY
	Nacionalidade
ORDER BY
	Jogadores_ABS DESC
-- Nos temos 162 nacionalidade diferentes entre todos os jogadores, mas 50% deles então concentrado em apenas 10 nacionalidades


-- Variáveis Quantitativas
SELECT
	'Idade' AS 'Variável',
	AVG(Idade) AS 'Média',
	MIN(Idade) AS 'Mínimo',
	MAX(Idade) AS 'Máximo',
	ROUND(STDEV(Idade),2) AS 'DesvPad'
FROM
	#tabela_fifa_corrigida2

UNION

SELECT
	'Overall' AS 'Variável',
	AVG(Overall) AS 'Média',
	MIN(Overall) AS 'Mínimo',
	MAX(Overall) AS 'Máximo',
	ROUND(STDEV(Overall),2) AS 'DesvPad'
FROM
	#tabela_fifa_corrigida2

UNION

SELECT
	'Altura' AS 'Variável',
	AVG(Altura) AS 'Média',
	MIN(Altura) AS 'Mínimo',
	MAX(Altura) AS 'Máximo',
	ROUND(STDEV(Altura),2) AS 'DesvPad'
FROM
	#tabela_fifa_corrigida2
	
UNION

SELECT
	'Peso' AS 'Variável',
	AVG(Peso) AS 'Média',
	MIN(Peso) AS 'Mínimo',
	MAX(Peso) AS 'Máximo',
	ROUND(STDEV(Peso),2) AS 'DesvPad'
FROM
	#tabela_fifa_corrigida2

UNION

SELECT
	'Salario' AS 'Variável',
	AVG(Salario) AS 'Média',
	MIN(Salario) AS 'Mínimo',
	MAX(Salario) AS 'Máximo',
	ROUND(STDEV(Salario),2) AS 'DesvPad'
FROM
	#tabela_fifa_corrigida2
WHERE
	Salario <> 0

UNION

SELECT
	'IMC' AS 'Variável',
	ROUND(AVG(IMC),2) AS 'Média',
	MIN(IMC) AS 'Mínimo',
	MAX(IMC) AS 'Máximo',
	ROUND(STDEV(IMC),2) AS 'DesvPad'
FROM
	#tabela_fifa_corrigida2

UNION

SELECT
	'Recisao' AS 'Variável',
	ROUND(AVG(CAST(Recisao AS float)),2) AS 'Média',
	MIN(CAST(Recisao AS float)) AS 'Mínimo',
	MAX(CAST(Recisao AS float)) AS 'Máximo',
	ROUND(STDEV(CAST(Recisao AS float)),2) AS 'DesvPad'
FROM
	#tabela_fifa_corrigida2
WHERE
	Recisao <> 0
-- Analisando as variáves quantitativas, um ponto que chamou muito minha atenção foi a distribuição da variável Salário,
-- onde existem poucos com salário altos e muitos com slários "Baixos"


-- Análise Bidimensional - Correlação

-- OVERALL X FAIXA ETÁRIA - Seria Interessante fazer um Box Plot

SELECT COUNT(Overall) FROM 	#tabela_fifa_corrigida2
SELECT VAR(Overall) FROM 	#tabela_fifa_corrigida2

SELECT
	Faixa_Etaria,
	COUNT(Overall) AS 'Contagem',
	AVG(Overall) AS 'Média',
	ROUND(STDEV(Overall),2) AS 'Desv',
	ROUND(VAR(Overall),2) AS 'Var',
	ROUND(COUNT(Overall)*VAR(Overall),2) AS 'N_x_Var'
FROM
	#tabela_fifa_corrigida2
GROUP BY
	Faixa_Etaria
ORDER BY
	Faixa_Etaria

SELECT
	ROUND(1-((SUM(N_x_Var)/SUM(Contagem))/(SELECT VAR(Overall) FROM 	#tabela_fifa_corrigida2)),2) AS 'R²'
FROM
	(SELECT
		Faixa_Etaria,
		COUNT(Overall) AS 'Contagem',
		AVG(Overall) AS 'Média',
		ROUND(STDEV(Overall),2) AS 'Desv',
		ROUND(VAR(Overall),2) AS 'Var',
		ROUND(COUNT(Overall)*VAR(Overall),2) AS 'N_x_Var'
	FROM
		#tabela_fifa_corrigida2
	GROUP BY
		Faixa_Etaria) AS Tab1
-- 25% da variabilidade média total do Overall é explicado pela Faixa etária do jogador do jogador
-- Analisando a média, desvio padrão do Overall por faixa etária, podemos presumir que os jogadores atingem seu auge em questão de desempenho na faixa etária 25-35 anos.
-- Para tirar melhores conclusões, é ideal plotarmos um Box Plot.

-- Idade x Overall 
SELECT AVG(Overall) FROM #tabela_fifa_corrigida2 --66
SELECT STDEV(Overall) FROM #tabela_fifa_corrigida2 --6,95
SELECT AVG(Idade) FROM #tabela_fifa_corrigida2 --181
SELECT STDEV(Idade) FROM #tabela_fifa_corrigida2 --6,76
SELECT COUNT(1) FROM #tabela_fifa_corrigida2 -- 18278

SELECT
	Overall,
	Idade,
	(Overall-(SELECT AVG(Overall) FROM #tabela_fifa_corrigida2))/(SELECT STDEV(Overall) FROM #tabela_fifa_corrigida2) AS '(X-Xb)/Desv',
	(Idade-(SELECT AVG(Idade) FROM #tabela_fifa_corrigida2))/(SELECT STDEV(Idade) FROM #tabela_fifa_corrigida2) AS '(y-yb)/Desv',
	((Overall-(SELECT AVG(Overall) FROM #tabela_fifa_corrigida2))/(SELECT STDEV(Overall) FROM #tabela_fifa_corrigida2))*((Idade-(SELECT AVG(Idade) FROM #tabela_fifa_corrigida2))/(SELECT STDEV(Idade) FROM #tabela_fifa_corrigida2)) AS'Formula'
FROM
	#tabela_fifa_corrigida2


SELECT
	ROUND((SUM(Formula)/((SELECT COUNT(1) FROM #tabela_fifa_corrigida2 )-1)),1) AS 'Correlação'
FROM
	(SELECT
		Overall,
		Idade,
		(Overall-(SELECT AVG(Overall) FROM #tabela_fifa_corrigida2))/(SELECT STDEV(Overall) FROM #tabela_fifa_corrigida2) AS '(X-Xb)/Desv',
		(Idade-(SELECT AVG(Idade) FROM #tabela_fifa_corrigida2))/(SELECT STDEV(Idade) FROM #tabela_fifa_corrigida2) AS '(y-yb)/Desv',
		((Overall-(SELECT AVG(Overall) FROM #tabela_fifa_corrigida2))/(SELECT STDEV(Overall) FROM #tabela_fifa_corrigida2))*((Idade-(SELECT AVG(Idade) FROM #tabela_fifa_corrigida2))/(SELECT STDEV(Idade) FROM #tabela_fifa_corrigida2)) AS'Formula'
	FROM
		#tabela_fifa_corrigida2) AS Tab1

-- Existe uma correlação moderada entre Overall e o Idade (Coef=0,5)


-- OVERALL X Nacionalidade - Seria Interessante fazer um Box Plot

SELECT COUNT(Overall) FROM 	#tabela_fifa_corrigida2
SELECT VAR(Overall) FROM 	#tabela_fifa_corrigida2

SELECT
	Nacionalidade,
	COUNT(Overall) AS 'Contagem',
	AVG(Overall) AS 'Média',
	ROUND(STDEV(Overall),2) AS 'Desv',
	ROUND(VAR(Overall),2) AS 'Var',
	ROUND(COUNT(Overall)*VAR(Overall),2) AS 'N_x_Var'
FROM
	#tabela_fifa_corrigida2
GROUP BY
	Nacionalidade
ORDER BY
	Média DESC

SELECT
	ROUND(1-((SUM(N_x_Var)/SUM(Contagem))/(SELECT VAR(Overall) FROM 	#tabela_fifa_corrigida2)),2) AS 'R²'
FROM
	(SELECT
		Nacionalidade,
		COUNT(Overall) AS 'Contagem',
		AVG(Overall) AS 'Média',
		ROUND(STDEV(Overall),2) AS 'Desv',
		ROUND(VAR(Overall),2) AS 'Var',
		ROUND(COUNT(Overall)*VAR(Overall),2) AS 'N_x_Var'
	FROM
		#tabela_fifa_corrigida2
	GROUP BY
		Nacionalidade) AS Tab1
-- 17% da variabilidade média total do Overall é explicado pela nacionalidade do jogador
-- Analisando a média, desvio padrão e a quantidade de jogadores por país podemos presumir que o brasil tem mais jogadores com Overall (acima da média)
-- Para tirar melhores conclusões, é ideal plotarmos um Box Plot.


-- Salário x Overall
SELECT AVG(Overall) FROM #tabela_fifa_corrigida2 --66
SELECT STDEV(Overall) FROM #tabela_fifa_corrigida2 --6,95
SELECT AVG(Salario) FROM #tabela_fifa_corrigida2 --9456
SELECT STDEV(Salario) FROM #tabela_fifa_corrigida2 --21351,714
SELECT COUNT(1) FROM #tabela_fifa_corrigida2 -- 18278

SELECT
	Overall,
	Salario,
	(Overall-(SELECT AVG(Overall) FROM #tabela_fifa_corrigida2))/(SELECT STDEV(Overall) FROM #tabela_fifa_corrigida2) AS '(X-Xb)/Desv',
	(Salario-(SELECT AVG(Salario) FROM #tabela_fifa_corrigida2))/(SELECT STDEV(Salario) FROM #tabela_fifa_corrigida2) AS '(y-yb)/Desv',
	((Overall-(SELECT AVG(Overall) FROM #tabela_fifa_corrigida2))/(SELECT STDEV(Overall) FROM #tabela_fifa_corrigida2))*((Salario-(SELECT AVG(Salario) FROM #tabela_fifa_corrigida2))/(SELECT STDEV(Salario) FROM #tabela_fifa_corrigida2)) AS'Formula'
FROM
	#tabela_fifa_corrigida2

SELECT
	ROUND((SUM(Formula)/((SELECT COUNT(1) FROM #tabela_fifa_corrigida2 )-1)),1) AS 'Correlação'
FROM
	(SELECT
		Overall,
		Salario,
		(Overall-(SELECT AVG(Overall) FROM #tabela_fifa_corrigida2))/(SELECT STDEV(Overall) FROM #tabela_fifa_corrigida2) AS '(X-Xb)/Desv',
		(Salario-(SELECT AVG(Salario) FROM #tabela_fifa_corrigida2))/(SELECT STDEV(Salario) FROM #tabela_fifa_corrigida2) AS '(y-yb)/Desv',
		((Overall-(SELECT AVG(Overall) FROM #tabela_fifa_corrigida2))/(SELECT STDEV(Overall) FROM #tabela_fifa_corrigida2))*((Salario-(SELECT AVG(Salario) FROM #tabela_fifa_corrigida2))/(SELECT STDEV(Salario) FROM #tabela_fifa_corrigida2)) AS'Formula'
	FROM
		#tabela_fifa_corrigida2) AS Tab1

-- Existe uma forte correlação entre Overall e o Salário (Coef=0,6)
-- Ou seja, quanto melhor o jogador (Overall mais alto) melhor será sua remuneração.


-- Análises

-- Clubes Com Maiores Folhas Salariais	(TOP 10)
SELECT SUM(Salario) FROM #tabela_fifa_corrigida2
SELECT COUNT(DISTINCT(Clube)) FROM #tabela_fifa_corrigida2 --698 clubes

DROP TABLE IF EXISTS #tabela_folha_salarial
SELECT
	Clube,
	SUM(Salario) AS 'Folha_Salarial'
INTO
	#tabela_folha_salarial
FROM
	#tabela_fifa_corrigida2
GROUP BY
	Clube


SELECT TOP 10
	*,
	(CAST(Folha_Salarial AS float)/(SELECT SUM(Salario) FROM #tabela_fifa_corrigida2)*100) AS 'Relativo'
FROM
	#tabela_folha_salarial
ORDER BY
	Folha_Salarial DESC

-- As folhas salarias dos 10 clubes com maiores folhas salariais (1,5% do total de clubes) corresondem a Aproximadamente 20% da soma das
-- folhas salariais de todos os clubes (698)
-- Isso mostra a desigualdade entre os clubes, se falando de infraestrutura e contratações, assim deixando campeonatos menos competitivos.

-- Clubes Com Maiores Overall	(TOP 10)
SELECT TOP 10
	Clube,
	AVG(Overall) AS 'Overall'
FROM	
	#tabela_fifa_corrigida2
WHERE
	Clube<>Nacionalidade
GROUP BY
	Clube
ORDER BY
	Overall DESC
-- Dentro dos TOP 10 clubes com melhores médias de Overall, estão os 3 campeões das champions  2020-2022.
-- E dos Títulos de 2010-2019 (10 disputas), só dois foram ganhos por clubes fora desse top 10, mostrado uma forte Hegemonia desses clubes.
-- Outra analise interessante, é de que desses 10 clubes (Top 10 Overall), 7 deles se encntram no top 10 de maiores folas salariais.
-- Isso só confirma nossa analise anterior, de existir uma desigualdade entre os clubes e uma falta de competitividade nos campeonatos.


-- Paises Com Mais Jogadores Acima da Média (Overall 66) Top 5
DROP TABLE IF EXISTS #jogadores_pais_bons
SELECT
	Nacionalidade,
	AVG(Overall) AS 'Overall',
	COUNT(1) AS 'Jogadores'
INTO
	#jogadores_pais_bons
FROM
	#tabela_fifa_corrigida2
WHERE
	Overall>66
GROUP BY
	Nacionalidade
ORDER BY
	Jogadores DESC
	

DROP TABLE IF EXISTS #jogadores_pais
SELECT
	Nacionalidade,
	COUNT(1) AS 'contagem'
INTO
	#jogadores_pais
FROM
	#tabela_fifa_corrigida2
GROUP BY 
	Nacionalidade
ORDER BY
	contagem DESC


SELECT TOP 5
	jb.Nacionalidade,
	jb.Overall,
	jb.Jogadores AS 'Bons_Jogadores',
	jt.contagem AS 'Contagem_Jogadores',
	ROUND((CAST(jb.Jogadores AS float)/jt.contagem),2) AS 'Prop_Jogadores_Bons'
FROM
	#jogadores_pais_bons jb
	LEFT JOIN #jogadores_pais jt
		ON jb.Nacionalidade=jt.Nacionalidade
ORDER BY
	jb.Jogadores DESC

-- O país que apresenta a melhor relação quantidade absoluta e proposrção de jogadores "bons" é o Brasil,
-- com isso seria interessante os clubes direcionarem os olhares para o Brasil na hora de contratar seus jogadores/Promessas.
	

-- Melhores Jogadores Por Posição
DROP TABLE IF EXISTS #jogadores_Overall
SELECT
	Posicao,
	MAX(Overall) AS 'Overall'
INTO
	#jogadores_Overall
FROM
	#tabela_fifa_corrigida2
GROUP BY
	Posicao

SELECT
	t.Nome,
	o.Posicao,
	o.Overall
FROM
	#jogadores_Overall o
	LEFT JOIN #tabela_fifa_corrigida2 t
	ON o.Overall = t.Overall AND o.Posicao=t.Posicao
	

-- Jogadores com Maiores Salários TOP 5
SELECT TOP 5
	Nome,
	Salario
FROM
	#tabela_fifa_corrigida2
ORDER BY
	Salario DESC

-- Jogadores com Maiores Overall TOP 5
SELECT TOP 5
	Nome,
	Overall
FROM
	#tabela_fifa_corrigida2
ORDER BY
	Overall DESC
-- Dentro dos 5 melhores jogadores (Maiores Overais), 3 deles estão entro do TOP5 maiores salários
-- Isso nos mostra a alta remuneração por alto desempenho.

-- Promessas
SELECT TOP 10
	Nome,
	Clube,
	Overall,
	Idade,
	Validade_Contrato
FROM
	#tabela_fifa_corrigida2
WHERE
	Idade<=20
ORDER BY
	Overall DESC, Idade ASC
-- Os 10 melhores jogadores com 20 anos ou menos (Dessas 10 promessas, 5 mudaram de clube até o ano 2022).
-- Isso mostra o itneresse dos clubes por jogadores jovens com ótimos desempenhos.

-- Curiosidades: Canhotos x Destros
SELECT COUNT(Perna) FROM #tabela_fifa_corrigida2

SELECT
	Perna,
	COUNT(Perna) AS 'Freq_Abs',
	ROUND(CAST(COUNT(Perna) AS float)/(SELECT COUNT(Perna) FROM #tabela_fifa_corrigida2),2) AS 'Freq_Rel',
	AVG(Overall) 'Media_Overall',
	MIN(Overall) 'Min_Overall',
	MAX(Overall) 'Max_Overall',
	ROUND(STDEV(Overall),2) 'Desvp_Overall'
FROM
	#tabela_fifa_corrigida2
GROUP BY
	Perna



