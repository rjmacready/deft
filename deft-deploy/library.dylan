module: dylan-user
author: Fabrice Leal
copyright: See LICENSE file in this distribution.

define library deft-deploy
  use common-dylan;
  use command-interface;
  use io;

  use deft-core;

  export deft-deploy;
end library;

define module deft-deploy
  use common-dylan;
  use command-interface;

  use format-out;
  
  use deft-core;
end module;


