Tool to mirror HTTP directory
=============================

Expoected variables:

 * `STORAGE_DIR` directory where to create timestamp dirs with new content
 * `HTTP_DIRS` list of URLs to mirror, space separated
 * `SKIP_AGE_CHECK` normally we only perform a backup if last backup log is
    6+ days older, but setting this to "true" overrides that

Testing
-------

Run it with some basic param to see if all looks good:

    ./tests.sh
