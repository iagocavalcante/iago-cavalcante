%{
  title: "Migração de api-desktop-processador para i9_processador: Decisões Arquiteturais e Lições Aprendidas",
  description: "Uma análise abrangente das decisões arquiteturais por trás da migração de um processador baseado em Java para uma aplicação moderna em Elixir Phoenix",
  tags: ~w(elixir phoenix java migração arquitetura i9amazon),
  published: true,
  locale: "pt_BR",
  author: "Iago Cavalcante"
}
---

# Migração de api-desktop-processador para i9_processador: Decisões Arquiteturais e Lições Aprendidas

Na evolução do ecossistema i9Amazon, uma das decisões arquiteturais mais significativas foi a migração do `api-desktop-processador` (baseado em Java) para o `i9_processador` (Elixir Phoenix). Esta migração representou não apenas uma mudança de tecnologia, mas um repensar fundamental de como lidamos com processamento de dados, sincronização e operações multi-tenant.

## Contexto: O Sistema Legado

O `api-desktop-processador` original foi construído como uma aplicação Java com as seguintes características:

- **Stack Tecnológico**: Java 8, Maven, Hibernate, MySQL
- **Arquitetura**: Aplicação jar monolítica com escalabilidade limitada
- **Dependências**: Grande dependência do JPA/Hibernate para acesso a dados
- **Deploy**: Deploy tradicional de jar com escalonamento manual

```xml
<!-- Dependências Java Legadas -->
<dependency>
    <groupId>org.hibernate</groupId>
    <artifactId>hibernate-core</artifactId>
    <version>5.4.10.Final</version>
</dependency>
<dependency>
    <groupId>mysql</groupId>
    <artifactId>mysql-connector-java</artifactId>
    <version>5.1.48</version>
</dependency>
```

Embora funcional, este sistema enfrentava várias limitações:
- Capacidades limitadas de processamento concorrente
- Procedimentos complexos de deploy e escalonamento
- Falta de padrões modernos de API web
- Arquitetura monolítica tornando adição de funcionalidades desafiadora
- Ações pesadas de escrita e leitura em disco
- Processamento sincrono diretamente na escrita de arquivos e operações de banco de dados usando os arquivos com `LOAD INFILE`

## A Nova Arquitetura: i9_processador

O novo `i9_processador` representa um redesign arquitetural completo:

### Evolução do Stack Tecnológico

**De Java para Elixir/Phoenix:**
- **Runtime**: Máquina Virtual BEAM com concorrência baseada no modelo de atores
- **Framework**: Phoenix 1.8
- **Linguagem**: Elixir 1.15+ com paradigmas de programação funcional
- **Dependências**: Ecossistema moderno e leve

```elixir
# Dependências Elixir Modernas
defp deps do
  [
    {:phoenix, "~> 1.8.0-rc.3"},
    {:phoenix_ecto, "~> 4.5"},
    {:ecto_sql, "~> 3.10"},
    {:oban, "~> 2.19"},           # Processamento de jobs em background
    {:ex_aws_s3, "~> 2.0"},      # Armazenamento em nuvem usando Tigris
    {:jose, "~> 1.11"},          # Manipulação de JWT
    {:pdf_generator, "~> 0.6.2"} # Geração de PDF
  ]
end
```

### Decisões Arquiteturais

#### 1. Estratégia de Banco de Dados Duplo

Uma das decisões mais críticas foi implementar uma arquitetura de banco de dados duplo:

```elixir
# PostgreSQL para dados modernos da aplicação e processamento de filas
config :i9_processador, I9Processador.RepoPostgres,
  adapter: Ecto.Adapters.Postgres

# MySQL para integração com sistema legado
config :i9_processador, I9Processador.RepoMysql,
  adapter: Ecto.Adapters.MyXQL
```

**Justificativa:**
- **PostgreSQL**: Banco primário para novas funcionalidades, processamento de jobs (Oban) e estruturas de dados modernas
- **MySQL**: Mantido para integração com sistema legado e dados empresariais existentes
- **Isolamento de Schema**: Isolamento de dados específicos por empresa usando padrão `_#{cnpj}`

#### 2. Processamento de Jobs em Background com Oban

Substituição do processamento síncrono por sistema robusto de jobs em background:

```elixir
# Configuração de jobs em background
config :i9_processador, Oban,
  repo: I9Processador.RepoPostgres,
  queues: [
    sync: 10,
    fv: 5,
    pdf: 3,
    transfer: 5
  ]
```

