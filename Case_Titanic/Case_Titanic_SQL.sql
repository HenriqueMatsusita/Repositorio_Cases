SELECT 
	*
FROM 
	titanic

-- Identificando valores NULL 
SELECT
	COUNT(1)- COUNT(PassengerId) AS 'Id Passageiro',
	COUNT(1)- COUNT(Survived) AS 'Sobreviveu',
	COUNT(1)- COUNT(Pclass) AS 'Classe',
	COUNT(1)- COUNT(Name) AS 'Nome',
	COUNT(1)- COUNT(Sex) AS 'Sexo',
	COUNT(1)- COUNT(Age) AS 'Idade',
	COUNT(1)- COUNT(SibSp) AS 'SibSp',
	COUNT(1)- COUNT(Parch) AS 'Parch',
	COUNT(1)- COUNT(Ticket) AS 'Ticket',
	COUNT(1)- COUNT(Fare) AS 'Pre�o',
	COUNT(1)- COUNT(Cabin) AS 'Cabine',
	COUNT(1)- COUNT(Embarked) AS 'Embarcou'	
FROM
	titanic t 

	
-- Histograma das vari�veis qualitativas

-- Sobreviventes
SELECT
	Survived,
	COUNT(Survived)
FROM
	titanic 
GROUP BY
	Survived

-- Classe
SELECT
	PClass,
	COUNT(Pclass)
FROM
	titanic 
GROUP BY
	Pclass
ORDER BY
	Pclass

-- Sexo
SELECT
	Sex,
	COUNT(Sex)
FROM
	titanic 
GROUP BY
	Sex

-- Embarcou
SELECT
	Embarked,
	COUNT(Embarked)
FROM
	titanic 
WHERE 
	Embarked IS NOT NULL
GROUP BY
	Embarked
ORDER BY
	Embarked 
	
-- Medidas Resumo das Vari�veis Quantitativas

-- Idade
SELECT 
	'Idade' AS 'Vari�vel',
	SUM(Age) AS 'Soma',
	COUNT(Age) AS 'Contagem',
	AVG(Age) AS 'M�dia',
	MIN(Age) AS 'M�nimo',
	MAX(Age) AS 'M�ximo',
	STDEVP(Age) AS 'Desvio Padr�o'
FROM
	titanic t 

-- Pre�o
SELECT 
	'Pre�o' AS 'Vari�vel',
	SUM(Fare) AS 'Soma',
	COUNT(Fare) AS 'Contagem',
	AVG(Fare) AS 'M�dia',
	MIN(Fare) AS 'M�nimo',
	MAX(Fare) AS 'M�ximo',
	STDEVP(Fare) AS 'Desvio Padr�o'
FROM
	titanic t 

-- Corre��o da Vari�vel Idade
-- Criand Faixa Et�ria (SUBQUERYS e Tabelas Tempor�rias)

SELECT
	*,
	CASE WHEN Age>100 THEN Age/10
		 ELSE Age
	END AS Age_Tratada
FROM 
	titanic

DROP TABLE IF EXISTS #tabela_age_tratada_hkm
SELECT
	*,
	CASE WHEN Age_Tratada IS NULL THEN NULL
		 WHEN Age_Tratada<10 THEN 'A-0 a 9 Anos'
		 WHEN Age_Tratada<20 THEN 'B-10 a 19 Anos'
		 WHEN Age_Tratada<30 THEN 'C-20 a 29 Anos'
		 WHEN Age_Tratada<40 THEN 'D-30 a 39 Anos'
		 WHEN Age_Tratada<50 THEN 'E-40 a 49 Anos'
		 WHEN Age_Tratada<60 THEN 'F-50 a 59 Anos'
		 WHEN Age_Tratada<70 THEN 'G-60 a 69 Anos'
		 WHEN Age_Tratada<-100 THEN 'H-Acima DE 70 Anos'
		 ELSE 'Z-Checar'
	END AS Faixa_Et�ria
