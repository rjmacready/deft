module: dylan-user
author: Bruce Mitchener, Jr.
copyright: See LICENSE file in this distribution.

define library deft-build
  use common-dylan;
  use cli;
  use io;

  use deft-core;

  export deft-build;
end library;

define module deft-build
  use common-dylan, exclude: { format-to-string };
  use cli;
  use format-out;

  use deft-core;
end module;