**Benefícios:**
- Processamento confiável de jobs com lógica de retry
- Gerenciamento de filas para diferentes domínios de negócio
- Persistência de jobs baseada em banco de dados
- Monitoramento e observabilidade integrados

#### 3. Arquitetura Multi-Tenant

Implementação de multi-tenancy baseado em CNPJ:

```elixir
# Padrão de acesso dinâmico a schema
def get_company_schema(cnpj) do
  "_#{cnpj}"
end

# Isolamento de dados específicos por empresa
def execute_for_company(cnpj, query) do
  schema = get_company_schema(cnpj)
  I9Processador.RepoMysql.query("USE #{schema}; #{query}")
end
```

**Benefícios de Segurança:**
- Isolamento completo de dados entre empresas
- Autenticação CNPJ + Token em todos os endpoints
- Controle de acesso baseado em módulos

#### 4. Infraestrutura Cloud-Native

Adoção de padrões modernos de deploy em nuvem:

```elixir
# Integração S3 para armazenamento de arquivos
config :ex_aws,
  access_key_id: {:system, "AWS_ACCESS_KEY_ID"},
  secret_access_key: {:system, "AWS_SECRET_ACCESS_KEY"},
  region: "us-east-1"
```

**Evolução do Deployment:**
- **De**: Deploy manual de jar em VMs
- **Para**: Contêineres Docker no Fly.io
- **Benefícios**: Auto-scaling, deploys zero-downtime, infraestrutura como código

#### 5. Design API-First

Transformação de ferramenta interna de processamento para plataforma de API abrangente:

```elixir
# Estrutura de API RESTful
scope "/api/v1", I9ProcessadorWeb do
  pipe_through :api

  get "/transferencia/:ente/:situacao/:dtIni/:dtFim", TransferenciaController, :consulta
  post "/transferencia", TransferenciaController, :create_or_update
end

# Endpoints especializados para diferentes domínios
scope "/sync", I9ProcessadorWeb do
  post "/upload/v3", SyncController, :upload
  get "/arquivos", SyncController, :list_files
end

scope "/fv", I9ProcessadorWeb do
  get "/v1/consultapedido/:type", FVController, :consulta_pedido
  post "/v1/enviapedido/:type", FVController, :envia_pedido
end
```

### Melhorias de Performance e Escalabilidade

#### Modelo de Concorrência

**Java (Antes):**
- Concorrência baseada em threads com escalabilidade limitada
- Pegada pesada de memória por conexão
- Gerenciamento complexo de threads

**Elixir (Depois):**
- Modelo de atores com processos leves
- Milhões de processos concorrentes possíveis
- Tolerância a falhas com filosofia "let it crash"

#### Eficiência de Memória

```elixir
# Uso de memória de processo Elixir
Process.info(self(), :memory)
# => {:memory, 2704} # bytes, não MB!

# Comparado com threads Java (vários MB cada)
```

#### Performance de Banco de Dados

- **Pool de Conexões**: Otimizado para PostgreSQL e MySQL
- **Otimização de Queries**: SQL raw para lógica de negócio complexa quando necessário
- **Operações em Massa**: Operações eficientes de `LOAD DATA INFILE` para sincronização de dados

### Melhorias nos Domínios de Negócio

#### 1. Sistema de Sincronização

**Funcionalidades Aprimoradas:**
- Sincronização de dados multi-loja
- Upload de arquivos com armazenamento no Storage na nuvem
- Processamento em background com lógica de retry
- Logging e monitoramento abrangentes

```elixir
# Endpoint moderno de sync com funcionalidades abrangentes
def upload_v3(conn, params) do
  with {:ok, company} <- validate_company(params),
       {:ok, file} <- handle_file_upload(params),
       {:ok, job} <- schedule_processing_job(file, company) do
    json(conn, %{status: "accepted", job_id: job.id})
  end
end
```

#### 2. Módulo Força de Vendas (FV)

**Novas Capacidades:**
- Suporte a aplicações mobile e desktop
- Gerenciamento de pedidos em tempo real
- Sincronização de dados de clientes
- Autenticação baseada em token por empresa

#### 3. Sistema de Geração de PDF

