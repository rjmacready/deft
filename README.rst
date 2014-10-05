Deft, a Dylan Environment For Tools
===================================

Deft is a framework for producing tools for building and working
with Dylan projects.  Projects can customize the behavior by
providing a ``deft-package.json`` file.

It is extensible and will support plug-in loading in the future.

It is currently under development.

Building Deft
-------------

You must build Deft with a build of Open Dylan from the master
branch. Deft relies on features which have been added to Open
Dylan after the 2013.2 release.

To get things set up correctly, please use the ``Makefile`` to
build Deft::

    make

Installing Deft
---------------

To install Deft, you can use the ``Makefile``::

    make install

This will copy a variety of things to ``/opt/deft`` and you
can then add ``/opt/deft/bin`` to your path.

If you want to change the install destination, you can override
the ``INSTALL_DIR``::

    make install INSTALL_DIR=/usr/local/deft

Usage
-----

::

   deft
   > open deft
   > show registries
   > build
   > test
   > close deft


Commands
--------

::

    (deft-new)
    new application PROJECT-NAME
    new library PROJECT-NAME
    
    (deft-core)
    open PROJECT
    close PROJECT
    show deft config
    show project [PROJECT]
    show registries
    show deft version
    show dylan version

    (deft-build)
    build [PROJECT] [VERBOSE?]
    clean [PROJECT]
    show reports
    report [REPORT] [PROJECT] [FORMAT]

    (deft-browse)
    inspect DYLAN-OBJECT-NAME

    (deft-graph)
    graph [PROJECT]

    (deft-test)
    show tests
    test

    (deft-dfmc)
    dfmc trace set (text|html)
    dfmc trace show
    dfmc trace clear
