# **Projeto Transações Financeiras** 💵

## Resumo

  Criação de query em SQL para obter saldos mensais das contas de clientes e de dashboard no Looker Studio para análise do comportamento financeiro.


[Notebook com desenvolvimento em SQL]()

[Scripts em SQL]()

[Relatório - Análise de transações Financeiras]()

A seguir descrevo o passo a passo da resolução desse projeto.

## Índice 

- [1. Contexto]()
- [2. Ferramentas utilizadas]()
- [3. Etapas da análise]()
- [4. Produtos do projeto]()
- [5. Principais insights]()
- [6. Conclusão]()


## 1. Contexto

Uma Analista de Negócios do Banco XPTO, responsável pela análise do comportamento financeiro dos clientes, precisa obter os dados do Ambiente de Data Warehouse referentes aos  saldos mensais de Janeiro a Dezembro de 2020. Além das tabelas de tempo (d_time, d_year, d_month, d_week, d_weekday), localização (city, state, country), contas (accounts) e clientes (customers), três tabelas armazenam os movimentos financeiros das contas:

- transfer_ins: Transferências não PIX recebidas em uma conta.
- transfer_outs: Transferências não PIX enviadas de uma conta.
- pix_movements: Transferências PIX, que podem ser recebidas (pix_in) ou enviadas de uma conta (pix_out).


Para chegar no valor de saldo mensal por cliente, é necessário agrupar dados presentes em diferentes tabelas de tempo, localização, contas, clientes e movimentos financeiros. O Saldo Mensal da Conta é o valor em dinheiro que o cliente possui na conta ao final do mês. Esse valor é calculado usando a soma de todos os valores recebidos, subtraindo todos os valores enviados e acrescentando ou subtraindo o saldo acumulado do mês anterior. 

**Ela pediu então para a Giulia, analista de dados responsável, criar uma query em SQL para ajudá-la a compilar esses dados em uma tabela única. Além disso, pediu um relatório de análise das transações financeiras a partir desse compilado, com os principais indicadores a serem apresentados para a gerência do setor.** 

A arquitetura de dados do Banco XPTO funciona da seguinte forma:


<img width="642" height="357" alt="image" src="https://github.com/user-attachments/assets/cda4b051-42e0-4320-ba1d-fcfe9c7fbc51" />


Dados armazenados no Data Warehouse e ligações entre as tabelas:

<img width="642" height="400" alt="image" src="https://github.com/user-attachments/assets/9d81349b-790e-4c6d-8e4e-ba63fbaf0a75" />


Os dados são fictícios e obtidos através da plataforma de ensino EBA Renata Biaggi.


## 2. Ferramentas utilizadas

- SQL
- Google BigQuery
- Looker Studio
- Estatística descritiva

## 3. Etapas da análise

O projeto foi desenvolvido por etapas usando técnicas de extração, transformação e upload dos dados (ETL), linguagem SQL, análise exploratória dos dados (EDA), recursos para visualização (gráficos, tabelas, mapas) e estatística descritiva.

<ins>3.1 Exploração dos dados:</ins> Exploração univariada inicial das planilhas em Excel para entender os tipos de variável, investigar valores únicos, verificar valores ausentes ou nulos e a qualidade dos dados. Essa etapa é fundamental para a organização dos dados e qualidade das análises subsequentes. Resultado da avaliação das tabelas recebidas:

<img width="302" height="235" alt="image" src="https://github.com/user-attachments/assets/ce4360be-e2cc-40c9-8c06-c9dab6e225d9" />



<ins>3.2 Upload dos dados e validação:</ins> Carregar os conjuntos de dados no BigQuery, validar se as tabelas geradas possuem equivalência de registros com os arquivos em excel, verificar o esquema e tipo de dados em cada uma. Para essa validação, foram feitas queries em SQL com comandos simples como SELECT e COUNT.

<ins>3.3 Criação de uma tabela única:</ins> Para construir o saldo mensal por cliente, são necessárias informações provenientes de todas as bases. Foi testado inicialmente a junção entre tabelas usando FULL JOIN e INNER JOIN, mas o tempo de processamento e uso de memória foram altos. Nesse caso, o próprio BigQuery indicou a criação de uma tabela para otimizar a performance. Esse processo também facilitará a etapa posterior de confecção do relatório. Por isso, optou-se por combinar todas as transferências (entrada, saída e pix) em uma única tabela chamada *total_transfers*.

