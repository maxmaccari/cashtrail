# Cashtrail
> An open-source tool for you to track, manage, and plan your money.

![Elixir CI](https://github.com/maxmaccari/cashtrail/workflows/Elixir%20CI/badge.svg?branch=master)
[![Gitpod Ready-to-Code](https://img.shields.io/badge/Gitpod-Ready--to--Code-blue?logo=gitpod)](https://gitpod.io/#https://github.com/maxmaccari/cashtrail) 

## !!!Warning!!!

**This is a working in progress project that is in Phase 1 of development.**

The objectives are:

  - [ ] Phase 1: Implement money tracking and management business rules;
  - [ ] Phase 2: Implement the LiveView frontend;
  - [ ] Phase 3: Implement the GraphQL schema;
  - [ ] Phase 4: Implement the Restful APIs

At this moment the project is in **Phase 1**, so this is not ready for use.

## Motivation

I was looking for another application to track my incomes and expenses, and I wanted 
something that I could track in different currencies, use the same application for
my company and my personal finances, have to control of the data, and I could 
integrate extend or easily with other applications.

This is not intended to be complex accounting software. This is an expense tracker 
that  I thought according to my needs, and that could be the needs of other people. 
And as it is an open-source project focused on being easily integrated and extended, 
So I believe that this can be easily modified to other people's needs.

So I encourage you to fork the project and modify it according to your needs. The 
core is extensively documented, and Elixir is an easy language to deal with business 
rules. So I hope there will not be a problem for you working in the source code.

## Structure

### Entities and Multi-tenancy with Postgres schemas

The Cashtrail works with entities. Entities are distinct units of data that you may want to manage. This can be your company finances, your finances, or some other organization's finances.

So you can host the application, and use this to control in the same instance:
  * Your finances;
  * Your company or startup finances;
  * Some organization that you take care of the treasury finances;
  * Finances of any member of your family.

There are some permission control implemented. So, each user can create how many entities they want and add other users as a member of their entity.

When an entity is created, this generates a schema in the Postgres database. 
This is not very scalable in enterprise terms, but it makes it easier to keep data 
isolated between entities and make it easier to create queries.

### Umbrella project

This project is structured as an umbrella project as well. You can read more about this
on https://elixir-lang.org/getting-started/mix-otp/dependencies-and-umbrella-projects.html

The applications under the umbrella are:
  * Cashtrail: This is the core of the application and where all business logic
  rules related to baking and transactions are created. You can see 
  `apps/cashtrail/README.md` or the [docs](https://maxmaccari.github.io/cashtrail/doc/api-reference.html) for more info about how this project is 
  structured.
  * CastrailWeb: The web application where the LiveView app, GraphQL Schema, and
  the rest endpoints will be mounted.

### Built With

* [Elixir](https://elixir-lang.org/) - The programming language used
* [Phoenix](http://www.phoenixframework.org/) - The web framework used

You can learn the technologies that this project is built in the following links:

  * [Elixir - Oficial Guide](https://elixir-lang.org/getting-started/introduction.html)
  * [Elixir School](https://elixirschool.com/)
  * [Phoenix Documentation](https://hexdocs.pm/phoenix/overview.html)
  * [Ecto Documentation](https://hexdocs.pm/ecto/Ecto.html)

## Getting Started

### Prerequisites

You will need to have Erlang 21.0+ and Elixir 1.10+ installed to continue. You can have
the installation instructions on the [official elixir website](https://elixir-lang.org/install.html).

After install elixir, you can enter the following command to check the version:

```console
foo@bar:~$ elixir --version
Erlang/OTP 21 [erts-10.3.5.4] [source] [64-bit] [smp:8:8] [ds:8:8:10] [async-threads:1] [hipe]

Elixir 1.10.2 (compiled with Erlang/OTP 21)
```

You should have access to a [Postgres 9.6+](https://www.postgresql.org/) database to run the application
and the tests. You can have the installation instructions on the [official Postgres website](https://www.postgresql.org/docs/9.6/tutorial-install.html).

### Building and running the application

First, you have to clone this repository.

```console
foo@bar:~$ git clone git@github.com:maxmaccari/cashtrail.git
Cloning into 'cashtrail'...
foo@bar:~$ cd cashtrail
```

After you can run `mix deps.get` to fetch all dependencies.

```console
foo@bar:~$ mix deps.get
```

And you can compile the dependencies through the command

```console
foo@bar:~$ mix deps.compile
```

### Running the tests

You can change the database configuration on `config/test.exs`. After setting the 
proper configuration you can run the following command.

```console
foo@bar:~$ mix test
```

You can see the [Ecto Repositories documentation](https://hexdocs.pm/ecto/Ecto.html#module-repositories)
if you need instructions to configure the database.

### Running for development

You can change the database configuration for development on `config/dev.exs`. 
After setting the proper configuration you can run the following command.

```console
foo@bar:~$ mix phx.server
[info] Running CashtrailWeb.Endpoint with cowboy 2.7.0 at 0.0.0.0:4000 (http)
[info] Access CashtrailWeb.Endpoint at http://localhost:4000
```

You can access the server at http://localhost:4000

You can see the [Ecto Repositories documentation](https://hexdocs.pm/ecto/Ecto.html#module-repositories)
if you need instructions to configure the database.

## Deployment

TO BE WRITTEN

## Authors

* **Maxsuel Fernandes Maccari** - [maxmaccari](https://github.com/maxmaccari) - [Linkedin](https://www.linkedin.com/in/maxmaccari/)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details
