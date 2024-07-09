%{
  title: "Company vs. Hype: How to Identify What to Use or Not to Use",
  author: "Iago Cavalcante",
  tags: ~w(company),
  description: "In this article, we will discuss how hype can negatively affect companies.",
  locale: "en",
  published: true
}
---

# Success Case: Cost Reduction and Infrastructure Simplification with Fly.io

Recently, I followed the journey of a client who had been using the AWS ecosystem for over two years, with an average monthly expense of around three thousand reais. The initial decision to migrate to AWS was driven by the perception of a robust system capable of handling high request volumes and scalability. However, this resulted in the creation of a complex infrastructure with various services, maintained by a development team of just one person, along with freelancers.

The consultancy responsible for the AWS migration delivered an extremely robust structure, requiring minimal DevOps knowledge. This complexity made managing and implementing new features a significant challenge for such a small team, in addition to incurring high costs.

My role as a consultant was to find the best cost-benefit ratio for the moment, optimizing delivery cycles and reducing infrastructure costs while making management easier. We decided to migrate the AWS infrastructure to a Platform as a Service (PaaS) like Fly.io. This choice allowed us to configure scalable machines, efficient monitoring, and a simple CLI in just a few steps. Additionally, latency was reduced with servers in São Paulo and Rio de Janeiro.

### Migration Process

The migration of systems from AWS to two organizations on Fly.io – one for production and one for staging – took approximately three weeks. The decision to separate environments aimed for better cost control and greater visibility. With staging machines that can be turned off at specific times and activated only for tests, monthly expenses were reduced to less than 20 dollars. These systems included databases, SSO, a processing service for local-cloud synchronization, license control APIs, among others, totaling about 10 machines.
Achieved Results

By the end of the first month, the savings amounted to 2,500 reais. The simplicity of Fly.io allowed us to access logs and dashboards with just a few clicks, with each application monitored via Grafana. With a small team, everyone gained visibility and understanding of what happens in the ecosystem, facilitating management and maintenance.

### Standardization and Scalability

To meet the need for high scalability, I chose to build a monolith using Elixir, unifying several services into domains within the Elixir API. During the process, I found and resolved a bug in the MyXQL library when deploying the API on Fly.io [(link to the bug)](https://community.fly.io/t/fixed-mysql-support-for-phoenix-and-ecto/19983).

Additionally, to ensure a consistent and professional experience, we standardized projects and hired a designer to develop a dashboard for client use.

### Conclusion

The migration to Fly.io not only drastically reduced costs but also simplified infrastructure management, making it more accessible for a small team. The choice of technologies like Elixir to build a scalable monolithic system, combined with project standardization and an intuitive design, allowed for significant improvements in efficiency and quality of the services offered.
