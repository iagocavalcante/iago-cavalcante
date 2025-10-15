%{
  title: "Migration from api-desktop-processador to i9_processador: Architectural Decisions and Lessons Learned",
  description: "A comprehensive analysis of the architectural decisions behind migrating from a Java-based processor to a modern Elixir Phoenix application",
  tags: ~w(elixir phoenix java migration architecture i9amazon),
  published: true,
  locale: "en",
  author: "Iago Cavalcante"
}
---

# Migration from api-desktop-processador to i9_processador: Architectural Decisions and Lessons Learned

In the evolution of the i9Amazon ecosystem, one of the most significant architectural decisions was the migration from `api-desktop-processador` (Java-based) to `i9_processador` (Elixir Phoenix). This migration represented not just a technology change, but a fundamental rethinking of how we handle data processing, synchronization, and multi-tenant operations.

## Background: The Legacy System

The original `api-desktop-processador` was built as a Java application with the following characteristics:

- **Technology Stack**: Java 8, Maven, Hibernate, MySQL
- **Architecture**: Monolithic jar application with limited scalability
- **Dependencies**: Heavy reliance on JPA/Hibernate for data access
- **Deployment**: Traditional jar deployment with manual scaling

```xml
<!-- Legacy Java Dependencies -->
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

While functional, this system faced several limitations:
- Limited concurrent processing capabilities
- Complex deployment and scaling procedures
- Lack of modern web API standards
- Monolithic architecture making feature additions challenging
- Heavy disk read and write operations
- Synchronous processing directly during file writes and database operations using files with `LOAD INFILE`

## The New Architecture: i9_processador

The new `i9_processador` represents a complete architectural redesign:

### Technology Stack Evolution

**From Java to Elixir/Phoenix:**
- **Runtime**: BEAM Virtual Machine with actor model concurrency
- **Framework**: Phoenix 1.8 with LiveView capabilities
- **Language**: Elixir 1.15+ with functional programming paradigms
- **Dependencies**: Modern, lightweight ecosystem

```elixir
# Modern Elixir Dependencies
defp deps do
  [
    {:phoenix, "~> 1.8.0-rc.3"},
    {:phoenix_ecto, "~> 4.5"},
    {:ecto_sql, "~> 3.10"},
    {:oban, "~> 2.19"},           # Background job processing
    {:ex_aws_s3, "~> 2.0"},      # Cloud storage
    {:jose, "~> 1.11"},          # JWT handling
    {:pdf_generator, "~> 0.6.2"} # PDF generation
  ]
end
```

### Architectural Decisions

#### 1. Dual Database Strategy

One of the most critical decisions was implementing a dual database architecture:

```elixir
# PostgreSQL for modern application data and background job processing
config :i9_processador, I9Processador.RepoPostgres,
  adapter: Ecto.Adapters.Postgres

# MySQL for legacy system integration and real business data
config :i9_processador, I9Processador.RepoMysql,
  adapter: Ecto.Adapters.MyXQL
```

**Rationale:**
- **PostgreSQL**: Primary database for new features, background job processing (Oban), and modern data structures
- **MySQL**: Maintained for legacy system integration and real production business data
- **Schema Isolation**: Company-specific data isolation using `_#{cnpj}` pattern

#### 2. Background Job Processing with Oban

Replaced synchronous processing with robust background job system:

```elixir
# Background job configuration
config :i9_processador, Oban,
  repo: I9Processador.RepoPostgres,
  queues: [
    sync: 10,
    fv: 5,
    pdf: 3,
    transfer: 5
  ]
```

**Benefits:**
- Reliable job processing with retry logic
- Queue management for different business domains
- Database-backed job persistence
- Built-in monitoring and observability

#### 3. Multi-Tenant Architecture

Implemented CNPJ-based multi-tenancy:

```elixir
# Dynamic schema access pattern
def get_company_schema(cnpj) do
  "_#{cnpj}"
end

# Company-specific data isolation
def execute_for_company(cnpj, query) do
  schema = get_company_schema(cnpj)
  I9Processador.RepoMysql.query("USE #{schema}; #{query}")
end
```

**Security Benefits:**
- Complete data isolation between companies
- CNPJ + Token authentication on all endpoints
- Module-based feature access control

#### 4. Cloud-Native Infrastructure

Embraced modern cloud deployment patterns:

```elixir
# S3 integration for file storage
config :ex_aws,
  access_key_id: {:system, "AWS_ACCESS_KEY_ID"},
  secret_access_key: {:system, "AWS_SECRET_ACCESS_KEY"},
  region: "us-east-1"
```

**Deployment Evolution:**
- **From**: Manual jar deployment on VMs
- **To**: Docker containers on Fly.io
- **Benefits**: Auto-scaling, zero-downtime deployments, infrastructure as code