**Documentos Profissionais:**
- Templates de documentos empresariais brasileiros
- Suporte a múltiplos formatos (fatura, relatório, recibo)
- Estratégia de fallback: API Externa → wkhtmltopdf → HTML
- Gerenciamento eficiente de arquivos temporários

#### 4. Gerenciamento de Licenças

**Funcionalidades Empresariais:**
- Validação de token JWT usando JOSE
- Controle de acesso baseado em módulos
- Validação e ativação de licenças de empresa
- Integração com sistema de cobrança

## Estratégia de Migração e Lições Aprendidas

### 1. Abordagem de Migração de Dados

**Migração Incremental:**
- Mantido MySQL para acesso a dados legados
- Introduzido PostgreSQL para novas funcionalidades
- Migração gradual da lógica de negócio

### 2. Compatibilidade de API

**Compatibilidade Reversa:**
- Mantidos contratos de API existentes
- Introdução gradual de endpoints v2/v3
- Testes extensivos com scripts curl (41+ endpoints documentados)

### 3. Estratégia de Testes

```bash
# Abordagem abrangente de testes
mix test                    # Testes unitários
mix ecto.reset && mix test  # Testes de integração com reset de banco
```

### 4. Evolução do Deployment

**Infraestrutura como Código:**
```dockerfile
# Deploy moderno com Docker
FROM elixir:1.15-alpine
RUN apk add --no-cache wkhtmltopdf
COPY . /app
WORKDIR /app
RUN mix deps.get && mix compile
```

## Resultados de Performance

### Performance de Produção no Mundo Real

As melhorias mais dramáticas vieram nas operações de processamento de dados em massa. Nossas métricas de produção demonstram ganhos excepcionais de performance:

**Performance de Processamento de Dados em Massa:**
- **Antes (Java)**: Tempo de processamento máximo de **3 minutos** para grandes datasets
- **Depois (Elixir + Oban)**: Tempo de processamento máximo reduzido para **20 segundos**
- **Manipulação de Carga**: Processamento bem-sucedido de **56.000+ registros** usando MySQL `LOAD DATA INFILE`
- **Pico de Produção**: Tempos de resposta consistentemente abaixo de 20s mesmo durante sincronização de dados empresariais

Essas melhorias são particularmente significativas ao lidar com clientes empresariais com requisitos massivos de sincronização de dados, onde o sistema antigo frequentemente dava timeout ou exigia intervenção manual.

Em termos de tráfego de dados pela API, hoje são quase 1TB que entram e saem por mês. Hoje temos em torno de 300 clientes ativos na empresa.

### Dados de Monitoramento de Produção

Nosso dashboard de monitoramento mostra o sistema lidando com cargas concorrentes altas com performance consistente:

- **Volume de Requisições de Pico**: 175+ requisições/minuto durante horário comercial
- **Distribuição de Tempo de Resposta**:
  - Média: ~2.15s para operações complexas
  - p99: Abaixo de 20s mesmo para processamento de dados em massa
  - p50: Tempos de resposta sub-segundo para operações padrão
- **Alta Disponibilidade**: 99.9%+ uptime com deploys zero-downtime

### Comparação de Benchmarks

| Métrica | Java (Antes) | Elixir (Depois) | Melhoria |
|---------|--------------|-----------------|----------|
| Uso de Memória | ~1500MB base | ~512MB base | 75% redução |
| Conexões Concorrentes | ~100 | ~10.000+ | 100x aumento |
| Tempo de Resposta (média) | 800ms | 50ms | 94% melhoria |
| **Processamento em Massa** | **3+ minutos** | **20 segundos** | **90% melhoria** |
| **Processamento de Datasets Grandes** | **Timeouts frequentes** | **56k+ registros** | **Manipulação confiável** |
| Tempo de Deploy | 10+ minutos | < 2 minutos | 80% mais rápido |

### Contribuindo para Open Source: Otimização MyXQL

Durante nosso processo de otimização, descobrimos e contribuímos para um bug existente no método nativo de LOAD DATA INFILE no driver MyXQL que estava afetando operações em massa:

