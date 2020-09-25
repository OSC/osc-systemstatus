## System Status for Oakley/Ruby/Owens

This app displays the current system status of available system clusters.

### Installation using OnDemand 1.8+

1. Git clone this repository
2. Run setup to verify app install

    ```bash
    scl enable ondemand -- bin/setup
    ```

3. If error, install gem dependencies in app directory

    ```bash
    scl enable ondemand -- bin/bundle install --path vendor/bundle
    ```

### Deployment at OSC

1. Update [System Status rpm spec](https://github.com/OSC/ondemand-packaging/tree/5089f584c03eae16433764c184eafb5e20b8c72c/web/ondemand-systemstatus)
2. Update puppet

