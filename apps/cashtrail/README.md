# Cashtrail

This is the core of Cashtrail application. This project has all business rules
related to authentication, entities and money transactions, that is the base
of Cashtrail.

## Milestones

This is a working in progress application.

The requirement to be done are:

  - [x] User creating, updating and deleting;
  - [x] Authentication;
  - [x] Entities management;
  - [x] Contacts management;
  - [x] Currencies management
  - [ ] Accounts (bank) management;
  - [ ] Transactions management;
  - [ ] Tagging transactions
  - [ ] Credit card business rules;
  - [ ] Default data creation;


First, you have to clone this repository. 

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
After setting the proper configuration you can run the iex. As this is not a 
web application, the only way to use this is through the console. So, to run
this application in console mode, you can execute the following command.

```console
foo@bar:~$ iex -S mix 
iex -S mix
Erlang/OTP 21 [erts-10.3.5.4] [source] [64-bit] [smp:8:8] [ds:8:8:10] [async-threads:1] [hipe]

Interactive Elixir (1.10.2) - press Ctrl+C to exit (type h() ENTER for help)
iex(1)>
```

To know what to do from here, you can open the generated docs to see what are
the available modules, or running docs in the console. 

```console
iex(1)> iex(1)> h Cashtrail.Accounts

                               Cashtrail.Accounts                               

The Accounts is responsible for deal with user accounts and authentication
rules
```

### Generating docs

You can generate the docs for this application running the following command:

```console
foo@bar:~$ mix docs
Docs successfully generated.
View them at "doc/index.html".
```

The docs are generated in the `doc/` folder. At this point you can open the
`doc/index.html` in your browser to explore the documentation of this project.

## Built With

* [Elixir](https://elixir-lang.org/) - The programming language used
* [Ecto](https://hex.pm/packages/ecto) - A toolkit for data mapping and language integrated query
* [Phoenix PubSub](https://hex.pm/packages/phoenix_pubsub) - PubSub used to broadcast events
in the application

## Versioning

We don't use any versioning system yet, but we're planning to use 
[SemVer](http://semver.org/) for versioning when this project reach the 1.0 version
and be ready for production use.

## Authors

* **Maxsuel Fernandes Maccari** - [maxmaccari](https://github.com/maxmaccari) - [Linkedin](https://www.linkedin.com/in/maxmaccari/)

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details
