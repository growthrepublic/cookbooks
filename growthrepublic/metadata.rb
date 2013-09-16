name             'growthrepublic'
maintainer       'Growth Republic Ltd.'
maintainer_email 'maciek@growthrepublic.com'
license          'All rights reserved'
description      'Installs/Configures growthrepublic applications'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'
supports         'ubuntu', '>= 8.10'

recipe           "growthrepublic::database", "Creates database"
recipe           "growthrepublic::newrelic", "Creates newrelic configuration file"

depends          "deploy"
depends          "database"