-- CASE CHURN APP
-- Case - Churn Em App de Comida

-- Objetivos:
-- - Identificar principais fatores de riscos que estão associados ao Churn do Cliente
-- - Traçar perfil de clientes mais propensos a dar Churn
-- - Sugerir possíveis planos de ação para redução do churn
-- Criando uma tabela temporária com um JOIN entre as tabelas fato e dimensão

DROP TABLE IF EXISTS #join_churn_henrique_matsushita
SELECT 
	dc.*,
	fc.DataUltimaTransacao
INTO
	#join_churn_henrique_matsushita
FROM 
	preditiva.db_churn.dim_clientes dc
	LEFT JOIN preditiva.db_churn.fato_churn fc
	ON dc.ClientId=fc.ClientId

-- Verificando se há valores nulos
SELECT 
	COUNT(ClientId) AS 'Qtd Clientes',
	COUNT(DataExtracao) AS 'Qtd Data Extração',
	COUNT(Score_Credito) AS 'Qtd Score',
	COUNT(Estado) AS 'Qtd Estado',
	COUNT(Gênero) AS 'Qtd Genero',
	COUNT(Idade) AS 'Qtd Idade', 
	COUNT(Tempo_Cliente) AS 'Qtd TempoClientes',
	COUNT(Limite_Credito_Mercado) AS 'Qtd Limite',
	COUNT(Qte_Categorias) AS 'Qtd Categorias',
	COUNT(Usa_Cartao_Credito) AS 'Qtd UsaCartao',
	COUNT(Programa_Fidelidade) AS 'Qtd Fidelidade',
	COUNT(Sum_Pedidos_Acumulados) AS 'Qtd SomaPedidos',
	COUNT(DataUltimaTransacao) AS 'Qtd Última Transação',
	COUNT(1) AS 'Qtd Total'
FROM
	#join_churn_henrique_matsushita
	
	
-- Verificando se há Cliente ID repetido	
SELECT 
	COUNT(DISTINCT ClientId) AS 'Qtd Clientes',
	COUNT(1) AS 'Qtd Total'
FROM
	#join_churn_henrique_matsushita
	
	
-- Criado coluna "Dias Inativos" e coluna "Cliente ativo"

DROP TABLE IF EXISTS #fato_churn_flag_ativo_henrique_matsushita
SELECT
	*,
	DATEDIFF(dd,DataUltimaTransacao,'2019-10-30') as dias_inativo,
	CASE
		WHEN DATEDIFF(dd,DataUltimaTransacao,'2019-10-30') >= 30 THEN 1
		ELSE 0
	END as Cliente_Ativo
INTO
	#fato_churn_flag_ativo_henrique_matsushita
FROM
	#join_churn_henrique_matsushita
ORDER BY
	DataUltimaTransacao DESC

	