#### 5. API-First Design

Transformed from internal processing tool to comprehensive API platform:

```elixir
# RESTful API structure
scope "/api/v1", I9ProcessadorWeb do
  pipe_through :api

  get "/transferencia/:ente/:situacao/:dtIni/:dtFim", TransferenciaController, :consulta
  post "/transferencia", TransferenciaController, :create_or_update
end

# Specialized endpoints for different domains
scope "/sync", I9ProcessadorWeb do
  post "/upload/v3", SyncController, :upload
  get "/arquivos", SyncController, :list_files
end

scope "/fv", I9ProcessadorWeb do
  get "/v1/consultapedido/:type", FVController, :consulta_pedido
  post "/v1/enviapedido/:type", FVController, :envia_pedido
end
```

### Performance and Scalability Improvements

#### Concurrency Model

**Java (Before):**
- Thread-based concurrency with limited scalability
- Heavy memory footprint per connection
- Complex thread management

**Elixir (After):**
- Actor model with lightweight processes
- Millions of concurrent processes possible
- Fault-tolerance with "let it crash" philosophy

#### Memory Efficiency

```elixir
# Elixir process memory usage
Process.info(self(), :memory)
# => {:memory, 2704} # bytes, not MB!

# Compared to Java threads (several MB each)
```

#### Database Performance

- **Connection Pooling**: Optimized for both PostgreSQL and MySQL
- **Query Optimization**: Raw SQL for complex business logic when needed
- **Bulk Operations**: Efficient `LOAD DATA INFILE` operations for data synchronization

### Business Domain Enhancements

#### 1. Synchronization System

**Enhanced Features:**
- Multi-store data synchronization
- File upload with S3 storage
- Background processing with retry logic
- Comprehensive logging and monitoring

```elixir
# Modern sync endpoint with comprehensive features
def upload_v3(conn, params) do
  with {:ok, company} <- validate_company(params),
       {:ok, file} <- handle_file_upload(params),
       {:ok, job} <- schedule_processing_job(file, company) do
    json(conn, %{status: "accepted", job_id: job.id})
  end
end
```

#### 2. Sales Force (FV) Module

**New Capabilities:**
- Mobile and desktop application support
- Real-time order management
- Customer data synchronization
- Token-based authentication per company

#### 3. PDF Generation System

**Professional Documents:**
- Brazilian business document templates
- Multiple format support (invoice, report, receipt)
- Fallback strategy: External API → wkhtmltopdf → HTML
- Memory-efficient temporary file management

#### 4. License Management

**Enterprise Features:**
- JWT-based token validation using JOSE
- Module-based feature access control
- Company license validation and activation
- Billing system integration

## Migration Strategy and Lessons Learned

### 1. Data Migration Approach

**Incremental Migration:**
- Maintained MySQL for legacy data access
- Introduced PostgreSQL for new features
- Gradual migration of business logic

### 2. API Compatibility

**Backward Compatibility:**
- Maintained existing API contracts
- Gradual introduction of v2/v3 endpoints
- Extensive testing with curl scripts (41+ endpoints documented)

### 3. Testing Strategy

```bash
# Comprehensive testing approach
mix test                    # Unit tests
mix ecto.reset && mix test  # Integration tests with database reset
```

### 4. Deployment Evolution

**Infrastructure as Code:**
```dockerfile
# Modern Docker deployment
FROM elixir:1.15-alpine
RUN apk add --no-cache wkhtmltopdf
COPY . /app
WORKDIR /app
RUN mix deps.get && mix compile
```

## Performance Results

### Real-World Production Performance

The most dramatic improvement came in bulk data processing operations. Our production metrics demonstrate exceptional performance gains:

**Bulk Data Processing Performance:**
- **Before (Java)**: Peak processing time of **3 minutes** for large datasets
- **After (Elixir + Oban)**: Peak processing time reduced to **20 seconds**
- **Load Handling**: Successfully processing **56,000+ records** using MySQL `LOAD DATA INFILE`
- **Production Peak**: Response times consistently under 20s even during enterprise data synchronization

These improvements are particularly significant when handling enterprise clients with massive data synchronization requirements, where the old system would frequently timeout or require manual intervention.

In terms of API data traffic, we now handle nearly 1TB that flows in and out per month. We currently have around 300 active clients in the company.

### Production Monitoring Data

Our monitoring dashboard shows the system handling high concurrent loads with consistent performance:

- **Peak Request Volume**: 175+ requests/minute during business hours
- **Response Time Distribution**:
  - Average: ~2.15s for complex operations
  - p99: Under 20s even for bulk data processing
  - p50: Sub-second response times for standard operations
- **High Availability**: 99.9%+ uptime with zero-downtime deployments

### Benchmarks Comparison

