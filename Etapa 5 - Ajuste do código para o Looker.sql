CREATE OR REPLACE TABLE 
  `Projeto_Final_SQL.total_transfers1`
AS

(SELECT
  transaction_id,
  customer_id,
  full_name,
  account_id,
  amount,
  status,
  type_transaction,
  date_completed,
  month,
  account_status,
  state

FROM
(
-->seleção de dados necessários da tabela pix:
SELECT 
DISTINCT
  p.id AS transaction_id,
  a.customer_id, --localizada na tabela de accounts
  CONCAT(c.first_name,' ',c.last_name) AS full_name,--localizada na tabela de customer
  p.account_id,
  pix_amount AS amount,
  p.status,
  p.in_or_out AS type_transaction,
   DATE(action_timestamp) AS date_completed,-->devemos filtrar o período entre jan/2020 e dez/2020 / localizada na tabela time
  EXTRACT(MONTH FROM DATE(action_timestamp)) AS month, --month extraído da própria coluna de date_completed da tabela time
  a.status AS account_status,--status das contas para análise dos clientes no relatório
  state.state --dado de localização para análise geográfica de clientes e transações no relatório
FROM 
  `Projeto_Final_SQL.pix_movements` p 
LEFT JOIN --usamos essa junção pq queremos somente as informações que estão também na pix movements
  `Projeto_Final_SQL.accounts` a ON p.account_id = a.account_id
LEFT JOIN 
  `Projeto_Final_SQL.customers` c ON a.customer_id = c.customer_id
LEFT JOIN
`Projeto_Final_SQL.city` city ON city.city_id = c.customer_city
LEFT JOIN
`Projeto_Final_SQL.state` state ON state.state_id = city.state_id
LEFT JOIN
  `Projeto_Final_SQL.time` t ON p.pix_completed_at = t.time_id
WHERE 
  p.status = 'completed' AND DATE(action_timestamp) BETWEEN '2020-01-01' AND '2020-12-31'

UNION ALL --necessário que todas as 3 tabelas tenham as mesmas colunas
-->seleção de dados necessários da tabela transfer_in na mesma ordem da tabela pix para facilitar união dos dados

SELECT 
DISTINCT
  i.id AS transaction_id,
  a.customer_id,--customer_id só tem na tabela accounts
  CONCAT(c.first_name,' ',c.last_name) AS full_name,--localizada na tabela de customer
  i.account_id,
  i.amount,
  i.status,
  'transfer_ins' AS type_transaction, --criação de nova coluna com o tipo de transação, sabendo que essa tabela é somente de entrada de dinheiro,
  DATE(action_timestamp) AS date_completed,
  EXTRACT(MONTH FROM DATE(action_timestamp)) AS month,
  a.status AS account_status,
  state.state
FROM 
  `Projeto_Final_SQL.transfer_ins` i
LEFT JOIN
  `Projeto_Final_SQL.accounts` a ON i.account_id = a.account_id
LEFT JOIN
  `Projeto_Final_SQL.customers`c ON a.customer_id = c.customer_id
LEFT JOIN
`Projeto_Final_SQL.city` city ON city.city_id = c.customer_city
LEFT JOIN
`Projeto_Final_SQL.state` state ON state.state_id = city.state_id
LEFT JOIN
  `Projeto_Final_SQL.time`t ON i.transaction_completed_at = t.time_id
WHERE 
i.status = 'completed' AND DATE(action_timestamp) BETWEEN '2020-01-01' AND '2020-12-31'

UNION ALL
-->seleção de dados necessários da tabela transfer_outs na mesma ordem que anteriores:

SELECT
DISTINCT
  o.id AS transaction_id,
  a.customer_id,
  CONCAT(c.first_name,' ',c.last_name) AS full_name,
  o.account_id,
  o.amount,
  o.status,
  'transfer_outs' AS type_transaction,
  DATE(action_timestamp) AS date_completed,
  EXTRACT(MONTH FROM DATE(action_timestamp)) AS month,
  a.status AS account_status,
  state.state
FROM 
  `Projeto_Final_SQL.transfer_outs` o
LEFT JOIN
  `Projeto_Final_SQL.accounts` a ON o.account_id = a.account_id
LEFT JOIN
  `Projeto_Final_SQL.customers`c ON a.customer_id = c.customer_id
LEFT JOIN
`Projeto_Final_SQL.city` city ON city.city_id = c.customer_city
LEFT JOIN
`Projeto_Final_SQL.state` state ON state.state_id = city.state_id
LEFT JOIN
  `Projeto_Final_SQL.time`t ON o.transaction_completed_at = t.time_id
WHERE 
o.status = 'completed' AND DATE(action_timestamp) BETWEEN '2020-01-01' AND '2020-12-31'));
