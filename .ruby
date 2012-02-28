---
source:
- PROFILE
- Profile
authors:
- name: Thomas Sawyer
  email: transfire@gmail.com
copyrights:
- holder: Thomas Sawyer
  year: '2011'
  license: BSD-2-Clause
requirements:
- name: rubytest
- name: ae
- name: detroit
  groups:
  - build
  development: true
- name: reap
  groups:
  - build
  development: true
- name: qed
  groups:
  - test
  development: true
dependencies: []
alternatives: []
conflicts: []
repositories:
- uri: git://github.com/proutils/citron.git
  scm: git
  name: upstream
resources:
  home: http://rubyworks.github.com/citron
  code: http://github.com/rubyworks/citron
  bugs: http://github.com/rubyworks/citron/issues
  chat: irc://chat.us.freenode.net/rubyworks
  mail: http://groups.google.com/groups/rubyworks-mailinglist
extra: {}
load_path:
- lib
revision: 0
name: citron
title: Citron
version: 0.4.0
summary: Classic Unit Testing
description: Citron is a classical unit testing framework with a developer freindly
  DSL, runs on top of RubyTest and is BRASS compliant.
organization: RubyWorks
date: '2012-02-25'
