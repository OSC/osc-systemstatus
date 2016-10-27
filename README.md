## README

### System Status for Oakley/Ruby

This app displays the current system status of available system clusters.

### Deployment on OOD

1. Git clone this repository
2. Modify `.env.production` as appropriate, or rename one of the versioned copies
3. Install gems and restart app.

```
$ scl enable git19 rh-ruby22 nodejs010 -- bin/bundle install --path=vendor/bundle
$ scl enable git19 rh-ruby22 nodejs010 -- bin/rake assets:clobber RAILS_ENV=production
$ scl enable git19 rh-ruby22 nodejs010 -- bin/rake assets:precompile RAILS_ENV=production
$ scl enable git19 rh-ruby22 nodejs010 -- bin/rake ood_appkit:restart
```

### Options

#### The Ganglia Interface - ganglia.rb

ganglia.rb provides an object-oriented approach to Ganglia interaction.

To use, simply create a new Ganglia object with `Ganglia.new` and use the chainable setter methods to build a request.

The object will build a string that can be used to request the desired report from the ganglia server.

#### Server

Initialize the Ganglia object with `Ganglia.new "servername"` where server name is the Ganglia ID of the monitored server.  

#### Report Range

The ganglia server accepts a limited number of range options. These can be set by calling the following methods.

* `Ganglia.hour` (default) Set the object to report data from one hour ago.
* `Ganglia.two_hours` Set the object to report data from two hours ago.
* `Ganglia.four_hours` Set the object to report data from four hours ago.
* `Ganglia.day` Set the object to report data from one day ago.
* `Ganglia.week` Set the object to report data from one week ago.
* `Ganglia.month` Set the object to report data from one month ago.
* `Ganglia.year` Set the object to report data from one year ago.

#### Report Type

There are currently five types of reports available from the ganglia server. These can be set using the following methods.
Additionally, a custom method is provided for future compatibility.

* `Ganglia.report_cpu` (default) Sets the object to request a CPU report.
* `Ganglia.report_mem` Sets the object to request a memory report.
* `Ganglia.report_load` Sets the object to request a load report.
* `Ganglia.report_network` Sets the object to request a network report.
* `Ganglia.report_packet` Sets the object to request a packet report.
* `Ganglia.report(option)` Sets the object to request a user-defined report type.

#### Report Size

The following methods select the size of the chart that is generated. "small", "medium", and "large" are defined by the server.
Additionally, a custom method is provided to manually select the chart size.

* `Ganglia.small` (default) Sets the chart size to the server-defined small size.
* `Ganglia.medium` Sets the chart size to the server-defined medium size.
* `Ganglia.large` Sets the chart size to the server-defined large size.
* `Ganglia.size(width, height)` Sets the chart size to a user-defined size.

### Outputs

* `Ganglia.to_s` Generates a string representing a https request to graph.php
* `Ganglia.png` Generates a string representing a https request to graph.php with a png extension
* `Ganglia.json` Generates a string representing a https request to graph.php that returns a json containing graph datapoints.

### Examples

    irb(main):006:0> Ganglia.new.oakley.day.report_cpu.large.png
    => "https://cts05.osc.edu/od_monitor/graph.php?&r=day&g=cpu_report&z=large&c=Oakley+nodes&timestamp=1443466436.png"

    irb(main):007:0> g = Ganglia.new
    irb(main):008:0> g.large.report_mem
    irb(main):009:0> g.json
    => "https://cts05.osc.edu/od_monitor/graph.php?&r=hour&g=mem_report&z=large&c=Oakley+nodes&timestamp=1443466650&json=true"

    irb(main):010:0> g.ruby.png
    => "https://cts05.osc.edu/od_monitor/graph.php?&r=hour&g=mem_report&z=large&c=Ruby&timestamp=1443467236.png"