| Metric | Java (Before) | Elixir (After) | Improvement |
|--------|---------------|----------------|-------------|
| Memory Usage | ~1500MB base | ~512MB base | 75% reduction |
| Concurrent Connections | ~100 | ~10,000+ | 100x increase |
| Response Time (avg) | 800ms | 50ms | 94% improvement |
| **Bulk Processing** | **3+ minutes** | **20 seconds** | **90% improvement** |
| **Large Dataset Processing** | **Frequent timeouts** | **56k+ records** | **Reliable handling** |
| Deployment Time | 10+ minutes | < 2 minutes | 80% faster |

### Contributing to Open Source: MyXQL Optimization

During our optimization process, we discovered and contributed to an existing bug in the native LOAD DATA INFILE method in the MyXQL driver that was affecting bulk operations:

**MyXQL Enhancement Discovery:**
- **Issue**: [elixir-ecto/myxql#204](https://github.com/elixir-ecto/myxql/pull/204)
- **Impact**: Improved MySQL connection handling for high-volume `LOAD DATA INFILE` operations
- **Benefit**: Enhanced bulk insert performance crucial for our synchronization system

```elixir
# Custom MyXQL fork with optimizations
{
  :myxql,
  git: "https://github.com/franknfjr/myxql.git",
  branch: "master",
  override: true
}
```

The bug was discovered when attempting to use the MyXQL driver to perform LOAD DATA INFILE operations. After the contribution, the issue was resolved and performance was significantly improved. The driver continues with the Pull Request open for review and integration into the library. We are using our fork to perform the necessary operations.

### Reliability Improvements

- **Fault Tolerance**: Supervisor trees ensure system resilience during high-load periods
- **Hot Code Deployment**: Zero-downtime updates even during peak business hours
- **Monitoring**: Built-in observability with Phoenix LiveDashboard showing real-time performance
- **Job Processing**: Reliable background processing with Oban handling 56k+ record batches
- **Error Recovery**: Automatic retry logic for failed bulk operations
- **Memory Management**: Consistent memory usage even under extreme load conditions
- **Load Observability**: We use Fly.io's default configuration with two machines to maintain system stability and high availability. Our uptime since migration has been 99.99%.
- **Scalability**: With support for multiple instances and horizontal scalability, allowing the system to grow according to demand.

## Business Impact

### Developer Experience

**Productivity Gains:**
- Faster feature development with Phoenix generators
- Interactive development with `iex -S mix phx.server`
- Comprehensive API documentation and Postman collections
- Modern tooling and ecosystem
- Most endpoints now have integration tests

### Operational Benefits

**Infrastructure Efficiency:**
- Reduced server costs through better resource utilization
- Simplified deployment pipeline
- Auto-scaling capabilities
- Better monitoring and observability

### Feature Velocity

**New Capabilities Enabled:**
- Real-time features with Phoenix LiveView for internal dashboard implementation
- WebSocket support for live updates
- Modern API design patterns
- Microservice-ready architecture
- Ready for asynchronous systems architecture

## Future Architecture Considerations

### Microservices Evolution

The current monolithic design is ready for future microservice decomposition:

```elixir
# Domain boundaries already established
- SyncService (file processing)
- FVService (sales force)
- LicenseService (licensing)
- PDFService (document generation)
- TransferService (multi-store operations)
```

### Event-Driven Architecture

Foundation laid for event sourcing:

```elixir
# Oban jobs as events
%{
  event_type: "file_uploaded",
  company: cnpj,
  metadata: %{file_path: path, size: size}
}
```

## Conclusion

The migration from `api-desktop-processador` to `i9_processador` represents more than a technology upgrade—it's a transformation toward modern, scalable, and maintainable architecture. Key success factors included:

1. **Incremental Migration**: Maintaining system stability while introducing improvements
2. **Technology Fit**: Elixir's concurrency model perfectly matched our processing needs
3. **Domain-Driven Design**: Clear business domain separation enabling future scaling
4. **Cloud-Native Approach**: Infrastructure designed for modern deployment patterns

The result is a system that not only meets current business requirements but provides a solid foundation for future growth and innovation in the i9Amazon ecosystem.

### Resources

- **Documentation**: Comprehensive API documentation markdown with 40+ endpoints and Postman collection
- **Testing**: Extensive curl scripts for all business domains
- **Deployment**: Fly.io with Docker containers
- **Monitoring**: Phoenix LiveDashboard, Oban Web UI, and Grafana with Prometheus

This migration serves as a blueprint for modernizing legacy systems while maintaining business continuity and enabling future innovation.

With this solid foundation, we have peace of mind to spend more time on innovation and continuous development, ensuring our products continue to evolve and meet the growing needs of the market. Additionally, we've reduced operational costs with support calls due to failures or demand spikes, ensuring a more reliable and efficient user experience.