**Descoberta de Melhoria MyXQL:**
- **Issue**: [elixir-ecto/myxql#204](https://github.com/elixir-ecto/myxql/pull/204)
- **Impacto**: Melhorou o tratamento de conexões MySQL para operações de alto volume com `LOAD DATA INFILE`
- **Benefício**: Performance aprimorada de inserção em massa crucial para nosso sistema de sincronização

```elixir
# Fork customizado MyXQL com otimizações
{
  :myxql,
  git: "https://github.com/franknfjr/myxql.git",
  branch: "master",
  override: true
}
```

O bug foi encontrado ao tentar utilizar o driver MyXQL e tentar realizar uma operação de LOAD DATA INFILE. Após a contribuição, o problema foi resolvido e a performance foi significativamente melhorada. O driver continua com o Pull Request aberto para revisão e integração a lib, estamos utilizando nosso fork para realizar as operações necessárias.

### Melhorias de Confiabilidade

- **Tolerância a Falhas**: Árvores de supervisores garantem resiliência do sistema durante períodos de alta carga
- **Deploy de Código Hot**: Atualizações zero-downtime mesmo durante horários de pico
- **Monitoramento**: Observabilidade integrada com Phoenix LiveDashboard mostrando performance em tempo real
- **Processamento de Jobs**: Processamento confiável em background com Oban lidando com batches de 56k+ registros
- **Recuperação de Erros**: Lógica automática de retry para operações em massa que falharam
- **Gerenciamento de Memória**: Uso consistente de memória mesmo sob carga extrema
- **Load observabilidade**: Utilizamos o default da fly com duas máquinas para manter sempre o sistema estável e com alta disponibilidade. Nossa disponibilidade desde a migração foi de 99,99%.
- **Escalabilidade**: Com suporte a múltiplas instâncias e escalabilidade horizontal, permitindo que o sistema cresça conforme a demanda.

## Impacto nos Negócios

### Experiência do Desenvolvedor

**Ganhos de Produtividade:**
- Desenvolvimento mais rápido de funcionalidades
- Desenvolvimento interativo com `iex -S mix phx.server`
- Documentação abrangente de API e coleções Postman
- Ferramentas e ecossistema modernos
- A maioria dos endpoints hoje conta com testes de integração

### Benefícios Operacionais

**Eficiência de Infraestrutura:**
- Custos reduzidos de servidor através de melhor utilização de recursos
- Pipeline de deploy simplificado
- Capacidades de auto-scaling
- Melhor monitoramento e observabilidade

### Velocidade de Funcionalidades

**Novas Capacidades Habilitadas:**
- Funcionalidades em tempo real com Phoenix LiveView para implementação do dashboard interno
- Suporte WebSocket para atualizações ao vivo
- Padrões modernos de design de API
- Arquitetura pronta para microsserviços
- Arquitetura pronta para lidar com sistemas assincronos

## Considerações Arquiteturais Futuras

### Arquitetura Orientada a Eventos

Base estabelecida para event sourcing:

```elixir
# Jobs Oban como eventos
%{
  event_type: "file_uploaded",
  company: cnpj,
  metadata: %{file_path: path, size: size}
}
```

## Conclusão

A migração do `api-desktop-processador` para o `i9_processador` representa mais que uma atualização tecnológica, é uma transformação em direção a uma arquitetura moderna, escalável e sustentável. Fatores-chave de sucesso incluíram:

1. **Migração Incremental**: Manter estabilidade do sistema enquanto introduz melhorias
2. **Adequação Tecnológica**: O modelo de concorrência do Elixir combinou perfeitamente com nossas necessidades de processamento
3. **Design Orientado a Domínio**: Separação clara de domínios de negócio permitindo escalonamento futuro
4. **Abordagem Cloud-Native**: Infraestrutura projetada para padrões modernos de deployment

O resultado é um sistema que não apenas atende aos requisitos atuais de negócio, mas fornece uma base sólida para crescimento futuro e inovação no ecossistema i9Amazon.

### Recursos

- **Documentação**: Documentação abrangente de API em markdown com 40+ endpoints e coleção Postman
- **Testes**: Scripts curl extensivos para todos os domínios de negócio
- **Deployment**: Fly.io com contêineres Docker
- **Monitoramento**: Phoenix LiveDashboard, Oban Web UI e Grafana com Prometheus

Esta migração serve como um blueprint para modernizar sistemas legados mantendo continuidade dos negócios e habilitando inovação futura.

Com essa base sólida, temos tranquilidade em gastar mais tempo com inovação e desenvolvimento contínuo, garantindo que nossos produtos continuem a evoluir e atender às necessidades crescentes do mercado. Além disso, diminuimos os custos operacionais com chamados em caso de falhas ou picos de demanda, garantindo uma experiência de usuário mais confiável e eficiente.
