SELECT
	*
FROM
	Henrique.dbo.oca


-- Avaliando se há valores NaN

SELECT
	COUNT(1)-COUNT([Ano de exibição]) AS 'Ano de Exibição',
	COUNT(1)-COUNT([Título da obra]) AS 'Título da obra',
	COUNT(1)-COUNT([CPB ROE]) AS 'CPB ROE',
	COUNT(1)-COUNT([Gênero]) AS 'Gênero',
	COUNT(1)-COUNT([País(es) produtor(es) da obra]) AS 'País produtor da obra',
	COUNT(1)-COUNT([Nacionalidade da obra]) AS 'Nacionalidade da obra',
	COUNT(1)-COUNT([Data de lançamento]) AS 'Data de Lançamento',
	COUNT(1)-COUNT([Empresa distribuidora]) AS 'Empresa distribuidora',
	COUNT(1)-COUNT([Origem da empresa distribuidora]) AS 'Origem da empresa distribuidora',
	COUNT(1)-COUNT([Público no ano de exibição]) AS 'Público no ano de exibição',
	COUNT(1)-COUNT([Renda (R$) no ano de exibição]) AS 'Renda($)'
FROM
	Henrique.dbo.oca

-- Avaliando contagem de valores únicos

SELECT
	COUNT(DISTINCT [Ano de exibição]) AS 'Ano de Exibição',
	COUNT(DISTINCT [Título da obra]) AS 'Título da obra',
	COUNT(DISTINCT [CPB ROE]) AS 'CPB ROE',
	COUNT(DISTINCT [Gênero]) AS 'Gênero',
	COUNT(DISTINCT [País(es) produtor(es) da obra]) AS 'País(es) produtor(es) da obra',
	COUNT(DISTINCT [Nacionalidade da obra]) AS 'Nacionalidade da obra',
	COUNT(DISTINCT [Data de lançamento]) AS 'Data de lançamento',
	COUNT(DISTINCT [Empresa distribuidora]) AS 'Empresa distribuidora',
	COUNT(DISTINCT [Origem da empresa distribuidora]) AS 'Origem da empresa distribuidora',
	COUNT(DISTINCT [Público no ano de exibição]) AS 'Público no ano de exibição',
	COUNT(DISTINCT [Renda (R$) no ano de exibição]) AS 'Renda (R$) no ano de exibição'
FROM
	Henrique.dbo.oca


-- Agupando quantidade de filmes pelo Ano de Exibição
SELECT
	[Ano de exibição],
	COUNT([Ano de exibição]) AS 'Data de lançamento'
FROM
	Henrique.dbo.oca
GROUP BY
	[Ano de exibição]
ORDER BY
	[Ano de exibição]

-- Tratamento de dados
-- Será necessário fazer um tratamento na coluna 'Renda' para conseguir efetuar a conversão do tipo de variável
-- Será necessário fazer um tratamento na coluna 'Público' para conseguir efetuar a conversão do tipo de variável

DROP TABLE IF EXISTS #tabela_teste1
SELECT
	*,
	CASE WHEN CHARINDEX(',',[Renda (R$) no ano de exibição]) != 0 THEN SUBSTRING([Renda (R$) no ano de exibição],1,DATALENGTH([Renda (R$) no ano de exibição])-3)
		 ELSE [Renda (R$) no ano de exibição]
	END AS 'Renda_tratado',
	REPLACE(CASE WHEN CHARINDEX(',',[Renda (R$) no ano de exibição]) != 0 THEN SUBSTRING([Renda (R$) no ano de exibição],1,DATALENGTH([Renda (R$) no ano de exibição])-3)
		 ELSE [Renda (R$) no ano de exibição]
	END,'.','') AS Renda_tratado_int,
	CAST(REPLACE([Público no ano de exibição],'.','') AS int) AS 'Público_tratado'
INTO
	#tabela_teste1
FROM
	Henrique.dbo.oca
WHERE
	[Renda (R$) no ano de exibição] != 'ND'

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


-- Análise de filmes com maiores públicos

SELECT TOP 5
	*
FROM
	#tabela_teste1
ORDER BY
	Público_tratado DESC

-- Análise do R$/Pessoas

SELECT
	[Título da obra],
	Público_tratado,
	CAST(Renda_tratado_int AS int) AS 'Renda',
	CASE WHEN Público_tratado!=0 THEN CAST(Renda_tratado_int AS int)/Público_tratado
		ELSE 0
	END AS 'R$/Pessoa',
	[Ano de exibição]
FROM
	#tabela_teste1
ORDER BY
	CAST(Renda_tratado_int AS int) DESC



