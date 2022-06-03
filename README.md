## Installation
1. Make sure you have [docker](https://www.docker.com/)  installed
2. Make sure you have [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) installed.
3. Clone the repository:
    ```bash
   git clone https://github.com/LiwaaAudi/database-practice.git
   cd database-practice
   ```

## Build
Create the database in a docker container, run
```bash
make database
```

## Notes
1. Run `make down` command to stop databases. The database server will be stopped, but all database files will be saved in 
the `./postgres-data` directory. The next time you run the `make database` command, all databases will be in the same state as
they were before shutdown.
2. Run `make clean` command only if you want to delete all database files and start the database next time from scratch.