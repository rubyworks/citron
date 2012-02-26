---
source:
- PROFILE
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
extra: {}
load_path:
- lib
revision: 0
name: citron
title: Citron
version: 0.3.0
summary: Classic Unit-style Test Framework
description: Citron is a unit testing framework with a classic test-case/test-unit
  style.
organization: RubyWorks
date: '2012-02-25'
