---Etapa 3: Passo 2 - fazer os cálculos mensais usando a tabela total_transfers. Será necessário criar CTEs.

--Informações necessárias:
--month
--customer_id
--full_name
--total_transfer_in = entrada de dinheiro no mês
--total_transfer_out = saída de dinheiro no mês
--account_monthly_balance = saldo mensal da conta / terão meses sem transação, mas será mostrado.

---Primeiro CTE ->todos os meses do 1 ao 12

WITH all_months AS
(
SELECT
DISTINCT
  month
FROM
  `Projeto_Final_SQL.total_transfers`
),

---Segundo CTE -> total de entradas = transferências recebidas pix e não pix

total_transfer_in AS
(
SELECT
  month,
  customer_id,
  full_name,
  COALESCE(SUM(amount),0) AS total_transfer_in
FROM
  `Projeto_Final_SQL.total_transfers`
WHERE 
  type_transaction IN ('pix_in','transfer_ins')
GROUP BY
  1,2,3
),

---Terceiro CTE ->total de saídas = transf enviadas pix e não pix

total_transfer_out AS
(
SELECT
  month,
  customer_id,
  full_name,
  COALESCE(SUM(amount),0) AS total_transfer_out
FROM
  `Projeto_Final_SQL.total_transfers`
WHERE 
  type_transaction IN ('pix_out','transfer_outs')
GROUP BY
  1,2,3
),

---Combinar todas as tabelas e normalizar os dados em colunas lado a lado de transfer in e transfer out

transfers_all AS
(
SELECT
  a.month,
  c.customer_id,
  c.full_name,
  COALESCE(tti.total_transfer_in,0) AS total_transfer_in,
  COALESCE(tto.total_transfer_out,0) AS total_transfer_out,
FROM
  all_months a
CROSS JOIN
  (SELECT DISTINCT customer_id,full_name FROM total_transfer_in) c
  LEFT JOIN total_transfer_in tti ON a.month = tti.month AND c.customer_id = tti.customer_id
  LEFT JOIN total_transfer_out tto ON a.month = tto.month AND c.customer_id = tto.customer_id

)

---SELECT COUNT(DISTINCT customer_id) FROM transfers_all--- 3988 customer_id que fizeram transações, de um total de 3997 clientes

---Calcular o saldo acumulado mensal com uso de função de agregação de janela partition by

SELECT
  month,
  customer_id,
  full_name,
  ROUND(total_transfer_in,2) AS total_transfer_in,
  ROUND(total_transfer_out,2) AS total_transfer_out,
  ROUND(SUM(total_transfer_in - total_transfer_out) OVER (PARTITION BY customer_id ORDER BY month),2) AS saldo_mensal 
FROM
  transfers_all
ORDER BY
  full_name, month;

---Essa consulta processa 22,84mb quando realizada / 1s de tempo decorrido / 22s tempo de slot consumido / 16,51 MB embaralhados / 0B espalhados para o disco.