<ins>3.4 Cálculo de saldos mensais por cliente:</ins> A partir da tabela única total_transfers é possível extrair por cliente o valor total recebido na conta, o valor total enviado para outras contas e o mês da transação. Como as entradas e saídas de dinheiro podem ter mais de um tipo, por serem realizadas através de pix ou não, foram criadas tabelas temporárias (CTE) para agrupar essas transações por tipo. Ao final, as CTE de total de entradas, saídas e mês foram combinadas entre si usando CROSS JOIN e o cálculo por cliente realizado com agregação de WINDOW FUNCTION. Essa consulta processou 22,84MB quando realizada, 1s de tempo decorrido, 22s de tempo de slot consumido, 16,51 MB embaralhados e 0B espalhados para o disco.
	
<ins>3.5 Melhorias no código:</ins> Como boa prática, a query foi revisada buscando otimização, legibilidade e melhor performance. Alguns pontos reavaliados foram o uso redundante de DISTINCT, repetição de datas em filtros e comandos, alias sem explicação clara no código, quantidade de tabelas temporárias criadas e alto número de registros na tabela total_transfers criada (475.639 linhas), o que pode dificultar análises futuras e a etapa seguinte de visualização dos dados. Após aplicação das melhorias foi criada a tabela total_transfers1, o processamento foi reduzido para 386ms de tempo de slot consumido e 5,39MB embaralhados. 
	
<ins>3.6 Confecção do relatório de análise de transações financeiras:</ins> O relatório foi desenvolvido no Looker Studio usando a tabela otimizada *total_transfers1* nativa do BigQuery como fonte de dados. Ele foi pensado para ser um relatório objetivo e claro, por isso está segmentado em uma visão geral de todas as transações realizadas por tipo(pix/não pix/entrada/saída), possui uma lista indicando valores transacionados por cada cliente, status da conta (ativo/inativo) e distribuição geográfica dos clientes e transações. Também há uma breve análise sobre o perfil de clientes da base de dados, de acordo com a proporção entre valores enviados e recebidos.

## 4. Produtos do projeto

[Notebook com desenvolvimento em SQL]()

[Scripts em SQL]()

[Relatório - Análise de transações Financeiras]()

## 5. Principais insights

- A etapa de validação dos dados é relativamente simples, mas muito importante para preceder qualquer análise. A validação dos dados após processo ETL no BigQuery assegura que todos os registros foram devidamente carregados, que não houve alteração dos valores originais e que o formato e tipo dos dados está correto. Essa etapa garante confiabilidade da análise, precisão dos dados que irão embasar as decisões de negócio e reduz retrabalhos.
  
- Manter uma sequência lógica ao fazer uma query em SQL e revisá-la ponto a ponto é crucial no desenvolvimento de projetos em dados. Nesse projeto houve um ganho significativo em desempenho após fazer alterações simples no código. Além da formatação da query para torná-la mais legível, o que reduz tempo de manutenção e facilita o uso por outros analistas.

- A distribuição dos valores transacionados por pix e transferências bancárias convencionais foi praticamente a mesma durante todo o período avaliado, cada um equivale a 50% do valor total transacionado. Isso indica que não houve uma preferência maior por pix ou transferência convencional pelos clientes.

- O total de dinheiro transacionado foi de R$ 476,2 milhões. Desse montante, R$ 333,98 milhões são referentes a entrada de dinheiro nas contas, correspondente a aproximadamente 70% do total. Enquanto que a saída de dinheiro foi de R$ 142,24 milhões, em torno de 30%. O ticket médio por transação ficou em torno de R$ 1.000,00 e a média geral de movimentações realizadas por cliente foi de 119.

- O estado de Minas Gerais foi o que mais teve valores transacionados, tanto entrada como saída. Logo em seguida aparecem os estados de São Paulo e do Rio Grande do Sul. As movimentações realizadas por clientes de Minas Gerais totalizaram R$ 65,6 milhões. Quando somamos a movimentação financeira dos clientes dos três estados, o valor é de R$ 163,27 milhões, equivalente a 34% do total geral transacionado (R$ 476,2 milhões). Os três estados juntos possuem 1366 clientes, que equivalem também a 34% do total de clientes ativos (3967).

## 6. Conclusão

A avaliação da evolução mensal de entrada e saída de dinheiro se mantém relativamente estável ao longo do período. Não há variações bruscas ou picos acentuados, o que pode sugerir que os clientes mantiveram uma receita regular ao longo do ano, com saldo positivo contínuo mês a mês. Os clientes movimentam dinheiro com frequência e constância. 

O comportamento das transações sugere que o perfil médio dos clientes é equilibrado. Isso é interessante para oferecer a esses clientes produtos e soluções adequadas a um perfil mais moderado, como investimentos de baixo risco e retorno estável. 

Uma sugestão para análises futuras é avaliar quais produtos e soluções financeiras do Banco XPTO estão atrelados a essa base de clientes para conseguir uma melhor avaliação de perfil e assim identificar oportunidades de aumento de receita com produtos melhor direcionados para cada perfil.  
