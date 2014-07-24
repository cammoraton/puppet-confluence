# puppet-confluence

####Table of Contents

1. [Overview - What is the confuence module?](#overview)
2. [Module Description - What does the module do?](#module-description)
    * [Packaging Confluence - Resources](#packaging-atlassian-confluenc)
3. [Setup - The basics of getting started with apache](#setup)
4. [Usage - The classes and defined types available for configuration](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
6. [Limitations - OS compatibility, etc.](#limitations)
7. [Development - Guide for contributing to the module](#development)
    * [Running tests - A quick guide](#running-tests)
    
##Overview

This project is intended to be a re-usable [Puppet](http://www.puppetlabs.com/puppet/) module that you can include in your own puppet environments.  It's goal is to enable you to set up and manage [Confluence](https://www.atlassian.com/software/confluence) with a minimal amount of effort.

##Module Description

[Confluence](https://www.atlassian.com/software/confluence) is a widely used enterprise wiki / team collaboration java application that is part of the atlassian family of products(which also include JIRA).  It is distributed to us from Atlassian, in their infinite wisdom via either a standalone binary or a tarball of an exploded war.

###Packaging Atlassian Confluence

For debian-based distributions at least, I put together a shell script that creates what I think is a sane standalone confluence. You can grab that [here](https://github.com/cammoraton/confluence-package-deb).

##Setup



##Usage

##Development

###Running tests


run rake with bundle exec.  yada yada.

documentation needs done.
