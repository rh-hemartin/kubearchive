```
integrations/database/postgresql/kubearchive.sql
    [13] 05a143e add json_path to log_url table (#707)
    [12] c2ab9fc Set default timezone in PostgreSQL (#686)
    [11] 549e66f Remove 'resource_kind_idx' as its not used (#669)
    [10, IGNORED] 70b0326 Change postgreSQL version to 16.2 (#661)
    [09] 9558c7b sink writes container name to database with the log url (#608)
    [08] e04d5b4 Fix result ordering (#599)
    [07] 1f8cf47 Improve PostgreSQL DB queries (#584)
    [06] 95a8ead Add pagination support (#484)
    [05] 7b10c22 Add log_url table to the database. (#449)
    [04] 5bf5c32 Add JSON indexes for PostgreSQL. (#518)
    [03] 9bcfaa2 Create indexes in the database (#511)
    [02] ca8bbf2 Install test database in development environment. (#417)

[IGNORED] database/ddl-resource.sql
    [01] 917c56a Fix error of function not found in DDL (#391)
    [00] 80ce7b1 Create SQL script to initialize the database (#346)
```

Execute the following commands:

```
kind create cluster
bash integrations/database/postgresql/install.sh
kubectl port-forward -n postgresql svc/kubearchive-rw 5432:5432 &
export PGPASSWORD=$(kubectl -n postgresql get secret kubearchive-superuser -o jsonpath='{.data.password}' | base64 --decode)
migrate -path sql-patches/ -database postgres://postgres:$PGPASSWORD@localhost:5432/kubearchive up
bash hack/quick-install.sh
bash test/log-generators/cronjobs/install.sh
kubectl logs -n kubearchive deployment/kubearchive-sink
```

* Test with data migrations, specially with the id changes
    * It can be done, I created some changes. Involves copying all the data. Its difficult.

* Compare with latest dump, see the differences
    * LOCALE=C on migration, UTF8 on current dump. This looks like it needs to be set at DB creation
    * Timezone none on migration, UTC on current dump. This requires the database to be modified, you need to name of the database, which could be a problem.
    However this can be done at DB creation, so we can add it as a requirement.

* Instructions for users
    1. Clone the repo
    2. Change to the version you want
    3. Stop kubearchive
    4. Apply the migrations
    5. Upgrade the KubeArchive version

* Get the schema version from code, so we don't start if the schema version is the required
    * If users use the DB dump instead of the migrations, the migration tool will not know which version the thing is...
    unless we dump the table with it

* Patch folders per version?
    * Looks like we can't, when applying a version, the previous "down" file needs to be present.
    Since versions are tracked within the database, I don't think we necessarily need separate folders.