-- Cálculo Freq relativa e ABS
SELECT
	Cliente_Ativo,
	COUNT(1) as freq_abs,
	CAST(COUNT(1) as FLOAT)/(SELECT COUNT(1) FROM #fato_churn_flag_ativo_henrique_matsushita) as freq_rel
FROM
	#fato_churn_flag_ativo_henrique_matsushita
GROUP BY
	Cliente_Ativo
	
-- Cálculo Faixas (Idade, Score, Limite Crédito e Total de Pedidos)
DROP TABLE IF EXISTS #fato_churn_flag_completo_henrique_matsushita	
SELECT 
	*,
	CASE WHEN Idade<=10 THEN '0 a 10'
		 WHEN Idade<=20 THEN '11 a 20'
		 WHEN Idade<=30 THEN '21 a 30'
		 WHEN Idade<=40 THEN '31 a 40'
		 WHEN Idade<=50 THEN '41 a 50'
		 WHEN Idade<=60 THEN '51 a 60'
		 WHEN Idade<=70 THEN '61 a 70'
		 ELSE '71+'
	END AS 'FaixaEtária',
	CASE WHEN Score_Credito <= 450 THEN '0 a 450'
		 WHEN Score_Credito <= 550 THEN '451 a 550'
		 WHEN Score_Credito <= 650 THEN '551 a 650'
		 WHEN Score_Credito <= 750 THEN '651 a 750'
		 WHEN Score_Credito <= 850 THEN '751 a 850'
		 ELSE '851+'
	END AS 'FaixaScore',
	CASE WHEN Limite_Credito_Mercado <= 500 THEN '0 a 500'
		 WHEN Limite_Credito_Mercado <= 1000 THEN '501 a 1000'
		 WHEN Limite_Credito_Mercado <= 1500 THEN '1001 a 1500'
		 WHEN Limite_Credito_Mercado <= 2000 THEN '1501 a 2000'
		 ELSE '2001+'
	END AS 'FaixaLimiteCredito',
	CASE WHEN Sum_Pedidos_Acumulados <= 150 THEN '0 a 150'
		 WHEN Sum_Pedidos_Acumulados <= 300 THEN '151 a 300'
		 WHEN Sum_Pedidos_Acumulados <= 450 THEN '301 a 450'
		 WHEN Sum_Pedidos_Acumulados <= 600 THEN '451 a 600'
		 WHEN Sum_Pedidos_Acumulados <= 750 THEN '601 a 750'
		 ELSE '751+'
	END AS 'FaixaTotalPedidos'
INTO 
	#fato_churn_flag_completo_henrique_matsushita	
FROM 
	#fato_churn_flag_ativo_henrique_matsushita
	
-- Cálculo Churn Geral
SELECT
	AVG(CAST (Cliente_Ativo AS FLOAT)) AS 'CHURN'
FROM
	#fato_churn_flag_completo_henrique_matsushita

-- Calculo Freq Relativa e Abs
	
-- SUBQUERY - Total Cliente Inativos
SELECT	COUNT(ClientId) FROM #fato_churn_flag_completo_henrique_matsushita WHERE Cliente_Ativo =1
-- SUBQUERY - Total Cliente Ativos
SELECT	COUNT(ClientId) FROM #fato_churn_flag_completo_henrique_matsushita WHERE Cliente_Ativo =0
	
-- USA CARTAO DE CREDITO
SELECT
	Usa_Cartao_Credito,
	SUM(Cliente_Ativo) AS 'Cliente Inativo',
	COUNT(1)-SUM(Cliente_Ativo) AS 'Cliente Ativo',
	CAST(SUM(Cliente_Ativo) AS FLOAT)/(SELECT	COUNT(ClientId) FROM #fato_churn_flag_completo_henrique_matsushita WHERE Cliente_Ativo =1) AS 'Cliente Inativo Relativo',
	CAST(COUNT(1)-SUM(Cliente_Ativo) AS FLOAT)/(SELECT	COUNT(ClientId) FROM #fato_churn_flag_completo_henrique_matsushita WHERE Cliente_Ativo =0)AS 'Cliente Ativo Relativo',
	COUNT(1) AS 'Freq ABS Total',
	CAST(COUNT(1) AS FLOAT)/(SELECT COUNT(1) FROM #fato_churn_flag_completo_henrique_matsushita) AS 'Freq Rel Total',
	AVG(CAST(Cliente_Ativo AS FLOAT) ) AS 'Churn',
	'Usa Cartão de Crédito' AS Variável
FROM
	#fato_churn_flag_completo_henrique_matsushita
GROUP BY 
	Usa_Cartao_Credito 
	
	
-- ESTADO
SELECT
	Estado,
	SUM(Cliente_Ativo) AS 'Cliente Inativo',
	COUNT(1)-SUM(Cliente_Ativo) AS 'Cliente Ativo',
	CAST(SUM(Cliente_Ativo) AS FLOAT)/(SELECT	COUNT(ClientId) FROM #fato_churn_flag_completo_henrique_matsushita WHERE Cliente_Ativo =1) AS 'Cliente Inativo Relativo',
	CAST(COUNT(1)-SUM(Cliente_Ativo) AS FLOAT)/(SELECT	COUNT(ClientId) FROM #fato_churn_flag_completo_henrique_matsushita WHERE Cliente_Ativo =0)AS 'Cliente Ativo Relativo',
	COUNT(1) AS 'Freq ABS Total',
	CAST(COUNT(1) AS FLOAT)/(SELECT COUNT(1) FROM #fato_churn_flag_completo_henrique_matsushita) AS 'Freq Rel Total',
	AVG(CAST(Cliente_Ativo AS FLOAT) ) AS 'Churn',
	'Estado' AS Variável
FROM
	#fato_churn_flag_completo_henrique_matsushita
GROUP BY 
	Estado 	
	

-- GÊNERO
SELECT
	Gênero,
	SUM(Cliente_Ativo) AS 'Cliente Inativo',
	COUNT(1)-SUM(Cliente_Ativo) AS 'Cliente Ativo',
	CAST(SUM(Cliente_Ativo) AS FLOAT)/(SELECT	COUNT(ClientId) FROM #fato_churn_flag_completo_henrique_matsushita WHERE Cliente_Ativo =1) AS 'Cliente Inativo Relativo',
	CAST(COUNT(1)-SUM(Cliente_Ativo) AS FLOAT)/(SELECT	COUNT(ClientId) FROM #fato_churn_flag_completo_henrique_matsushita WHERE Cliente_Ativo =0)AS 'Cliente Ativo Relativo',
	COUNT(1) AS 'Freq ABS Total',
	CAST(COUNT(1) AS FLOAT)/(SELECT COUNT(1) FROM #fato_churn_flag_completo_henrique_matsushita) AS 'Freq Rel Total',
	AVG(CAST(Cliente_Ativo AS FLOAT) ) AS 'Churn',
	'Gênero' AS Variável
FROM
	#fato_churn_flag_completo_henrique_matsushita
GROUP BY 
	Gênero		
	
	
-- TEMPLO CLIENTE
SELECT
	Tempo_Cliente ,
	SUM(Cliente_Ativo) AS 'Cliente Inativo',
	COUNT(1)-SUM(Cliente_Ativo) AS 'Cliente Ativo',
	CAST(SUM(Cliente_Ativo) AS FLOAT)/(SELECT	COUNT(ClientId) FROM #fato_churn_flag_completo_henrique_matsushita WHERE Cliente_Ativo =1) AS 'Cliente Inativo Relativo',
	CAST(COUNT(1)-SUM(Cliente_Ativo) AS FLOAT)/(SELECT	COUNT(ClientId) FROM #fato_churn_flag_completo_henrique_matsushita WHERE Cliente_Ativo =0)AS 'Cliente Ativo Relativo',
	COUNT(1) AS 'Freq ABS Total',
	CAST(COUNT(1) AS FLOAT)/(SELECT COUNT(1) FROM #fato_churn_flag_completo_henrique_matsushita) AS 'Freq Rel Total',
	AVG(CAST(Cliente_Ativo AS FLOAT) ) AS 'Churn',
	'Tempo Cliente' AS Variável
FROM
	#fato_churn_flag_completo_henrique_matsushita
GROUP BY 
	Tempo_Cliente
ORDER BY 
	Tempo_Cliente ASC
	
	
-- CATEGORIAS
SELECT
	Qte_Categorias ,
	SUM(Cliente_Ativo) AS 'Cliente Inativo',
	COUNT(1)-SUM(Cliente_Ativo) AS 'Cliente Ativo',
	CAST(SUM(Cliente_Ativo) AS FLOAT)/(SELECT	COUNT(ClientId) FROM #fato_churn_flag_completo_henrique_matsushita WHERE Cliente_Ativo =1) AS 'Cliente Inativo Relativo',
	CAST(COUNT(1)-SUM(Cliente_Ativo) AS FLOAT)/(SELECT	COUNT(ClientId) FROM #fato_churn_flag_completo_henrique_matsushita WHERE Cliente_Ativo =0)AS 'Cliente Ativo Relativo',
	COUNT(1) AS 'Freq ABS Total',
	CAST(COUNT(1) AS FLOAT)/(SELECT COUNT(1) FROM #fato_churn_flag_completo_henrique_matsushita) AS 'Freq Rel Total',
	AVG(CAST(Cliente_Ativo AS FLOAT) ) AS 'Churn',
	'Categorias' AS Variável
FROM
	#fato_churn_flag_completo_henrique_matsushita
GROUP BY 
	Qte_Categorias
ORDER BY 
	Qte_Categorias ASC

	
-- PROGRAMA DE FIDELIDADE
SELECT
	Programa_Fidelidade  ,
	SUM(Cliente_Ativo) AS 'Cliente Inativo',
	COUNT(1)-SUM(Cliente_Ativo) AS 'Cliente Ativo',
	CAST(SUM(Cliente_Ativo) AS FLOAT)/(SELECT	COUNT(ClientId) FROM #fato_churn_flag_completo_henrique_matsushita WHERE Cliente_Ativo =1) AS 'Cliente Inativo Relativo',
	CAST(COUNT(1)-SUM(Cliente_Ativo) AS FLOAT)/(SELECT	COUNT(ClientId) FROM #fato_churn_flag_completo_henrique_matsushita WHERE Cliente_Ativo =0)AS 'Cliente Ativo Relativo',
	COUNT(1) AS 'Freq ABS Total',
	CAST(COUNT(1) AS FLOAT)/(SELECT COUNT(1) FROM #fato_churn_flag_completo_henrique_matsushita) AS 'Freq Rel Total',
	AVG(CAST(Cliente_Ativo AS FLOAT) ) AS 'Churn',
	'Programa Fidelidade' AS Variável
FROM
	#fato_churn_flag_completo_henrique_matsushita
GROUP BY 
	Programa_Fidelidade
ORDER BY 
	Programa_Fidelidade ASC
	
	
-- USA CARTÃO DE CRÉDITO
SELECT
	Usa_Cartao_Credito  ,
	SUM(Cliente_Ativo) AS 'Cliente Inativo',
	COUNT(1)-SUM(Cliente_Ativo) AS 'Cliente Ativo',
	CAST(SUM(Cliente_Ativo) AS FLOAT)/(SELECT	COUNT(ClientId) FROM #fato_churn_flag_completo_henrique_matsushita WHERE Cliente_Ativo =1) AS 'Cliente Inativo Relativo',
	CAST(COUNT(1)-SUM(Cliente_Ativo) AS FLOAT)/(SELECT	COUNT(ClientId) FROM #fato_churn_flag_completo_henrique_matsushita WHERE Cliente_Ativo =0)AS 'Cliente Ativo Relativo',
	COUNT(1) AS 'Freq ABS Total',
	CAST(COUNT(1) AS FLOAT)/(SELECT COUNT(1) FROM #fato_churn_flag_completo_henrique_matsushita) AS 'Freq Rel Total',
	AVG(CAST(Cliente_Ativo AS FLOAT) ) AS 'Churn',
	'Usa Cartão de Crédito' AS Variável
FROM
	#fato_churn_flag_completo_henrique_matsushita
GROUP BY 
	Usa_Cartao_Credito  
ORDER BY 
	Usa_Cartao_Credito   ASC
	
-- FAIXA ETÁRIA
SELECT
	FaixaEtária  ,
	SUM(Cliente_Ativo) AS 'Cliente Inativo',
	COUNT(1)-SUM(Cliente_Ativo) AS 'Cliente Ativo',
	CAST(SUM(Cliente_Ativo) AS FLOAT)/(SELECT	COUNT(ClientId) FROM #fato_churn_flag_completo_henrique_matsushita WHERE Cliente_Ativo =1) AS 'Cliente Inativo Relativo',
	CAST(COUNT(1)-SUM(Cliente_Ativo) AS FLOAT)/(SELECT	COUNT(ClientId) FROM #fato_churn_flag_completo_henrique_matsushita WHERE Cliente_Ativo =0)AS 'Cliente Ativo Relativo',
	COUNT(1) AS 'Freq ABS Total',
	CAST(COUNT(1) AS FLOAT)/(SELECT COUNT(1) FROM #fato_churn_flag_completo_henrique_matsushita) AS 'Freq Rel Total',
	AVG(CAST(Cliente_Ativo AS FLOAT) ) AS 'Churn',
	'Faixa Etária' AS Variável
FROM
	#fato_churn_flag_completo_henrique_matsushita
GROUP BY 
	FaixaEtária  
ORDER BY 
	FaixaEtária  ASC

	
-- FAIXA SCORE
SELECT
	FaixaScore  ,
	SUM(Cliente_Ativo) AS 'Cliente Inativo',
	COUNT(1)-SUM(Cliente_Ativo) AS 'Cliente Ativo',
	CAST(SUM(Cliente_Ativo) AS FLOAT)/(SELECT	COUNT(ClientId) FROM #fato_churn_flag_completo_henrique_matsushita WHERE Cliente_Ativo =1) AS 'Cliente Inativo Relativo',
	CAST(COUNT(1)-SUM(Cliente_Ativo) AS FLOAT)/(SELECT	COUNT(ClientId) FROM #fato_churn_flag_completo_henrique_matsushita WHERE Cliente_Ativo =0)AS 'Cliente Ativo Relativo',
	COUNT(1) AS 'Freq ABS Total',
	CAST(COUNT(1) AS FLOAT)/(SELECT COUNT(1) FROM #fato_churn_flag_completo_henrique_matsushita) AS 'Freq Rel Total',
	AVG(CAST(Cliente_Ativo AS FLOAT) ) AS 'Churn',
	'Faixa Score' AS Variável
FROM
	#fato_churn_flag_completo_henrique_matsushita
GROUP BY 
	FaixaScore 
ORDER BY 
	FaixaScore  ASC
	
-- FAIXA LimiteCartão
SELECT
	FaixaLimiteCredito  ,
	SUM(Cliente_Ativo) AS 'Cliente Inativo',
	COUNT(1)-SUM(Cliente_Ativo) AS 'Cliente Ativo',
	CAST(SUM(Cliente_Ativo) AS FLOAT)/(SELECT	COUNT(ClientId) FROM #fato_churn_flag_completo_henrique_matsushita WHERE Cliente_Ativo =1) AS 'Cliente Inativo Relativo',
	CAST(COUNT(1)-SUM(Cliente_Ativo) AS FLOAT)/(SELECT	COUNT(ClientId) FROM #fato_churn_flag_completo_henrique_matsushita WHERE Cliente_Ativo =0)AS 'Cliente Ativo Relativo',
	COUNT(1) AS 'Freq ABS Total',
	CAST(COUNT(1) AS FLOAT)/(SELECT COUNT(1) FROM #fato_churn_flag_completo_henrique_matsushita) AS 'Freq Rel Total',
	AVG(CAST(Cliente_Ativo AS FLOAT) ) AS 'Churn',
	'LimiteCartão' AS Variável
FROM
	#fato_churn_flag_completo_henrique_matsushita
GROUP BY 
	FaixaLimiteCredito
ORDER BY 
	FaixaLimiteCredito  ASC	
	
	
-- Criando Tabela Com Todas As Variáveis Ordenada pelo Churn

DROP TABLE IF EXISTS #fato_churn_Churn_Variaveis_henrique_matsushita	
-- USA CARTAO DE CREDITO
SELECT
	CAST (Usa_Cartao_Credito AS VARCHAR) AS Categoria,
	AVG(CAST(Cliente_Ativo AS FLOAT) ) AS 'Churn',
	'Usa Cartão de Crédito' AS Variável
INTO
	#fato_churn_Churn_Variaveis_henrique_matsushita	
FROM
	#fato_churn_flag_completo_henrique_matsushita

GROUP BY 
	Usa_Cartao_Credito 

	
UNION
	
-- ESTADO
SELECT
	Estado  AS Categoria,
	AVG(CAST(Cliente_Ativo AS FLOAT) ) AS 'Churn',
	'Estado' AS Variável
FROM
	#fato_churn_flag_completo_henrique_matsushita
GROUP BY 
	Estado 	
	
UNION

-- GÊNERO
SELECT
	Gênero  AS Categoria,
	AVG(CAST(Cliente_Ativo AS FLOAT) ) AS 'Churn',
	'Gênero' AS Variável
FROM
	#fato_churn_flag_completo_henrique_matsushita
GROUP BY 
	Gênero		
	
UNION 

-- TEMPO CLIENTE
SELECT
	CAST (Tempo_Cliente AS VARCHAR)  AS Categoria,
	AVG(CAST(Cliente_Ativo AS FLOAT) ) AS 'Churn',
	'Tempo Cliente' AS Variável
FROM
	#fato_churn_flag_completo_henrique_matsushita
GROUP BY 
	Tempo_Cliente

	
UNION 

-- CATEGORIAS
SELECT
	CAST (Qte_Categorias AS VARCHAR)  AS Categoria,
	AVG(CAST(Cliente_Ativo AS FLOAT) ) AS 'Churn',
	'Categorias' AS Variável
FROM
	#fato_churn_flag_completo_henrique_matsushita
GROUP BY 
	Qte_Categorias


UNION 

-- PROGRAMA DE FIDELIDADE
SELECT
	CAST (Programa_Fidelidade AS VARCHAR)  AS Categoria ,
	AVG(CAST(Cliente_Ativo AS FLOAT) ) AS 'Churn',
	'Programa Fidelidade' AS Variável
FROM
	#fato_churn_flag_completo_henrique_matsushita
GROUP BY 
	Programa_Fidelidade

	
UNION	
-- USA CARTÃO DE CRÉDITO
SELECT
	CAST(Usa_Cartao_Credito AS VARCHAR)   AS Categoria,
	AVG(CAST(Cliente_Ativo AS FLOAT) ) AS 'Churn',
	'Usa Cartão de Crédito' AS Variável
FROM
	#fato_churn_flag_completo_henrique_matsushita
GROUP BY 
	Usa_Cartao_Credito  

	
UNION	

-- FAIXA ETÁRIA
SELECT
	FaixaEtária   AS Categoria,
	AVG(CAST(Cliente_Ativo AS FLOAT) ) AS 'Churn',
	'Faixa Etária' AS Variável
FROM
	#fato_churn_flag_completo_henrique_matsushita
GROUP BY 
	FaixaEtária  


UNION 

-- FAIXA SCORE
SELECT
	FaixaScore  AS Categoria ,
	AVG(CAST(Cliente_Ativo AS FLOAT) ) AS 'Churn',
	'Faixa Score' AS Variável
FROM
	#fato_churn_flag_completo_henrique_matsushita
GROUP BY 
	FaixaScore 

	
UNION
	
-- FAIXA LimiteCartão
SELECT
	FaixaLimiteCredito  ,
	AVG(CAST(Cliente_Ativo AS FLOAT) ) AS 'Churn',
	'LimiteCartão' AS Variável
FROM
	#fato_churn_flag_completo_henrique_matsushita
GROUP BY 
	FaixaLimiteCredito
ORDER BY 
	AVG(CAST(Cliente_Ativo AS FLOAT) ) DESC

-- Selecioando as categorias que possuem os 5 Menores Churn
	
SELECT TOP 10
	*
FROM
	#fato_churn_Churn_Variaveis_henrique_matsushita	
ORDER BY 
	Churn ASC

-- Selecioando as categorias que possuem os 5 Maiores Churn
	
SELECT TOP 10
	*
FROM
	#fato_churn_Churn_Variaveis_henrique_matsushita	



SELECT
	*
FROM 
	#fato_churn_flag_completo_henrique_matsushita
	
-- Criando Perfis
SELECT
	*,
	CASE WHEN Idade>40 AND Limite_Credito_Mercado>1000 AND Programa_Fidelidade = 0 THEN 'Perfil Alto Churn'
		 WHEN Idade<=40 AND Qte_Categorias=2 AND Programa_Fidelidade = 0 THEN 'Perfil Baixo Churn'
		 ELSE 'Padrão'
	END AS 'Perfil CLiente'
FROM 
	#fato_churn_flag_completo_henrique_matsushita
	
-- Verificando Churn Por Perfil Criado
-- Lembrando que o Churn geral é de 20%
SELECT
	CASE WHEN Idade>40 AND Limite_Credito_Mercado>1000 AND Programa_Fidelidade = 0 THEN 'Perfil Alto Churn'
		 WHEN Idade<=40 AND Qte_Categorias=2 AND Programa_Fidelidade = 0 THEN 'Perfil Baixo Churn'
		 ELSE 'Padrão'
	END AS 'Perfil CLiente',
	AVG (CAST(Cliente_Ativo AS FLOAT)) AS 'Churn'
FROM 
	#fato_churn_flag_completo_henrique_matsushita
GROUP BY
	CASE WHEN Idade>40 AND Limite_Credito_Mercado>1000 AND Programa_Fidelidade = 0 THEN 'Perfil Alto Churn'
		 WHEN Idade<=40 AND Qte_Categorias=2 AND Programa_Fidelidade = 0 THEN 'Perfil Baixo Churn'
		 ELSE 'Padrão'
	END
ORDER BY 
	Churn ASC


