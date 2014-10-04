module: dylan-user
author: Francesco Ceccon
copyright: See LICENSE file in this distribution.

define library deft-graph
  use common-dylan;
  use command-interface;
  use collections;
  use io;
  use registry-projects;
  use system;

  use deft-core;
  use deft-dfmc;

  use environment-protocols;

  export deft-graph;
end library;

define module deft-graph
  use common-dylan;
  use command-interface,
    rename: { parameter-name => command-parameter-name };
  use file-system;
  use format-out;
  use locators;
  use operating-system,
    exclude: { load-library,
               run-application  };
  use registry-projects;
  use table-extensions;

  use deft-core;
  use deft-dfmc;

  use environment-protocols,
    exclude: { application-filename,
               application-arguments,
               print-environment-object };
end module;
