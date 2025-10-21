---Etapa 4 - melhoria do código do saldo mensal

---Primeiro CTE ->todos os meses do 1 ao 12

WITH all_months AS
(
SELECT
DISTINCT
  month
FROM
  `Projeto_Final_SQL.total_transfers`
),

---Segundo CTE -> cacular entradas e saídas em uma única CTE

transfers_combined AS
(
SELECT
  month,
  customer_id,
  full_name,
  SUM(CASE WHEN type_transaction IN ('pix_in', 'transfers_in') THEN amount ELSE 0 END) AS total_transfer_in,
  SUM(CASE WHEN type_transaction IN ('pix_out', 'transfers_outs') THEN amount ELSE 0 END) AS total_transfer_out
FROM
  `Projeto_Final_SQL.total_transfers`
WHERE 
  type_transaction IN ('pix_in','transfer_ins')
GROUP BY
  1,2,3
),

---Combinar todas as tabelas e normalizar os dados em colunas lado a lado de transfer in e transfer out -> combinar todos os meses com todos os clientes

transfers_all AS
(
SELECT
  m.month,
  c.customer_id,
  c.full_name,
  COALESCE(tc.total_transfer_in, 0) AS total_transfer_in,
  COALESCE(tc.total_transfer_out, 0) AS total_transfer_out
FROM
  all_months m
CROSS JOIN
  (SELECT DISTINCT customer_id,full_name FROM transfers_combined) c
LEFT JOIN transfers_combined tc ON m.month = tc.month AND c.customer_id = tc.customer_id
)

---Calcular o saldo acumulado mensal com uso de função de agregação de janela partition by -> calcular o saldo mensal acumulado por cliente

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