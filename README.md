## System Status for Oakley/Ruby/Owens

This app displays the current system status of available system clusters.

### Installation using OnDemand 1.8+

1. Ensure you have the right ruby module with `module list` for `ruby/2.7.3` or higher.
2. Git clone this repository
3. Run setup to verify app install

    ```bash
    bin/bundle config --local --path vendor/bundle
    bin/setup
    ```

### Deployment at OSC

1. Update [System Status rpm spec](https://github.com/OSC/ondemand-packaging/tree/5089f584c03eae16433764c184eafb5e20b8c72c/web/ondemand-systemstatus)
2. Update puppet

