<h1 align="center">
<img
    width="150"
    src="https://www.graylog.fr/wp-content/uploads/2014/05/graylog2_logo.png"
    alt="graylog logo"
    >
  <br>
    
  Graylog - Logs Management Stack
  <br>
</h1>

<h4 align="center">Various log aggregator in order to enhance debugging and monitoring</h4>

<p align="center">
  <img 
  width="150" src="http://www.kaliop.fr/sites/default/files/inline-images/visuel-k-new.jpg" 
  alt="Kaliop logo">
</p>
<br>

This stack is a poke in order to demonstrate the power of such tool. Please follow the guide to accomplish the walkthrough.

This library is mainly maintained by [Andréas HANSS](https://github.com/ScreamZ), feel free to contact if you are having some questions.

# Requirements

- **Kaliop eZ Docker stack.** https://github.com/kaliop/ezdocker-stack
- **Docker & Docker-compose.** Recent version

# Introduction

**Why GRAYLOG ?**

- Open source log management.
- Scale well in large architecture.
- Embedded user authentication system.
- Embedded alert system on various metrics.
- Support for various format, especially well with [GELF](http://docs.graylog.org/en/2.2/pages/gelf.html).
- Awesome admin & UI.
- Support for LDAP.

**Why not ELK (Elastic Logstash Kibana)**
- Require [Shield/security](https://www.elastic.co/products/x-pack/security) for user authentication handling (Not free).
- Require [Watcher](https://www.elastic.co/products/x-pack/alerting) for user authentication handling (Not free).
- Heavy costly resources consumption and poor performances.
- Logstash has no UI out-of-the-box, require manual configuration.

# Setup

## What is logged

At the moment you're able to receive following logs :

- **Varnish BAN / PURGE -** While you're not banning using the Varnish agent tool, take note that it works with back-office BANs.

- **Apache2 Access/Errors**

- **Nginx Access/Errors**

- **SOLR**


# Troubleshooting

**Check docker network**
Your containers might be on different network, feel free to update the docker-compose.yml file accordingly in order to match.

# Future improvements

**Pre-bootstrap Mongo with config**
Instead of doing the restore, bootstrap the database at compilation with given parameters.

**Use log aggregator system**

- ElasticBEAT with graylog sidecar mode or without. http://docs.graylog.org/en/2.2/pages/collector.html (Deprecated) see http://docs.graylog.org/en/2.2/pages/collector_sidecar.html
- FluentD
- Rsylog / Syslog-NG

**Think about using LDAP system**

**Optimize index and stream internally**

**Find a way to use GELF everywhere**

- In symfony use monolog with specific wrapper that ignore exception in case of not responsing server

**Format Apache/NGINX logs upstream in config**