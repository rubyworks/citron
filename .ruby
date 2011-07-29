--- 
authors: 
- name: Thomas Sawyer
  email: transfire@gmail.com
copyrights: 
- holder: Thomas Sawyer
  year: "2011"
  license: BSD-2-Clause
replacements: []

conflicts: []

requirements: 
- name: test
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

repositories: 
- uri: git://github.com/proutils/citron.git
  scm: git
  name: upstream
resources: 
  home: http://rubyworks.github.com/citron
  code: http://github.com/rubyworks/citron
load_path: 
- lib
extra: 
  manifest: MANIFEST
alternatives: []

revision: 0
name: citron
title: Citron
suite: RubyWorks
summary: Classic Unit-style Test Framework
description: Citron is a unit testing framework with a classic test-case/test-unit style.
version: 0.1.0
date: "2011-07-29"
