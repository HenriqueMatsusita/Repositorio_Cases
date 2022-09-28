-- Case - OCA

-- Objetivos:
-- - Identificar filmes com maiores renda e p�blico

-- Conhecimentos aplicados
-- Estat�stica:
       -- - An�lise exploratoria das vari�veis qualitativas (Tabela de Frequ�ncia/Histograma)
       -- - An�lise exploratoria das vari�veis quantitativas (Medidas Resumo (M�dia, Soma e Contagem))
-- SQL:
       -- - Selecionar vari�veis que quero visualizar de uma tabela (SELECT/FROM)
       -- - Comandos para exii��o de medidas resumo (COUNT, SUM, AVG)
       -- - Comandos para an�lise de valores �nicos (DISTINCT)
       -- - An�lise de valores nulos (Count(1)-Count(vari�vel))
       -- - Criar Filtros (WHERE) com aux�lio das sintaxes condicionais (AND, OR, NOT) e compara��o (<, >, !=)
       -- - Agrupar medidas resumos por categoria (GROUP BY)
       -- - Ordenar DataFrame (ORDER BY)
       -- - Criar colunas condicionais (CASE-WHEN-THEN-ELSE-END)
       -- - Convers�o de tipo de vari�vel (CAST)
       -- - Manipula��o de String (CHARINDEX, SUBSTRING e DATALENGTH)
       -- - Criar tabelas din�micas (INTO), com finalidade de deixar o c�digo mais "limpo"



SELECT
	*
FROM
	Henrique.dbo.oca


-- Avaliando se h� valores NaN

SELECT
	COUNT(1)-COUNT([Ano de exibi��o]) AS 'Ano de Exibi��o',
	COUNT(1)-COUNT([T�tulo da obra]) AS 'T�tulo da obra',
	COUNT(1)-COUNT([CPB ROE]) AS 'CPB ROE',
	COUNT(1)-COUNT([G�nero]) AS 'G�nero',
	COUNT(1)-COUNT([Pa�s(es) produtor(es) da obra]) AS 'Pa�s produtor da obra',
	COUNT(1)-COUNT([Nacionalidade da obra]) AS 'Nacionalidade da obra',
	COUNT(1)-COUNT([Data de lan�amento]) AS 'Data de Lan�amento',
	COUNT(1)-COUNT([Empresa distribuidora]) AS 'Empresa distribuidora',
	COUNT(1)-COUNT([Origem da empresa distribuidora]) AS 'Origem da empresa distribuidora',
	COUNT(1)-COUNT([P�blico no ano de exibi��o]) AS 'P�blico no ano de exibi��o',
	COUNT(1)-COUNT([Renda (R$) no ano de exibi��o]) AS 'Renda($)'
FROM
	Henrique.dbo.oca

-- Avaliando contagem de valores �nicos

SELECT
	COUNT(DISTINCT [Ano de exibi��o]) AS 'Ano de Exibi��o',
	COUNT(DISTINCT [T�tulo da obra]) AS 'T�tulo da obra',
	COUNT(DISTINCT [CPB ROE]) AS 'CPB ROE',
	COUNT(DISTINCT [G�nero]) AS 'G�nero',
	COUNT(DISTINCT [Pa�s(es) produtor(es) da obra]) AS 'Pa�s(es) produtor(es) da obra',
	COUNT(DISTINCT [Nacionalidade da obra]) AS 'Nacionalidade da obra',
	COUNT(DISTINCT [Data de lan�amento]) AS 'Data de lan�amento',
	COUNT(DISTINCT [Empresa distribuidora]) AS 'Empresa distribuidora',
	COUNT(DISTINCT [Origem da empresa distribuidora]) AS 'Origem da empresa distribuidora',
	COUNT(DISTINCT [P�blico no ano de exibi��o]) AS 'P�blico no ano de exibi��o',
	COUNT(DISTINCT [Renda (R$) no ano de exibi��o]) AS 'Renda (R$) no ano de exibi��o'
FROM
	Henrique.dbo.oca


-- Agupando quantidade de filmes pelo Ano de Exibi��o
SELECT
	[Ano de exibi��o],
	COUNT([Ano de exibi��o]) AS 'Data de lan�amento'
FROM
	Henrique.dbo.oca
GROUP BY
	[Ano de exibi��o]
ORDER BY
	[Ano de exibi��o]

-- Tratamento de dados
-- Ser� necess�rio fazer um tratamento na coluna 'Renda' para conseguir efetuar a convers�o do tipo de vari�vel
-- Ser� necess�rio fazer um tratamento na coluna 'P�blico' para conseguir efetuar a convers�o do tipo de vari�vel

DROP TABLE IF EXISTS #tabela_teste1
SELECT
	*,
	CASE WHEN CHARINDEX(',',[Renda (R$) no ano de exibi��o]) != 0 THEN SUBSTRING([Renda (R$) no ano de exibi��o],1,DATALENGTH([Renda (R$) no ano de exibi��o])-3)
		 ELSE [Renda (R$) no ano de exibi��o]
	END AS 'Renda_tratado',
	REPLACE(CASE WHEN CHARINDEX(',',[Renda (R$) no ano de exibi��o]) != 0 THEN SUBSTRING([Renda (R$) no ano de exibi��o],1,DATALENGTH([Renda (R$) no ano de exibi��o])-3)
		 ELSE [Renda (R$) no ano de exibi��o]
	END,'.','') AS Renda_tratado_int,
	CAST(REPLACE([P�blico no ano de exibi��o],'.','') AS int) AS 'P�blico_tratado'
INTO
	#tabela_teste1
FROM
	Henrique.dbo.oca
WHERE
	[Renda (R$) no ano de exibi��o] != 'ND'

-- Filme com maior Renda
SELECT TOP 1
	*
FROM
	#tabela_teste1
ORDER BY
	CAST(Renda_tratado_int AS int) DESC

-- TOP 5 filmes com maiores rendas
SELECT TOP 5
	*
FROM
	#tabela_teste1
ORDER BY
	CAST(Renda_tratado_int AS int) DESC


-- An�lise de filmes com maiores p�blicos

SELECT TOP 5
	*
FROM
	#tabela_teste1
ORDER BY
	P�blico_tratado DESC

-- An�lise do R$/Pessoas

SELECT
	[T�tulo da obra],
	P�blico_tratado,
	CAST(Renda_tratado_int AS int) AS 'Renda',
	CASE WHEN P�blico_tratado!=0 THEN CAST(Renda_tratado_int AS int)/P�blico_tratado
		ELSE 0
	END AS 'R$/Pessoa',
	[Ano de exibi��o]
FROM
	#tabela_teste1
ORDER BY
	CAST(Renda_tratado_int AS int) DESC



