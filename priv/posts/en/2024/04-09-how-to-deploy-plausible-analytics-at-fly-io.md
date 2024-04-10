%{
  title: "How to deploy Plausible Analytics at Fly.io",
  author: "Iago Cavalcante",
  tags: ~w(fly infrastructure plausible-analytics),
  description: "In this article, I want to help you deploy a self-hosted analystics tool for free!",
  locale: "en",
  published: true
}
---

### What is Plausible Analytics?

Plausible is an alternative to Google Analytics, as described on their website:

> Plausible is an intuitive, lightweight, and open-source web analytics tool. It operates without cookies and is fully compliant with GDPR, CCPA, and PECR regulations. Developed and hosted in the EU, it runs on European-owned cloud infrastructure 🇪🇺.

It's an open-source tool that's easy to use. You can opt for a monthly subscription or deploy it within your own infrastructure. In this blog post, we'll guide you through the process of provisioning this amazing tool on fly.io with some simple steps.

![clipboard.png](https://uploads.inkdrop.app/attachments/user-fdfaa371b7f6d16427ab769a7f8931cd/file:OxTEvoY6-/index-public)

### Let's Get Started

To run Plausible in full, we would typically need an SMTP server if we intend to send emails. However, for the purpose of this blog post, we won't dive into that.

Firstly, you'll need a fly.io account. We'll deploy three machines here: one for [Fast Open-Source OLAP DBMS - ClickHouse](https://clickhouse.com/), another for Postgres, and the third for [Plausible Community Edition (CE)](https://plausible.io/docs/self-hosting).

This guide is based on the repository [GitHub - intever/plausible-hosting](https://github.com/intever/plausible-hosting). I've created a new repository with some updates based on this.

Let's follow these steps to start building our own infrastructure for analytics:

```bash
git clone git@github.com:iagocavalcante/plausible-hosting.git
cd plausible-hosting
```

Inside the cloned repository, we have two main folders: one for ClickHouse and the other for Plausible Analytics.

Let's begin with ClickHouse. Navigate to the ClickHouse folder:


```bash
cd clickhouse
```

You may refer to [Install flyctl](https://fly.io/docs/hands-on/install-flyctl/) to proceed with the fly configuration.

Assuming you have `flyctl` installed, let's create our fly app here with the following command:

```bash
fly launch --no-deploy
```

![Captura de Tela 2024-04-09 às 20.41.33](https://uploads.inkdrop.app/attachments/user-fdfaa371b7f6d16427ab769a7f8931cd/file:kjQ1VDG0I/index-public)
This command will prompt you to copy the configuration file `fly.toml`, confirm the settings, and it will open a browser window where you can tweak settings. We'll change the app's name to `plausible-clickhouse` and confirm settings.

![Captura de Tela 2024-04-09 às 20.44.08](https://uploads.inkdrop.app/attachments/user-fdfaa371b7f6d16427ab769a7f8931cd/file:CyHiJWaOe/index-public)

Now, let's create a volume to persist files since fly machines are ephemeral:

```bash
flyctl volumes create plausible_clickhouse_data --region gru --size 1
```

![Captura de Tela 2024-04-09 às 20.48.22](https://uploads.inkdrop.app/attachments/user-fdfaa371b7f6d16427ab769a7f8931cd/file:nwhog2hno/index-public)

![Captura de Tela 2024-04-09 às 20.50.04](https://uploads.inkdrop.app/attachments/user-fdfaa371b7f6d16427ab769a7f8931cd/file:g6fbYKkmJ/index-public)

Once created, deploy the ClickHouse app:

```bash
fly deploy
```

![Captura de Tela 2024-04-09 às 20.54.48](https://uploads.inkdrop.app/attachments/user-fdfaa371b7f6d16427ab769a7f8931cd/file:BDhZLYQP7/index-public)

Now, let's move to the Plausible folder:

```bash
cd ../plausible
```

Similarly, launch the Plausible app:

```bash
fly launch --no-deploy
```

![Captura de Tela 2024-04-09 às 21.03.04](https://uploads.inkdrop.app/attachments/user-fdfaa371b7f6d16427ab769a7f8931cd/file:AeYyDntn7/index-public)

Follow the prompts, changing the database part in the browser settings as necessary. Confirm the settings and proceed. This command will create an app and Postgres database for us.

From:

![Captura de Tela 2024-04-09 às 21.04.21](https://uploads.inkdrop.app/attachments/user-fdfaa371b7f6d16427ab769a7f8931cd/file:zop7pKhzM/index-public)

To:

![Captura de Tela 2024-04-09 às 21.07.14](https://uploads.inkdrop.app/attachments/user-fdfaa371b7f6d16427ab769a7f8931cd/file:C3N8Xr-9W/index-public)

Save `DATABASE_URL` in a safe place if you want to connect later.

![Captura de Tela 2024-04-09 às 21.09.41](https://uploads.inkdrop.app/attachments/user-fdfaa371b7f6d16427ab769a7f8931cd/file:F9yy_3cxi/index-public)

Update the `.env-example` file with the correct information:

```env
SECRET_KEY_BASE=your_secret_key
ADMIN_USER_NAME=Your_Name
ADMIN_USER_EMAIL=your_email@example.com
ADMIN_USER_PWD=generated_password
BASE_URL=https://yourdomain.com
DISABLE_REGISTRATION=invite_only
```

Also change the `CLICKHOUSE_DATABASE_URL` to the ClickHouse URL app we create after deploying the ClickHouse app. It should look like this:

```toml
[env]
  CLICKHOUSE_DATABASE_URL= "http://plausible-clickhouse-wandering-sun-4794.internal:8123/plausible_events_db"
```

Now, set these secrets inside our app at fly:

```
flyctl secrets import < .env-example
```

![Captura de Tela 2024-04-09 às 21.17.46](https://uploads.inkdrop.app/attachments/user-fdfaa371b7f6d16427ab769a7f8931cd/file:01f5vHBrX/index-public)

Make a final change in our `fly.toml` file:

```toml
[deploy]
  release_command = 'db migrate'
```

Change this to:

```toml
[deploy]
  release_command = 'db createdb'
```

Deploy the Plausible app:

```bash
fly deploy
```

The release command may succeed, but the machine might not be healthy. In this case, change back the release command to `db migrate` in `fly.toml` and deploy again.


```toml
[deploy]
  release_command = 'db migrate'
```

Then, deploy again:

```bash
fly deploy
```

Check the URL for the app, and if everything is okay, you should see the screen to fill in the fields. You can now configure Plausible for your site/domains and have a good self-hosted analytics tool for free or at a low cost.

![Captura de Tela 2024-04-09 às 21.32.53](https://uploads.inkdrop.app/attachments/user-fdfaa371b7f6d16427ab769a7f8931cd/file:lerWuRR3A/index-public)

That's it, folks. See you soon! 🚀


references:

- [Plausible Analytics](https://plausible.io/)
- [Fly.io](https://fly.io/)
- [Self host Plausible with Fly](https://blog.liallen.me/self-host-plausible-with-fly)