INTO
	#tabela_age_tratada_hkm
FROM
	(SELECT
		*,
		CASE WHEN Age>100 THEN Age/10
		 ELSE Age
		END AS Age_Tratada
	FROM 
		titanic 
	) AS titanic_age_tratada
	
-- Histograma
SELECT
	Faixa_Et�ria,
	COUNT(Faixa_Et�ria) 
FROM
	#tabela_age_tratada_hkm
GROUP BY
	Faixa_Et�ria
ORDER BY 
	COUNT(Faixa_Et�ria) DESC
	
-- Calcular IV Entre Vari�veos Qualitativas x Sobreviveu?
	
-- Pclass x Survived	
-- SUBQUERYS Auxiliares
SELECT SUM(CAST (Survived AS FLOAT)) FROM #tabela_age_tratada_hkm
SELECT COUNT(Survived)-SUM(CAST (Survived AS FLOAT)) FROM #tabela_age_tratada_hkm	

-- IV
DROP TABLE IF EXISTS #tabela_IV_Pclass_hkm
SELECT 
	Pclass,
	SUM(CAST (Survived AS FLOAT)) AS 'Sobreviveu',
	SUM(CAST (Survived AS FLOAT))/(SELECT SUM(CAST (Survived AS FLOAT)) FROM #tabela_age_tratada_hkm) AS 'fre_Rel_Sobreviveu',
	COUNT(Survived)-SUM(CAST (Survived AS FLOAT)) AS 'N�o Sobreviveu',
	(COUNT(Survived)-SUM(CAST (Survived AS FLOAT)))/(SELECT COUNT(Survived)-SUM(CAST (Survived AS FLOAT)) FROM #tabela_age_tratada_hkm) AS 'fre_Rel_N�o_Sobreviveu',
	COUNT(Survived) AS Freq_Absoluta,
	SUM(CAST (Survived AS FLOAT))/COUNT(Survived) AS 'Tx_Sobreviv�ncia',
	SUM(CAST (Survived AS FLOAT))/(COUNT(Survived)-SUM(CAST (Survived AS FLOAT))) AS 'ODDS',
	LOG(SUM(CAST (Survived AS FLOAT))/(COUNT(Survived)-SUM(CAST (Survived AS FLOAT)))) AS 'LN_ODDS',
	((SUM(CAST (Survived AS FLOAT))/(SELECT SUM(CAST (Survived AS FLOAT)) FROM #tabela_age_tratada_hkm))-((COUNT(Survived)-SUM(CAST (Survived AS FLOAT)))/(SELECT COUNT(Survived)-SUM(CAST (Survived AS FLOAT)) FROM #tabela_age_tratada_hkm)))
	*(LOG(SUM(CAST (Survived AS FLOAT))/(COUNT(Survived)-SUM(CAST (Survived AS FLOAT))))) AS 'IV'
INTO
	#tabela_IV_Pclass_hkm
FROM 
	#tabela_age_tratada_hkm
GROUP BY
	Pclass
ORDER BY 	
	Pclass

-- TABELA IV	
SELECT 	
	*
FROM 	
	#tabela_IV_Pclass_hkm
ORDER BY 	
	Pclass
	
-- SOMA DO IV	
SELECT 
	SUM(IV) AS 'Soma_IV'
FROM
	#tabela_IV_Pclass_hkm

-- Sexo x Survived	
-- SUBQUERYS Auxiliares
SELECT SUM(CAST (Survived AS FLOAT)) FROM #tabela_age_tratada_hkm
SELECT COUNT(Survived)-SUM(CAST (Survived AS FLOAT)) FROM #tabela_age_tratada_hkm	

-- IV
DROP TABLE IF EXISTS #tabela_IV_Sex_hkm
SELECT 
	Sex,
	SUM(CAST (Survived AS FLOAT)) AS 'Sobreviveu',
	SUM(CAST (Survived AS FLOAT))/(SELECT SUM(CAST (Survived AS FLOAT)) FROM #tabela_age_tratada_hkm) AS 'fre_Rel_Sobreviveu',
	COUNT(Survived)-SUM(CAST (Survived AS FLOAT)) AS 'N�o Sobreviveu',
	(COUNT(Survived)-SUM(CAST (Survived AS FLOAT)))/(SELECT COUNT(Survived)-SUM(CAST (Survived AS FLOAT)) FROM #tabela_age_tratada_hkm) AS 'fre_Rel_N�o_Sobreviveu',
	COUNT(Survived) AS Freq_Absoluta,
	SUM(CAST (Survived AS FLOAT))/COUNT(Survived) AS 'Tx_Sobreviv�ncia',
	SUM(CAST (Survived AS FLOAT))/(COUNT(Survived)-SUM(CAST (Survived AS FLOAT))) AS 'ODDS',
	LOG(SUM(CAST (Survived AS FLOAT))/(COUNT(Survived)-SUM(CAST (Survived AS FLOAT)))) AS 'LN_ODDS',
	((SUM(CAST (Survived AS FLOAT))/(SELECT SUM(CAST (Survived AS FLOAT)) FROM #tabela_age_tratada_hkm))-((COUNT(Survived)-SUM(CAST (Survived AS FLOAT)))/(SELECT COUNT(Survived)-SUM(CAST (Survived AS FLOAT)) FROM #tabela_age_tratada_hkm)))
	*(LOG(SUM(CAST (Survived AS FLOAT))/(COUNT(Survived)-SUM(CAST (Survived AS FLOAT))))) AS 'IV'
INTO
	#tabela_IV_Sex_hkm
FROM 
	#tabela_age_tratada_hkm
GROUP BY
	Sex
ORDER BY 	
	Sex

-- TABELA IV	
SELECT 	
	*
FROM 	
	#tabela_IV_Sex_hkm

	
-- SOMA DO IV	
SELECT 
	SUM(IV) AS 'Soma_IV'
FROM
	#tabela_IV_Sex_hkm
	
-- Faixa Et�ria x Survived	
-- SUBQUERYS Auxiliares
SELECT SUM(CAST (Survived AS FLOAT)) FROM #tabela_age_tratada_hkm
SELECT COUNT(Survived)-SUM(CAST (Survived AS FLOAT)) FROM #tabela_age_tratada_hkm	

-- IV
DROP TABLE IF EXISTS #tabela_IV_Faixa_Et�ria_hkm
SELECT 
	Faixa_Et�ria,
	SUM(CAST (Survived AS FLOAT)) AS 'Sobreviveu',
	SUM(CAST (Survived AS FLOAT))/(SELECT SUM(CAST (Survived AS FLOAT)) FROM #tabela_age_tratada_hkm) AS 'fre_Rel_Sobreviveu',
	COUNT(Survived)-SUM(CAST (Survived AS FLOAT)) AS 'N�o Sobreviveu',
	(COUNT(Survived)-SUM(CAST (Survived AS FLOAT)))/(SELECT COUNT(Survived)-SUM(CAST (Survived AS FLOAT)) FROM #tabela_age_tratada_hkm) AS 'fre_Rel_N�o_Sobreviveu',
	COUNT(Survived) AS Freq_Absoluta,
	SUM(CAST (Survived AS FLOAT))/COUNT(Survived) AS 'Tx_Sobreviv�ncia',
	SUM(CAST (Survived AS FLOAT))/(COUNT(Survived)-SUM(CAST (Survived AS FLOAT))) AS 'ODDS',
	LOG(SUM(CAST (Survived AS FLOAT))/(COUNT(Survived)-SUM(CAST (Survived AS FLOAT)))) AS 'LN_ODDS',
	((SUM(CAST (Survived AS FLOAT))/(SELECT SUM(CAST (Survived AS FLOAT)) FROM #tabela_age_tratada_hkm))-((COUNT(Survived)-SUM(CAST (Survived AS FLOAT)))/(SELECT COUNT(Survived)-SUM(CAST (Survived AS FLOAT)) FROM #tabela_age_tratada_hkm)))
	*(LOG(SUM(CAST (Survived AS FLOAT))/(COUNT(Survived)-SUM(CAST (Survived AS FLOAT))))) AS 'IV'
INTO
	#tabela_IV_Faixa_Et�ria_hkm
FROM 
	#tabela_age_tratada_hkm
GROUP BY
	Faixa_Et�ria
ORDER BY 	
	Faixa_Et�ria

-- TABELA IV	
SELECT 	
	*
FROM 	
	#tabela_IV_Faixa_Et�ria_hkm

	
-- SOMA DO IV	
SELECT 
	SUM(IV) AS 'Soma_IV'
FROM
	#tabela_IV_Faixa_Et�ria_hkm

	
-- AN�LISE DE DADOS
	
-- Pclass x Sexo
SELECT
	Pclass,
	Sex,
	SUM(CAST (Survived AS FLOAT)) AS 'Sobreviveu',
	COUNT(Survived)-SUM(CAST (Survived AS FLOAT)) AS 'N�o Sobreviveu',
	SUM(CAST (Survived AS FLOAT))/COUNT(Survived) AS 'Tx_Sobreviv�ncia'
FROM 
	#tabela_age_tratada_hkm
GROUP BY
	Pclass, Sex
ORDER BY
	Pclass, Sex
	
	
DROP TABLE IF EXISTS #tabela_analise_teste1
SELECT 
	Pclass,
	COUNT(Pclass) AS 'ContagemFemale'
INTO
	#tabela_analise_teste1
FROM
	#tabela_age_tratada_hkm
WHERE 
	Sex = 'female'
GROUP BY
	Pclass
ORDER BY
	Pclass

DROP TABLE IF EXISTS #tabela_analise_teste2
SELECT 
	Pclass,
	COUNT(Pclass) AS 'ContagemMale'
INTO
	#tabela_analise_teste2
FROM
	#tabela_age_tratada_hkm
WHERE 
	Sex = 'male'
GROUP BY
	Pclass
ORDER BY,
	Pclass
	
SELECT 
	t1.*,
	t2.ContagemMale,
	CAST(t1.ContagemFemale AS FLOAT)/(SELECT SUM(ContagemFemale) FROM #tabela_analise_teste1) AS 'Freq_rel_Female',
	CAST(t2.ContagemMale AS FLOAT)/(SELECT SUM(ContagemMale) FROM #tabela_analise_teste2) AS 'Freq_rel_Male',
	CAST(t2.ContagemMale AS FLOAT)/t1.ContagemFemale AS 'Prop_Male/Female'
FROM 
	#tabela_analise_teste1 t1 INNER JOIN #tabela_analise_teste2 t2
	ON t1.Pclass=t2.Pclass
	
-- Insights
-- 1 - Taxa de sobreviv�ncia das mulheres � muito superior ao dos homens, essa diferen�a pode se por conta de a mulher ter
-- prioridade para embarcar nos bote salva vidas
-- 2 - Taxa de sobreviv�cia de crian�as e idosos (70+) � superior as demais faixas et�rias,essa diferen�a pode se por conta 
-- de a crian�as e idosos terem prioridade para embarcar nos bote salva vidas
-- 3 - Taxa de sobrevivencia das pessoas que estavam de terceira classe � inferior ao das pessoas que estavam de primeira
-- e segunda classe, isso pode ser causado por dois fatores, primeiro, fato dos passageiros de terceira classe tere maior
-- dificuldade de acesso aos botes, segundo, pelo fato de haver uma maior propor��o (homem/mulher) do que em outras classes.
	