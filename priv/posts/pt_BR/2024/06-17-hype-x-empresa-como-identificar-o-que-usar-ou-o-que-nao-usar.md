%{
  title: "Empresa x Hype: Como identificar o que usar ou o que não usar",
  author: "Iago Cavalcante",
  tags: ~w(company),
  description: "Neste artigo vamos abordar como o hype pode afetar empresas negativamente",
  locale: "pt_BR",
  published: true
}
---

# Caso de Sucesso: Redução de Custos e Simplificação de Infraestrutura com Fly.io

Recentemente, acompanhei a jornada de um cliente que já estava há mais de dois anos utilizando o ecossistema da AWS, com um gasto médio de cerca de três mil reais por mês. A decisão inicial de migrar para a AWS foi motivada pela percepção de um sistema robusto, capaz de suportar altos volumes de requisições e escalabilidade. Entretanto, isso resultou na criação de uma infraestrutura complexa, com diversos serviços, mas mantida por uma equipe de desenvolvimento composta por apenas uma pessoa, além de freelancers.

A consultoria responsável pela migração para a AWS entregou uma estrutura extremamente robusta, que exigia um conhecimento mínimo em DevOps. Essa complexidade tornou a gestão e a implementação de novas funcionalidades um grande desafio para uma equipe tão pequena, além de implicar em altos custos.

Meu papel como consultor foi encontrar a melhor relação custo-benefício para o momento, otimizando os ciclos de entrega e reduzindo os custos de infraestrutura, ao mesmo tempo que tornava a gestão mais fácil. Decidimos migrar a infraestrutura da AWS para um serviço de Platform as a Service (PaaS), como a Fly.io. Essa escolha nos permitiu, em poucos passos, configurar máquinas escaláveis, monitoramento eficiente e um CLI simples. Além disso, a latência foi reduzida com servidores em São Paulo e Rio de Janeiro.

### Processo de Migração

A migração dos sistemas da AWS para duas organizações na Fly.io – uma de produção e outra de homologação – levou aproximadamente três semanas. A decisão de separar os ambientes visava um melhor controle de custos e maior visibilidade. Com máquinas em homologação que podem ser desligadas em momentos específicos e ativadas apenas para testes, os gastos mensais foram reduzidos para menos de 20 dólares. Esses sistemas incluíam banco de dados, SSO, serviço de processamento para sincronismo local-nuvem, APIs para controle de licença, entre outros, totalizando cerca de 10 máquinas.

### Resultados Alcançados

Ao final do primeiro mês, a economia foi de 2.500 reais. A simplicidade da Fly.io permitiu que, com poucos cliques, pudéssemos acessar logs e dashboards, cada aplicação contando com monitoramento via Grafana. Com uma equipe reduzida, todos passaram a ter visibilidade e entendimento do que acontece no ecossistema, facilitando a gestão e a manutenção.

### Padronização e Escalabilidade

Para lidar com a necessidade de alta escalabilidade, optei por construir um monolito utilizando Elixir, unificando vários serviços em domínios dentro da API em Elixir. Durante o processo, encontrei e resolvi um bug na biblioteca MyXQL ao subir a API na Fly.io ([link para o bug](https://github.com/elixir-ecto/myxql/pull/183)).

Além disso, para garantir uma experiência consistente e profissional, padronizamos os projetos e contratamos um designer para desenvolver um dashboard para uso dos clientes.

### Conclusão

A migração para a Fly.io não só reduziu drasticamente os custos, mas também simplificou a gestão da infraestrutura, tornando-a mais acessível para uma equipe pequena. A escolha de tecnologias como Elixir para construir um sistema monolítico e escalável, aliado a uma padronização de projetos e um design intuitivo, permitiu um avanço significativo na eficiência e na qualidade dos serviços oferecidos.
